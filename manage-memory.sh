#!/bin/bash
# filepath: /home/msalsouri/Projects/DB-GPT/manage-memory.sh
# Master script for DB-GPT memory management system
# This script serves as the main entry point for all memory management operations

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
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to display help
show_help() {
    echo -e "${BOLD}DB-GPT Memory Management System${NC}"
    echo ""
    echo -e "Usage: ${CYAN}$(basename "$0") [COMMAND]${NC}"
    echo ""
    echo -e "${BOLD}COMMANDS:${NC}"
    echo -e "  ${GREEN}status${NC}        Check system and agent memory status"
    echo -e "  ${GREEN}auto${NC}          Auto-select the appropriate agent based on available memory"
    echo -e "  ${GREEN}lite${NC}          Run the memory-efficient shell agent"
    echo -e "  ${GREEN}clean${NC}         Clean up memory usage (system, agent, or Ollama)"
    echo -e "  ${GREEN}setup${NC}         Set up and verify memory management components"
    echo -e "  ${GREEN}advanced${NC}      Access advanced memory management tools"
    echo -e "  ${GREEN}help${NC}          Show this help message"
    echo ""
    echo -e "${BOLD}EXAMPLES:${NC}"
    echo -e "  ${CYAN}$(basename "$0") status${NC}    - Check current memory usage"
    echo -e "  ${CYAN}$(basename "$0") auto${NC}      - Auto-select agent based on memory"
    echo -e "  ${CYAN}$(basename "$0") lite${NC}      - Run memory-efficient shell agent"
    echo ""
}

# Function to check if required files exist
check_requirements() {
    local missing=0
    
    # Check for memory-manager.sh
    if [ ! -f "$PROJECT_ROOT/memory-manager.sh" ]; then
        echo -e "${RED}✗ memory-manager.sh not found${NC}"
        missing=1
    fi
    
    # Check for auto-memory-manager.sh
    if [ ! -f "$PROJECT_ROOT/auto-memory-manager.sh" ]; then
        echo -e "${RED}✗ auto-memory-manager.sh not found${NC}"
        missing=1
    fi
    
    # Check for run-smart-shell-agent-lite.sh
    if [ ! -f "$PROJECT_ROOT/run-smart-shell-agent-lite.sh" ]; then
        echo -e "${RED}✗ run-smart-shell-agent-lite.sh not found${NC}"
        missing=1
    fi
    
    # Check if tools directory exists
    if [ ! -d "$PROJECT_ROOT/tools/memory" ]; then
        echo -e "${YELLOW}! tools/memory directory not found${NC}"
        
        # Create directory if it doesn't exist
        echo -e "${YELLOW}Creating tools/memory directory...${NC}"
        mkdir -p "$PROJECT_ROOT/tools/memory/models"
        
        # Copy scripts if they exist
        if [ -f "$PROJECT_ROOT/cleanup-ollama.sh" ]; then
            cp "$PROJECT_ROOT/cleanup-ollama.sh" "$PROJECT_ROOT/tools/memory/"
            chmod +x "$PROJECT_ROOT/tools/memory/cleanup-ollama.sh"
        fi
        
        if [ -f "$PROJECT_ROOT/monitor-memory.sh" ]; then
            cp "$PROJECT_ROOT/monitor-memory.sh" "$PROJECT_ROOT/tools/memory/"
            chmod +x "$PROJECT_ROOT/tools/memory/monitor-memory.sh"
        fi
        
        if [ -f "$PROJECT_ROOT/verify-ollama.sh" ]; then
            cp "$PROJECT_ROOT/verify-ollama.sh" "$PROJECT_ROOT/tools/memory/"
            chmod +x "$PROJECT_ROOT/tools/memory/verify-ollama.sh"
        fi
        
        if [ -f "$PROJECT_ROOT/optimize-ollama-params.sh" ]; then
            cp "$PROJECT_ROOT/optimize-ollama-params.sh" "$PROJECT_ROOT/tools/memory/"
            chmod +x "$PROJECT_ROOT/tools/memory/optimize-ollama-params.sh"
        fi
        
        if [ -f "$PROJECT_ROOT/test-minimal-agent.sh" ]; then
            cp "$PROJECT_ROOT/test-minimal-agent.sh" "$PROJECT_ROOT/tools/memory/"
            chmod +x "$PROJECT_ROOT/tools/memory/test-minimal-agent.sh"
        fi
        
        # Copy model files if they exist
        if [ -f "$PROJECT_ROOT/smart-shell-agent-lite.Modelfile" ]; then
            cp "$PROJECT_ROOT/smart-shell-agent-lite.Modelfile" "$PROJECT_ROOT/tools/memory/models/"
        fi
        
        if [ -f "$PROJECT_ROOT/minimal-shell-agent.Modelfile" ]; then
            cp "$PROJECT_ROOT/minimal-shell-agent.Modelfile" "$PROJECT_ROOT/tools/memory/models/"
        fi
        
        if [ -f "$PROJECT_ROOT/lite-test.Modelfile" ]; then
            cp "$PROJECT_ROOT/lite-test.Modelfile" "$PROJECT_ROOT/tools/memory/models/"
        fi
    fi
    
    if [ $missing -eq 1 ]; then
        echo -e "${RED}Error: Required files are missing.${NC}"
        echo -e "${YELLOW}Please run 'git pull' to update your repository.${NC}"
        return 1
    fi
    
    return 0
}

