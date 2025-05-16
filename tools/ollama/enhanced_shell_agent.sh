#!/bin/bash
# DB-GPT Enhanced Shell Agent with MCP Streaming
# This script provides a shell agent that leverages the Enhanced MCP server with streaming

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the project root from the script location
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default configuration
DEFAULT_MODEL="codellama"
DEFAULT_PORT=8000
DEFAULT_HOST="localhost"
HISTORY_FILE="$PROJECT_ROOT/.shell_agent_history_enhanced"
TEMP_DIR="$PROJECT_ROOT/.tmp"
MODE="shell"
TASK_FILE="$PROJECT_ROOT/.shell_agent_tasks_enhanced"

# Parse command line arguments
model="$DEFAULT_MODEL"
port="$DEFAULT_PORT"
host="$DEFAULT_HOST"
mode="$MODE"
task=""

print_help() {
    echo -e "${CYAN}DB-GPT Enhanced Shell Agent${NC}"
    echo ""
    echo "Usage: $(basename "$0") [options]"
    echo ""
    echo "Options:"
    echo "  --model MODEL          - Model to use (default: codellama)"
    echo "  --port PORT            - MCP server port (default: 8000)"
    echo "  --host HOST            - MCP server host (default: localhost)"
    echo "  --mode MODE            - Agent mode: shell, code, or chat (default: shell)"
    echo "  --task TASK            - Specific task for the agent to work on"
    echo "  --help                 - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") --model llama3 --mode code"
    echo "  $(basename "$0") --task \"optimize the memory usage in the Python script\""
    echo ""
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --model)
            model="$2"
            shift 2
            ;;
        --port)
            port="$2"
            shift 2
            ;;
        --host)
            host="$2"
            shift 2
            ;;
        --mode)
            mode="$2"
            shift 2
            ;;
        --task)
            task="$2"
            shift 2
            ;;
        --help)
            print_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            print_help
            exit 1
            ;;
    esac
done

# Set up the API base URL
API_BASE="http://$host:$port"

# Create necessary directories and files
mkdir -p "$TEMP_DIR"
touch "$HISTORY_FILE"

# Create task file if it doesn't exist
if [ ! -f "$TASK_FILE" ]; then
    echo "Current tasks:" > "$TASK_FILE"
    echo "- Set up enhanced shell agent with streaming" >> "$TASK_FILE"
    echo "" >> "$TASK_FILE"
    echo "Completed tasks:" >> "$TASK_FILE"
    echo "" >> "$TASK_FILE"
    echo "Next steps:" >> "$TASK_FILE"
    echo "- Integrate with more Ollama models" >> "$TASK_FILE"
    echo "- Add tool usage capabilities" >> "$TASK_FILE"
fi

# Helper function to check if MCP server is running
check_mcp_server() {
    if ! curl -s "$API_BASE/v1/health" > /dev/null; then
        echo -e "${RED}Error: Enhanced MCP server is not running at $API_BASE${NC}"
        echo -e "${YELLOW}Start the server with:${NC} ${GREEN}mcp-enhanced-$model${NC}"
        exit 1
    fi
}

# Get the appropriate system prompt based on mode
get_system_prompt() {
    case "$mode" in
        shell)
            echo "You are a helpful shell assistant. You help users with shell commands, scripting, and system administration tasks. When asked to write a script, format it correctly with proper shebang and make it executable. Always explain what your commands or scripts do."
            ;;
        code)
            echo "You are a programming assistant specializing in software development. You help write, debug, and optimize code. Provide clean, well-commented code that follows best practices. Explain your implementation and any design decisions."
            ;;
        chat)
            echo "You are a helpful assistant who can answer questions about a wide range of topics. Provide clear, concise answers. If you don't know something, be honest about it."
            ;;
        *)
            echo "You are a helpful assistant. You provide clear, factual information and assist with various tasks."
            ;;
    esac
}

