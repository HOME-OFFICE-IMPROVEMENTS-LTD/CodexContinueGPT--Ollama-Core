#!/bin/bash
# DB-GPT Agent Commands for Ollama
# Uses the existing Ollama integration to provide agent functionality

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default model - can be changed based on preference
DEFAULT_MODEL="codellama:latest"
# Alternative models you might want to use
# DEFAULT_MODEL="llama3:latest"
# DEFAULT_MODEL="mistral:latest"
# DEFAULT_MODEL="phi3:latest"

# Check if curl is installed
check_curl() {
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}Error: curl is not installed. Please install curl to use API-based system prompts.${NC}"
        return 1
    fi
    return 0
}

# Check if jq is installed
check_jq() {
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}Warning: jq is not installed. JSON responses will be displayed raw.${NC}"
        return 1
    fi
    return 0
}

# Check if Ollama API is available
check_ollama_api() {
    if ! check_curl; then
        return 1
    fi
    
    local api_url="http://localhost:11434/api/tags"
    if ! curl -s --connect-timeout 2 "$api_url" &> /dev/null; then
        echo -e "${RED}Error: Ollama API not available at $api_url${NC}"
        echo -e "${YELLOW}Make sure Ollama is running. Try starting it with 'ollama serve' command.${NC}"
        return 1
    fi
    return 0
}

# Function to escape special characters in JSON
escape_for_json() {
    local string="$1"
    # Escape backslashes first, then quotes, newlines, tabs, etc.
    string="${string//\\/\\\\}"
    string="${string//\"/\\\"}"
    string="${string//$'\n'/\\n}"
    string="${string//$'\r'/\\r}"
    string="${string//$'\t'/\\t}"
    echo "$string"
}

