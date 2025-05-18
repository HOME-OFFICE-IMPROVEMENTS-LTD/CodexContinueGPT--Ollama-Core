#!/bin/bash
# Launch CodexContinue-GPT in the container from the host machine

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if container is running
if ! docker ps | grep -q "dbgpt-shell-agent"; then
    echo -e "${RED}Error: dbgpt-shell-agent container is not running${NC}"
    echo "Starting the container now..."
    cd "$(dirname "$0")/.." && docker-compose up -d dbgpt-shell-agent
    
    # Wait for container to be ready
    echo -e "Waiting for container to be ready..."
    sleep 5
fi

# Check if arguments are passed
if [ $# -eq 0 ]; then
    # No arguments - show intro and launch interactive mode
    echo -e "${CYAN}=====================================${NC}"
    echo -e "${CYAN}     CodexContinue-GPT Launcher     ${NC}"
    echo -e "${CYAN}=====================================${NC}"
    echo -e "Launching interactive mode in container..."
    docker exec -it dbgpt-shell-agent bash -c "cc --auto"
else
    # Passing arguments to the container
    args_quoted=""
    for arg in "$@"; do
        args_quoted="$args_quoted \"$arg\""
    done
    
    # Execute with the provided arguments
    docker exec -it dbgpt-shell-agent bash -c "cc $args_quoted"
fi
