#!/bin/bash
# Start the Enhanced MCP Ollama server

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

# Default settings
HOST="0.0.0.0"
PORT="8000"
MODEL="codellama"
OLLAMA_API_BASE="http://localhost:11434"
TIMEOUT=60
USE_ENHANCED=true

# Print script banner
echo -e "${BLUE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
echo -e "${BLUE}┃${NC} ${MAGENTA}DB-GPT Enhanced MCP Server for Ollama${NC}                               ${BLUE}┃${NC}"
echo -e "${BLUE}┃${NC} ${CYAN}Provides OpenAI-compatible API endpoints for Ollama models${NC}            ${BLUE}┃${NC}"
echo -e "${BLUE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
echo ""

# Help function
show_help() {
  echo -e "${CYAN}Usage:${NC}"
  echo "  $0 [options]"
  echo ""
  echo -e "${CYAN}Options:${NC}"
  echo "  --port PORT         Set the server port (default: 8000)"
  echo "  --model MODEL       Set the default Ollama model (default: codellama)"
  echo "  --host HOST         Set the server host (default: 0.0.0.0)"
  echo "  --ollama-api URL    Set the Ollama API base URL (default: http://localhost:11434)"
  echo "  --timeout SECONDS   Set request timeout in seconds (default: 60)"
  echo "  --standard          Use standard MCP server instead of enhanced version"
  echo "  --help              Show this help message"
  echo ""
  echo -e "${CYAN}Examples:${NC}"
  echo "  $0 --model llama3 --port 8080"
  echo "  $0 --ollama-api http://ollama-container:11434"
  exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --port)
      PORT="$2"
      shift 2
      ;;
    --model)
      MODEL="$2"
      shift 2
      ;;
    --host)
      HOST="$2"
      shift 2
      ;;
    --ollama-api)
      OLLAMA_API_BASE="$2"
      shift 2
      ;;
    --timeout)
      TIMEOUT="$2"
      shift 2
      ;;
    --standard)
      USE_ENHANCED=false
      shift
      ;;
    --help)
      show_help
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      echo "Use --help to see available options"
      exit 1
      ;;
  esac
done

# Check if Ollama is running
if ! curl -s "$OLLAMA_API_BASE/api/version" > /dev/null; then
  echo -e "${YELLOW}Warning: Ollama server doesn't seem to be running at $OLLAMA_API_BASE${NC}"
  echo -e "Start it with: ${CYAN}ollama serve${NC}"
  echo ""
  read -p "Would you like to try starting ollama now? (y/n): " yn
  case $yn in
      [Yy]* ) 
        echo -e "${CYAN}Starting Ollama server...${NC}"
        ollama serve & 
        # Wait for Ollama to start
        echo -e "${YELLOW}Waiting for Ollama to start...${NC}"
        for i in {1..10}; do
          if curl -s "$OLLAMA_API_BASE/api/version" > /dev/null; then
            echo -e "${GREEN}Ollama server is now running!${NC}"
            break
          fi
          if [ $i -eq 10 ]; then
            echo -e "${RED}Timeout waiting for Ollama to start. Please check if it's running.${NC}"
            exit 1
          fi
          sleep 1
        done
        ;;
      * ) 
        echo "Please start ollama before continuing"
        exit 1 
        ;;
  esac
fi

# Get Ollama version
OLLAMA_VERSION=$(curl -s "$OLLAMA_API_BASE/api/version" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
echo -e "${GREEN}Connected to Ollama version $OLLAMA_VERSION${NC}"

# Check if model is available
if ! ollama list | grep -q "$MODEL"; then
  echo -e "${YELLOW}Model '$MODEL' is not available. Do you want to pull it now?${NC}"
  read -p "Pull model $MODEL? (y/n): " yn
  case $yn in
      [Yy]* )
        echo -e "${CYAN}Pulling model $MODEL...${NC}"
        ollama pull "$MODEL" 
        ;;
      * ) 
        # Show available models
        echo -e "${YELLOW}Available models:${NC}"
        ollama list
        read -p "Choose an available model from the list: " MODEL
        if [ -z "$MODEL" ]; then
          echo -e "${RED}No model selected. Using default model 'codellama'.${NC}"
          MODEL="codellama"
        fi
        ;;
  esac
fi

# Check if requirements are installed
if ! python3 -c "import fastapi, uvicorn, requests" &> /dev/null; then
  echo -e "${YELLOW}Required Python packages (fastapi, uvicorn, requests) are not installed.${NC}"
  read -p "Install required packages? (y/n): " yn
  case $yn in
      [Yy]* )
        echo -e "${CYAN}Installing required packages...${NC}"
        pip install fastapi uvicorn requests
        ;;
      * ) 
        echo -e "${RED}Cannot continue without required packages.${NC}"
        exit 1
        ;;
  esac
fi

# Select the server script
if [ "$USE_ENHANCED" = true ]; then
  SERVER_SCRIPT="$REPO_ROOT/tools/ollama/mcp_ollama_server_enhanced.py"
  echo -e "${GREEN}Using enhanced MCP server with streaming support and better error handling${NC}"
else
  SERVER_SCRIPT="$REPO_ROOT/tools/ollama/mcp_ollama_server.py"
  echo -e "${YELLOW}Using standard MCP server${NC}"
fi

# Make script executable
chmod +x "$SERVER_SCRIPT"

# Show configuration
echo -e "${CYAN}Server Configuration:${NC}"
echo -e "  - Host: ${YELLOW}$HOST${NC}"
echo -e "  - Port: ${YELLOW}$PORT${NC}"
echo -e "  - Default Model: ${YELLOW}$MODEL${NC}"
echo -e "  - Ollama API: ${YELLOW}$OLLAMA_API_BASE${NC}"
echo -e "  - Timeout: ${YELLOW}${TIMEOUT}s${NC}"
echo ""

# Start the MCP server
echo -e "${GREEN}Starting MCP Ollama server...${NC}"
echo -e "${CYAN}API endpoint will be available at ${YELLOW}http://$HOST:$PORT/v1${NC}"
echo -e "${CYAN}Documentation available at ${YELLOW}http://$HOST:$PORT/docs${NC}"
echo -e "${CYAN}Health check at ${YELLOW}http://$HOST:$PORT/v1/health${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}"
echo ""

# Export environment variables
export OLLAMA_API_BASE="$OLLAMA_API_BASE"
export OLLAMA_MODEL="$MODEL"
export OLLAMA_TIMEOUT="$TIMEOUT"
export HOST="$HOST"
export PORT="$PORT"

# Run the server
python3 "$SERVER_SCRIPT"
