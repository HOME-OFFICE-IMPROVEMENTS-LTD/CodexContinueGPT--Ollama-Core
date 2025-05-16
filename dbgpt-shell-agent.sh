#!/bin/bash
# DB-GPT Shell Agent using Open Interpreter
# Provides an intelligent interactive shell agent backed by Ollama models

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Define the project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INTERPRETER_CONFIG="$PROJECT_ROOT/.interpreter"

# Check dependencies
check_dependencies() {
  if ! command -v interpreter &> /dev/null; then
    echo -e "${YELLOW}Open Interpreter not found. Installing...${NC}"
    pip install open-interpreter
  fi
  
  if ! command -v ollama &> /dev/null; then
    echo -e "${RED}Ollama not found. Please install Ollama first:${NC}"
    echo "curl -fsSL https://ollama.com/install.sh | sh"
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

# Available models function
available_models() {
  echo -e "${CYAN}Available Ollama models:${NC}"
  ollama list
}

# Configure Open Interpreter
configure_interpreter() {
  local model=$1
  
  # Create or update config file
  cat > "$INTERPRETER_CONFIG" << EOF
{
  "auto_run": true,
  "model": "ollama/$model",
  "temperature": 0.7,
  "context_window": 16000,
  "max_tokens": 2000,
  "system_message": "You are a helpful shell assistant for DB-GPT with extensive knowledge of databases, SQL, bash, and development workflows. Help the user with their shell commands, database operations, and code generation needs. When possible, show practical examples. When writing scripts, ensure they have proper error handling.",
  "api_base": "http://localhost:11434/api",
  "display_api_keys": false
}
EOF
}

# Start the agent with a specific Ollama model
start_agent() {
  local model=${1:-"codellama"}
  
  echo -e "${CYAN}====================================${NC}"
  echo -e "${CYAN}   DB-GPT Shell Agent with Ollama   ${NC}"
  echo -e "${CYAN}====================================${NC}"
  echo ""
  
  # Check if model exists
  if ! ollama list | grep -q "$model"; then
    echo -e "${YELLOW}Model '$model' not found in Ollama.${NC}"
    available_models
    read -p "Would you like to pull this model? (y/n): " yn
    case $yn in
      [Yy]* ) 
        echo "Pulling model $model..."
        ollama pull $model 
        ;;
      * ) 
        echo "Please specify a different model."
        exit 1
        ;;
    esac
  fi
  
  echo -e "${GREEN}Starting Shell Agent with model:${NC} $model"
  echo -e "${YELLOW}This agent can understand and execute shell commands.${NC}"
  echo -e "${YELLOW}Always review commands before confirming execution.${NC}"
  echo ""
  
  # Configure interpreter
  configure_interpreter $model
  
  # Start interpreter
  echo -e "${CYAN}Starting interactive session...${NC}"
  echo -e "${CYAN}Type 'exit' or press Ctrl+D to exit${NC}"
  echo ""
  
  # Launch interpreter
  interpreter
}

# Main execution
check_dependencies
check_ollama_running

# Parse command line arguments
model="codellama"
if [ $# -ge 1 ]; then
  model=$1
fi

start_agent $model
