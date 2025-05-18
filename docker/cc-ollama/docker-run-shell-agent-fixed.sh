# filepath: /home/msalsouri/Projects/DB-GPT/docker/cc-ollama/docker-run-shell-agent-fixed.sh
#!/bin/bash
# Enhanced DB-GPT Shell Agent Runner for Docker
# This is a modified version of run-shell-agent.sh for the Docker environment

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m' # No Color

PROJECT_ROOT="/app/agent"
MODEL_NAME="codex-shell-agent"
HISTORY_FILE="$PROJECT_ROOT/.shell_agent_history"
TASK_FILE="$PROJECT_ROOT/.shell_agent_tasks"
MODE="chat"

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

# Function to audit code - FIXED FOR DOCKER
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
    local file_content=$(cat "$file")
    
    # Create a prompt file for the audit
    cat > /tmp/audit_prompt.txt << EOF
I need you to audit this code file:

\`\`\`
$file_content
\`\`\`

Please provide:
1. A summary of what this code does
2. Any bugs or issues you see
3. Security concerns
4. Performance optimizations
5. Recommendations for improvement
EOF

    # Run Ollama with the prompt file
    ollama run $MODEL_NAME < /tmp/audit_prompt.txt
    
    # Clean up
    rm /tmp/audit_prompt.txt
    
    # Save audit to history
    echo "$(date): Audited file: $file" >> "$HISTORY_FILE"
}

# Function to manage tasks - FIXED FOR DOCKER
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
        ${EDITOR:-nano} "$TASK_FILE"
        echo -e "${GREEN}Tasks updated successfully.${NC}"
    fi
    
    # Extract task sections
    CURRENT_TASKS=$(grep -A 10 'Current tasks:' "$TASK_FILE" | tail -n +2)
    COMPLETED_TASKS=$(grep -A 10 'Completed tasks:' "$TASK_FILE" | tail -n +2)
    NEXT_STEPS=$(grep -A 10 'Next steps:' "$TASK_FILE" | tail -n +2)
    
    # Create a prompt file for task insights
    cat > /tmp/task_prompt.txt << EOF
Here are my current tasks and progress:

Current tasks:
$CURRENT_TASKS

Completed tasks:
$COMPLETED_TASKS

Next steps:
$NEXT_STEPS

Please provide insights, suggestions for prioritization, and any recommendations for my current task list.
EOF

    # Use Ollama to provide insights on tasks
    echo -e "${BLUE}Generating insights on your tasks...${NC}"
    echo ""
    
    ollama run $MODEL_NAME < /tmp/task_prompt.txt
    
    # Clean up
    rm /tmp/task_prompt.txt
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
    
    # Ask for confirmation
    read -p "Are you sure you want to clear history? (y/n): " confirm
    
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        > "$HISTORY_FILE"
        echo -e "${GREEN}History cleared successfully.${NC}"
    else
        echo -e "${YELLOW}Operation cancelled.${NC}"
    fi
}

# Process arguments
if [ $# -eq 0 ]; then
    # No arguments means chat mode
    MODE="chat"
else
    while [ $# -gt 0 ]; do
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --chat)
                MODE="chat"
                shift
                ;;
            --audit)
                MODE="audit"
                if [ -n "$2" ]; then
                    AUDIT_FILE="$2"
                    shift 2
                else
                    echo -e "${RED}Error: --audit requires a file argument${NC}"
                    exit 1
                fi
                ;;
            --tasks)
                MODE="tasks"
                shift
                ;;
            --history)
                MODE="history"
                shift
                ;;
            --clear)
                MODE="clear"
                shift
                ;;
            *)
                echo -e "${RED}Error: Unknown option $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
fi

# Execute requested mode
case "$MODE" in
    "chat")
        start_chat
        ;;
    "audit")
        audit_code "$AUDIT_FILE"
        ;;
    "tasks")
        manage_tasks
        ;;
    "history")
        show_history
        ;;
    "clear")
        clear_history
        ;;
    *)
        echo -e "${RED}Error: Unknown mode $MODE${NC}"
        show_help
        exit 1
        ;;
esac

exit 0
