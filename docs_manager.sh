#!/bin/bash
# DB-GPT Documentation Manager
# This script helps manage and organize project documentation

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_DIR="$PROJECT_ROOT/docs"
WIKI_DIR="$DOCS_DIR/wiki"

print_help() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}   DB-GPT Documentation Manager    ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo ""
    echo -e "Usage: $0 [command]"
    echo ""
    echo -e "Commands:"
    echo -e "  ${GREEN}list${NC}        List all documentation files"
    echo -e "  ${GREEN}organize${NC}    Organize documentation (move files to docs/wiki)"
    echo -e "  ${GREEN}verify${NC}      Verify documentation integrity"
    echo -e "  ${GREEN}search${NC} TERM Search for a term in documentation"
    echo -e "  ${GREEN}update${NC}      Update documentation index"
    echo -e "  ${GREEN}check-dead${NC}  Check for dead links in documentation"
    echo -e "  ${GREEN}help${NC}        Show this help message"
    echo ""
}

list_docs() {
    echo -e "${BLUE}Documentation files in root directory:${NC}"
    find "$PROJECT_ROOT" -maxdepth 1 -name "*.md" | sort
    
    echo -e "\n${BLUE}Documentation files in docs/wiki:${NC}"
    find "$WIKI_DIR" -name "*.md" | sort
    
    echo -e "\n${BLUE}Other documentation:${NC}"
    find "$DOCS_DIR" -name "*.md" -not -path "$WIKI_DIR/*" | sort
}

organize_docs() {
    echo -e "${YELLOW}Running documentation organizer...${NC}"
    "$PROJECT_ROOT/organize_docs.sh"
}

verify_docs() {
    echo -e "${YELLOW}Verifying documentation integrity...${NC}"
    
    # Check for duplicate files
    echo -e "${BLUE}Checking for duplicate documentation...${NC}"
    ROOT_FILES=$(find "$PROJECT_ROOT" -maxdepth 1 -name "*.md" -type f | sed 's!.*/!!')
    WIKI_FILES=$(find "$WIKI_DIR" -name "*.md" -type f | sed 's!.*/!!')
    
    DUPLICATES=0
    for file in $ROOT_FILES; do
        if echo "$WIKI_FILES" | grep -q "^$file$"; then
            echo -e "${RED}Duplicate found: $file exists in both root and docs/wiki/${NC}"
            DUPLICATES=$((DUPLICATES+1))
        fi
    done
    
    if [ $DUPLICATES -eq 0 ]; then
        echo -e "${GREEN}No duplicates found${NC}"
    else
        echo -e "${RED}$DUPLICATES duplicate file(s) found${NC}"
    fi
    
    # Check for broken internal links
    echo -e "\n${BLUE}Checking for potential broken internal links...${NC}"
    grep -r "\[.*\](.*\.md)" --include="*.md" "$PROJECT_ROOT" | while read -r line; do
        file=$(echo "$line" | cut -d: -f1)
        link=$(echo "$line" | grep -o "\[.*\](.*\.md)" | sed 's/.*(\(.*\))/\1/')
        dir=$(dirname "$file")
        
        # Check if the link is relative and the file exists
        if [[ "$link" != /* && "$link" != http* ]]; then
            if [ ! -f "$dir/$link" ]; then
                echo -e "${RED}Potential broken link: $file links to $link${NC}"
            fi
        fi
    done
}

search_docs() {
    local term="$1"
    if [ -z "$term" ]; then
        echo -e "${RED}Error: No search term provided${NC}"
        echo -e "Usage: $0 search TERM"
        exit 1
    fi
    
    echo -e "${YELLOW}Searching for '$term' in documentation...${NC}"
    grep -r --include="*.md" --color=always "$term" "$PROJECT_ROOT"
}

update_index() {
    echo -e "${YELLOW}Updating documentation index...${NC}"
    
    # Count documentation files by category
    local ollama_count=$(grep -l "ollama\|Ollama" "$WIKI_DIR"/*.md | wc -l)
    local mcp_count=$(grep -l "MCP\|Model Context Protocol" "$WIKI_DIR"/*.md | wc -l)
    local agent_count=$(grep -l "agent\|Agent" "$WIKI_DIR"/*.md | wc -l)
    local total_count=$(find "$WIKI_DIR" -name "*.md" | wc -l)
    
    # Create updated index
    cat > "$WIKI_DIR/Documentation-Index.md" << EOF
# DB-GPT Documentation Index

This index provides links to all documentation in the DB-GPT project. Currently, there are $total_count documentation files in the wiki directory.

## Documentation Categories

- Ollama Integration ($ollama_count files)
- Model Context Protocol ($mcp_count files)
- Agent System ($agent_count files)

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
- [Benchmark Tool](BENCHMARK_TOOL.md) - Model benchmarking tool

## Shell Agents

- [Enhanced Shell Agent](ENHANCED_SHELL_AGENT.md) - Enhanced shell agent with streaming
- [Agent Memory Guide](AGENT_MEMORY_GUIDE.md) - Guide for using agent memory system

## Project Information

- [Contributing](CONTRIBUTING.md) - Guide for contributing to the project
- [Security](SECURITY.md) - Security policies and procedures
- [Disclaimer](DISCKAIMER.md) - Project disclaimers and legal information

## Configuration and Usage

- [Aliases](ALIASES.md) - Shell aliases reference
- [Aliases README](ALIASES_README.md) - Comprehensive guide to shell aliases

---

Last updated: $(date)
EOF

    echo -e "${GREEN}Documentation index updated successfully${NC}"
}

check_dead_links() {
    echo -e "${YELLOW}Checking for dead links in documentation...${NC}"
    
    # Find all markdown links
    find "$PROJECT_ROOT" -name "*.md" -type f -exec grep -l "\[.*\](.*)" {} \; | while read -r file; do
        echo -e "${BLUE}Checking links in: $file${NC}"
        
        # Extract links
        grep -o "\[.*\](.*)" "$file" | sed 's/\[.*\](\(.*\))/\1/' | while read -r link; do
            # Skip external links and anchors
            if [[ "$link" == http* || "$link" == "#"* ]]; then
                continue
            fi
            
            # Remove anchor from link if present
            link_file=$(echo "$link" | cut -d'#' -f1)
            
            # Empty links (just anchors to the same file)
            if [ -z "$link_file" ]; then
                continue
            fi
            
            # Check if the linked file exists
            dir=$(dirname "$file")
            if [ ! -f "$dir/$link_file" ]; then
                echo -e "${RED}  Dead link: $link${NC}"
            fi
        done
    done
}

# Main execution
if [ $# -eq 0 ]; then
    print_help
    exit 0
fi

case "$1" in
    list)
        list_docs
        ;;
    organize)
        organize_docs
        ;;
    verify)
        verify_docs
        ;;
    search)
        search_docs "$2"
        ;;
    update)
        update_index
        ;;
    check-dead)
        check_dead_links
        ;;
    help|--help|-h)
        print_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        print_help
        exit 1
        ;;
esac
