# filepath: /home/msalsouri/Projects/DB-GPT/docker/cc-ollama/ccgpt.sh
#!/bin/bash
# CodexContinueGPT (CCGpt) Shell Agent
# This script provides an interface to use Ollama's pre-trained models for shell assistance

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration - Create a local directory in user's home
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$HOME/.ccgpt"

# Create project directory if it doesn't exist
mkdir -p "$PROJECT_ROOT"
BASE_MODEL="codellama" # Options: codellama, llama3, mistral, gemma, etc.
HISTORY_FILE="$PROJECT_ROOT/.ccgpt_history"
TASK_FILE="$PROJECT_ROOT/.ccgpt_tasks"
SYSTEM_PROMPT_FILE="$PROJECT_ROOT/ccgpt_system_prompt.txt"
MODE="chat"
AUTO_SELECT=false # Whether to auto-select the model based on prompt

# Model configurations for different tasks
CODE_MODEL="codellama" # Best for code-related tasks (programming, bugs, algorithms)
TASK_MODEL="mistral" # Best for task management (todos, planning, organization)
GENERAL_MODEL="llama3" # Best for general conversation and explanations

# Create history file if it doesn't exist
touch "$HISTORY_FILE"

# Create task file if it doesn't exist
if [ ! -f "$TASK_FILE" ]; then
    echo "Current tasks:" > "$TASK_FILE"
    echo "- Set up CodexContinueGPT agent" >> "$TASK_FILE"
    echo "" >> "$TASK_FILE"
    echo "Completed tasks:" >> "$TASK_FILE"
    echo "" >> "$TASK_FILE"
    echo "Next steps:" >> "$TASK_FILE"
    echo "- Enhance CCGpt capabilities" >> "$TASK_FILE"
fi

# Create system prompt file if it doesn't exist
if [ ! -f "$SYSTEM_PROMPT_FILE" ]; then
    cat > "$SYSTEM_PROMPT_FILE" << 'EOF'
You are CodexContinueGPT (CCGpt), a specialized shell assistant with Ollama integration.
Your capabilities include:

1. CODE AUDITING: You review code for bugs, security issues, and adherence to best practices.
   - Identify potential security vulnerabilities
   - Check for performance bottlenecks
   - Ensure proper error handling and logging
   - Verify that the code follows project conventions

2. BEST PRACTICES: You provide guidance on:
   - Shell scripting standards
   - Docker container management
   - Ollama model operations
   - Python development practices
   - Git workflow procedures

3. TASK MANAGEMENT: You keep track of:
   - Current development goals
   - Pending tasks and their priorities
   - Recent modifications and their impact
   - Future improvement opportunities

4. ENVIRONMENT MANAGEMENT: You help with:
   - Docker container setup and configuration
   - Python virtual environment management
   - Dependency installation and updates
   - System configuration for optimal performance

Always reason through your answers step by step, providing clear explanations along with executable commands.
When suggesting improvements, explain the reasoning behind them.
EOF
fi

# Function to display help information
show_help() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}    CodexContinueGPT (CCGpt)       ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "  cc [options]"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  --chat          Interactive chat mode (default)"
    echo -e "  --audit <file>  Audit code in specified file"
    echo -e "  --tasks         View and manage task tracking"
    echo -e "  --history       Show recent conversation history"
    echo -e "  --clear         Clear conversation history"
    echo -e "  --model <name>  Use specific model (default: $BASE_MODEL)"
    echo -e "  --auto          Enable auto model selection"
    echo -e "  --help          Show this help message"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  cc --audit /path/to/file.py    # Audit a Python file"
    echo -e "  cc --model llama3              # Use llama3 model instead"
    echo -e "  cc --auto                      # Enable auto model selection"
    echo -e "  cc --tasks                     # Manage development tasks"
    echo ""
}

