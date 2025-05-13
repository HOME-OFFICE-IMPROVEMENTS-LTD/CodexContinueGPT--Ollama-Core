#!/bin/bash
# DB-GPT Ollama Model Manager
# This script helps manage Ollama models for DB-GPT integration

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Paths and settings
CONFIG_DIR="/home/msalsouri/Projects/DB-GPT/configs"
OLLAMA_CONFIG_FILE="$CONFIG_DIR/dbgpt-proxy-ollama.toml"

# Check if Ollama is installed
check_ollama() {
    if ! command -v ollama &> /dev/null; then
        echo -e "${RED}Error: ollama is not installed or not in PATH${NC}"
        echo "Please install ollama first: curl -fsSL https://ollama.com/install.sh | sh"
        exit 1
    fi
}

# Check if Ollama is running
check_ollama_running() {
    if ! curl -s http://localhost:11434/api/version &> /dev/null; then
        echo -e "${YELLOW}Warning: Ollama server doesn't seem to be running${NC}"
        echo -e "Start it with: ${CYAN}ollama serve${NC} (or via systemctl if installed as a service)"
        echo ""
        read -p "Would you like to start ollama now? (y/n): " yn
        case $yn in
            [Yy]* ) ollama serve & ;;
            * ) echo "Please start ollama before continuing"; exit 1 ;;
        esac
    fi
}

# List available models
list_models() {
    echo -e "${CYAN}Locally installed Ollama models:${NC}"
    ollama list

    echo -e "\n${CYAN}Currently configured model in DB-GPT:${NC}"
    current_model=$(grep -A 3 "models.llms" "$OLLAMA_CONFIG_FILE" | grep "name" | head -1 | cut -d'"' -f2 || echo "Not found")
    echo "$current_model"
}

# Pull a new model
pull_model() {
    echo -e "${CYAN}Pulling Ollama model: $1${NC}"
    ollama pull "$1"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully pulled model: $1${NC}"
        
        read -p "Would you like to set this as the active model for DB-GPT? (y/n): " yn
        case $yn in
            [Yy]* ) update_config "$1" ;;
            * ) echo "Model pulled but not set as active" ;;
        esac
    else
        echo -e "${RED}Failed to pull model: $1${NC}"
    fi
}

# Update DB-GPT configuration with new model
update_config() {
    local new_model="$1"
    local temp_file=$(mktemp)
    
    # Use sed to replace the model name line
    sed -e "/\[\[models\.llms\]\]/,/provider/ s/name = \".*\"/name = \"$new_model\"/" "$OLLAMA_CONFIG_FILE" > "$temp_file"
    
    # Check if sed operation succeeded
    if [ $? -eq 0 ]; then
        mv "$temp_file" "$OLLAMA_CONFIG_FILE"
        echo -e "${GREEN}Successfully updated DB-GPT configuration to use model: $new_model${NC}"
        echo "Restart DB-GPT for changes to take effect"
    else
        echo -e "${RED}Failed to update configuration file${NC}"
        rm "$temp_file"
    fi
}

# Show recommended models for shell guidance
show_recommended_models() {
    echo -e "${CYAN}Recommended Ollama Models for Shell Guidance:${NC}"
    echo -e "${GREEN}codellama${NC} - Excellent for code and shell commands (${YELLOW}~3.8GB${NC})"
    echo -e "${GREEN}llama3${NC} - Good general purpose model (${YELLOW}~4.7GB${NC})"
    echo -e "${GREEN}mistral${NC} - Fast and efficient with good shell capabilities (${YELLOW}~4.1GB${NC})"
    echo -e "${GREEN}codestral${NC} - Code-focused version of Mistral (${YELLOW}~4.3GB${NC})"
    echo -e "${GREEN}codegemma:7b${NC} - Google's model for code generation (${YELLOW}~4.0GB${NC})"
    echo -e "${GREEN}phi3:mini${NC} - Lightweight but capable (${YELLOW}~1.8GB${NC})"
}

# Start DB-GPT with Ollama configuration
start_dbgpt() {
    cd /home/msalsouri/Projects/DB-GPT
    echo -e "${CYAN}Starting DB-GPT with Ollama configuration...${NC}"
    echo -e "${YELLOW}DB-GPT will be available at http://localhost:5670${NC}"
    uv run dbgpt start webserver --config configs/dbgpt-proxy-ollama.toml
}

# Deploy with Docker-Compose
deploy_docker() {
    cd /home/msalsouri/Projects/DB-GPT
    echo -e "${CYAN}Deploying DB-GPT using Docker-Compose...${NC}"
    echo -e "${YELLOW}Please set your SiliconFlow API key in the environment${NC}"
    echo -e "${YELLOW}DB-GPT will be available at http://localhost:5670${NC}"
    read -p "Enter your SiliconFlow API key: " api_key
    SILICONFLOW_API_KEY=$api_key docker compose up -d
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Docker-Compose deployment successful${NC}"
        echo -e "To view logs: ${CYAN}docker logs db-gpt-webserver-1 -f${NC}"
    else
        echo -e "${RED}Docker-Compose deployment failed${NC}"
    fi
}

# Show help menu
show_help() {
    echo -e "${GREEN}DB-GPT Ollama Model Manager${NC}"
    echo "This script helps manage Ollama models for DB-GPT integration"
    echo ""
    echo -e "${CYAN}Usage:${NC}"
    echo "  ./ollama_manager.sh [command]"
    echo ""
    echo -e "${CYAN}Commands:${NC}"
    echo "  list         List installed Ollama models"
    echo "  pull MODEL   Pull a new model from Ollama library"
    echo "  recommend    Show recommended models for shell tasks"
    echo "  update MODEL Set an installed model as active in DB-GPT config"
    echo "  start        Start DB-GPT with Ollama configuration"
    echo "  docker       Deploy DB-GPT using Docker-Compose"
    echo "  help         Show this help message"
    echo ""
    echo -e "${CYAN}Examples:${NC}"
    echo "  ./ollama_manager.sh list"
    echo "  ./ollama_manager.sh pull codellama"
    echo "  ./ollama_manager.sh update llama3"
    echo "  ./ollama_manager.sh start"
    echo "  ./ollama_manager.sh docker"
}

# Main execution logic
check_ollama

if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

command="$1"
case "$command" in
    "list")
        check_ollama_running
        list_models
        ;;
    "pull")
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Please specify a model name to pull${NC}"
            echo "Example: ./ollama_manager.sh pull codellama"
            exit 1
        fi
        check_ollama_running
        pull_model "$2"
        ;;
    "recommend")
        show_recommended_models
        ;;
    "update")
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Please specify a model name to update${NC}"
            echo "Example: ./ollama_manager.sh update codellama"
            exit 1
        fi
        update_config "$2"
        ;;
    "start")
        check_ollama_running
        start_dbgpt
        ;;
    "docker")
        deploy_docker
        ;;
    "help"|*)
        show_help
        ;;
esac
