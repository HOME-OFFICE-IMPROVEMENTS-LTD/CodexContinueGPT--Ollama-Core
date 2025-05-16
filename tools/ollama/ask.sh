#!/bin/bash
# CodexContinueGPT™ Advanced Ollama Query Tool
# This script provides an advanced interface for querying Ollama models

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default settings
DEFAULT_MODEL="codellama"
OLLAMA_API="http://localhost:11434"

# Script paths
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

# Help function
show_help() {
    echo -e "${GREEN}CodexContinueGPT™ Advanced Ollama Query Tool${NC}"
    echo -e "${CYAN}Usage:${NC}"
    echo -e "  ./ask.sh \"<your question>\""
    echo -e "  ./ask.sh --model MODEL_NAME \"<your question>\""
    echo -e "  ./ask.sh --list"
    echo -e "  ./ask.sh --help"
    echo ""
    echo -e "${CYAN}Examples:${NC}"
    echo -e "  ./ask.sh \"What is quantum computing?\""
    echo -e "  ./ask.sh --model llama3 \"Write a haiku about programming\""
    echo -e "  ./ask.sh --model codellama \"Generate a Python class for managing users\""
    echo ""
    echo -e "${CYAN}Available Models:${NC}"
    list_models
    exit 0
}

# Check if Ollama is installed and running
check_ollama() {
    if ! command -v ollama &> /dev/null; then
        echo -e "${RED}Error: ollama is not installed or not in PATH${NC}"
        echo "Please install ollama first: curl -fsSL https://ollama.com/install.sh | sh"
        exit 1
    fi

    if ! curl -s http://localhost:11434/api/version &> /dev/null; then
        echo -e "${YELLOW}Warning: Ollama server doesn't seem to be running${NC}"
        echo -e "Start it with: ${CYAN}ollama serve${NC} (or via systemctl if installed as a service)"
        read -p "Try to connect anyway? (y/n): " choice
        if [[ ! $choice =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# List available models
list_models() {
    echo -e "Querying available models from Ollama..."
    MODELS=$(curl -s "$OLLAMA_API/api/tags" | grep -o '"name":"[^"]*"' | grep -o '[^"]*$' | sort)
    
    if [ -z "$MODELS" ]; then
        echo -e "${YELLOW}No models found or unable to connect to Ollama.${NC}"
        echo -e "Make sure Ollama is running with: ${CYAN}ollama serve${NC}"
        return
    fi
    
    echo -e "${GREEN}Available models:${NC}"
    echo "$MODELS" | while read model; do
        echo -e "  ${CYAN}$model${NC}"
    done
}

# Main function
main() {
    check_ollama
    
    # Parse command line arguments
    MODEL="$DEFAULT_MODEL"
    QUESTION=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --model|-m)
                MODEL="$2"
                shift 2
                ;;
            --list|-l)
                list_models
                exit 0
                ;;
            --help|-h)
                show_help
                ;;
            *)
                if [ -z "$QUESTION" ]; then
                    QUESTION="$1"
                else
                    QUESTION="$QUESTION $1"
                fi
                shift
                ;;
        esac
    done
    
    # If no question provided, show help
    if [ -z "$QUESTION" ]; then
        show_help
    fi
    
    # Run the query
    echo -e "${GREEN}Asking $MODEL:${NC} $QUESTION"
    echo -e "${YELLOW}=== Response ===${NC}"
    
    # Use ollama to run the model
    ollama run $MODEL "$QUESTION"
    
    echo -e "${YELLOW}=== End of Response ===${NC}"
}

# Execute main function with all arguments
main "$@"
