# filepath: /home/msalsouri/Projects/DB-GPT/docker/cc-ollama/install-ccgpt-enhanced.sh
#!/bin/bash
# Install enhanced CodexContinue-GPT with auto-model selection

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}====================================${NC}"
echo -e "${CYAN}CodexContinue-GPT Enhanced Installer ${NC}"
echo -e "${CYAN}====================================${NC}"
echo ""

# Check if container is running
if ! docker ps | grep -q "dbgpt-shell-agent"; then
    echo -e "${RED}Error: dbgpt-shell-agent container is not running${NC}"
    echo "Please start the container first with:"
    echo "docker-compose up -d dbgpt-shell-agent"
    exit 1
fi

echo -e "Installing enhanced version of CodexContinue-GPT..."

# Copy the enhanced script to the container
echo -e "\n${YELLOW}Copying enhanced script to container...${NC}"
docker cp ccgpt-enhanced.sh dbgpt-shell-agent:/app/agent/ccgpt.sh
docker exec -it dbgpt-shell-agent bash -c "chmod +x /app/agent/ccgpt.sh"

echo -e "${GREEN}✓ Enhanced script copied successfully${NC}"

# Create/update command wrappers
echo -e "\n${YELLOW}Setting up command wrappers...${NC}"
docker exec -it dbgpt-shell-agent bash -c '
# Create ccgpt command
cat > /usr/local/bin/ccgpt << EOF
#!/bin/bash
exec /app/agent/ccgpt.sh "\$@"
EOF
chmod +x /usr/local/bin/ccgpt

# Create cc command (shorter alias)
cat > /usr/local/bin/cc << EOF
#!/bin/bash
exec /app/agent/ccgpt.sh "\$@"
EOF
chmod +x /usr/local/bin/cc

# Add to .bashrc if not already there
if ! grep -q "alias cc=" ~/.bashrc; then
    echo "alias cc=\"/app/agent/ccgpt.sh\"" >> ~/.bashrc
    echo "alias ccgpt=\"/app/agent/ccgpt.sh\"" >> ~/.bashrc
    source ~/.bashrc
fi
'

echo -e "${GREEN}✓ Command wrappers set up successfully${NC}"

# Verify installation
echo -e "\n${YELLOW}Verifying installation...${NC}"
./verify-ccgpt.sh

echo -e "\n${GREEN}Installation completed successfully!${NC}"
echo -e "${YELLOW}To use CodexContinue-GPT:${NC}"
echo "1. Connect to the container with:"
echo "   docker exec -it dbgpt-shell-agent bash"
echo ""
echo "2. Run with auto-model selection:"
echo "   cc --auto"
echo ""
echo "3. Or specify a model manually:"
echo "   cc --model codellama"
echo "   cc --model mistral"
echo "   cc --model llama3"
