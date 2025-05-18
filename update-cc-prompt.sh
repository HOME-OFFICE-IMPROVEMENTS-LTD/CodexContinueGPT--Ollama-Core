#!/bin/bash
# update-cc-prompt.sh - Updates CodexContinueGPT system prompt in the Docker container

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if container is running
if ! docker ps | grep -q "dbgpt-shell-agent"; then
    echo -e "${RED}Error: dbgpt-shell-agent container is not running${NC}"
    echo "Please start the container first."
    exit 1
fi

echo -e "${CYAN}Updating CodexContinueGPT system prompt in container...${NC}"

# Create a temporary file with the system prompt content
cat > /tmp/cc_system_prompt.txt << 'EOF'
You are CodexContinueGPT, a custom implementation built by Home & Office Improvements Ltd. on Ollama models (codellama, mistral, llama3) for the DB-GPT project. You were architected by msalsouri. You assist with code generation, task management, and answering questions about the project. 

You are aware of the file organization plan that includes:
1. Reorganizing Ollama documentation files from root to /docs/ollama/
2. Moving CC-GPT related scripts from root to /docker/cc-ollama/
3. Creating a standardized structure for easier maintenance

Your capabilities include direct query support (non-interactive usage), interactive mode, and auto-model selection based on query content. You are integrated with cc-advisor.sh which allows consulting you before file operations.

When asked about your capabilities, explain that you are a custom interface to Ollama models created specifically for the DB-GPT project by Home & Office Improvements Ltd., with msalsouri as the architect.
EOF

# Copy the system prompt to a location in the container
docker cp /tmp/cc_system_prompt.txt dbgpt-shell-agent:/tmp/cc_system_prompt.txt

# Create a script to add the system prompt to all CC scripts in the container
cat > /tmp/update_cc_scripts.sh << 'EOF'
#!/bin/bash

# Find all ccgpt scripts that use ollama run
find /app/agent -name "ccgpt*.sh" -type f -exec grep -l "ollama run" {} \; | while read script; do
    echo "Updating $script..."
    
    # Check if script already has SYSTEM_PROMPT
    if grep -q "SYSTEM_PROMPT=" "$script"; then
        echo "Script already has SYSTEM_PROMPT, updating..."
        # Replace existing SYSTEM_PROMPT with new one
        sed -i '/SYSTEM_PROMPT=/,/[^"]*"$/c\SYSTEM_PROMPT="$(cat /tmp/cc_system_prompt.txt)"' "$script"
    else
        echo "Adding SYSTEM_PROMPT to $script..."
        # Add SYSTEM_PROMPT after model configuration
        sed -i '/^# Model configuration/,/USE_REAL_OLLAMA=/a\\n# System prompt to provide context to the model\nSYSTEM_PROMPT="$(cat /tmp/cc_system_prompt.txt)"' "$script"
    fi
    
    # Update ollama run commands to use system prompt
    sed -i 's/ollama run "\$SELECTED_MODEL" "\$USER_INPUT"/ollama run "\$SELECTED_MODEL" --system "\$SYSTEM_PROMPT" "\$USER_INPUT"/g' "$script"
done

echo "Update complete!"
EOF

# Copy the update script to the container
docker cp /tmp/update_cc_scripts.sh dbgpt-shell-agent:/tmp/update_cc_scripts.sh

# Run the update script in the container
docker exec -it dbgpt-shell-agent bash -c "chmod +x /tmp/update_cc_scripts.sh && /tmp/update_cc_scripts.sh"

# Clean up
rm /tmp/cc_system_prompt.txt
rm /tmp/update_cc_scripts.sh

echo -e "${GREEN}System prompt update complete!${NC}"
echo -e "${YELLOW}Try running a query to test: ./cc-advisor.sh ask \"What is CodexContinueGPT and how does it work?\"${NC}"
