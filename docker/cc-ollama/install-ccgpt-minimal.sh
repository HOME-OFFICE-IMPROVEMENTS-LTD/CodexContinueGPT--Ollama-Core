# filepath: /home/msalsouri/Projects/DB-GPT/docker/cc-ollama/install-ccgpt-minimal.sh
#!/bin/bash
# CodexContinue-GPT - Minimal Installation Script

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}====================================${NC}"
echo -e "${CYAN}    CodexContinue-GPT Installer     ${NC}"
echo -e "${CYAN}====================================${NC}"
echo ""

# Check if container is running
if ! docker ps | grep -q "dbgpt-shell-agent"; then
    echo -e "${RED}Error: dbgpt-shell-agent container is not running${NC}"
    exit 1
fi

# Create the script directly
echo -e "Creating CodexContinue-GPT script..."
cat > /tmp/ccgpt.sh << 'EOF'
#!/bin/bash
# CodexContinue-GPT - Auto Model Selection Shell Agent

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
BASE_MODEL="codellama"
CODE_MODEL="codellama"
TASK_MODEL="mistral"
GENERAL_MODEL="llama3"
AUTO_SELECT=false

echo -e "${CYAN}=====================================${NC}"
echo -e "${CYAN}     CodexContinue-GPT v1.0         ${NC}"
echo -e "${CYAN}=====================================${NC}"

# Process command line options
for arg in "$@"; do
  if [[ "$arg" == "--auto" ]]; then
    AUTO_SELECT=true
    echo -e "${GREEN}Auto model selection enabled${NC}"
  elif [[ "$arg" == "--help" ]]; then
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "  ccgpt [options]"
    echo -e "  cc [options]"
    echo -e ""
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  --auto    Enable auto model selection"
    echo -e "  --help    Show this help message"
    exit 0
  fi
done

# Function to select the best model
select_model() {
  local input="$1"
  local input_lower=$(echo "$input" | tr "[:upper:]" "[:lower:]")
  
  if [[ "$input_lower" =~ (code|function|class|bug|error) ]]; then
    echo "$CODE_MODEL"
  elif [[ "$input_lower" =~ (task|todo|priority|plan) ]]; then
    echo "$TASK_MODEL"
  else
    echo "$GENERAL_MODEL"
  fi
}

# Interactive chat
echo -e "Type your questions or commands. Use ${YELLOW}exit${NC} to quit."
if [ "$AUTO_SELECT" = true ]; then
  echo -e "Auto-Model Selection: ON"
  echo -e "  • ${YELLOW}$CODE_MODEL${NC}: Code-related queries"
  echo -e "  • ${YELLOW}$TASK_MODEL${NC}: Task management"
  echo -e "  • ${YELLOW}$GENERAL_MODEL${NC}: General conversation"
else
  echo -e "Using model: ${YELLOW}$BASE_MODEL${NC}"
fi

while true; do
  echo -e "${YELLOW}>>>${NC} "
  read -r user_input
  
  if [[ "$user_input" == "exit" ]]; then
    echo -e "Exiting CodexContinue-GPT. Goodbye!"
    break
  fi
  
  # Select model
  if [ "$AUTO_SELECT" = true ]; then
    model=$(select_model "$user_input")
    echo -e "${BLUE}Using model:${NC} ${YELLOW}$model${NC}"
  else
    model="$BASE_MODEL"
  fi
  
  # Process with Ollama
  if command -v ollama &> /dev/null; then
    response=$(echo "$user_input" | ollama run $model 2>&1)
    echo "$response"
  else
    echo -e "${RED}Ollama not found. This is a model selection demo only.${NC}"
    echo -e "The query would be processed with: $model"
  fi
done
EOF
chmod +x /tmp/ccgpt.sh

# Copy to container and create command wrappers
echo -e "Installing in container..."
docker cp /tmp/ccgpt.sh dbgpt-shell-agent:/app/agent/ccgpt.sh
docker exec -it dbgpt-shell-agent bash -c "
chmod +x /app/agent/ccgpt.sh

# Create command wrappers
echo '#!/bin/bash
exec /app/agent/ccgpt.sh \"\$@\"' > /usr/local/bin/cc
chmod +x /usr/local/bin/cc

echo '#!/bin/bash
exec /app/agent/ccgpt.sh \"\$@\"' > /usr/local/bin/ccgpt
chmod +x /usr/local/bin/ccgpt

# Add aliases to bashrc
grep -q 'alias cc=' ~/.bashrc || echo '
# CodexContinue-GPT aliases
alias ccgpt=\"/app/agent/ccgpt.sh\"
alias cc=\"ccgpt\"
' >> ~/.bashrc
"

echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo -e "To use CodexContinue-GPT:"
echo -e "1. Connect to the container:"
echo -e "   ${YELLOW}docker exec -it dbgpt-shell-agent bash${NC}"
echo -e ""
echo -e "2. Run with auto-model selection:"
echo -e "   ${YELLOW}cc --auto${NC}"
echo -e ""
echo -e "The script will automatically select the best model:"
echo -e "• codellama: for code-related queries"
echo -e "• mistral: for task management"
echo -e "• llama3: for general conversation"
