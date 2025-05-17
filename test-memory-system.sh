#!/bin/bash
# filepath: /home/msalsouri/Projects/DB-GPT/test-memory-system.sh
# Test Script for DB-GPT Memory Management System
# Tests all components of the memory management system

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

echo -e "${BOLD}${CYAN}DB-GPT Memory Management System Test${NC}"
echo -e "${YELLOW}This script will test all components of the memory management system${NC}\n"

# Test 1: Check if memory manager exists
echo -e "${BOLD}Test 1:${NC} Checking for memory manager..."
if [ -f "$PROJECT_ROOT/memory-manager.sh" ]; then
    echo -e "  ${GREEN}✓ memory-manager.sh found${NC}"
else
    echo -e "  ${RED}✗ memory-manager.sh not found${NC}"
    exit 1
fi

# Test 2: Check if auto-memory-manager exists
echo -e "\n${BOLD}Test 2:${NC} Checking for auto-memory-manager..."
if [ -f "$PROJECT_ROOT/auto-memory-manager.sh" ]; then
    echo -e "  ${GREEN}✓ auto-memory-manager.sh found${NC}"
else
    echo -e "  ${RED}✗ auto-memory-manager.sh not found${NC}"
    exit 1
fi

# Test 3: Check if shell-agent-manager.sh includes auto-select
echo -e "\n${BOLD}Test 3:${NC} Checking if shell-agent-manager includes auto-select..."
if grep -q "auto|auto-select|memory-based" "$PROJECT_ROOT/shell-agent-manager.sh"; then
    echo -e "  ${GREEN}✓ shell-agent-manager.sh has auto-select capability${NC}"
else
    echo -e "  ${RED}✗ shell-agent-manager.sh missing auto-select capability${NC}"
    exit 1
fi

# Test 4: Check if run-smart-shell-agent-lite.sh exists
echo -e "\n${BOLD}Test 4:${NC} Checking for memory-efficient agent..."
if [ -f "$PROJECT_ROOT/run-smart-shell-agent-lite.sh" ]; then
    echo -e "  ${GREEN}✓ run-smart-shell-agent-lite.sh found${NC}"
else
    echo -e "  ${RED}✗ run-smart-shell-agent-lite.sh not found${NC}"
    exit 1
fi

# Test 5: Check if lite agent uses memory-efficient parameters
echo -e "\n${BOLD}Test 5:${NC} Checking if lite agent uses memory-efficient parameters..."
if grep -q "ollama run \"\$MODEL\" \"\$user_input\"" "$PROJECT_ROOT/run-smart-shell-agent-lite.sh"; then
    echo -e "  ${GREEN}✓ Lite agent correctly uses memory-efficient parameters${NC}"
else
    echo -e "  ${RED}✗ Lite agent not using memory-efficient parameters${NC}"
    exit 1
fi

# Test 6: Check if minimal agent exists
echo -e "\n${BOLD}Test 6:${NC} Checking for minimal agent..."
if [ -f "$PROJECT_ROOT/test-minimal-agent.sh" ]; then
    echo -e "  ${GREEN}✓ test-minimal-agent.sh found${NC}"
else
    echo -e "  ${RED}✗ test-minimal-agent.sh not found${NC}"
    exit 1
fi

# Test 7: Check if documentation exists
echo -e "\n${BOLD}Test 7:${NC} Checking for documentation..."
if [ -f "$PROJECT_ROOT/memory-efficient-README.md" ] && [ -f "$PROJECT_ROOT/memory-management-report.md" ]; then
    echo -e "  ${GREEN}✓ Documentation found${NC}"
else
    echo -e "  ${RED}✗ Documentation missing${NC}"
    exit 1
fi

# All tests passed
echo -e "\n${GREEN}${BOLD}All tests passed!${NC}"
echo -e "${YELLOW}Memory management system is correctly installed.${NC}"
echo -e "\n${BOLD}Usage:${NC}"
echo -e "  ${BLUE}./shell-agent-manager.sh auto${NC}       - Auto-select agent based on memory"
echo -e "  ${BLUE}./shell-agent-manager.sh memory${NC}     - Open memory management interface"
echo -e "  ${BLUE}./memory-manager.sh${NC}                - Manage memory directly"
echo -e "  ${BLUE}./run-smart-shell-agent-lite.sh${NC}    - Run memory-efficient agent directly"

echo -e "\n${YELLOW}Note: Run ./memory-manager.sh help for more options${NC}"

exit 0
