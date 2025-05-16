#!/bin/bash
# DB-GPT Shell Agent Docker Launcher
# This script launches the Ollama Shell Agent in a Docker container

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m' # No Color

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_COMPOSE_FILE="$PROJECT_ROOT/docker/oi-ollama/docker-compose.shell-agent.yml"

echo -e "${CYAN}====================================${NC}"
echo -e "${CYAN}   DB-GPT Shell Agent Launcher      ${NC}"
echo -e "${CYAN}====================================${NC}"
echo ""

# Check if Docker and Docker Compose are installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed or not in PATH${NC}"
    echo -e "Please install Docker first"
    exit 1
fi

# Check if Docker Compose file exists
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo -e "${RED}Error: Docker Compose file not found at $DOCKER_COMPOSE_FILE${NC}"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo -e "${RED}Error: Docker daemon is not running${NC}"
    echo -e "Please start Docker first"
    exit 1
fi

# Check if the shell agent is already running
if docker ps | grep -q "dbgpt-shell-agent"; then
    echo -e "${YELLOW}Shell agent is already running.${NC}"
    echo ""
    echo -e "${CYAN}Options:${NC}"
    echo -e "1. Connect to the running shell agent container"
    echo -e "2. Restart the shell agent container"
    echo -e "3. Stop the shell agent container"
    echo -e "4. Exit"
    echo ""
    read -p "Please choose an option (1-4): " option
    
    case $option in
        1)
            echo -e "${GREEN}Connecting to shell agent container...${NC}"
            docker exec -it dbgpt-shell-agent bash
            ;;
        2)
            echo -e "${YELLOW}Restarting shell agent container...${NC}"
            docker-compose -f "$DOCKER_COMPOSE_FILE" down
            docker-compose -f "$DOCKER_COMPOSE_FILE" up -d
            echo -e "${GREEN}Shell agent restarted. Connecting to container...${NC}"
            docker exec -it dbgpt-shell-agent bash
            ;;
        3)
            echo -e "${YELLOW}Stopping shell agent container...${NC}"
            docker-compose -f "$DOCKER_COMPOSE_FILE" down
            echo -e "${GREEN}Shell agent stopped.${NC}"
            ;;
        4|*)
            echo -e "${YELLOW}Exiting without changes.${NC}"
            exit 0
            ;;
    esac
else
    # Start the shell agent container
    echo -e "${GREEN}Starting shell agent container...${NC}"
    echo -e "${YELLOW}This may take a few minutes on first run while building the image...${NC}"
    
    cd "$PROJECT_ROOT"
    docker-compose -f "$DOCKER_COMPOSE_FILE" up -d --build
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Shell agent container started successfully.${NC}"
        echo -e "${CYAN}Connecting to shell agent container...${NC}"
        docker exec -it dbgpt-shell-agent bash
    else
        echo -e "${RED}Failed to start shell agent container.${NC}"
        exit 1
    fi
fi
