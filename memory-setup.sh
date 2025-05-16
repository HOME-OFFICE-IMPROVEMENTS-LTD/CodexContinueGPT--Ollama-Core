#!/bin/bash
# filepath: /home/msalsouri/Projects/DB-GPT/memory-setup.sh
# Quick Setup and Demo of Memory Management System

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BOLD}${CYAN}DB-GPT Memory Management Setup${NC}"
echo -e "${YELLOW}This script will help you set up and test the memory management system${NC}\n"

# Check dependencies
echo -e "${BOLD}Step 1:${NC} Checking for required dependencies..."

# Check Ollama
if ! command -v ollama &> /dev/null; then
    echo -e "  ${RED}✗ Ollama not found${NC}"
    echo -e "    Please install Ollama from https://ollama.ai/download"
    exit 1
else
    echo -e "  ${GREEN}✓ Ollama is installed${NC}"
fi

# Check for required paths
echo -e "\n${BOLD}Step 2:${NC} Checking for memory management files..."

# Check for core memory management scripts
if [ -f "$PROJECT_ROOT/memory-manager.sh" ]; then
    echo -e "  ${GREEN}✓ memory-manager.sh found${NC}"
else
    echo -e "  ${RED}✗ Core memory manager not found${NC}"
    echo -e "    Please run git pull to update your repository"
    exit 1
fi

# Check tools directory
if [ -d "$PROJECT_ROOT/tools/memory" ]; then
    echo -e "  ${GREEN}✓ Memory tools directory found${NC}"
else
    echo -e "  ${YELLOW}! Memory tools directory not found, creating it${NC}"
    mkdir -p "$PROJECT_ROOT/tools/memory"
    
    # Copy relevant scripts if they exist in the main directory
    for script in cleanup-ollama.sh monitor-memory.sh optimize-ollama-params.sh verify-ollama.sh test-minimal-agent.sh; do
        if [ -f "$PROJECT_ROOT/$script" ]; then
            cp "$PROJECT_ROOT/$script" "$PROJECT_ROOT/tools/memory/"
            chmod +x "$PROJECT_ROOT/tools/memory/$script"
            echo -e "    ${GREEN}✓ Copied $script to tools/memory/${NC}"
        fi
    done
fi

# Run the memory system test
echo -e "\n${BOLD}Step 3:${NC} Testing memory management system..."
"$PROJECT_ROOT/test-memory-system.sh"

# Show quick demo
echo -e "\n${BOLD}Step 4:${NC} Would you like to see a quick demo? (y/n)"
read -r see_demo

if [[ "$see_demo" =~ ^[Yy]$ ]]; then
    # Check current memory
    echo -e "\n${BOLD}Current Memory Status:${NC}"
    free -h
    
    echo -e "\n${BOLD}Auto-selecting appropriate agent:${NC}"
    "$PROJECT_ROOT/auto-memory-manager.sh"
fi

echo -e "\n${BOLD}${GREEN}Setup Complete!${NC}"
echo -e "${YELLOW}For a quick reference guide, see: MEMORY_QUICK_GUIDE.md${NC}"
echo -e "${YELLOW}For detailed documentation, see: memory-efficient-README.md and memory-management-report.md${NC}"

exit 0