# Function to run Ollama with appropriate prompting based on availability
run_ollama_prompt() {
    local model=$1
    local system_prompt=$2
    local user_prompt=$3
    
    # Escape prompts for JSON
    local escaped_system_prompt=$(escape_for_json "$system_prompt")
    local escaped_user_prompt=$(escape_for_json "$user_prompt")
    
    # Check if Ollama API is available for system prompts
    if check_ollama_api; then
        echo -e "${GREEN}Using Ollama API with system prompt support${NC}"
        
        # Prepare JSON data
        local json_data
        if [ -z "$user_prompt" ]; then
            # If no user prompt is provided, use a default empty message
            json_data=$(cat <<EOF
{
  "model": "$model",
  "stream": true,
  "messages": [
    {"role": "system", "content": "$escaped_system_prompt"},
    {"role": "user", "content": ""}
  ]
}
EOF
)
        else
            # If user prompt is provided
            json_data=$(cat <<EOF
{
  "model": "$model",
  "stream": true,
  "messages": [
    {"role": "system", "content": "$escaped_system_prompt"},
    {"role": "user", "content": "$escaped_user_prompt"}
  ]
}
EOF
)
        fi

        # Use process substitution to handle interactive chat mode
        # Parse the streaming JSON and extract just the content
        if check_jq; then
            # Create a temporary file for the complete conversation
            local temp_file=$(mktemp)
            
            # Create a file to store the entire conversation history
            local history_file=$(mktemp)
            
            # Initialize conversation history with system and user message
            echo "{\"role\":\"system\",\"content\":\"$escaped_system_prompt\"}" > "$history_file"
            if [ -n "$user_prompt" ]; then
                echo "{\"role\":\"user\",\"content\":\"$escaped_user_prompt\"}" >> "$history_file"
            else
                echo "{\"role\":\"user\",\"content\":\"\"}" >> "$history_file"
            fi
            
            # Stream the content through jq to extract just the assistant message
            curl -s "http://localhost:11434/api/chat" \
              -H "Content-Type: application/json" \
              -d "$json_data" | while read -r line; do
                if [[ -n "$line" ]]; then
                    # Extract just the content from the JSON response
                    content=$(echo "$line" | jq -r 'if .message.content != null then .message.content else "" end')
                    if [[ "$content" != "" ]]; then
                        # Print content without newlines to create a continuous stream
                        echo -n "$content"
                        # Append to temp file for full conversation context
                        echo -n "$content" >> "$temp_file"
                    fi
                    
                    # If the message is done, print a newline
                    if [[ $(echo "$line" | jq -r '.done // false') == "true" ]]; then
                        echo ""
                    fi
                fi
            done
            
            # Add assistant response to history
            echo "{\"role\":\"assistant\",\"content\":\"$(escape_for_json "$(cat "$temp_file")")\"}" >> "$history_file"
            
            # Read user input and continue the conversation
            local input=""
            while true; do
                echo ""
                read -p "> " input
                
                # Check if user wants to exit
                if [[ "$input" == "exit" || "$input" == "quit" ]]; then
                    # DB-GPT Agent Memory Integration - Save before exiting
                    local agent_type="unknown"
                    if [[ "$FUNCNAME" == *"code_assistant"* ]]; then
                        agent_type="code"
                    elif [[ "$FUNCNAME" == *"shell_helper"* ]]; then
                        agent_type="shell"
                    elif [[ "$FUNCNAME" == *"task_manager"* ]]; then
                        agent_type="tasks"
                    elif [[ "$FUNCNAME" == *"audit_code"* ]]; then
                        agent_type="audit"
                    elif [[ "$FUNCNAME" == *"git_helper"* ]]; then
                        agent_type="git"
                    elif [[ "$FUNCNAME" == *"decision_audit"* ]]; then
                        agent_type="decision"
                    fi
                    
                    # Check if memory integration script exists and save the conversation
                    local memory_script="$(dirname "$0")/agent-memory.sh"
                    if [ -f "$memory_script" ] && [ "$agent_type" != "unknown" ]; then
                        # Save conversation to memory
                        bash "$memory_script" save "$agent_type" "$history_file"
                    fi
                    
                    # Cleanup temporary files
                    rm -f "$temp_file" "$history_file"
                    break
                fi
                
                # Add user input to conversation history
                echo "{\"role\":\"user\",\"content\":\"$(escape_for_json "$input")\"}" >> "$history_file"
                
                # Create messages array from history file
                local messages="["
                local first=true
                while IFS= read -r message; do
                    if [ "$first" = true ]; then
                        messages="$messages$message"
                        first=false
                    else
                        messages="$messages,$message"
                    fi
                done < "$history_file"
                messages="$messages]"
                
                # Create new JSON payload with full conversation history
                local next_json=$(cat <<EOF
{
  "model": "$model",
  "stream": true,
  "messages": $messages
}
EOF
)
                
                # Get model response
                local temp_response=$(mktemp)
                curl -s "http://localhost:11434/api/chat" \
                  -H "Content-Type: application/json" \
                  -d "$next_json" | while read -r line; do
                    if [[ -n "$line" ]]; then
                        content=$(echo "$line" | jq -r 'if .message.content != null then .message.content else "" end')
                        if [[ "$content" != "" ]]; then
                            echo -n "$content"
                            echo -n "$content" >> "$temp_response"
                        fi
                        if [[ $(echo "$line" | jq -r '.done // false') == "true" ]]; then
                            echo ""
                        fi
                    fi
                done
                
                # Add assistant response to conversation history
                echo "{\"role\":\"assistant\",\"content\":\"$(escape_for_json "$(cat "$temp_response")")\"}" >> "$history_file"
                
                # Remove temporary response file
                rm -f "$temp_response"
            done
            
            # DB-GPT Agent Memory Integration
            # Save conversation to persistent memory if applicable
            local agent_type="unknown"
            if [[ "$FUNCNAME" == *"code_assistant"* ]]; then
                agent_type="code"
            elif [[ "$FUNCNAME" == *"shell_helper"* ]]; then
                agent_type="shell"
            elif [[ "$FUNCNAME" == *"task_manager"* ]]; then
                agent_type="tasks"
            elif [[ "$FUNCNAME" == *"audit_code"* ]]; then
                agent_type="audit"
            elif [[ "$FUNCNAME" == *"git_helper"* ]]; then
                agent_type="git"
            elif [[ "$FUNCNAME" == *"decision_audit"* ]]; then
                agent_type="decision"
            fi
            
            # Check if memory integration script exists and save the conversation
            local memory_script="$(dirname "$0")/agent-memory.sh"
            if [ -f "$memory_script" ] && [ "$agent_type" != "unknown" ]; then
                # Save conversation to memory
                bash "$memory_script" save "$agent_type" "$history_file"
            fi
            
            # Clean up the main temp file if we exited the loop naturally
            rm -f "$temp_file" "$history_file"
        else
            # No jq available, just display raw output
            curl -s "http://localhost:11434/api/chat" \
              -H "Content-Type: application/json" \
              -d "$json_data" 
              
            echo -e "\n${YELLOW}Note: Install jq for a better experience with parsed JSON output.${NC}"
        fi
    else
        echo -e "${YELLOW}Using Ollama in legacy mode (combined prompts)${NC}"
        local combined_prompt="$system_prompt

$user_prompt"
        ollama run $model "$combined_prompt"
    fi
}

