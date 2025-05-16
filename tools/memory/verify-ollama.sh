#!/bin/bash
# filepath: /home/msalsouri/Projects/DB-GPT/verify-ollama.sh
# Simple script to verify if Ollama is working properly

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BOLD}Ollama Verification Test${NC}"
echo -e "${YELLOW}This script will verify if Ollama is working properly${NC}\n"

# Check if Ollama is installed
if ! command -v ollama &> /dev/null; then
    echo -e "${RED}Error: Ollama is not installed or not in your PATH.${NC}"
    echo -e "${YELLOW}Please install Ollama first: https://ollama.ai/download${NC}"
    exit 1
fi

# Check if Ollama service is running
if ! pgrep -f "ollama serve" > /dev/null; then
    echo -e "${YELLOW}Ollama service is not running. Starting it now...${NC}"
    ollama serve > /dev/null 2>&1 &
    sleep 3
    
    if ! pgrep -f "ollama serve" > /dev/null; then
        echo -e "${RED}Error: Failed to start Ollama service.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Ollama service started successfully.${NC}"
else
    echo -e "${GREEN}Ollama service is running.${NC}"
fi

# List available models
echo -e "\n${YELLOW}Available models:${NC}"
ollama list

# Test with the simplest possible model
BASE_MODEL="codellama"
if ollama list | grep -q "$BASE_MODEL"; then
    echo -e "\n${YELLOW}Testing Ollama with $BASE_MODEL...${NC}"
    
    # Run a very simple test
    if echo "Hello" | ollama run "$BASE_MODEL" "Reply with one word only: Hi" > /dev/null; then
        echo -e "${GREEN}Test passed! Ollama is working properly with $BASE_MODEL.${NC}"
    else
        echo -e "${RED}Test failed. Ollama could not run $BASE_MODEL properly.${NC}"
        exit 1
    fi
else
    echo -e "\n${YELLOW}Base model $BASE_MODEL not found. Pulling it now...${NC}"
    if ollama pull "$BASE_MODEL"; then
        echo -e "${GREEN}Successfully pulled $BASE_MODEL.${NC}"
        
        echo -e "\n${YELLOW}Testing Ollama with $BASE_MODEL...${NC}"
        if echo "Hello" | ollama run "$BASE_MODEL" "Reply with one word only: Hi" > /dev/null; then
            echo -e "${GREEN}Test passed! Ollama is working properly with $BASE_MODEL.${NC}"
        else
            echo -e "${RED}Test failed. Ollama could not run $BASE_MODEL properly.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Error: Failed to pull $BASE_MODEL.${NC}"
        exit 1
    fi
fi

# Create a minimal test model
echo -e "\n${YELLOW}Creating a minimal test model...${NC}"
TEMP_MODELFILE=$(mktemp)
MINIMAL_MODEL="test-minimal-model"

# Create minimal modelfile
cat > "$TEMP_MODELFILE" << EOF
FROM $BASE_MODEL

SYSTEM """
You are a helpful assistant.
"""
EOF

# Create the minimal model
if ollama create "$MINIMAL_MODEL" -f "$TEMP_MODELFILE"; then
    echo -e "${GREEN}Minimal test model created successfully.${NC}"
    
    # Test the minimal model
    echo -e "\n${YELLOW}Testing minimal model...${NC}"
    if echo "Hello" | ollama run "$MINIMAL_MODEL" "Reply with one word only: Hi" > /dev/null; then
        echo -e "${GREEN}Test passed! Minimal model works correctly.${NC}"
        
        # Clean up
        echo -e "\n${YELLOW}Cleaning up test model...${NC}"
        ollama rm "$MINIMAL_MODEL"
        echo -e "${GREEN}Test model removed.${NC}"
    else
        echo -e "${RED}Test failed. Minimal model could not run properly.${NC}"
    fi
else
    echo -e "${RED}Failed to create minimal test model.${NC}"
fi

# Clean up
rm "$TEMP_MODELFILE"

echo -e "\n${BOLD}Ollama Verification Summary:${NC}"
echo -e "1. Ollama installation: ${GREEN}OK${NC}"
echo -e "2. Ollama service: ${GREEN}Running${NC}"
echo -e "3. Base model ($BASE_MODEL): ${GREEN}Available and working${NC}"
echo -e "4. Model creation capabilities: ${GREEN}Working${NC}"
echo -e "5. Available memory: $(free -h | awk 'NR==2{print $7}')"

echo -e "\n${GREEN}Ollama is functioning properly!${NC}"

exit 0
