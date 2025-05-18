# filepath: /home/msalsouri/Projects/DB-GPT/docker/cc-ollama/install-ccgpt-final.sh
#!/bin/bash
# Final Installation Script for CodexContinue-GPT

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}====================================${NC}"
echo -e "${CYAN}  CodexContinue-GPT Final Installer ${NC}"
echo -e "${CYAN}====================================${NC}"
echo ""

# Check if container is running
if ! docker ps | grep -q "dbgpt-shell-agent"; then
    echo -e "${RED}Error: dbgpt-shell-agent container is not running${NC}"
    echo "Please start the container first with:"
    echo "docker-compose up -d dbgpt-shell-agent"
    exit 1
fi

echo -e "Installing final version of CodexContinue-GPT..."

# Copy the final script to the container
echo -e "\n${YELLOW}Copying final script to container...${NC}"
docker cp ccgpt-final.sh dbgpt-shell-agent:/app/agent/ccgpt.sh
docker exec -it dbgpt-shell-agent bash -c "chmod +x /app/agent/ccgpt.sh"

echo -e "${GREEN}✓ Final script copied successfully${NC}"

# Copy the help script to the container
echo -e "\n${YELLOW}Copying help script to container...${NC}"
docker cp ccgpt-help.sh dbgpt-shell-agent:/app/agent/ccgpt-help.sh
docker exec -it dbgpt-shell-agent bash -c "chmod +x /app/agent/ccgpt-help.sh"

echo -e "${GREEN}✓ Help script copied successfully${NC}"

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
    echo "alias cc-help=\"/app/agent/ccgpt-help.sh\"" >> ~/.bashrc
    source ~/.bashrc
fi
'

echo -e "${GREEN}✓ Command wrappers set up successfully${NC}"

# Copy documentation to appropriate location
echo -e "\n${YELLOW}Setting up documentation...${NC}"
if [ ! -d "/home/msalsouri/Projects/DB-GPT/docs/CodexContinueGPT" ]; then
    mkdir -p "/home/msalsouri/Projects/DB-GPT/docs/CodexContinueGPT"
fi
cp "/home/msalsouri/Projects/DB-GPT/docs/CodexContinueGPT.md" "/home/msalsouri/Projects/DB-GPT/docs/CodexContinueGPT/README.md"

echo -e "${GREEN}✓ Documentation set up successfully${NC}"

# Create system-wide aliases
echo -e "\n${YELLOW}Setting up system-wide aliases...${NC}"
if [ -f "/home/msalsouri/.bashrc" ]; then
    if ! grep -q "alias cc=" ~/.bashrc; then
        echo "" >> ~/.bashrc
        echo "# CodexContinue-GPT aliases" >> ~/.bashrc
        echo "alias cc='./launch-ccgpt.sh'" >> ~/.bashrc
        echo "alias ccgpt='./launch-ccgpt.sh'" >> ~/.bashrc
        source ~/.bashrc
        echo -e "${GREEN}✓ System aliases added to ~/.bashrc${NC}"
    else
        echo -e "${YELLOW}System aliases already exist in ~/.bashrc${NC}"
    fi
fi

# Verify installation
echo -e "\n${YELLOW}Verifying installation...${NC}"
./verify-ccgpt.sh

echo -e "\n${GREEN}Installation completed successfully!${NC}"
echo -e "${YELLOW}To use CodexContinue-GPT:${NC}"
echo "1. From the host machine:"
echo "   ./launch-ccgpt.sh"
echo ""
echo "2. Inside the container:"
echo "   cc --auto"
echo ""
echo "3. For usage guide:"
echo "   cc --guide"
echo ""
echo "4. To test without real Ollama API calls:"
echo "   cc --auto --test"