# Function for getting code assistance
code_assistant() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}   DB-GPT Code Assistant   ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo -e "${YELLOW}Using model: $DEFAULT_MODEL${NC}"
    echo -e "${YELLOW}Type your code questions. Use 'exit' to quit.${NC}"
    echo ""
    
    # System prompt for code assistance
    SYSTEM_PROMPT="You are an expert programming assistant. Help the user write high-quality, secure, and efficient code. Provide examples, explain concepts, and suggest improvements."
    
    # Run ollama with the system prompt
    run_ollama_prompt "$DEFAULT_MODEL" "$SYSTEM_PROMPT" ""
}

# Function for shell script assistance
shell_helper() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}   DB-GPT Shell Helper   ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo -e "${YELLOW}Using model: $DEFAULT_MODEL${NC}"
    echo -e "${YELLOW}Ask for shell command help or script creation. Use 'exit' to quit.${NC}"
    echo ""
    
    # System prompt for shell assistance
    SYSTEM_PROMPT="You are an expert in shell scripting and command-line operations. Your primary goal is to help the user with shell commands, explain their usage, and create shell scripts. Always provide clear explanations and make sure commands are secure and follow best practices."
    
    # Run ollama with the system prompt
    run_ollama_prompt "$DEFAULT_MODEL" "$SYSTEM_PROMPT" ""
}

# Function for task management
task_manager() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}   DB-GPT Task Manager   ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo -e "${YELLOW}Using model: $DEFAULT_MODEL${NC}"
    echo -e "${YELLOW}Manage your development tasks and track progress. Use 'exit' to quit.${NC}"
    echo ""
    
    # Check if task file exists, create if it doesn't
    TASK_FILE="$HOME/.dbgpt_tasks"
    if [ ! -f "$TASK_FILE" ]; then
        echo "# DB-GPT Tasks" > "$TASK_FILE"
        echo "## Current Tasks" >> "$TASK_FILE"
        echo "- Set up development environment" >> "$TASK_FILE"
        echo "## Completed Tasks" >> "$TASK_FILE"
        echo "## Future Tasks" >> "$TASK_FILE"
    fi
    
    # Show current tasks
    echo -e "${BLUE}Current tasks from $TASK_FILE:${NC}"
    cat "$TASK_FILE"
    echo ""
    
    # Ask if user wants to edit tasks
    read -p "Would you like to edit tasks first? (y/n): " edit_choice
    if [[ "$edit_choice" == "y" || "$edit_choice" == "Y" ]]; then
        ${EDITOR:-vim} "$TASK_FILE"
        echo -e "${GREEN}Tasks updated.${NC}"
        echo ""
    fi
    
    # Get task content
    TASK_CONTENT=$(cat "$TASK_FILE")
    
    # System prompt for task management
    SYSTEM_PROMPT="You are a project management assistant focused on helping developers organize their tasks and workflow. Help the user prioritize tasks, break down large tasks into smaller steps, and keep track of progress."
    
    # User prompt with task content
    USER_PROMPT="Here are the current tasks:

$TASK_CONTENT

When asked about the current tasks, refer to the content above."
    
    # Run ollama with the system and user prompts
    run_ollama_prompt "$DEFAULT_MODEL" "$SYSTEM_PROMPT" "$USER_PROMPT"
}

# Function for code auditing
audit_code() {
    local file=$1
    
    # Check if file is provided
    if [ -z "$file" ]; then
        echo -e "${RED}Error: No file specified for audit${NC}"
        echo "Usage: audit-code <file>"
        return 1
    fi
    
    # Check if file exists
    if [ ! -f "$file" ]; then
        echo -e "${RED}Error: File $file not found${NC}"
        return 1
    fi
    
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}   DB-GPT Code Auditor   ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo -e "${YELLOW}Using model: $DEFAULT_MODEL${NC}"
    echo -e "${YELLOW}Auditing file: $file${NC}"
    echo ""
    
    # Read file content
    local content=$(cat "$file")
    
    # System prompt for code auditing
    SYSTEM_PROMPT="You are a code auditor with expertise in identifying security vulnerabilities, performance issues, and code quality concerns. Analyze the provided code and report:
    1. Security vulnerabilities
    2. Performance bottlenecks
    3. Code quality issues
    4. Best practice violations
    5. Suggested improvements
    
    Organize your response into sections for each category, including specific line references where appropriate."
    
    # User prompt with file content
    USER_PROMPT="Please audit the following code from file $file:
    