# Process command line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --chat) MODE="chat" ;;
        --audit)
            MODE="audit"
            if [[ -n "$2" && ! "$2" =~ ^--+ ]]; then
                FILE_TO_AUDIT="$2"
                shift
            else
                echo -e "${RED}Error: --audit requires a file path${NC}"
                exit 1
            fi
            ;;
        --tasks) MODE="tasks" ;;
        --history) 
            tail -n 30 "$HISTORY_FILE"
            exit 0
            ;;
        --clear)
            echo "" > "$HISTORY_FILE"
            echo -e "${GREEN}Conversation history cleared${NC}"
            exit 0
            ;;
        --model)
            if [[ -n "$2" && ! "$2" =~ ^--+ ]]; then
                BASE_MODEL="$2"
                shift
            else
                echo -e "${RED}Error: --model requires a model name${NC}"
                exit 1
            fi
            ;;
        --auto)
            AUTO_SELECT=true
            echo -e "${GREEN}Auto model selection enabled${NC}"
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
    shift
done

# Check if Ollama is installed and running
if ! command -v ollama &> /dev/null; then
    echo -e "${RED}Error: Ollama is not installed or not in PATH${NC}"
    echo -e "Please install Ollama from https://ollama.ai/ first"
    exit 1
fi

# Check if Ollama service is running
if ! pgrep -x "ollama" > /dev/null; then
    echo -e "${YELLOW}Ollama service is not running. Starting it...${NC}"
    ollama serve &
    sleep 5
fi

# Check if the models are available
check_models() {
    local models_to_check=("$BASE_MODEL")
    
    # If auto-select is enabled, check all specialized models too
    if [ "$AUTO_SELECT" = true ]; then
        models_to_check+=("$CODE_MODEL" "$TASK_MODEL" "$GENERAL_MODEL")
    fi
    
    # Remove duplicates
    models_to_check=($(echo "${models_to_check[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    
    for model in "${models_to_check[@]}"; do
        echo -e "${BLUE}Checking if $model model is available...${NC}"
        if ! ollama list | grep -q "$model"; then
            echo -e "${YELLOW}Model $model not found. Pulling it now...${NC}"
            ollama pull $model
        fi
    done
}

# Check required models
check_models

# Read the system prompt
SYSTEM_PROMPT=$(cat "$SYSTEM_PROMPT_FILE")

# Function to select the best model based on input content
select_model_for_input() {
    local input="$1"
    local selected_model="$BASE_MODEL"
    
    # Convert to lowercase for easier matching
    local input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    
    # Check if input contains code-related keywords
    if [[ "$input_lower" =~ (code|function|class|bug|error|syntax|variable|algorithm|implementation|compile|execute|program|script|git|docker|python|javascript|html|css|java|cpp|c\+\+|bash|shell|debug|exception|library|framework|api|module|import|package|dependency|build|develop) ]]; then
        selected_model="$CODE_MODEL"
    
    # Check if input contains task management keywords
    elif [[ "$input_lower" =~ (task|todo|priority|deadline|project|plan|organize|schedule|track|progress|management|backlog|sprint|milestone|goal|assign|complete|pending|status|reminder|checklist|roadmap) ]]; then
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

# Function to handle code auditing
audit_code() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo -e "${RED}Error: File not found: $file${NC}"
        exit 1
    fi
    
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}   CCGpt - Code Audit Mode         ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo -e "Auditing file: ${YELLOW}$file${NC}"
    echo ""
    
    # Read file content
    local file_content=$(cat "$file")
    
    # Create the prompt
    local prompt="Please audit the following code file and provide detailed feedback:
    
File: $file
    
$file_content

Please provide:
1. A summary of what the code does
2. Any potential bugs or issues
3. Security concerns
4. Performance improvements
5. Best practices recommendations
6. Example code for any suggested improvements"

    # Auto-select the best model for code auditing
    local current_model=$(select_model_for_input "code audit $file")
    
    # Show which model is being used if auto-selection is on
    if [ "$AUTO_SELECT" = true ]; then
        echo -e "${BLUE}Using model:${NC} ${YELLOW}$current_model${NC}"
    fi
    
    # Send to Ollama and process the response
    echo "$prompt" | ollama run $current_model --system "$SYSTEM_PROMPT"
    
    # Log the activity
    echo "Code Audit: $file" >> "$HISTORY_FILE"
    if [ "$AUTO_SELECT" = true ]; then
        echo "Model used: $current_model" >> "$HISTORY_FILE"
    fi
    echo "" >> "$HISTORY_FILE"
}

# Function to handle task management
manage_tasks() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}   CCGpt - Task Manager Mode       ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo ""
    
    # Display current tasks
    echo "Current Task List:"
    cat "$TASK_FILE"
    echo ""
    
    # Ask if user wants to update tasks
    read -p "Would you like to update tasks? (y/n): " update_choice
    if [[ "$update_choice" =~ ^[Yy]$ ]]; then
        # Open task file in editor
        ${EDITOR:-nano} "$TASK_FILE"
        echo "Tasks updated successfully."
        echo "Generating insights on your tasks..."
        echo ""
        
        # Generate insights based on updated tasks
        local task_content=$(cat "$TASK_FILE")
        local prompt="Here are my current tasks:

