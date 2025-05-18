# filepath: /home/msalsouri/Projects/DB-GPT/docker/cc-ollama/ccgpt-help.sh
#!/bin/bash
# Display quick usage guide for CodexContinue-GPT

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}=====================================${NC}"
echo -e "${CYAN}  CodexContinue-GPT - Quick Guide    ${NC}"
echo -e "${CYAN}=====================================${NC}"
echo ""
echo -e "${YELLOW}Basic Commands:${NC}"
echo -e "  ${GREEN}cc${NC}               - Run with default model (codellama)"
echo -e "  ${GREEN}cc --auto${NC}        - Enable auto-model selection"
echo -e "  ${GREEN}cc --model mistral${NC} - Run with specific model"
echo -e "  ${GREEN}cc --help${NC}        - Show help information"
echo ""
echo -e "${YELLOW}Direct Queries:${NC}"
echo -e "  ${GREEN}cc --auto \"query text\"${NC} - Process query directly (non-interactive)"
echo -e "  ${GREEN}cc --test \"query text\"${NC} - Test mode with direct query"
echo ""
echo -e "${YELLOW}Auto-Selection Keywords:${NC}"
echo -e "  ${GREEN}Code Model (codellama):${NC}"
echo -e "    - code, function, class, bug, error, variable, algorithm..."
echo ""
echo -e "  ${GREEN}Task Model (mistral):${NC}"
echo -e "    - task, todo, priority, deadline, project, schedule..."
echo ""
echo -e "  ${GREEN}General Model (llama3):${NC}"
echo -e "    - Any other conversation topic"
echo ""
echo -e "${YELLOW}Examples:${NC}"
echo -e "  \"Write a function to sort an array in JavaScript\" → codellama"
echo -e "  \"Create a todo list for my project\" → mistral"
echo -e "  \"Tell me about artificial intelligence\" → llama3"
echo ""
echo -e "${YELLOW}For more details:${NC}"
echo -e "  See the full documentation at: ${GREEN}docs/CodexContinueGPT.md${NC}"
