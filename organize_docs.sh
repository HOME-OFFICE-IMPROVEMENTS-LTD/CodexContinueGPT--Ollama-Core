#!/bin/bash
# Script to organize documentation files by moving them from root to docs/wiki

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}====================================${NC}"
echo -e "${CYAN}   DB-GPT Documentation Organizer   ${NC}"
echo -e "${CYAN}====================================${NC}"
echo ""

# Change to the repository directory
cd "$(dirname "$0")" || exit

# Make sure the wiki directory exists
if [ ! -d "docs/wiki" ]; then
    echo -e "${YELLOW}Creating docs/wiki directory...${NC}"
    mkdir -p docs/wiki
fi

# Function to copy a file to docs/wiki if it exists
copy_to_wiki() {
    local file=$1
    if [ -f "$file" ]; then
        echo -e "${GREEN}Copying $file to docs/wiki/${NC}"
        cp "$file" docs/wiki/
    else
        echo -e "${RED}Warning: $file not found${NC}"
    fi
}

# List of documentation files to organize
echo -e "${BLUE}Organizing documentation files...${NC}"

# Documentation files to copy to wiki directory
DOCS_TO_COPY=(
    "AGENT_MEMORY_GUIDE.md"
    "ALIASES.md"
    "ALIASES_README.md"
    "BENCHMARK_TOOL.md"
    "CONTRIBUTING.md"
    "DISCKAIMER.md"
    "ENHANCED_MCP_OLLAMA.md"
    "ENHANCED_SHELL_AGENT.md"
    "MCP_MEMORY_AGENT.md"
    "MCP_OLLAMA.md"
    "OLLAMA_ENHANCEMENTS.md"
    "OLLAMA_INDEX.md"
    "OLLAMA_INTEGRATION.md"
    "OLLAMA_STATUS.md"
    "Ollama-Index.md"
    "SECURITY.md"
    "TODAY_ENHANCEMENTS.md"
)

# Copy each documentation file to the wiki directory
for doc in "${DOCS_TO_COPY[@]}"; do
    copy_to_wiki "$doc"
done

# Create a documentation index file in the wiki directory
echo -e "${YELLOW}Creating documentation index...${NC}"
cat > docs/wiki/Documentation-Index.md << EOF
# DB-GPT Documentation Index

This index provides links to all documentation in the DB-GPT project.

## Ollama Integration

- [Ollama Index](Ollama-Index.md) - Main index for Ollama integration
- [Ollama Integration Guide](OLLAMA_INTEGRATION.md) - How to integrate Ollama with DB-GPT
- [Ollama Status](OLLAMA_STATUS.md) - Current status of Ollama integration
- [Ollama Enhancements](OLLAMA_ENHANCEMENTS.md) - Enhancements made to Ollama integration
- [Today's Enhancements](TODAY_ENHANCEMENTS.md) - Latest enhancements to the project

## Model Context Protocol (MCP)

- [MCP Ollama](MCP_OLLAMA.md) - Basic MCP server for Ollama
- [Enhanced MCP Ollama](ENHANCED_MCP_OLLAMA.md) - Enhanced MCP server with streaming
- [MCP Memory Agent](MCP_MEMORY_AGENT.md) - MCP memory agent integration

## Shell Agents

- [Enhanced Shell Agent](ENHANCED_SHELL_AGENT.md) - Enhanced shell agent with streaming
- [Agent Memory Guide](AGENT_MEMORY_GUIDE.md) - Guide for using agent memory system

## Tools and Utilities

- [Benchmark Tool](BENCHMARK_TOOL.md) - Model benchmarking tool
- [Aliases](ALIASES.md) - Shell aliases reference
- [Aliases README](ALIASES_README.md) - Comprehensive guide to shell aliases

## Project Information

- [Contributing](CONTRIBUTING.md) - Guide for contributing to the project
- [Security](SECURITY.md) - Security policies and procedures
- [Disclaimer](DISCKAIMER.md) - Project disclaimers and legal information
EOF

echo -e "${GREEN}Documentation organization complete!${NC}"
echo -e "${YELLOW}You can now use git to add, commit, and push the changes.${NC}"
