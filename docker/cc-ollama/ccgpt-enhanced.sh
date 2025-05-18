# filepath: /home/msalsouri/Projects/DB-GPT/docker/cc-ollama/ccgpt-enhanced.sh
#!/bin/bash
# CodexContinue-GPT - Shell-based AI assistant with auto-model selection
# v1.0

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Model configuration
BASE_MODEL="codellama"  # Default model
CODE_MODEL="codellama"  # Best for code-related queries
TASK_MODEL="mistral"    # Best for task management
GENERAL_MODEL="llama3"  # Best for general conversation
AUTO_SELECT=false       # Default to manual selection

# Process command-line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --help|-h)
      echo -e "${CYAN}=====================================${NC}"
      echo -e "${CYAN}     CodexContinue-GPT v1.0         ${NC}"
      echo -e "${CYAN}=====================================${NC}"
      echo "Usage: ccgpt [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --auto      Enable auto-model selection"
      echo "  --model     Specify model manually (codellama, mistral, llama3)"
      echo "  --help      Show this help message"
      echo "  --version   Show version information"
      exit 0
      ;;
    --version|-v)
      echo "CodexContinue-GPT v1.0"
      exit 0
      ;;
    --auto|-a)
      AUTO_SELECT=true
      shift
      ;;
    --model|-m)
      BASE_MODEL="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Try 'ccgpt --help' for more information."
      exit 1
      ;;
  esac
done

# Function to select the appropriate model based on input
select_model_for_input() {
    local input="$1"
    local selected_model="$BASE_MODEL"
    
    # Convert to lowercase for easier matching
    local input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    
    # Check if input contains code-related keywords
    if [[ "$input_lower" =~ (code|function|class|bug|error|syntax|variable|algorithm|javascript|python|java|c\+\+|html|css|sql|programming|debug|compiler|api|library|framework|git|github|loop|recursion|sort|search|array|object|string|integer|boolean|float|double|int|char|void|return|import|export|module|package|npm|pip|gem|maven|gradle) ]]; then
        selected_model="$CODE_MODEL"
    
    # Check if input contains task management keywords
    elif [[ "$input_lower" =~ (task|todo|priority|deadline|project|schedule|planning|organize|list|reminder|management|assign|track|progress|milestone|goal|objective|plan|roadmap|backlog|sprint|agile|kanban|scrum|team|collaboration|meeting|minutes|notes|summary|report|status|update) ]]; then
        selected_model="$TASK_MODEL"
    
    # Default to general conversation model
    else
        selected_model="$GENERAL_MODEL"
    fi
    
    # Only change from BASE_MODEL if auto-select is on
    if [ "$AUTO_SELECT" = true ]; then
        echo "$selected_model"
    else
        echo "$BASE_MODEL"
    fi
}

# Display welcome message
echo -e "${CYAN}=====================================${NC}"
echo -e "${CYAN}     CodexContinue-GPT v1.0         ${NC}"
echo -e "${CYAN}=====================================${NC}"

# Show configuration info based on mode
if [ "$AUTO_SELECT" = true ]; then
    echo -e "Auto-Model Selection: ${GREEN}ON${NC}"
    echo -e "Models configured:"
    echo -e "  • ${YELLOW}$CODE_MODEL${NC}: Code-related queries"
    echo -e "  • ${YELLOW}$TASK_MODEL${NC}: Task management"
    echo -e "  • ${YELLOW}$GENERAL_MODEL${NC}: General conversation"
    echo -e "\nEnter your query below. Type 'exit' to quit."
else
    echo -e "Using model: ${YELLOW}$BASE_MODEL${NC}"
    echo -e "Auto-Model Selection: ${RED}OFF${NC}"
    echo -e "Tip: Use --auto to enable smart model selection"
    echo -e "\nEnter your query below. Type 'exit' to quit."
fi

# History tracking
HISTORY_FILE="/tmp/ccgpt_history.txt"
touch "$HISTORY_FILE"

# Main interaction loop
while true; do
    # Prompt for input
    echo -e "\n${GREEN}You:${NC}"
    read -r USER_INPUT
    
    # Check for exit command
    if [[ "$USER_INPUT" == "exit" || "$USER_INPUT" == "quit" ]]; then
        echo -e "${CYAN}Goodbye!${NC}"
        exit 0
    fi
    
    # Skip empty input
    if [[ -z "$USER_INPUT" ]]; then
        continue
    fi
    
    # Select the appropriate model
    SELECTED_MODEL=$(select_model_for_input "$USER_INPUT")
    
    # Display which model was selected (only in auto mode)
    if [ "$AUTO_SELECT" = true ]; then
        echo -e "\n${CYAN}Using model: $SELECTED_MODEL for this query${NC}"
    fi
    
    # Record in history
    echo "$(date '+%Y-%m-%d %H:%M:%S') | Model: $SELECTED_MODEL | Query: $USER_INPUT" >> "$HISTORY_FILE"
    
    # Simulate response (in a real implementation, this would call Ollama)
    echo -e "\n${YELLOW}CodexContinue-GPT (via $SELECTED_MODEL):${NC}"
    
    case "$SELECTED_MODEL" in
        "$CODE_MODEL")
            echo "Here's a sample response using the code-specialized model."
            if [[ "$USER_INPUT" =~ function|code|javascript ]]; then
                echo "```javascript"
                echo "function sortArray(arr) {"
                echo "  return arr.sort((a, b) => a - b);"
                echo "}"
                echo "```"
            fi
            ;;
        "$TASK_MODEL")
            echo "Here's a sample response using the task management model."
            if [[ "$USER_INPUT" =~ todo|task|list ]]; then
                echo "1. First priority task"
                echo "2. Second priority task"
                echo "3. Follow-up items"
            fi
            ;;
        "$GENERAL_MODEL")
            echo "Here's a sample response using the general conversation model."
            echo "This would be a more conversational, informative answer about general topics."
            ;;
    esac
    
    # In a real implementation, this would use the actual Ollama API
    # ollama run $SELECTED_MODEL "$USER_INPUT"
done
