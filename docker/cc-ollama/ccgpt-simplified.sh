#!/bin/bash
# CodexContinue-GPT - Shell-based AI assistant with auto-model selection
# v1.0 - Simple Direct Query Support

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
USE_REAL_OLLAMA=true    # Set to false for testing without Ollama
OLLAMA_HOST="localhost" # Host for Ollama API
OLLAMA_PORT="11434"     # Port for Ollama API

# Initialize variable to store direct query if provided
DIRECT_QUERY=""

# Process command-line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --help|-h)
      echo -e "${CYAN}=====================================${NC}"
      echo -e "${CYAN}     CodexContinue-GPT v1.0         ${NC}"
      echo -e "${CYAN}=====================================${NC}"
      echo "Usage: ccgpt [OPTIONS] [QUERY]"
      echo ""
      echo "Options:"
      echo "  --auto      Enable auto-model selection"
      echo "  --model     Specify model manually (codellama, mistral, llama3)"
      echo "  --test      Run in test mode (don't use real Ollama)"
      echo "  --help      Show this help message"
      echo "  --version   Show version information"
      echo "  --guide     Show quick usage guide"
      echo ""
      echo "Examples:"
      echo "  cc --auto \"Write a function to sort an array\""
      echo "  cc --model mistral \"Create a todo list\""
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
    --test|-t)
      USE_REAL_OLLAMA=false
      shift
      ;;
    --guide|-g)
      # Display the usage guide
      if [ -f "/app/agent/ccgpt-help.sh" ]; then
        /app/agent/ccgpt-help.sh
      else
        echo "Guide not found. Please reinstall CodexContinue-GPT."
      fi
      exit 0
      ;;
    -*)
      echo "Unknown option: $1"
      echo "Try 'ccgpt --help' for more information."
      exit 1
      ;;
    *)
      # If we encounter a non-option argument, treat it as the query
      DIRECT_QUERY="$1"
      shift
      # Capture any remaining arguments as part of the query
      while [[ $# -gt 0 ]]; do
        DIRECT_QUERY="$DIRECT_QUERY $1"
        shift
      done
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
    if [[ "$input_lower" =~ code|function|class|bug|error|syntax|variable|algorithm|javascript|python|java|cpp|html|css|sql|programming ]]; then
        selected_model="$CODE_MODEL"
    # Check if input contains task management keywords
    elif [[ "$input_lower" =~ task|todo|priority|deadline|project|schedule|planning|organize|list|reminder ]]; then
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

# Function to call Ollama API (simplified for testing)
call_ollama_api() {
    local model="$1"
    local prompt="$2"
    
    if [ "$USE_REAL_OLLAMA" = true ]; then
        # Use ollama command-line tool
        ollama run "$model" "$prompt"
    else
        # Simulate a response for testing
        echo "TEST MODE: Simulated response from $model"
        echo ""
        
        if [[ "$model" == "$CODE_MODEL" ]]; then
            echo "Here's a simple function to sort an array:"
            echo ""
            echo "function sortArray(arr) {"
            echo "  return [...arr].sort((a, b) => a - b);"
            echo "}"
        elif [[ "$model" == "$TASK_MODEL" ]]; then
            echo "Here's a task list:"
            echo "1. First priority task"
            echo "2. Second priority task"
            echo "3. Follow-up items"
        else
            echo "This is general information about the topic you asked about."
        fi
    fi
}

# Display welcome message
echo -e "${CYAN}=====================================${NC}"
echo -e "${CYAN}     CodexContinue-GPT v1.0         ${NC}"
echo -e "${CYAN}=====================================${NC}"

# Show configuration info
if [ "$AUTO_SELECT" = true ]; then
    echo -e "Auto-Model Selection: ${GREEN}ON${NC}"
    echo -e "Models configured:"
    echo -e "  • ${YELLOW}$CODE_MODEL${NC}: Code-related queries"
    echo -e "  • ${YELLOW}$TASK_MODEL${NC}: Task management"
    echo -e "  • ${YELLOW}$GENERAL_MODEL${NC}: General conversation"
    if [ "$USE_REAL_OLLAMA" = false ]; then
        echo -e "${RED}Note: Running in test mode (no real Ollama calls)${NC}"
    fi
fi

# Process direct query or start interactive mode
if [[ -n "$DIRECT_QUERY" ]]; then
    # Process direct query (non-interactive mode)
    USER_INPUT="$DIRECT_QUERY"
    
    # Select the appropriate model
    SELECTED_MODEL=$(select_model_for_input "$USER_INPUT")
    
    # Display which model was selected (only in auto mode)
    if [ "$AUTO_SELECT" = true ]; then
        echo -e "\n${CYAN}Using model: $SELECTED_MODEL for this query${NC}"
    fi
    
    # Get response from Ollama (or simulation)
    echo -e "\n${YELLOW}CodexContinue-GPT (via $SELECTED_MODEL):${NC}"
    call_ollama_api "$SELECTED_MODEL" "$USER_INPUT"
    exit 0
else
    # Interactive mode
    echo -e "\nEnter your query below. Type 'exit' to quit."
    
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
        
        # Get response from Ollama (or simulation)
        echo -e "\n${YELLOW}CodexContinue-GPT (via $SELECTED_MODEL):${NC}"
        call_ollama_api "$SELECTED_MODEL" "$USER_INPUT"
    done
fi
