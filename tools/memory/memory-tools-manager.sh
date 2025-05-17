#!/bin/bash
# filepath: /home/msalsouri/Projects/DB-GPT/tools/memory/memory-tools-manager.sh
# Memory Tools Manager - A unified interface for all memory-related tools

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Function to display menu
show_menu() {
    clear
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
    echo -e "  ${YELLOW}9${NC}. ${GREEN}Test Minimal Agent${NC} - Run lightweight agent for low memory"
    echo -e "  ${YELLOW}10${NC}. ${GREEN}Ollama Memory Monitor${NC} - Monitor Ollama memory usage"
    echo -e "  ${YELLOW}11${NC}. ${GREEN}Enhanced Cleanup${NC} - Find and organize duplicate files"
    echo -e "  ${YELLOW}0${NC}. ${RED}Exit${NC}"
    echo ""
    echo -e "${BOLD}Memory Tools Organization:${NC}"
    echo -e "  ${CYAN}Main scripts${NC}: Located in project root"
    echo -e "  ${CYAN}Utility scripts${NC}: Located in tools/memory directory"
    echo -e "  ${CYAN}Model definitions${NC}: Located in tools/memory/models"
    echo ""
}

# Function to run the selected tool
run_tool() {
    local choice=$1
    
    case $choice in
        1)
            if [ -f "$PROJECT_ROOT/auto-memory-manager.sh" ]; then
                "$PROJECT_ROOT/auto-memory-manager.sh"
            else
                echo -e "${RED}Error: Auto Memory Manager not found.${NC}"
            fi
            ;;
        2)
            if [ -f "$PROJECT_ROOT/memory-manager.sh" ]; then
                "$PROJECT_ROOT/memory-manager.sh"
            else
                echo -e "${RED}Error: Memory Manager not found.${NC}"
            fi
            ;;
        3)
            if [ -f "$SCRIPT_DIR/monitor-memory.sh" ]; then
                "$SCRIPT_DIR/monitor-memory.sh"
            elif [ -f "$PROJECT_ROOT/monitor-memory.sh" ]; then
                "$PROJECT_ROOT/monitor-memory.sh"
            else
                echo -e "${RED}Error: Monitor Memory script not found.${NC}"
            fi
            ;;
        4)
            if [ -f "$SCRIPT_DIR/optimize-ollama-params.sh" ]; then
                "$SCRIPT_DIR/optimize-ollama-params.sh"
            elif [ -f "$PROJECT_ROOT/optimize-ollama-params.sh" ]; then
                "$PROJECT_ROOT/optimize-ollama-params.sh"
            else
                echo -e "${RED}Error: Optimize Ollama Parameters script not found.${NC}"
            fi
            ;;
        5)
            if [ -f "$SCRIPT_DIR/verify-ollama.sh" ]; then
                "$SCRIPT_DIR/verify-ollama.sh"
            elif [ -f "$PROJECT_ROOT/verify-ollama.sh" ]; then
                "$PROJECT_ROOT/verify-ollama.sh"
            else
                echo -e "${RED}Error: Verify Ollama script not found.${NC}"
            fi
            ;;
        6)
            if [ -f "$SCRIPT_DIR/cleanup-ollama.sh" ]; then
                "$SCRIPT_DIR/cleanup-ollama.sh"
            else
                echo -e "${RED}Error: Cleanup Ollama script not found.${NC}"
            fi
            ;;
        7)
            if [ -f "$SCRIPT_DIR/cleanup_temp_files.sh" ]; then
                "$SCRIPT_DIR/cleanup_temp_files.sh"
            elif [ -f "$SCRIPT_DIR/cleanup-temp-files.sh" ]; then
                "$SCRIPT_DIR/cleanup-temp-files.sh"
            else
                echo -e "${RED}Error: Cleanup Temporary Files script not found.${NC}"
            fi
            ;;
        8)
            if [ -f "$PROJECT_ROOT/test-memory-system.sh" ]; then
                "$PROJECT_ROOT/test-memory-system.sh"
            else
                echo -e "${RED}Error: Test Memory System script not found.${NC}"
            fi
            ;;
        9)
            if [ -f "$SCRIPT_DIR/test-minimal-agent.sh" ]; then
                "$SCRIPT_DIR/test-minimal-agent.sh"
            elif [ -f "$PROJECT_ROOT/test-minimal-agent.sh" ]; then
                "$PROJECT_ROOT/test-minimal-agent.sh"
            else
                echo -e "${RED}Error: Test Minimal Agent script not found.${NC}"
            fi
            ;;
        10)
            if [ -f "$SCRIPT_DIR/ollama-memory-monitor.sh" ]; then
                "$SCRIPT_DIR/ollama-memory-monitor.sh"
            else
                echo -e "${RED}Error: Ollama Memory Monitor script not found.${NC}"
            fi
            ;;
        11)
            if [ -f "$SCRIPT_DIR/enhanced-cleanup.sh" ]; then
                "$SCRIPT_DIR/enhanced-cleanup.sh"
            else
                echo -e "${RED}Error: Enhanced Cleanup script not found.${NC}"
            fi
            ;;
        0)
            echo -e "${GREEN}Exiting Memory Tools Manager.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}"
            ;;
    esac
    
    # Pause before returning to menu
    echo ""
    read -p "Press Enter to continue..."
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice [0-11]: " choice
    echo ""
    run_tool $choice
done