# Execute based on command
case "$1" in
    status)
        check_requirements || exit 1
        "$PROJECT_ROOT/memory-manager.sh" status
        ;;
    
    auto)
        check_requirements || exit 1
        "$PROJECT_ROOT/auto-memory-manager.sh"
        ;;
    
    lite)
        check_requirements || exit 1
        "$PROJECT_ROOT/run-smart-shell-agent-lite.sh"
        ;;
    
    clean)
        check_requirements || exit 1
        
        if [ -z "$2" ]; then
            "$PROJECT_ROOT/memory-manager.sh" clean
        else
            "$PROJECT_ROOT/memory-manager.sh" clean "$2"
        fi
        ;;
    
    setup)
        check_requirements || exit 1
        
        if [ -f "$PROJECT_ROOT/memory-setup.sh" ]; then
            "$PROJECT_ROOT/memory-setup.sh"
        else
            echo -e "${RED}Error: memory-setup.sh not found.${NC}"
            echo -e "${YELLOW}Please run 'git pull' to update your repository.${NC}"
            exit 1
        fi
        ;;
    
    advanced)
        check_requirements || exit 1
        "$PROJECT_ROOT/memory-manager.sh"
        ;;
    
    help)
        show_help
        ;;
    
    *)
        if [ -z "$1" ]; then
            # No command provided, show status and menu
            check_requirements || exit 1
            
            clear
            echo -e "${BOLD}${BLUE}DB-GPT Memory Management System${NC}\n"
            
            # Show quick memory status
            free_mem=$(free | grep Mem | awk '{print $4}')
            total_mem=$(free | grep Mem | awk '{print $2}')
            free_percent=$((free_mem * 100 / total_mem))
            
            echo -e "${BOLD}Memory Status:${NC} $(($free_mem / 1024 / 1024)) GB free of $(($total_mem / 1024 / 1024)) GB (${free_percent}% free)"
            
            # Recommendation based on available memory
            if [ $free_percent -lt 10 ]; then
                echo -e "${RED}CRITICAL: Low memory available${NC}"
                echo -e "${YELLOW}Recommended action: Clean memory and use minimal agent${NC}"
            elif [ $free_percent -lt 25 ]; then
                echo -e "${YELLOW}LOW: Limited memory available${NC}"
                echo -e "${CYAN}Recommended action: Use memory-efficient agent${NC}"
            else
                echo -e "${GREEN}GOOD: Sufficient memory available${NC}"
                echo -e "${CYAN}You can use any agent version${NC}"
            fi
            
            echo -e "\n${BOLD}Available Actions:${NC}"
            echo -e "1. ${CYAN}Auto-select agent${NC} (based on memory)"
            echo -e "2. ${CYAN}Run memory-efficient agent${NC}"
            echo -e "3. ${CYAN}Clean memory${NC}"
            echo -e "4. ${CYAN}Advanced memory management${NC}"
            echo -e "5. ${CYAN}Exit${NC}"
            
            echo -ne "\n${BOLD}Enter choice (1-5):${NC} "
            read -r choice
            
            case "$choice" in
                1) "$PROJECT_ROOT/auto-memory-manager.sh" ;;
                2) "$PROJECT_ROOT/run-smart-shell-agent-lite.sh" ;;
                3) "$PROJECT_ROOT/memory-manager.sh" clean ;;
                4) "$PROJECT_ROOT/memory-manager.sh" ;;
                5) echo -e "${YELLOW}Exiting...${NC}"; exit 0 ;;
                *) echo -e "${RED}Invalid choice.${NC}"; exit 1 ;;
            esac
        else
            echo -e "${RED}Unknown command: $1${NC}"
            show_help
            exit 1
        fi
        ;;
esac

exit 0
