#!/bin/bash
# DB-GPT Ollama Commands Helper Script
# Displays the available Ollama commands for quick reference

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${CYAN}====================================${NC}"
echo -e "${CYAN}      DB-GPT Ollama Commands        ${NC}"
echo -e "${CYAN}====================================${NC}"
echo ""

# Show shell helper commands
echo -e "${MAGENTA}=== Shell Helper Commands ===${NC}"
echo -e "${YELLOW}sh-help${NC} \"How do I find large files?\"         ${GREEN}# Get shell command help${NC}"
echo -e "${YELLOW}sh-explain${NC} \"find / -type f -size +100M\"      ${GREEN}# Explain a shell command${NC}"
echo -e "${YELLOW}sh-script${NC} \"create a backup script\"           ${GREEN}# Generate a shell script${NC}"
echo ""

# Show direct model interaction commands
echo -e "${MAGENTA}=== Direct Model Interaction ===${NC}"
echo -e "${YELLOW}ask${NC} \"Write a Python function to download a file\"       ${GREEN}# Query with CodeLlama${NC}"
echo -e "${YELLOW}ask-llama${NC} \"Explain quantum computing\"                  ${GREEN}# Query with Llama3${NC}"
echo -e "${YELLOW}ask-code${NC} \"Write a JavaScript sorting function\"         ${GREEN}# Code-specific query${NC}"
echo -e "${YELLOW}ask-any${NC} mistral \"Explain Docker containers\"            ${GREEN}# Use any model${NC}"
echo ""

# Show model management commands
echo -e "${MAGENTA}=== Model Management ===${NC}"
echo -e "${YELLOW}om-list${NC}                ${GREEN}# List available models${NC}"
echo -e "${YELLOW}om-pull${NC} MODEL          ${GREEN}# Pull a new model${NC}" 
echo -e "${YELLOW}om-update${NC} MODEL        ${GREEN}# Set model as active${NC}"
echo -e "${YELLOW}om-recommend${NC}           ${GREEN}# Show recommended models${NC}"
echo ""

# Show MCP integration commands
echo -e "${MAGENTA}=== Model Context Protocol (MCP) ===${NC}"
echo -e "${YELLOW}mcp-start-codellama${NC}    ${GREEN}# Start MCP server with CodeLlama${NC}"
echo -e "${YELLOW}mcp-start-llama3${NC}       ${GREEN}# Start MCP server with Llama3${NC}"
echo -e "${YELLOW}mcp-dbgpt${NC}              ${GREEN}# Start DB-GPT with MCP configuration${NC}"
echo ""

# Show Agent Commands (using standard Ollama)
echo -e "${MAGENTA}=== Agent Commands ===${NC}"
echo -e "${YELLOW}code-assistant${NC}         ${GREEN}# Use CodeLlama for code assistance${NC}"
echo -e "${YELLOW}shell-helper${NC}           ${GREEN}# Get shell scripting assistance${NC}"
echo -e "${YELLOW}task-manager${NC}           ${GREEN}# Manage development tasks${NC}"
echo -e "${YELLOW}audit-code${NC} FILE        ${GREEN}# Audit code in specified file${NC}"
echo -e "${YELLOW}git-helper${NC}             ${GREEN}# Git operations with auto-staging and commits${NC}"
echo -e "${YELLOW}decision-audit${NC}         ${GREEN}# Audit implementation decisions${NC}"
echo ""

echo -e "${CYAN}To use these commands, first load the aliases:${NC}"
echo -e "${YELLOW}source .aliases${NC}"
echo ""
echo -e "${GREEN}Happy coding with DB-GPT and Ollama!${NC}"
echo -e "${CYAN}====================================${NC}"
