# filepath: /home/msalsouri/Projects/DB-GPT/docker/cc-ollama/verify-ccgpt.sh
#!/bin/bash
# Verify CodexContinue-GPT installation

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}====================================${NC}"
echo -e "${CYAN}CodexContinue-GPT Verification Test ${NC}"
echo -e "${CYAN}====================================${NC}"
echo ""

# Check if container is running
if ! docker ps | grep -q "dbgpt-shell-agent"; then
    echo -e "${RED}Error: dbgpt-shell-agent container is not running${NC}"
    echo "Please start the container first with:"
    echo "docker-compose up -d dbgpt-shell-agent"
    exit 1
fi

echo -e "Verifying installation in container..."

# Check if files exist and have content
echo -e "\nChecking if script files exist:"
docker exec -it dbgpt-shell-agent bash -c "
if [ -f /app/agent/ccgpt.sh ] && [ -s /app/agent/ccgpt.sh ]; then
    echo -e '${GREEN}✓ Main script exists and has content${NC}'
else
    echo -e '${RED}✗ Main script is missing or empty${NC}'
fi

if [ -f /usr/local/bin/ccgpt ] && [ -s /usr/local/bin/ccgpt ]; then
    echo -e '${GREEN}✓ ccgpt command exists${NC}'
else
    echo -e '${RED}✗ ccgpt command is missing${NC}'
fi

if [ -f /usr/local/bin/cc ] && [ -s /usr/local/bin/cc ]; then
    echo -e '${GREEN}✓ cc command exists${NC}'
else
    echo -e '${RED}✗ cc command is missing${NC}'
fi
"

# Check if the script can run
echo -e "\nTesting basic functionality:"
docker exec -it dbgpt-shell-agent bash -c "
echo -e 'Testing main script (help command):'
/app/agent/ccgpt.sh --help 2>/dev/null | head -n 3 || echo '${RED}Failed to run main script${NC}'

echo -e '\nTesting cc command:'
cc --version 2>/dev/null || echo '${RED}Failed to run cc command${NC}'

echo -e '\nTesting ccgpt command:'
ccgpt --version 2>/dev/null || echo '${RED}Failed to run ccgpt command${NC}'
"

echo -e "\nVerifying configuration:"
docker exec -it dbgpt-shell-agent bash -c "
# Check if model variables are defined in the script
if grep -q 'CODE_MODEL=' /app/agent/ccgpt.sh && grep -q 'TASK_MODEL=' /app/agent/ccgpt.sh && grep -q 'GENERAL_MODEL=' /app/agent/ccgpt.sh; then
    echo -e '${GREEN}✓ Auto-model selection variables are configured${NC}'
else
    echo -e '${RED}✗ Auto-model selection variables missing${NC}'
fi

# Check if auto-select function exists
if grep -q 'select_model_for_input' /app/agent/ccgpt.sh; then
    echo -e '${GREEN}✓ Model selection function exists${NC}'
else
    echo -e '${RED}✗ Model selection function missing${NC}'
fi
"
echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Connect to the container with:"
echo "   docker exec -it dbgpt-shell-agent bash"
echo ""
echo "2. Run CodexContinue-GPT with auto-model selection:"
echo "   cc --auto"
echo ""
echo "3. Test model selection with different queries:"
echo "   - Code: \"Write a function to sort an array in JavaScript\""
echo "   - Task: \"Create a todo list for my project\""
echo "   - General: \"Tell me about artificial intelligence\""
echo ""
echo "4. If you encounter any issues, check the error messages or"
echo "   run the full installer again with:"
echo "   ./install-ccgpt-full.sh"
