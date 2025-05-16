#!/bin/bash
# DB-GPT Shell Agent Builder
# This script builds a custom Ollama model for shell operations and code auditing

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m' # No Color

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODELFILE="$PROJECT_ROOT/shell-agent.Modelfile"
MODEL_NAME="codex-shell-agent"

echo -e "${CYAN}====================================${NC}"
echo -e "${CYAN}      DB-GPT Shell Agent Builder    ${NC}"
echo -e "${CYAN}====================================${NC}"
echo ""

# Check if Ollama is installed and running
if ! command -v ollama &> /dev/null; then
    echo -e "${RED}Error: Ollama is not installed or not in PATH${NC}"
    echo -e "Please install Ollama from https://ollama.ai/ first"
    exit 1
fi

# Check if Ollama service is running
if ! pgrep -x "ollama" > /dev/null; then
    echo -e "${YELLOW}Ollama service is not running. Starting it...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        open -a Ollama
    else
        # Linux
        ollama serve &
        sleep 5
    fi
fi

# Check if codellama base model is available
echo -e "${BLUE}Checking if codellama base model is available...${NC}"
if ! ollama list | grep -q "codellama"; then
    echo -e "${YELLOW}Base model codellama not found. Pulling it now...${NC}"
    ollama pull codellama
fi

# Check if the Modelfile exists
if [ ! -f "$MODELFILE" ]; then
    echo -e "${RED}Error: Modelfile not found at $MODELFILE${NC}"
    exit 1
fi

# Build the custom model
echo -e "${GREEN}Building custom shell agent model...${NC}"
echo -e "${BLUE}This may take a few minutes depending on your system...${NC}"
ollama create $MODEL_NAME -f "$MODELFILE"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Successfully built custom model: $MODEL_NAME${NC}"
    echo ""
    echo -e "${CYAN}You can now use your shell agent with:${NC}"
    echo -e "${YELLOW}ollama run $MODEL_NAME${NC}"
    
    # Add a convenient alias
    echo ""
    echo -e "${CYAN}Adding convenience alias to your .aliases file...${NC}"
    
    # Add alias to .aliases file if it doesn't already exist
    if ! grep -q "shell-agent=" "$PROJECT_ROOT/.aliases"; then
        echo "" >> "$PROJECT_ROOT/.aliases"
        echo "# Shell agent alias" >> "$PROJECT_ROOT/.aliases"
        echo "alias shell-agent=\"ollama run $MODEL_NAME\"" >> "$PROJECT_ROOT/.aliases"
        echo "alias code-audit=\"ollama run $MODEL_NAME --template code_audit\"" >> "$PROJECT_ROOT/.aliases"
        echo "alias task-track=\"ollama run $MODEL_NAME --template task_tracking\"" >> "$PROJECT_ROOT/.aliases"
        echo -e "${GREEN}Aliases added. Use 'source .aliases' to load them.${NC}"
    else
        echo -e "${BLUE}Alias already exists in .aliases file.${NC}"
    fi
else
    echo -e "${RED}Failed to build custom model.${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}====================================${NC}"
echo -e "${MAGENTA}Shell Agent Capabilities:${NC}"
echo ""
echo -e "${GREEN}1. Code Auditing${NC} - Review and improve your code"
echo -e "${GREEN}2. Best Practices${NC} - Get guidance on development standards"
echo -e "${GREEN}3. Task Management${NC} - Track your development goals"
echo -e "${GREEN}4. Environment Setup${NC} - Configure your working environment"
echo ""
echo -e "${CYAN}====================================${NC}"
