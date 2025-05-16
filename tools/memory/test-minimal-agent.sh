#!/bin/bash
# filepath: /home/msalsouri/Projects/DB-GPT/test-minimal-agent.sh
# This script provides a minimal shell agent with very low memory usage

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default model
MODEL="minimal-shell-agent"

# Function to display help
show_help() {
    echo -e "${BOLD}Minimal Shell Agent - Basic Assistant for Low Memory Systems${NC}"
    echo ""
    echo -e "Usage: ${CYAN}$(basename "$0") [OPTIONS]${NC}"
    echo ""
    echo "OPTIONS:"
    echo -e "  ${GREEN}-h, --help${NC}             Show this help message"
    echo -e "  ${GREEN}-m, --model MODEL${NC}      Use a different model (default: minimal-shell-agent)"
    echo -e "  ${GREEN}-b, --build${NC}            Build/rebuild the model before starting"
    echo ""
}

# Function to build the model
build_model() {
    echo -e "\n${YELLOW}Building Minimal Shell Agent model...${NC}"
    
    # Check if ollama is installed
    if ! command -v ollama &> /dev/null; then
        echo -e "${RED}Error: Ollama is not installed or not in your PATH.${NC}"
        echo -e "${YELLOW}Please install Ollama first: https://ollama.ai/download${NC}"
        exit 1
    fi
    
    # Create a minimal Modelfile if it doesn't exist
    if [ ! -f "$PROJECT_ROOT/minimal-shell-agent.Modelfile" ]; then
        echo -e "${YELLOW}Creating minimal Modelfile...${NC}"
        cat > "$PROJECT_ROOT/minimal-shell-agent.Modelfile" << 'EOF'
FROM llama3:8b

SYSTEM """
You are a helpful shell assistant. Your primary role is to:
1. Provide brief, accurate information about shell commands
2. Explain how to use common aliases and tools
3. Give simple examples of command usage

Keep your responses short and focused on essential information.
"""

PARAMETER temperature 0.7
PARAMETER num_ctx 2048
PARAMETER stop "Human:"
PARAMETER stop "<|start_header_id|>"
EOF
        echo -e "${GREEN}Created minimal Modelfile.${NC}"
    fi
    
    # Build the model
    echo -e "${YELLOW}Building model with Ollama...${NC}"
    if ! ollama create "$MODEL" -f "$PROJECT_ROOT/minimal-shell-agent.Modelfile"; then
        echo -e "${RED}Error: Failed to build the model.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Model built successfully!${NC}"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -m|--model)
            MODEL="$2"
            shift 2
            ;;
        -b|--build)
            BUILD=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Build the model if requested
if [ "$BUILD" = true ]; then
    build_model
fi

# Check if the model exists
if ! ollama list | grep -q "$MODEL"; then
    echo -e "${YELLOW}Model $MODEL not found. Building it now...${NC}"
    build_model
fi

# Verify the model works properly
echo -e "${YELLOW}Testing the model...${NC}"
if ! (echo "Test" | ollama run "$MODEL" "Reply with one word: Working" | grep -q "Working"); then
    echo -e "${RED}Error: The model doesn't seem to be working properly.${NC}"
    echo -e "${YELLOW}Attempting to rebuild the model...${NC}"
    build_model
    
    # Test again after rebuilding
    if ! (echo "Test" | ollama run "$MODEL" "Reply with one word: Working" | grep -q "Working"); then
        echo -e "${RED}Error: Model still not working after rebuild. Please check the Ollama installation.${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}Model is working properly!${NC}"

# Start the minimal shell agent
echo -e "${BOLD}${CYAN}Minimal Shell Agent${NC} - ${GREEN}Basic command assistant${NC}"
echo -e "${YELLOW}Type 'exit' or 'quit' to end the session${NC}"
echo -e "${YELLOW}Type 'help' for assistance${NC}"
echo ""

# Start the conversation loop
while true; do
    # Display prompt and get user input
    echo -e "${GREEN}You:${NC} " 
    read -r user_input
    
    # Check for exit command
    if [[ "$user_input" =~ ^(exit|quit)$ ]]; then
        echo -e "${YELLOW}Goodbye!${NC}"
        break
    fi
    
    # Process user input and get response from ollama
    echo -e "\n${BLUE}Minimal Agent:${NC}"
    ollama run "$MODEL" "$user_input"
    echo ""
done

exit 0