$task_content

Please analyze these tasks and provide insights:
1. Are there any tasks that should be prioritized?
2. Any suggestions for breaking down complex tasks?
3. Any recommendations for additional tasks I should consider?
4. How can I improve my task management approach?"

        # Auto-select the best model for task management
        local current_model=$(select_model_for_input "task management priority organize")
        
        # Show which model is being used if auto-selection is on
        if [ "$AUTO_SELECT" = true ]; then
            echo -e "${BLUE}Using model:${NC} ${YELLOW}$current_model${NC}"
        fi
        
        # Send to Ollama and process the response
        echo "$prompt" | ollama run $current_model --system "$SYSTEM_PROMPT"
        
        # Log the activity
        echo "Task Management" >> "$HISTORY_FILE"
        if [ "$AUTO_SELECT" = true ]; then
            echo "Model used: $current_model" >> "$HISTORY_FILE"
        fi
        echo "" >> "$HISTORY_FILE"
    fi
}

# Function for interactive chat mode
chat_mode() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}   CodexContinueGPT - Chat Mode    ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo -e "Type your questions or commands. Use 'exit' to quit."
    if [ "$AUTO_SELECT" = true ]; then
        echo -e "${GREEN}Auto-model selection is ON${NC}"
        echo -e "  • ${YELLOW}$CODE_MODEL${NC}: Code-related queries"
        echo -e "  • ${YELLOW}$TASK_MODEL${NC}: Task management"
        echo -e "  • ${YELLOW}$GENERAL_MODEL${NC}: General conversation"
    else
        echo -e "Using model: ${YELLOW}$BASE_MODEL${NC}"
    fi
    echo ""
    
    while true; do
        echo -e "${YELLOW}>>>${NC} " 
        read -r user_input
        
        # Exit if requested
        if [[ "$user_input" == "exit" ]]; then
            echo "Exiting CCGpt. Goodbye!"
            break
        fi
        
        # Add to history
        echo "User: $user_input" >> "$HISTORY_FILE"
        
        # Auto-select the best model for this input
        local current_model=$(select_model_for_input "$user_input")
        
        # Show which model is being used if auto-selection is on
        if [ "$AUTO_SELECT" = true ]; then
            echo -e "${BLUE}Using model:${NC} ${YELLOW}$current_model${NC}"
        fi
        
        # Process the query
        response=$(echo "$user_input" | ollama run $current_model --system "$SYSTEM_PROMPT")
        
        # Display and log the response
        echo "$response"
        echo "Assistant: $response" >> "$HISTORY_FILE"
        if [ "$AUTO_SELECT" = true ]; then
            echo "Model used: $current_model" >> "$HISTORY_FILE"
        fi
        echo "" >> "$HISTORY_FILE"
    done
}

# Execute the selected mode
case "$MODE" in
    "audit")
        audit_code "$FILE_TO_AUDIT"
        ;;
    "tasks")
        manage_tasks
        ;;
    "chat"|*)
        chat_mode
        ;;
esac
