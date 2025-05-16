#!/bin/bash
# DB-GPT Shell Agent Runner
# This script provides an enhanced interface to the custom Ollama shell agent

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m' # No Color

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODEL_NAME="codex-shell-agent"
HISTORY_FILE="$PROJECT_ROOT/.shell_agent_history"
TASK_FILE="$PROJECT_ROOT/.shell_agent_tasks"
MODE="chat"
TEMPLATE=""

# Create history file if it doesn't exist
touch "$HISTORY_FILE"

# Create task file if it doesn't exist
if [ ! -f "$TASK_FILE" ]; then
    echo "Current tasks:" > "$TASK_FILE"
    echo "- Set up custom shell agent" >> "$TASK_FILE"
    echo "" >> "$TASK_FILE"
    echo "Completed tasks:" >> "$TASK_FILE"
    echo "" >> "$TASK_FILE"
    echo "Next steps:" >> "$TASK_FILE"
    echo "- Enhance shell agent capabilities" >> "$TASK_FILE"
fi

# Function to display help information
show_help() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}      DB-GPT Shell Agent Runner     ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "  $0 [options]"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  --chat          Interactive chat mode (default)"
    echo -e "  --audit <file>  Audit code in specified file"
    echo -e "  --tasks         View and manage task tracking"
    echo -e "  --history       Show recent conversation history"
    echo -e "  --clear         Clear conversation history"
    echo -e "  --help          Show this help message"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  $0                   Start interactive chat"
    echo -e "  $0 --audit script.sh Audit the script.sh file"
    echo -e "  $0 --tasks           View and update task list"
    echo -e "  $0 --history         View recent conversations"
    echo ""
    echo -e "${CYAN}====================================${NC}"
}

# Function to enter chat mode
start_chat() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}   DB-GPT Shell Agent - Chat Mode   ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo -e "${YELLOW}Type your questions or commands. Use 'exit' to quit.${NC}"
    echo ""
    
    # Start Ollama in chat mode
    ollama run $MODEL_NAME
}

# Function to audit code
audit_code() {
    local file=$1
    
    # Check if file exists
    if [ ! -f "$file" ]; then
        echo -e "${RED}Error: File $file not found${NC}"
        exit 1
    fi
    
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}  DB-GPT Shell Agent - Code Audit   ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo -e "${YELLOW}Auditing file: $file${NC}"
    echo ""
    
    # Read file content
    local content=$(cat "$file")
    
    # Pass file content to Ollama with code_audit template
    ollama run $MODEL_NAME --template code_audit "$(cat <<EOF
{
  "code": "$content"
}
EOF
)"
    
    # Save audit to history
    echo "$(date): Audited file: $file" >> "$HISTORY_FILE"
}

# Function to manage tasks
manage_tasks() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN} DB-GPT Shell Agent - Task Manager  ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo ""
    
    # Display current tasks
    echo -e "${MAGENTA}Current Task List:${NC}"
    cat "$TASK_FILE"
    echo ""
    
    # Ask if user wants to update tasks
    read -p "Would you like to update tasks? (y/n): " update
    
    if [[ "$update" == "y" || "$update" == "Y" ]]; then
        # Open the task file in the default editor
        ${EDITOR:-vim} "$TASK_FILE"
        echo -e "${GREEN}Tasks updated successfully.${NC}"
    fi
    
    # Use Ollama to provide insights on tasks
    echo -e "${BLUE}Generating insights on your tasks...${NC}"
    echo ""
    
    ollama run $MODEL_NAME --template task_tracking "$(cat <<EOF
{
  "current_tasks": "$(grep -A 10 'Current tasks:' "$TASK_FILE" | tail -n +2)",
  "completed_tasks": "$(grep -A 10 'Completed tasks:' "$TASK_FILE" | tail -n +2)",
  "next_steps": "$(grep -A 10 'Next steps:' "$TASK_FILE" | tail -n +2)"
}
EOF
)"
}

# Function to show history
show_history() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN} DB-GPT Shell Agent - History View  ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo ""
    
    if [ -s "$HISTORY_FILE" ]; then
        cat "$HISTORY_FILE" | tail -n 20
    else
        echo -e "${YELLOW}No history found.${NC}"
    fi
}

# Function to clear history
clear_history() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN} DB-GPT Shell Agent - Clear History ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo ""
    
    read -p "Are you sure you want to clear the history? (y/n): " confirm
    
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        > "$HISTORY_FILE"
        echo -e "${GREEN}History cleared successfully.${NC}"
    else
        echo -e "${YELLOW}Operation canceled.${NC}"
    fi
}

# Parse command line arguments
if [ "$#" -eq 0 ]; then
    MODE="chat"
else
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        --chat)
            MODE="chat"
            ;;
        --audit)
            if [ -z "$2" ]; then
                echo -e "${RED}Error: No file specified for audit${NC}"
                show_help
                exit 1
            fi
            MODE="audit"
            FILE_TO_AUDIT="$2"
            ;;
        --tasks)
            MODE="tasks"
            ;;
        --history)
            MODE="history"
            ;;
        --clear)
            MODE="clear"
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}"
            show_help
            exit 1
            ;;
    esac
fi

# Check if Ollama is installed and running
if ! command -v ollama &> /dev/null; then
    echo -e "${RED}Error: Ollama is not installed or not in PATH${NC}"
    echo -e "Please install Ollama from https://ollama.ai/ first"
    exit 1
fi

# Check if custom model exists
if ! ollama list | grep -q "$MODEL_NAME"; then
    echo -e "${RED}Error: Custom model $MODEL_NAME not found${NC}"
    echo -e "Please run build-shell-agent.sh first to create the model"
    exit 1
fi

# Run the selected mode
case "$MODE" in
    chat)
        start_chat
        ;;
    audit)
        audit_code "$FILE_TO_AUDIT"
        ;;
    tasks)
        manage_tasks
        ;;
    history)
        show_history
        ;;
    clear)
        clear_history
        ;;
esac
