#!/bin/bash
# filepath: /home/msalsouri/Projects/DB-GPT/test-ollama.sh
# Simple script to test Ollama installation

echo "Testing Ollama installation..."

# Check if ollama is installed
if ! command -v ollama &> /dev/null; then
    echo "Error: Ollama is not installed or not in your PATH."
    exit 1
fi

# Check if base model exists
if ! ollama list | grep -q "codellama"; then
    echo "Base model 'codellama' not found. Please pull it first with: ollama pull codellama"
    exit 1
fi

# Build a very simple test model
echo "Building test model..."
ollama create test-model -f test-model.Modelfile

# Test if the model works
echo "Testing model..."
if echo "Hello, are you working?" | ollama run test-model -d; then
    echo "Success! Ollama is working properly."
else
    echo "Error: Test model failed to respond. There might be an issue with Ollama."
    
    # Check Ollama server status
    echo "Checking Ollama server status..."
    if pgrep -x "ollama" > /dev/null; then
        echo "Ollama server is running."
    else
        echo "Ollama server is not running. Try starting it with: ollama serve"
    fi
fi

# Delete test model
echo "Cleaning up..."
ollama rm test-model

echo "Test complete."
