#!/bin/bash
# Script to fix hardcoded paths in ollama_manager.sh and other scripts
# For CodexContinueGPT™ project

# Get the current script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"
cd "$SCRIPT_DIR"

echo "Fixing hardcoded paths in ollama_manager.sh..."

# Create backup before making changes
cp ollama_manager.sh ollama_manager.sh.backup

# Replace hardcoded paths with dynamic paths - improved version
sed -i '/# Paths and settings/,/OLLAMA_CONFIG_FILE/c\# Paths and settings\nSCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" \&\& pwd )"\nREPO_ROOT="$( cd "$SCRIPT_DIR/../.." \&\& pwd )"\nCONFIG_DIR="$REPO_ROOT/configs"\nOLLAMA_CONFIG_FILE="$CONFIG_DIR/dbgpt-proxy-ollama.toml"' ollama_manager.sh
sed -i "s|cd /home/msalsouri/Projects/DB-GPT|cd \"\$REPO_ROOT\"|g" ollama_manager.sh

echo "Done fixing paths in ollama_manager.sh"

# Fix shell_helper.sh if it exists
if [ -f shell_helper.sh ]; then
  echo "Fixing hardcoded paths in shell_helper.sh..."
  cp shell_helper.sh shell_helper.sh.backup
  
  # Replace hardcoded paths with dynamic paths - improved version
  if grep -q "/home/msalsouri/Projects/DB-GPT" shell_helper.sh; then
    sed -i '/# Set script paths/,/REPO_ROOT/c\# Set script paths\nSCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" \&\& pwd )"\nREPO_ROOT="$( cd "$SCRIPT_DIR/../.." \&\& pwd )"' shell_helper.sh
    sed -i "s|cd /home/msalsouri/Projects/DB-GPT|cd \"\$REPO_ROOT\"|g" shell_helper.sh
  fi
  echo "Done fixing paths in shell_helper.sh"
fi

# Fix ask.sh if it exists
if [ -f ask.sh ]; then
  echo "Checking paths in ask.sh..."
  if grep -q "/home/msalsouri/Projects/DB-GPT" ask.sh; then
    cp ask.sh ask.sh.backup
    sed -i "s|cd /home/msalsouri/Projects/DB-GPT|cd \"\$( cd \"\$( dirname \"\${BASH_SOURCE[0]}\" )/../..\" \&\& pwd )\"|g" ask.sh
    echo "Done fixing paths in ask.sh"
  else
    echo "No hardcoded paths found in ask.sh"
  fi
fi

echo "All hardcoded paths have been replaced with dynamic paths"
echo "Backup files created with .backup extension"
echo "Please test the scripts to confirm they work correctly"