# Helper function to send a prompt to the MCP server (chat completion)
send_prompt() {
    local user_prompt="$1"
    local system_prompt="$2"
    
    # Create a temporary file for the request payload
    local temp_file=$(mktemp)
    
    # Prepare the JSON request
    cat > "$temp_file" << EOF
{
    "model": "$model",
    "messages": [
        {"role": "system", "content": "$system_prompt"},
        {"role": "user", "content": "$user_prompt"}
    ],
    "stream": true
}
EOF
    
    # Send streaming request
    curl -s "$API_BASE/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -d @"$temp_file" --no-buffer | while read -r line; do
        if [[ "$line" == data:*[DONE]* ]]; then
            continue
        fi
        
        if [[ "$line" == data:* ]]; then
            # Parse the delta content
            content=$(echo "$line" | sed 's/^data: //' | jq -r '.choices[0].delta.content // empty' 2>/dev/null)
            if [ -n "$content" ]; then
                echo -n "$content"
            fi
        fi
    done
    
    # Clean up
    rm "$temp_file"
}

# Get the last few entries from history for context
get_history_context() {
    local context_size=5
    local history_context=""
    
    if [ -f "$HISTORY_FILE" ]; then
        history_context=$(tail -n "$context_size" "$HISTORY_FILE")
    fi
    
    echo "$history_context"
}

# Add an entry to the history file
add_to_history() {
    local role="$1"
    local content="$2"
    
    echo "[$role]: $content" >> "$HISTORY_FILE"
}

# Helper function for command suggestions
suggest_command() {
    local query="$1"
    local system_prompt=$(get_system_prompt)
    local prompt="Please suggest a shell command for the following task: $query"
    
    echo -e "${BLUE}Suggesting command for:${NC} $query"
    echo -e "${GREEN}Suggested command:${NC}"
    
    send_prompt "$prompt" "$system_prompt"
    echo ""
}

# Helper function to explain a command
explain_command() {
    local command="$1"
    local system_prompt=$(get_system_prompt)
    local prompt="Please explain what this shell command does in detail: $command"
    
    echo -e "${BLUE}Explaining command:${NC} $command"
    echo -e "${GREEN}Explanation:${NC}"
    
    send_prompt "$prompt" "$system_prompt"
    echo ""
}

# Helper function to generate a script
generate_script() {
    local description="$1"
    local system_prompt=$(get_system_prompt)
    local prompt="Please write a shell script that will: $description. Include a proper shebang line and make it executable. Add comments to explain what the script does."
    
    echo -e "${BLUE}Generating script for:${NC} $description"
    echo -e "${GREEN}Generated script:${NC}"
    
    send_prompt "$prompt" "$system_prompt"
    echo ""
}

