#!/bin/bash
# Start the MCP Ollama server

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

# Default settings
HOST="0.0.0.0"
PORT="8000"
MODEL="codellama"
OLLAMA_API_BASE="http://localhost:11434"

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
    *)
      echo "Unknown option: $1"
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
      [Yy]* ) ollama serve & ;;
      * ) echo "Please start ollama before continuing"; exit 1 ;;
  esac
fi

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
        echo "Using default model instead"
        ;;
  esac
fi

# Check if requirements are installed
if ! python3 -c "import fastapi, uvicorn" &> /dev/null; then
  echo -e "${YELLOW}Required Python packages (fastapi, uvicorn) are not installed.${NC}"
  read -p "Install required packages? (y/n): " yn
  case $yn in
      [Yy]* )
        echo -e "${CYAN}Installing required packages...${NC}"
        pip install fastapi uvicorn requests
        ;;
      * ) 
        echo "Cannot continue without required packages."
        exit 1
        ;;
  esac
fi

# Make script executable
chmod +x "$REPO_ROOT/tools/ollama/mcp_ollama_server.py"

# Start the MCP server
echo -e "${GREEN}Starting MCP Ollama server on $HOST:$PORT with model $MODEL${NC}"
echo -e "${CYAN}API endpoint will be available at http://$HOST:$PORT/v1${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}"

# Export environment variables
export OLLAMA_API_BASE="$OLLAMA_API_BASE"
export OLLAMA_MODEL="$MODEL"
export HOST="$HOST"
export PORT="$PORT"

# Run the server
python3 "$REPO_ROOT/tools/ollama/mcp_ollama_server.py"
