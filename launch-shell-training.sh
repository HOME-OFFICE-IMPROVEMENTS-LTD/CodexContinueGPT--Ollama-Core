#!/bin/bash
# Shell Training Launch Script
# This script checks if the MCP server is running and starts it if needed
# before launching the shell training guide.

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default settings
MCP_HOST="localhost"
MCP_PORT=8000
DEFAULT_MODEL="codellama"

# Parse command line arguments to pass to the training script
ARGS=""
MODEL="$DEFAULT_MODEL"

for arg in "$@"; do
    if [[ "$arg" == "--model" && "$2" != "" ]]; then
        MODEL="$2"
    fi
    ARGS="$ARGS $arg"
done

# Function to check if MCP server is running
check_mcp_server() {
    if curl -s "http://$MCP_HOST:$MCP_PORT/v1/health" > /dev/null; then
        return 0  # Server is running
    else
        return 1  # Server is not running
    fi
}

# Function to start MCP server
start_mcp_server() {
    echo -e "${YELLOW}Enhanced MCP server is not running. Starting it now...${NC}"
    echo -e "${BLUE}Using model:${NC} $MODEL"
    
    # Start the MCP server in the background
    "$PROJECT_ROOT/tools/ollama/start_enhanced_mcp_server.sh" --model "$MODEL" --port "$MCP_PORT" > /dev/null 2>&1 &
    
    # Give it some time to start up
    echo -ne "${YELLOW}Starting server.${NC}"
    for i in {1..30}; do
        echo -ne "${YELLOW}.${NC}"
        sleep 1
        if check_mcp_server; then
            echo -e "\n${GREEN}Enhanced MCP server started successfully!${NC}"
            return 0
        fi
    done
    
    echo -e "\n${RED}Failed to start Enhanced MCP server. Please start it manually with:${NC}"
    echo -e "${CYAN}mcp-enhanced-$MODEL${NC}"
    return 1
}

# Main execution
echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN}    DB-GPT Shell Training Launcher      ${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""

# Check if MCP server is running
if check_mcp_server; then
    echo -e "${GREEN}Enhanced MCP server is already running.${NC}"
else
    start_mcp_server || exit 1
fi

# Launch the shell training guide
echo ""
echo -e "${BLUE}Launching Shell Training Guide...${NC}"
echo ""

"$PROJECT_ROOT/shell-training.sh" $ARGS