# Run the enhanced shell agent
run_shell_agent() {
    check_mcp_server
    
    echo -e "${CYAN}=========================================${NC}"
    echo -e "${CYAN}      DB-GPT Enhanced Shell Agent       ${NC}"
    echo -e "${CYAN}=========================================${NC}"
    echo ""
    echo -e "${BLUE}Model:${NC} ${YELLOW}$model${NC}"
    echo -e "${BLUE}Mode:${NC} ${YELLOW}$mode${NC}"
    echo -e "${BLUE}MCP server:${NC} ${YELLOW}$API_BASE${NC}"
    echo ""
    
    # If a task was specified, handle it directly
    if [ -n "$task" ]; then
        echo -e "${BLUE}Processing task:${NC} $task"
        echo ""
        
        local system_prompt=$(get_system_prompt)
        send_prompt "$task" "$system_prompt"
        echo ""
        
        add_to_history "user" "$task"
        exit 0
    fi
    
    echo -e "Type ${YELLOW}exit${NC} to quit, ${YELLOW}help${NC} for available commands."
    echo ""
    
    while true; do
        read -e -p "> " user_input
        
        case "$user_input" in
            exit|quit)
                echo -e "${GREEN}Session ended.${NC}"
                break
                ;;
            help)
                echo -e "${YELLOW}Available commands:${NC}"
                echo -e "  ${GREEN}help${NC}                 - Show this help message"
                echo -e "  ${GREEN}exit${NC} or ${GREEN}quit${NC}        - End the session"
                echo -e "  ${GREEN}suggest${NC} [task]       - Get command suggestions for a task"
                echo -e "  ${GREEN}explain${NC} [command]    - Explain what a command does"
                echo -e "  ${GREEN}script${NC} [description] - Generate a shell script"
                echo -e "  ${GREEN}mode${NC} [shell|code|chat] - Change the agent mode"
                echo -e "  ${GREEN}model${NC} [name]         - Change the model"
                echo -e "  ${GREEN}history${NC}              - Show conversation history"
                echo -e "  ${GREEN}clear${NC}                - Clear the screen"
                echo -e "Any other input will be treated as a question to the assistant."
                ;;
            suggest*)
                # Extract the content after "suggest "
                task_desc="${user_input#suggest }"
                if [ "$task_desc" == "suggest" ]; then
                    echo -e "${RED}Error: No task description provided${NC}"
                    echo -e "Usage: ${GREEN}suggest${NC} [task description]"
                else
                    suggest_command "$task_desc"
                    add_to_history "user" "suggest: $task_desc"
                fi
                ;;
            explain*)
                # Extract the content after "explain "
                cmd="${user_input#explain }"
                if [ "$cmd" == "explain" ]; then
                    echo -e "${RED}Error: No command provided${NC}"
                    echo -e "Usage: ${GREEN}explain${NC} [command]"
                else
                    explain_command "$cmd"
                    add_to_history "user" "explain: $cmd"
                fi
                ;;
            script*)
                # Extract the content after "script "
                script_desc="${user_input#script }"
                if [ "$script_desc" == "script" ]; then
                    echo -e "${RED}Error: No script description provided${NC}"
                    echo -e "Usage: ${GREEN}script${NC} [description]"
                else
                    generate_script "$script_desc"
                    add_to_history "user" "script: $script_desc"
                fi
                ;;
            mode*)
                # Extract the content after "mode "
                new_mode="${user_input#mode }"
                if [ "$new_mode" == "mode" ]; then
                    echo -e "${RED}Error: No mode specified${NC}"
                    echo -e "Usage: ${GREEN}mode${NC} [shell|code|chat]"
                elif [[ "$new_mode" == "shell" || "$new_mode" == "code" || "$new_mode" == "chat" ]]; then
                    mode="$new_mode"
                    echo -e "${GREEN}Mode changed to:${NC} $mode"
                else
                    echo -e "${RED}Error: Invalid mode${NC}"
                    echo -e "Valid modes: shell, code, chat"
                fi
                ;;
            model*)
                # Extract the content after "model "
                new_model="${user_input#model }"
                if [ "$new_model" == "model" ]; then
                    echo -e "${RED}Error: No model specified${NC}"
                    echo -e "Usage: ${GREEN}model${NC} [model name]"
                else
                    # Check if the model exists
                    if curl -s "$API_BASE/v1/models" | grep -q "\"id\": \"$new_model\""; then
                        model="$new_model"
                        echo -e "${GREEN}Model changed to:${NC} $model"
                    else
                        echo -e "${RED}Error: Model '$new_model' not found${NC}"
                        echo -e "Available models:"
                        curl -s "$API_BASE/v1/models" | grep "\"id\"" | sed 's/.*"id": "/- /' | sed 's/".*//'
                    fi
                fi
                ;;
            history)
                echo -e "${YELLOW}Conversation history:${NC}"
                if [ -f "$HISTORY_FILE" ]; then
                    cat "$HISTORY_FILE"
                else
                    echo -e "${RED}No history found.${NC}"
                fi
                ;;
            clear)
                clear
                echo -e "${CYAN}=========================================${NC}"
                echo -e "${CYAN}      DB-GPT Enhanced Shell Agent       ${NC}"
                echo -e "${CYAN}=========================================${NC}"
                echo ""
                echo -e "${BLUE}Model:${NC} ${YELLOW}$model${NC}"
                echo -e "${BLUE}Mode:${NC} ${YELLOW}$mode${NC}"
                echo -e "${BLUE}MCP server:${NC} ${YELLOW}$API_BASE${NC}"
                echo ""
                echo -e "Type ${YELLOW}exit${NC} to quit, ${YELLOW}help${NC} for available commands."
                echo ""
                ;;
            "")
                # Empty input, do nothing
                ;;
            *)
                # Treat as a question
                echo -e "${BLUE}Processing query...${NC}"
                system_prompt=$(get_system_prompt)
                history_context=$(get_history_context)
                
                # Include history context if available
                prompt="$user_input"
                if [ -n "$history_context" ]; then
                    prompt="Here's some context from our recent conversation:\n\n$history_context\n\n$user_input"
                fi
                
                send_prompt "$prompt" "$system_prompt"
                echo ""
                
                add_to_history "user" "$user_input"
                ;;
        esac
    done
}

# Main execution
run_shell_agent
