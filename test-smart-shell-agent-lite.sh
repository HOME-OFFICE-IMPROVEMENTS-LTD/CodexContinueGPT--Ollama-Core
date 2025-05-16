#!/bin/bash
# filepath: /home/msalsouri/Projects/DB-GPT/test-smart-shell-agent-lite.sh
# Test script for smart-shell-agent-lite

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

MODEL="smart-shell-agent-lite"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BOLD}Smart Shell Agent Lite Test${NC}"
echo -e "${YELLOW}This script will test if the smart-shell-agent-lite model is working properly${NC}\n"

# Check if Ollama is installed
if ! command -v ollama &> /dev/null; then
    echo -e "${RED}Error: Ollama is not installed or not in your PATH.${NC}"
    exit 1
fi

# Check if Ollama service is running
if ! pgrep -f "ollama serve" > /dev/null; then
    echo -e "${YELLOW}Ollama service is not running. Starting it now...${NC}"
    ollama serve > /dev/null 2>&1 &
    sleep 3
fi

# Create a simple Modelfile
TEMP_MODELFILE=$(mktemp)

cat > "$TEMP_MODELFILE" << EOF
FROM codellama:latest

SYSTEM """
You are a helpful assistant for the DB-GPT project.
"""
EOF

# Create or rebuild the model
echo -e "${YELLOW}Creating test model...${NC}"
if ollama create "$MODEL" -f "$TEMP_MODELFILE"; then
    echo -e "${GREEN}Model created successfully!${NC}"
    
    # Test the model with a specific task
    echo -e "${YELLOW}Testing the model with a simple query...${NC}"
    RESPONSE=$(echo "hi" | ollama run "$MODEL" "Reply with exactly: WORKING_OK" 2>/dev/null)
    
    if echo "$RESPONSE" | grep -q "WORKING_OK"; then
        echo -e "${GREEN}Test passed! Model is working correctly.${NC}"
        exit 0
    else
        echo -e "${RED}Test failed. Model did not respond correctly.${NC}"
        echo -e "${YELLOW}Response was:${NC}"
        echo "$RESPONSE"
        exit 1
    fi
else
    echo -e "${RED}Failed to create model.${NC}"
    exit 1
fi
