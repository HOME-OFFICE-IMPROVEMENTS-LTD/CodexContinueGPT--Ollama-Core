# CodexContinue-GPT - Simple version with direct query support

# Model configuration
BASE_MODEL="codellama"
CODE_MODEL="codellama"
TASK_MODEL="mistral"
GENERAL_MODEL="llama3"
AUTO_SELECT=false
USE_REAL_OLLAMA=true

# System prompt to provide context to the model
SYSTEM_PROMPT="You are CodexContinueGPT, a custom implementation built by Home & Office Improvements Ltd. on Ollama models (codellama, mistral, llama3) for the DB-GPT project. You were architected by msalsouri. You assist with code generation, task management, and answering questions about the project. 

You are aware of the file organization plan that includes:
1. Reorganizing Ollama documentation files from root to /docs/ollama/
2. Moving CC-GPT related scripts from root to /docker/cc-ollama/
3. Creating a standardized structure for easier maintenance

Your capabilities include direct query support (non-interactive usage), interactive mode, and auto-model selection based on query content. You are integrated with cc-advisor.sh which allows consulting you before file operations.

When asked about your capabilities, explain that you are a custom interface to Ollama models created specifically for the DB-GPT project by Home & Office Improvements Ltd., with msalsouri as the architect."

# Initialize direct query variable
DIRECT_QUERY=""

# Process arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --help|-h)
      echo "CodexContinue-GPT v1.0"
      echo "Usage: cc [OPTIONS] [QUERY]"
      echo "Options:"
      echo "  --auto      Enable auto-model selection"
      echo "  --model     Specify model manually"
      echo "  --test      Run in test mode"
      echo "  --help      Show this help"
      echo "  --version   Show version"
      echo "  --guide     Show guide"
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
      if [ -f "/app/agent/ccgpt-help.sh" ]; then
        /app/agent/ccgpt-help.sh
      else
        echo "Guide not found"
      fi
      exit 0
      ;;
    -*)
      echo "Unknown option: $1"
      exit 1
      ;;
    *)
      # Capture direct query
      DIRECT_QUERY="$1"
      shift
      # Append remaining args
      while [[ $# -gt 0 ]]; do
        DIRECT_QUERY="$DIRECT_QUERY $1"
        shift
      done
      ;;
  esac
done

# Model selection function
select_model() {
    local query="$1"
    local lowercase=$(echo "$query" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$lowercase" =~ code|function|class|javascript|algorithm ]]; then
        echo "$CODE_MODEL"
    elif [[ "$lowercase" =~ task|todo|priority|project ]]; then
        echo "$TASK_MODEL"
    else
        echo "$GENERAL_MODEL"
    fi
}

# Display header
echo "===================================="
echo "     CodexContinue-GPT v1.0         "
echo "===================================="

# Show mode
if [ "$AUTO_SELECT" = true ]; then
    echo "Auto-Model Selection: ON"
    echo "Models configured:"
    echo "  • $CODE_MODEL: Code-related queries"
    echo "  • $TASK_MODEL: Task management"
    echo "  • $GENERAL_MODEL: General conversation"
    if [ "$USE_REAL_OLLAMA" = false ]; then
        echo "Note: Running in test mode (no real Ollama calls)"
    fi
fi

# Process query or enter interactive mode
if [ -n "$DIRECT_QUERY" ]; then
    # Direct query mode
    USER_INPUT="$DIRECT_QUERY"
    
    # Select model
    if [ "$AUTO_SELECT" = true ]; then
        SELECTED_MODEL=$(select_model "$USER_INPUT")
        echo ""
        echo "Using model: $SELECTED_MODEL for this query"
    else
        SELECTED_MODEL="$BASE_MODEL"
    fi
    
    echo ""
    echo "CodexContinue-GPT (via $SELECTED_MODEL):"
    
    # Generate response
    if [ "$USE_REAL_OLLAMA" = true ]; then
        ollama run "$SELECTED_MODEL" --system "$SYSTEM_PROMPT" "$USER_INPUT"
    else
        echo "TEST MODE: Simulated response from $SELECTED_MODEL model"
        echo ""
        if [[ "$SELECTED_MODEL" == "$CODE_MODEL" ]]; then
            echo "Here's a simple function to sort an array:"
            echo ""
            echo "function sortArray(arr) {"
            echo "  return [...arr].sort((a, b) => a - b);"
            echo "}"
        elif [[ "$SELECTED_MODEL" == "$TASK_MODEL" ]]; then
            echo "Here's a task list:"
            echo "1. First priority task"
            echo "2. Second priority task"
            echo "3. Follow-up items"
        else
            echo "This is general information about the topic you asked about."
        fi
    fi
else
    # Interactive mode
    echo "Enter your query below. Type 'exit' to quit."
    
    while true; do
        echo ""
        echo "You:"
        read -r USER_INPUT
        
        # Check for exit
        if [[ "$USER_INPUT" == "exit" || "$USER_INPUT" == "quit" ]]; then
            echo "Goodbye!"
            exit 0
        fi
        
        # Skip empty input
        if [[ -z "$USER_INPUT" ]]; then
            continue
        fi
        
        # Select model
        if [ "$AUTO_SELECT" = true ]; then
            SELECTED_MODEL=$(select_model "$USER_INPUT")
            echo ""
            echo "Using model: $SELECTED_MODEL for this query"
        else
            SELECTED_MODEL="$BASE_MODEL"
        fi
        
        echo ""
        echo "CodexContinue-GPT (via $SELECTED_MODEL):"
        
        # Generate response
        if [ "$USE_REAL_OLLAMA" = true ]; then
            ollama run "$SELECTED_MODEL" --system "$SYSTEM_PROMPT" "$USER_INPUT"
        else
            echo "TEST MODE: Simulated response from $SELECTED_MODEL model"
            echo ""
            if [[ "$SELECTED_MODEL" == "$CODE_MODEL" ]]; then
                echo "Here's a simple function to sort an array:"
                echo ""
                echo "function sortArray(arr) {"
                echo "  return [...arr].sort((a, b) => a - b);"
                echo "}"
            elif [[ "$SELECTED_MODEL" == "$TASK_MODEL" ]]; then
                echo "Here's a task list:"
                echo "1. First priority task"
                echo "2. Second priority task"
                echo "3. Follow-up items"
            else
                echo "This is general information about the topic you asked about."
            fi
        fi
    done
fi
