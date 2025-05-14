#!/bin/bash
# CodexContinueGPT™ Shell Helper Script
# Uses Ollama with CodeLlama for powerful shell guidance

# Set the model to use
MODEL="codellama"

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Help function
show_help() {
    echo -e "${GREEN}CodexContinueGPT™ Shell Helper${NC}"
    echo -e "${CYAN}Usage:${NC}"
    echo -e "  ./shell_helper.sh \"<your shell question or task>\""
    echo -e "  ./shell_helper.sh --explain \"<shell command>\""
    echo -e "  ./shell_helper.sh --script \"<script description>\""
    echo ""
    echo -e "${CYAN}Examples:${NC}"
    echo -e "  ./shell_helper.sh \"How to find large files in Linux?\""
    echo -e "  ./shell_helper.sh --explain \"find / -type f -size +100M -exec ls -lh {} \\;\""
    echo -e "  ./shell_helper.sh --script \"backup all MySQL databases and compress them\""
    exit 0
}

# Check if Ollama is installed and the model is available
check_ollama() {
    if ! command -v ollama &> /dev/null; then
        echo -e "${YELLOW}Error: ollama is not installed or not in PATH${NC}"
        echo "Please install ollama first: curl -fsSL https://ollama.com/install.sh | sh"
        exit 1
    fi

    if ! ollama list | grep -q "$MODEL"; then
        echo -e "${YELLOW}Error: Model '$MODEL' is not available in ollama${NC}"
        echo "Please pull the model first: ollama pull $MODEL"
        exit 1
    fi
}

# Main function for shell questions
shell_question() {
    echo -e "${GREEN}Asking ${MODEL} about:${NC} $1"
    echo -e "${CYAN}Thinking...${NC}"
    ollama run $MODEL "$1"
}

# Function to explain a shell command
explain_command() {
    echo -e "${GREEN}Explaining command with ${MODEL}:${NC} $1"
    echo -e "${CYAN}Analyzing...${NC}"
    ollama run $MODEL "Explain in detail what this shell command does: $1"
}

# Function to generate a shell script
generate_script() {
    echo -e "${GREEN}Generating shell script with ${MODEL}:${NC} $1"
    echo -e "${CYAN}Creating script...${NC}"
    ollama run $MODEL "Create a detailed and well-commented bash script that $1. Include proper error handling and usage examples."
}

# Check if Ollama and model are available
check_ollama

# Process command line arguments
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    show_help
elif [ "$1" == "--explain" ] && [ -n "$2" ]; then
    explain_command "$2"
elif [ "$1" == "--script" ] && [ -n "$2" ]; then
    generate_script "$2"
elif [ -n "$1" ]; then
    shell_question "$1"
else
    show_help
fi
