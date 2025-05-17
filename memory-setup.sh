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
    
    # Create cleanup-temp-files script if it doesn't exist
    if [ ! -f "$PROJECT_ROOT/tools/memory/cleanup-temp-files.sh" ]; then
        echo -e "  ${YELLOW}! Creating cleanup-temp-files.sh script${NC}"
        cat > "$PROJECT_ROOT/tools/memory/cleanup-temp-files.sh" << 'EOF'
#!/bin/bash
# Quick cleanup script for temporary and backup files

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKUP_DIR="$PROJECT_ROOT/backup_cleanup"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo -e "${CYAN}DB-GPT Temporary File Cleanup${NC}"
echo -e "${YELLOW}This will move temporary and backup files to $BACKUP_DIR${NC}\n"

# Find and move .bak files
echo -e "Finding backup (.bak) files..."
find "$PROJECT_ROOT" -maxdepth 1 -name "*.bak" -type f -exec mv {} "$BACKUP_DIR/" \; -exec echo "  ${GREEN}Moved {} to backup_cleanup/${NC}" \;

# Find and move temp-* files
echo -e "\nFinding temporary (temp-*) files..."
find "$PROJECT_ROOT" -maxdepth 1 -name "temp-*" -type f -exec mv {} "$BACKUP_DIR/" \; -exec echo "  ${GREEN}Moved {} to backup_cleanup/${NC}" \;

# Find and move .tmp files
echo -e "\nFinding .tmp files..."
find "$PROJECT_ROOT" -maxdepth 1 -name "*.tmp" -type f -exec mv {} "$BACKUP_DIR/" \; -exec echo "  ${GREEN}Moved {} to backup_cleanup/${NC}" \;

echo -e "\n${GREEN}Cleanup complete!${NC}"
echo -e "All backup and temporary files have been moved to: $BACKUP_DIR"
EOF
        chmod +x "$PROJECT_ROOT/tools/memory/cleanup-temp-files.sh"
    fi
    
    # Create the tools manager if it doesn't exist
    if [ ! -f "$PROJECT_ROOT/tools/memory/memory-tools-manager.sh" ]; then
        echo -e "  ${YELLOW}! Creating memory-tools-manager.sh script${NC}"
        cat > "$PROJECT_ROOT/tools/memory/memory-tools-manager.sh" << 'EOF'
#!/bin/bash
# Memory Tools Manager - A unified interface for all memory-related tools

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo -e "${BOLD}${BLUE}DB-GPT Memory Tools Manager${NC}\n"
echo -e "${BOLD}Select a tool to run:${NC}"
echo -e "  ${YELLOW}1${NC}. ${GREEN}Auto Memory Manager${NC} - Auto-select agent based on memory"
echo -e "  ${YELLOW}2${NC}. ${GREEN}Memory Manager${NC} - Unified memory management dashboard"
echo -e "  ${YELLOW}3${NC}. ${GREEN}Monitor Memory${NC} - Real-time memory monitoring"
echo -e "  ${YELLOW}4${NC}. ${GREEN}Optimize Ollama Parameters${NC} - Tune for your system"
echo -e "  ${YELLOW}5${NC}. ${GREEN}Verify Ollama${NC} - Check Ollama installation and status"
echo -e "  ${YELLOW}6${NC}. ${GREEN}Cleanup Ollama${NC} - Remove unused models and cache"
echo -e "  ${YELLOW}7${NC}. ${GREEN}Cleanup Temporary Files${NC} - Remove temp and backup files"
echo -e "  ${YELLOW}8${NC}. ${GREEN}Test Memory System${NC} - Run all memory tests"
echo -e "  ${YELLOW}0${NC}. ${RED}Exit${NC}"

read -p "Enter your choice [0-8]: " choice
echo ""

case $choice in
    1) $PROJECT_ROOT/auto-memory-manager.sh ;;
    2) $PROJECT_ROOT/memory-manager.sh ;;
    3) $SCRIPT_DIR/monitor-memory.sh ;;
    4) $SCRIPT_DIR/optimize-ollama-params.sh ;;
    5) $SCRIPT_DIR/verify-ollama.sh ;;
    6) $SCRIPT_DIR/cleanup-ollama.sh ;;
    7) $SCRIPT_DIR/cleanup-temp-files.sh ;;
    8) $PROJECT_ROOT/test-memory-system.sh ;;
    0) echo -e "${GREEN}Exiting Memory Tools Manager.${NC}"; exit 0 ;;
    *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
esac
EOF
        chmod +x "$PROJECT_ROOT/tools/memory/memory-tools-manager.sh"
    fi
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
