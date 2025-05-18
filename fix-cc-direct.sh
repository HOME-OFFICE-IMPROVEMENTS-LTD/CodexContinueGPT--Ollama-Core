#!/bin/bash
# fix-cc-direct.sh - Direct fix for CodexContinueGPT in the container

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

echo -e "${CYAN}Examining CodexContinueGPT in container...${NC}"

# Create a temporary script to debug and fix the issue
cat > /tmp/debug_fix_cc.sh << 'EOF'
#!/bin/bash

# Find which script is actually run for CodexContinueGPT
echo "Checking which cc script is executed..."
which cc
echo ""

# Check if the executable is a symlink
echo "Checking if cc is a symlink..."
ls -la $(which cc)
echo ""

# Look at what files are in the ccgpt directory
echo "Checking ccgpt files in /app/agent..."
ls -la /app/agent/ccgpt*
echo ""

# Create our identity context
echo "Creating identity context..."
cat > /app/agent/identity.txt << 'INNEREOF'
I am CodexContinueGPT, a custom implementation built by Home & Office Improvements Ltd. on Ollama models (codellama, mistral, llama3) for the DB-GPT project. I was architected by msalsouri. I assist with code generation, task management, and answering questions about the project.

I am aware of the file organization plan that includes:
1. Reorganizing Ollama documentation files from root to /docs/ollama/
2. Moving CC-GPT related scripts from root to /docker/cc-ollama/
3. Creating a standardized structure for easier maintenance

My capabilities include direct query support (non-interactive usage), interactive mode, and auto-model selection based on query content. I am integrated with cc-advisor.sh which allows consulting me before file operations.

When asked about my capabilities, I explain that I am a custom interface to Ollama models created specifically for the DB-GPT project by Home & Office Improvements Ltd., with msalsouri as the architect.
INNEREOF

# Create a fixed wrapper script
echo "Creating fixed cc wrapper script..."
cat > /app/agent/cc-fixed << 'INNEREOF'
#!/bin/bash

# Get the original command arguments
ARGS=""
for arg in "$@"; do
    ARGS="$ARGS \"$arg\""
done

# Create identity prefix
IDENTITY=$(cat /app/agent/identity.txt)
IDENTITY_PREFIX="I am going to respond as if I am the following: $IDENTITY. Now, to answer your query: "

# If there are direct arguments, modify them
if [ $# -gt 0 ]; then
    # Check if the last argument doesn't start with -
    LAST_ARG="${!#}"
    if [[ ! "$LAST_ARG" == -* ]]; then
        # It's a direct query, we need to prefix it with identity
        # Remove the last argument
        set -- "${@:1:$(($#-1))}"
        # Create a prefixed version
        PREFIXED_QUERY="$IDENTITY_PREFIX $LAST_ARG"
        # Add it back with quotes to preserve spaces
        set -- "$@" "$PREFIXED_QUERY"
    fi
fi

# Call the original cc with modified arguments
/app/agent/cc "$@"
INNEREOF

chmod +x /app/agent/cc-fixed

# Create a backup of the original cc
echo "Backing up original cc..."
cp /usr/local/bin/cc /usr/local/bin/cc.bak

# Replace cc with our fixed version
echo "Replacing cc with fixed version..."
cat > /usr/local/bin/cc << 'INNEREOF'
#!/bin/bash
/app/agent/cc-fixed "$@"
INNEREOF

chmod +x /usr/local/bin/cc

echo "Fix applied. Try running a query now."
EOF

# Copy the debug/fix script to the container
docker cp /tmp/debug_fix_cc.sh dbgpt-shell-agent:/tmp/debug_fix_cc.sh

# Run the debug/fix script in the container
echo -e "${YELLOW}Running diagnostic and fix in the container...${NC}"
docker exec -it dbgpt-shell-agent bash -c "chmod +x /tmp/debug_fix_cc.sh && /tmp/debug_fix_cc.sh"

# Clean up
rm /tmp/debug_fix_cc.sh

echo -e "${GREEN}Direct fix applied!${NC}"
echo -e "${YELLOW}Try running a query to test: ./cc-advisor.sh ask \"What is CodexContinueGPT and how does it work?\"${NC}"
