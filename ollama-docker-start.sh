#!/bin/bash
# DB-GPT Ollama Docker Starter
# This script starts DB-GPT with Docker Compose and displays available Ollama commands

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Define the project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$PROJECT_ROOT/configs"
OLLAMA_CONFIG_FILE="$CONFIG_DIR/dbgpt-proxy-ollama.toml"

echo -e "${CYAN}====================================${NC}"
echo -e "${CYAN}   DB-GPT Ollama Docker Starter     ${NC}"
echo -e "${CYAN}====================================${NC}"
echo ""

# Check for API key if needed
if [ -z "$SILICONFLOW_API_KEY" ]; then
    echo -e "${YELLOW}No SILICONFLOW_API_KEY found in environment${NC}"
    read -p "Would you like to enter a SiliconFlow API key? (y/n): " yn
    case $yn in
        [Yy]* )
            read -p "Enter your SiliconFlow API key: " api_key
            export SILICONFLOW_API_KEY=$api_key
            ;;
        * )
            echo -e "${YELLOW}Using default configuration without API key${NC}"
            ;;
    esac
fi

# Start Docker Compose
echo -e "${GREEN}Starting DB-GPT with Docker Compose...${NC}"
docker compose up -d

# Check if docker-compose was successful
if [ $? -ne 0 ]; then
    echo -e "${RED}Docker Compose failed to start. Please check the logs.${NC}"
    exit 1
fi

echo -e "${GREEN}DB-GPT is now running with Docker!${NC}"
echo -e "Web interface available at: ${CYAN}http://localhost:5670${NC}"
echo ""
echo -e "${MAGENTA}=== Available Ollama Commands ===${NC}"
echo ""

# Show shell helper commands
echo -e "${CYAN}Shell Helper Commands:${NC}"
echo -e "${YELLOW}sh-help${NC} \"How do I find large files?\"         ${GREEN}# Get shell command help${NC}"
echo -e "${YELLOW}sh-explain${NC} \"find / -type f -size +100M\"      ${GREEN}# Explain a shell command${NC}"
echo -e "${YELLOW}sh-script${NC} \"create a backup script\"           ${GREEN}# Generate a shell script${NC}"
echo ""

# Show direct model interaction commands
echo -e "${CYAN}Direct Model Interaction:${NC}"
echo -e "${YELLOW}ask${NC} \"Write a Python function to download a file\"       ${GREEN}# Query with CodeLlama${NC}"
echo -e "${YELLOW}ask-llama${NC} \"Explain quantum computing\"                  ${GREEN}# Query with Llama3${NC}"
echo -e "${YELLOW}ask-code${NC} \"Write a JavaScript sorting function\"         ${GREEN}# Code-specific query${NC}"
echo -e "${YELLOW}ask-any${NC} mistral \"Explain Docker containers\"            ${GREEN}# Use any model${NC}"
echo ""

# Show model management commands
echo -e "${CYAN}Model Management:${NC}"
echo -e "${YELLOW}om-list${NC}                ${GREEN}# List available models${NC}"
echo -e "${YELLOW}om-pull${NC} MODEL          ${GREEN}# Pull a new model${NC}" 
echo -e "${YELLOW}om-update${NC} MODEL        ${GREEN}# Set model as active${NC}"
echo -e "${YELLOW}om-recommend${NC}           ${GREEN}# Show recommended models${NC}"
echo ""

# Show Docker container management
echo -e "${CYAN}Docker Container Management:${NC}"
echo -e "${YELLOW}docker logs db-gpt-webserver-1 -f${NC}    ${GREEN}# View server logs${NC}"
echo -e "${YELLOW}docker exec -it db-gpt-webserver-1 bash${NC}  ${GREEN}# Access container shell${NC}"
echo -e "${YELLOW}docker compose down${NC}                 ${GREEN}# Stop all containers${NC}"
echo ""

echo -e "${CYAN}To use these commands, first load the aliases:${NC}"
echo -e "${YELLOW}source .aliases${NC}"
echo ""
echo -e "${GREEN}Happy coding with DB-GPT and Ollama!${NC}"
echo -e "${CYAN}====================================${NC}"
