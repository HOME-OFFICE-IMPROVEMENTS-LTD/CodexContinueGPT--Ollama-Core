#!/bin/bash
# Script to remove documentation files from root directory after they've been copied to docs/wiki

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}====================================${NC}"
echo -e "${CYAN}   DB-GPT Documentation Cleanup     ${NC}"
echo -e "${CYAN}====================================${NC}"
echo ""

# Change to the repository directory
cd "$(dirname "$0")" || exit

# Check if docs/wiki directory exists
if [ ! -d "docs/wiki" ]; then
    echo -e "${RED}Error: docs/wiki directory not found!${NC}"
    echo -e "${YELLOW}Please run ./organize_docs.sh first to copy files to docs/wiki${NC}"
    exit 1
fi

# Function to check and remove a file if it exists in docs/wiki
cleanup_doc() {
    local file=$1
    if [ -f "$file" ] && [ -f "docs/wiki/$(basename "$file")" ]; then
        echo -e "${YELLOW}Removing $file from root directory (copy exists in docs/wiki)${NC}"
        rm "$file"
    elif [ -f "$file" ]; then
        echo -e "${RED}Warning: $file not found in docs/wiki, not removing${NC}"
    fi
}

# List of documentation files to clean up
echo -e "${BLUE}Cleaning up documentation files from root directory...${NC}"

# Documentation files to remove from root if they exist in docs/wiki
DOCS_TO_REMOVE=(
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

# Remove each documentation file from the root if it exists in wiki
for doc in "${DOCS_TO_REMOVE[@]}"; do
    cleanup_doc "$doc"
done

echo -e "${GREEN}Documentation cleanup complete!${NC}"
echo -e "${YELLOW}You can now run ./docs_manager.sh verify to check for any remaining issues.${NC}"
