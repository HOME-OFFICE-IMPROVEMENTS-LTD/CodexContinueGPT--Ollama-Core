# filepath: /home/msalsouri/Projects/DB-GPT/docker/cc-ollama/install-codexcontinue-gpt.sh
#!/bin/bash
# Installation script for CodexContinue-GPT

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}====================================${NC}"
echo -e "${CYAN}   CodexContinue-GPT Installer      ${NC}"
echo -e "${CYAN}====================================${NC}"
echo ""

# Check if container is running
if ! docker ps | grep -q "dbgpt-shell-agent"; then
    echo -e "${RED}Error: dbgpt-shell-agent container is not running${NC}"
    echo "Please start the container first with:"
    echo "docker-compose up -d dbgpt-shell-agent"
    exit 1
fi

echo -e "${YELLOW}Installing CodexContinue-GPT to container...${NC}"

# Copy files to container
echo -e "Copying script files..."
docker cp /home/msalsouri/Projects/DB-GPT/docker/cc-ollama/direct-shell-agent.sh dbgpt-shell-agent:/app/agent/codexcontinue-gpt.sh
docker cp /home/msalsouri/Projects/DB-GPT/docker/cc-ollama/ccgpt dbgpt-shell-agent:/usr/local/bin/ccgpt

# Make the scripts executable
echo -e "Setting permissions..."
docker exec -it dbgpt-shell-agent bash -c "chmod +x /app/agent/codexcontinue-gpt.sh /usr/local/bin/ccgpt"

# Create script that updates container's PATH variable
echo -e "Setting up PATH and aliases..."
docker exec -it dbgpt-shell-agent bash -c "cat > /app/agent/setup-codexcontinue.sh << 'EOF'
#!/bin/bash
# Source this file to set up CodexContinue-GPT environment

# Add alias for ccgpt
alias ccgpt='/app/agent/codexcontinue-gpt.sh'
alias cc='/usr/local/bin/ccgpt'

echo 'CodexContinue-GPT environment is ready!'
echo 'You can now use the commands: ccgpt or cc'
EOF"

# Make setup script executable
docker exec -it dbgpt-shell-agent bash -c "chmod +x /app/agent/setup-codexcontinue.sh"

# Add sourcing to container's .bashrc
docker exec -it dbgpt-shell-agent bash -c "echo 'source /app/agent/setup-codexcontinue.sh' >> ~/.bashrc"

echo -e "${GREEN}Installation completed!${NC}"
echo ""
echo -e "To use CodexContinue-GPT, reconnect to the container with:"
echo -e "${YELLOW}docker exec -it dbgpt-shell-agent bash${NC}"
echo ""
echo -e "Then you can run CodexContinue-GPT using:"
echo -e "  ${CYAN}ccgpt${NC} - Full command"
echo -e "  ${CYAN}cc${NC} - Short command"
echo ""
echo -e "For example:"
echo -e "  ${CYAN}cc --auto${NC} - Start in auto-model selection mode"
echo -e "  ${CYAN}cc --audit /path/to/file.py${NC} - Audit a code file"
