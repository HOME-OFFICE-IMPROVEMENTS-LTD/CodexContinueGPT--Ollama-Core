#!/bin/bash
# filepath: /home/msalsouri/Projects/DB-GPT/cleanup-ollama.sh
# Script to clean up Ollama processes and free memory

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to display help
show_help() {
    echo -e "${BOLD}Ollama Cleanup Utility${NC}"
    echo ""
    echo -e "Usage: ${GREEN}$(basename "$0") [OPTIONS]${NC}"
    echo ""
    echo "OPTIONS:"
    echo -e "  ${GREEN}-h, --help${NC}             Show this help message"
    echo -e "  ${GREEN}-f, --force${NC}            Force kill all Ollama processes"
    echo -e "  ${GREEN}-r, --restart${NC}          Restart Ollama service after cleanup"
    echo -e "  ${GREEN}-d, --delete MODEL${NC}     Delete a specific model"
    echo ""
    echo -e "Examples:"
    echo -e "  ${GREEN}$(basename "$0")${NC}                      # Interactive cleanup"
    echo -e "  ${GREEN}$(basename "$0") --force${NC}              # Force kill all Ollama processes"
    echo -e "  ${GREEN}$(basename "$0") --delete my-model${NC}    # Delete a specific model"
    echo ""
}

# Function to stop Ollama processes
stop_ollama() {
    echo -e "${YELLOW}Stopping Ollama processes...${NC}"
    
    # Check for running Ollama processes
    if pgrep -f "ollama" > /dev/null; then
        if [ "$1" == "force" ]; then
            echo -e "${RED}Force killing all Ollama processes...${NC}"
            pkill -9 -f "ollama"
        else
            echo -e "${YELLOW}Gracefully stopping Ollama...${NC}"
            pkill -f "ollama"
            sleep 2
            
            # Check if processes are still running after graceful stop
            if pgrep -f "ollama" > /dev/null; then
                echo -e "${YELLOW}Some Ollama processes still running. Force killing...${NC}"
                pkill -9 -f "ollama"
            fi
        fi
        
        sleep 1
        echo -e "${GREEN}All Ollama processes stopped.${NC}"
    else
        echo -e "${GREEN}No Ollama processes running.${NC}"
    fi
}

# Function to restart Ollama service
restart_ollama() {
    echo -e "${YELLOW}Restarting Ollama service...${NC}"
    
    # First make sure all processes are stopped
    stop_ollama "force"
    
    # Start Ollama service
    echo -e "${YELLOW}Starting Ollama service...${NC}"
    ollama serve > /dev/null 2>&1 &
    
    # Wait for service to start
    sleep 3
    
    # Check if service started successfully
    if pgrep -f "ollama serve" > /dev/null; then
        echo -e "${GREEN}Ollama service restarted successfully.${NC}"
    else
        echo -e "${RED}Failed to restart Ollama service.${NC}"
    fi
}

# Function to delete an Ollama model
delete_model() {
    model_name="$1"
    echo -e "${YELLOW}Checking if model ${model_name} exists...${NC}"
    
    if ollama list 2>/dev/null | grep -q "$model_name"; then
        echo -e "${YELLOW}Deleting model ${model_name}...${NC}"
        ollama rm "$model_name"
        echo -e "${GREEN}Model ${model_name} deleted.${NC}"
    else
        echo -e "${RED}Model ${model_name} does not exist.${NC}"
        echo -e "${YELLOW}Available models:${NC}"
        ollama list
    fi
}

# Function to show interactive menu
show_menu() {
    echo -e "${BOLD}Ollama Cleanup Utility${NC}"
    echo ""
    echo -e "1. ${GREEN}Show Ollama processes${NC}"
    echo -e "2. ${GREEN}Show Ollama models${NC}"
    echo -e "3. ${GREEN}Stop Ollama processes (graceful)${NC}"
    echo -e "4. ${GREEN}Force kill Ollama processes${NC}"
    echo -e "5. ${GREEN}Restart Ollama service${NC}"
    echo -e "6. ${GREEN}Delete a model${NC}"
    echo -e "7. ${GREEN}Clear system cache${NC}"
    echo -e "8. ${GREEN}Exit${NC}"
    echo ""
    echo -ne "${YELLOW}Enter your choice: ${NC}"
    read -r choice
    
    case "$choice" in
        1)  # Show Ollama processes
            echo ""
            ps aux | grep ollama | grep -v grep
            echo ""
            ;;
        2)  # Show Ollama models
            echo ""
            ollama list
            echo ""
            ;;
        3)  # Stop Ollama processes
            stop_ollama
            ;;
        4)  # Force kill Ollama processes
            stop_ollama "force"
            ;;
        5)  # Restart Ollama service
            restart_ollama
            ;;
        6)  # Delete a model
            echo -ne "${YELLOW}Enter model name to delete: ${NC}"
            read -r model_to_delete
            delete_model "$model_to_delete"
            ;;
        7)  # Clear system cache
            echo -e "${YELLOW}Clearing system cache...${NC}"
            sync
            echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
            echo -e "${GREEN}System cache cleared.${NC}"
            ;;
        8)  # Exit
            echo -e "${GREEN}Exiting...${NC}"
            exit 0
            ;;
        *)  # Invalid choice
            echo -e "${RED}Invalid choice.${NC}"
            ;;
    esac
    
    echo ""
    echo -ne "${YELLOW}Press Enter to continue...${NC}"
    read -r
    clear
    show_menu
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -r|--restart)
            RESTART=true
            shift
            ;;
        -d|--delete)
            MODEL_TO_DELETE="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Execute the requested action
if [ "$FORCE" = true ]; then
    stop_ollama "force"
    if [ "$RESTART" = true ]; then
        restart_ollama
    fi
elif [ "$RESTART" = true ]; then
    restart_ollama
elif [ -n "$MODEL_TO_DELETE" ]; then
    delete_model "$MODEL_TO_DELETE"
else
    # No specific action requested, show interactive menu
    clear
    show_menu
fi

exit 0
