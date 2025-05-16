#!/bin/bash
# On-Demand Shell Assistant
# This script provides a natural language interface to help users discover and use aliases

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODEL_NAME="codellama" # Use a larger model for better NLP capability
HISTORY_FILE="$PROJECT_ROOT/.shell_assistant_history"
ALIAS_CHEATSHEET="$PROJECT_ROOT/alias-cheatsheet.md"

# Create history file if it doesn't exist
touch "$HISTORY_FILE"

# Function to display help information
show_help() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}     DB-GPT Shell Assistant     ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "  $0 [options]"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  --chat            Interactive chat mode (default)"
    echo -e "  --help            Show this help message"
    echo -e "  --question \"text\" Ask a specific question directly"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  $0                                  Start interactive chat"
    echo -e "  $0 --question \"How do I use git?\"   Ask directly about git aliases"
    echo -e "  $0 --question \"What aliases help manage Ollama models?\"   Ask about model management"
    echo ""
    echo -e "${YELLOW}Tips for asking questions:${NC}"
    echo -e "  • Ask naturally: \"How do I work with git in this project?\""
    echo -e "  • Ask for examples: \"Show me examples of using Ollama models\""
    echo -e "  • Ask for specific tasks: \"What's the alias for pulling code?\""
    echo -e ""
    echo -e "${CYAN}====================================${NC}"
}

# Function to start interaction
start_assistant() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}   DB-GPT Shell Assistant - Chat   ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo -e "${YELLOW}Ask any question about aliases or how to perform tasks.${NC}"
    echo -e "${YELLOW}Type 'exit' to quit, 'help' for assistance.${NC}"
    echo ""
    
    # Read the alias cheatsheet
    if [ -f "$ALIAS_CHEATSHEET" ]; then
        ALIAS_CONTENT=$(cat "$ALIAS_CHEATSHEET")
    else
        echo -e "${RED}Warning: Alias cheatsheet not found at $ALIAS_CHEATSHEET${NC}"
        ALIAS_CONTENT="Alias cheatsheet not found."
    fi

    # Start conversation loop
    while true; do
        echo -e "${BOLD}${BLUE}You:${NC} " 
        read -r user_input
        
        # Check for exit command
        if [[ "$user_input" == "exit" || "$user_input" == "quit" ]]; then
            echo -e "${GREEN}Goodbye!${NC}"
            break
        fi
        
        # Check for help command
        if [[ "$user_input" == "help" ]]; then
            show_help
            continue
        fi
        
        # Log question to history
        echo "$(date): $user_input" >> "$HISTORY_FILE"
        
        # Process the question with Ollama
        echo -e "\n${BOLD}${CYAN}Assistant:${NC}"
        ollama run $MODEL_NAME "
You are a helpful shell assistant for the DB-GPT project. Your primary job is to help users discover and understand the aliases available in the project. Always prioritize teaching about relevant aliases when answering questions.

When someone asks how to do something, recommend the appropriate alias from the cheatsheet below, explain what it does, and provide an example of how to use it. If multiple aliases are relevant, mention all of them with brief explanations.

If someone asks a general question about a topic, provide relevant aliases from that category. Always be concise and practical in your responses.

Here's the current alias cheatsheet for the project:

$ALIAS_CONTENT

Now, please answer this question in a helpful, practical way:
$user_input
"
        echo -e "\n${CYAN}-----------------------------------${NC}\n"
    done
}

# Function to ask a specific question
ask_question() {
    local question=$1
    
    # Read the alias cheatsheet
    if [ -f "$ALIAS_CHEATSHEET" ]; then
        ALIAS_CONTENT=$(cat "$ALIAS_CHEATSHEET")
    else
        echo -e "${RED}Warning: Alias cheatsheet not found at $ALIAS_CHEATSHEET${NC}"
        ALIAS_CONTENT="Alias cheatsheet not found."
    fi
    
    # Log question to history
    echo "$(date): $question" >> "$HISTORY_FILE"
    
    # Process the question with Ollama
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}   DB-GPT Shell Assistant - Answer  ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo -e "${BLUE}Question:${NC} $question"
    echo -e "\n${BOLD}${CYAN}Assistant:${NC}"
    
    ollama run $MODEL_NAME "
You are a helpful shell assistant for the DB-GPT project. Your primary job is to help users discover and understand the aliases available in the project. Always prioritize teaching about relevant aliases when answering questions.

When someone asks how to do something, recommend the appropriate alias from the cheatsheet below, explain what it does, and provide an example of how to use it. If multiple aliases are relevant, mention all of them with brief explanations.

If someone asks a general question about a topic, provide relevant aliases from that category. Always be concise and practical in your responses.

Here's the current alias cheatsheet for the project:

$ALIAS_CONTENT

Now, please answer this question in a helpful, practical way:
$question
"
}

# Parse command line arguments
MODE="chat"
QUESTION=""

if [ "$#" -gt 0 ]; then
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        --chat)
            MODE="chat"
            ;;
        --question)
            if [ -z "$2" ]; then
                echo -e "${RED}Error: No question provided${NC}"
                show_help
                exit 1
            fi
            MODE="question"
            QUESTION="$2"
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}"
            show_help
            exit 1
            ;;
    esac
fi

# Check if Ollama is installed
if ! command -v ollama &> /dev/null; then
    echo -e "${RED}Error: Ollama is not installed or not in PATH${NC}"
    echo -e "Please install Ollama from https://ollama.ai/ first"
    exit 1
fi

# Run the selected mode
case "$MODE" in
    chat)
        start_assistant
        ;;
    question)
        ask_question "$QUESTION"
        ;;
esac
