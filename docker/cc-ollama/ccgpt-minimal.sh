# filepath: /home/msalsouri/Projects/DB-GPT/docker/cc-ollama/ccgpt-minimal.sh
#!/bin/bash
# A minimal version of the CodexContinue-GPT script for testing

MODEL="codellama"

# Process arguments
if [[ "$1" == "--auto" ]]; then
  echo "Auto-selection is enabled!"
  
  # Check input type for basic demonstration
  read -p "Enter your query: " QUERY
  
  if [[ "$QUERY" == *"code"* || "$QUERY" == *"function"* ]]; then
    MODEL="codellama"
    echo "Using code model: $MODEL"
  elif [[ "$QUERY" == *"task"* || "$QUERY" == *"todo"* ]]; then
    MODEL="mistral"
    echo "Using task model: $MODEL"
  else
    MODEL="llama3"
    echo "Using general model: $MODEL"
  fi
else
  echo "Using default model: $MODEL"
fi

echo "This is just a test!"