\`\`\`
$content
\`\`\`
    
Provide a comprehensive audit report with specific recommendations for improvements."
    
    # Run ollama with the system and user prompts
    run_ollama_prompt "$DEFAULT_MODEL" "$SYSTEM_PROMPT" "$USER_PROMPT"
}

# Function to audit decisions and implementation
decision_audit() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}   DB-GPT Decision Auditor   ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo -e "${YELLOW}Using model: $DEFAULT_MODEL${NC}"
    echo -e "${YELLOW}This tool will help audit implementation decisions.${NC}"
    echo ""
    
    # Ask for decision context
    echo -e "${BLUE}Please provide context about the decision or implementation to audit:${NC}"
    echo -e "(Type your description, then press Ctrl+D when finished)"
    echo ""
    
    # Capture multi-line input
    decision_context=$(cat)
    echo ""
    
    # System prompt for decision auditing
    SYSTEM_PROMPT="You are an impartial and objective code auditor and decision reviewer. Your task is to critically analyze the provided implementation decisions or architectural choices. Consider:

1. EFFECTIVENESS: Does the solution effectively solve the stated problem?
2. EFFICIENCY: Is this the most efficient approach available?
3. ALTERNATIVES: What other approaches could have been taken?
4. RISKS: What potential issues or vulnerabilities might this approach introduce?
5. BEST PRACTICES: Does this follow software engineering and domain-specific best practices?

Be honest but constructive in your feedback. Acknowledge good decisions while pointing out areas for improvement. Provide specific recommendations where appropriate."
    
    # User prompt with decision context
    USER_PROMPT="Please audit the following implementation decision/approach:

$decision_context

Provide a comprehensive, objective analysis including strengths, weaknesses, potential risks, and suggested improvements."
    
    # Run ollama with the system and user prompts
    run_ollama_prompt "$DEFAULT_MODEL" "$SYSTEM_PROMPT" "$USER_PROMPT"
}

# Function for git operations assistance
git_helper() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}   DB-GPT Git Helper   ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo -e "${YELLOW}Using model: $DEFAULT_MODEL${NC}"
    echo -e "${YELLOW}Get help with git operations or auto-commit changes. Use 'exit' to quit.${NC}"
    echo ""
    
    # Show git status
    echo -e "${BLUE}Current git status:${NC}"
    git status -s
    echo ""
    
    # Offer options
    echo -e "Options:"
    echo -e "  ${YELLOW}1${NC}. ${GREEN}Auto-commit changes${NC}"
    echo -e "  ${YELLOW}2${NC}. ${GREEN}Get git assistance${NC}"
    echo ""
    
    read -p "Select an option (1/2): " git_option
    case $git_option in
        1)
            auto_commit
            ;;
        2)
            # System prompt for git assistance
            SYSTEM_PROMPT="You are a Git expert who helps developers with Git commands and workflows. Your guidance should be accurate, secure, and follow Git best practices. Consider branching strategies, commit message conventions, merge vs. rebase workflows, and resolving conflicts."
            
            # Run ollama with the system prompt
            run_ollama_prompt "$DEFAULT_MODEL" "$SYSTEM_PROMPT" ""
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            ;;
    esac
}

# Helper function to generate commit messages and commit changes
auto_commit() {
    echo -e "${BLUE}Generating commit message based on changes...${NC}"
    
    # Get diff of staged changes
    local diff_content=$(git diff --cached)
    
    # If no changes are staged, offer to stage all changes
    if [ -z "$diff_content" ]; then
        echo -e "${YELLOW}No changes are staged for commit.${NC}"
        read -p "Would you like to stage all changes first? (y/n): " stage_choice
        if [[ "$stage_choice" == "y" || "$stage_choice" == "Y" ]]; then
            git add -A
            diff_content=$(git diff --cached)
            if [ -z "$diff_content" ]; then
                echo -e "${RED}No changes to commit.${NC}"
                return 1
            fi
        else
            echo -e "${RED}No changes to commit.${NC}"
            return 1
        fi
    fi
    
    # Get file names that were changed
    local changed_files=$(git diff --cached --name-only | tr '\n' ' ')
    
    # System prompt for commit message generation
    SYSTEM_PROMPT="You are a Git commit message expert. Your task is to generate a concise, informative commit message following best practices:
    1. Use the imperative mood (e.g., 'Add feature' not 'Added feature')
    2. Keep the first line under 50 characters
    3. Provide more details in subsequent lines if necessary
    4. Reference issue numbers if applicable
    5. Focus on WHY the change was made, not just WHAT was changed
    
    The message should have a one-line summary, followed by a blank line, and then a more detailed explanation if needed."
    
    # User prompt with changed files and diff content
    USER_PROMPT="Please generate a commit message for the following changes:
    
Changed files: $changed_files
    
Diff content:
\`\`\`
${diff_content:0:2000}
\`\`\`
    
Generate only the commit message without any additional text or explanation."
    
    # Run ollama to generate the commit message using API
    echo -e "${YELLOW}Using AI to analyze changes and generate commit message...${NC}"
    
    if check_curl && check_ollama_api; then
        # Escape prompts for JSON
        local escaped_system_prompt=$(escape_for_json "$SYSTEM_PROMPT")
        local escaped_user_prompt=$(escape_for_json "$USER_PROMPT")
        
        # Use API to generate commit message
        local json_data=$(cat <<EOF
{
  "model": "$DEFAULT_MODEL",
  "messages": [
    {"role": "system", "content": "$escaped_system_prompt"},
    {"role": "user", "content": "$escaped_user_prompt"}
  ]
}
EOF
)
        
        if check_jq; then
            # Get complete response and extract just the content
            local response=$(curl -s "http://localhost:11434/api/chat" \
              -H "Content-Type: application/json" \
              -d "$json_data")
            
            # Handle potential errors
            if echo "$response" | jq -e 'has("error")' > /dev/null; then
                echo -e "${RED}Error from API: $(echo "$response" | jq -r '.error')${NC}"
                commit_message="Error generating commit message"
            else
                commit_message=$(echo "$response" | jq -r '.message.content' | tr -d '\n')
            fi
        else
            # Extract message content without jq (more basic)
            local response=$(curl -s "http://localhost:11434/api/chat" \
              -H "Content-Type: application/json" \
              -d "$json_data")
              
            # Check for error indicators
            if [[ "$response" == *"\"error\""* ]]; then
                echo -e "${RED}Error from API. Check that Ollama is running correctly.${NC}"
                commit_message="Error generating commit message"
            else
                commit_message=$(echo "$response" | grep -oP '(?<="content":")[^"]*' | sed -e 's/\\n/\n/g')
            fi
        fi
    else
        # Fall back to classic ollama run with combined prompt
        local combined_prompt="$SYSTEM_PROMPT

$USER_PROMPT"
        commit_message=$(ollama run $DEFAULT_MODEL "$combined_prompt")
    fi
    
    # Show generated message and offer to edit
    echo -e "${GREEN}Suggested commit message:${NC}"
    echo -e "${CYAN}$commit_message${NC}"
    echo ""
    
    read -p "Use this message? (y/n/e to edit): " use_message
    
    case $use_message in
        y|Y)
            # Use the message as is
            echo "$commit_message" > /tmp/commit_msg.tmp
            git commit -F /tmp/commit_msg.tmp
            rm /tmp/commit_msg.tmp
            echo -e "${GREEN}Changes committed successfully.${NC}"
            ;;
        e|E)
            # Edit the message
            echo "$commit_message" > /tmp/commit_msg.tmp
            ${EDITOR:-vim} /tmp/commit_msg.tmp
            git commit -F /tmp/commit_msg.tmp
            rm /tmp/commit_msg.tmp
            echo -e "${GREEN}Changes committed with edited message.${NC}"
            ;;
        *)
            # Don't commit
            echo -e "${YELLOW}Commit cancelled.${NC}"
            ;;
    esac
}

# Function to provide detailed help about the agent commands
cchelp() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}   DB-GPT Agent Commands Help   ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo ""
    echo -e "${GREEN}Overview:${NC}"
    echo -e "DB-GPT Agent Commands uses Ollama to provide specialized AI assistants for different tasks."
    echo -e "Each agent has a specific role and system prompt to help with a particular domain."
    echo ""
    echo -e "${GREEN}Available Commands:${NC}"
    echo -e "  ${YELLOW}$(basename "$0") code${NC}             ${BLUE}# Code Assistant${NC}"
    echo -e "     Get help with programming tasks, code reviews, and explanations."
    echo ""
    echo -e "  ${YELLOW}$(basename "$0") shell${NC}            ${BLUE}# Shell Helper${NC}"
    echo -e "     Get assistance with shell commands, scripting, and automation tasks."
    echo ""
    echo -e "  ${YELLOW}$(basename "$0") tasks${NC}            ${BLUE}# Task Manager${NC}"
    echo -e "     Organize and manage your development tasks and track progress."
    echo -e "     Uses $HOME/.dbgpt_tasks file to store your tasks."
    echo ""
    echo -e "  ${YELLOW}$(basename "$0") audit <file>${NC}     ${BLUE}# Code Auditor${NC}"
    echo -e "     Review code for security issues, performance bottlenecks, and quality concerns."
    echo ""
    echo -e "  ${YELLOW}$(basename "$0") git${NC}              ${BLUE}# Git Helper${NC}"
    echo -e "     Get assistance with git operations, including auto-commit message generation."
    echo ""
    echo -e "  ${YELLOW}$(basename "$0") decision${NC}         ${BLUE}# Decision Auditor${NC}"
    echo -e "     Analyze and critique implementation decisions or architectural choices."
    echo ""
    echo -e "${GREEN}Technical Details:${NC}"
    echo -e "- Uses Ollama API with system prompts (when available)"
    echo -e "- Currently using the $DEFAULT_MODEL model"
    echo -e "- Conversation history is maintained throughout each session"
    echo -e "- Type 'exit' or 'quit' to end a session"
    echo ""
    echo -e "${GREEN}Tips:${NC}"
    echo -e "1. Be specific with your questions to get better results"
    echo -e "2. For the Git helper, you can auto-generate commit messages"
    echo -e "3. The Task Manager allows editing tasks before starting a session"
    echo -e "4. For the Code Auditor, provide a full file path for analysis"
    echo ""
    echo -e "To modify the default model, edit the DEFAULT_MODEL variable in this script."
    echo -e "${CYAN}====================================${NC}"
}

# Check if Ollama is available
ensure_ollama_running() {
    # First check if ollama command is available
    if ! command -v ollama &> /dev/null; then
        echo -e "${RED}Error: Ollama is not installed or not in PATH.${NC}"
        echo -e "${YELLOW}Please install Ollama first: https://ollama.com/download${NC}"
        return 1
    fi
    
    # Check if Ollama service is running
    if ! check_ollama_api; then
        echo -e "${YELLOW}Attempting to start Ollama service...${NC}"
        ollama serve &> /dev/null &
        
        # Give it a moment to start
        echo -e "${YELLOW}Waiting for Ollama to start...${NC}"
        sleep 3
        
        # Check again
        if ! check_ollama_api; then
            echo -e "${RED}Failed to start Ollama service.${NC}"
            echo -e "${YELLOW}Please start it manually with 'ollama serve' command.${NC}"
            return 1
        else
            echo -e "${GREEN}Ollama service started successfully.${NC}"
        fi
    fi
    
    return 0
}

# Main function to handle command line arguments
main() {
    # Ensure Ollama is running before proceeding with any command
    case "$1" in
        "code")
            ensure_ollama_running && code_assistant
            ;;
        "shell")
            ensure_ollama_running && shell_helper
            ;;
        "tasks")
            ensure_ollama_running && task_manager
            ;;
        "audit")
            shift
            ensure_ollama_running && audit_code "$@"
            ;;
        "git")
            ensure_ollama_running && git_helper
            ;;
        "decision")
            ensure_ollama_running && decision_audit
            ;;
        "help")
            cchelp
            ;;
        *)
            echo -e "${CYAN}====================================${NC}"
            echo -e "${CYAN}   DB-GPT Agent Commands   ${NC}"
            echo -e "${CYAN}====================================${NC}"
            echo ""
            echo -e "Usage:"
            echo -e "  ${YELLOW}$(basename "$0") code${NC}             ${GREEN}# Get code assistance${NC}"
            echo -e "  ${YELLOW}$(basename "$0") shell${NC}            ${GREEN}# Get shell scripting help${NC}"
            echo -e "  ${YELLOW}$(basename "$0") tasks${NC}            ${GREEN}# Manage development tasks${NC}"
            echo -e "  ${YELLOW}$(basename "$0") audit <file>${NC}     ${GREEN}# Audit code in specified file${NC}"
            echo -e "  ${YELLOW}$(basename "$0") git${NC}              ${GREEN}# Git operations assistant${NC}"
            echo -e "  ${YELLOW}$(basename "$0") decision${NC}         ${GREEN}# Audit implementation decisions${NC}"
            echo -e "  ${YELLOW}$(basename "$0") help${NC}             ${GREEN}# Show detailed help information${NC}"
            echo ""
            echo -e "To modify the default model, edit this file and change the DEFAULT_MODEL variable."
            echo -e "For detailed help, use the 'help' command."
            echo -e "${CYAN}====================================${NC}"
            ;;
    esac
}

# Run main function with all arguments
main "$@"
