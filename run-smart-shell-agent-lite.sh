#!/bin/bash
# filepath: /home/msalsouri/Projects/DB-GPT/run-smart-shell-agent-lite.sh
# Smart Shell Agent (Memory-Efficient Version) - An intelligent assistant for DB-GPT
# This script provides a natural language interface with lower memory usage

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default model
MODEL="smart-shell-agent-lite"

# Function to display help
show_help() {
    echo -e "${BOLD}Smart Shell Agent Lite - Natural Language Assistant for DB-GPT${NC}"
    echo ""
    echo -e "Usage: ${CYAN}$(basename "$0") [OPTIONS]${NC}"
    echo ""
    echo "OPTIONS:"
    echo -e "  ${GREEN}-h, --help${NC}             Show this help message"
    echo -e "  ${GREEN}-m, --model MODEL${NC}      Use a different model (default: smart-shell-agent-lite)"
    echo -e "  ${GREEN}-b, --build${NC}            Build/rebuild the model before starting"
    echo -e "  ${GREEN}--cleanup${NC}              Clean up unwanted files and commit changes"
    echo ""
    echo -e "Examples:"
    echo -e "  ${CYAN}$(basename "$0")${NC}                         # Start the smart shell agent (lite version)"
    echo -e "  ${CYAN}$(basename "$0") --build${NC}                 # Build and start the smart shell agent"
    echo ""
}

# Function to build the model
build_model() {
    echo -e "\n${YELLOW}Building Smart Shell Agent Lite model...${NC}"
    
    # Check if ollama is installed
    if ! command -v ollama &> /dev/null; then
        echo -e "${RED}Error: Ollama is not installed or not in your PATH.${NC}"
        echo -e "${YELLOW}Please install Ollama first: https://ollama.ai/download${NC}"
        exit 1
    fi
    
    # Check if the base model (codellama) exists
    if ! ollama list | grep -q "codellama"; then
        echo -e "${YELLOW}Base model 'codellama' not found. Pulling it now...${NC}"
        ollama pull codellama
        if [ $? -ne 0 ]; then
            echo -e "${RED}Error: Failed to pull codellama model.${NC}"
            exit 1
        fi
    fi
    
    # Create a memory-efficient Modelfile
    TEMP_MODELFILE=$(mktemp)
    
    # Write basic modelfile
    cat > "$TEMP_MODELFILE" << EOF
FROM codellama:latest

# Set parameters for optimal response with lower memory usage
PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER seed 42

# Add smart shell agent system prompt
SYSTEM """
You are SmartShellAgent, an intelligent AI assistant for the DB-GPT project with knowledge of the repository, its aliases, and best practices.

Your main capabilities include:
1. Understanding natural language queries about the project
2. Providing information about repository structure and aliases
3. Suggesting improvements and best practices
4. Helping with git operations and project management

Remember that your purpose is to make the user's experience with DB-GPT as smooth and productive as possible.
"""
EOF
    
    # Add minimal repository structure information
    echo -e "\n# Repository Structure" >> "$TEMP_MODELFILE"
    echo "SYSTEM \"\"\"" >> "$TEMP_MODELFILE"
    echo "Repository Structure:" >> "$TEMP_MODELFILE"
    find "$PROJECT_ROOT" -maxdepth 1 -type f -not -path "*/\.*" | sort | sed 's|'"$PROJECT_ROOT"'|PROJECT_ROOT|g' | head -n 20 >> "$TEMP_MODELFILE"
    echo "\"\"\"" >> "$TEMP_MODELFILE"
    
    # Add basic alias info
    echo -e "\n# Alias Information" >> "$TEMP_MODELFILE"
    echo "SYSTEM \"\"\"" >> "$TEMP_MODELFILE"
    echo "Common DB-GPT aliases:" >> "$TEMP_MODELFILE"
    echo "- Git aliases (gs, gco, gcb, gp)" >> "$TEMP_MODELFILE"
    echo "- Ollama manager aliases (om, om-list)" >> "$TEMP_MODELFILE"
    echo "- MCP server aliases (mcp-start, mcp-test)" >> "$TEMP_MODELFILE"
    echo "\"\"\"" >> "$TEMP_MODELFILE"
    
    # Build the model with ollama
    if ollama create "$MODEL" -f "$TEMP_MODELFILE"; then
        echo -e "${GREEN}Model built successfully!${NC}"
        # Save a copy of the successful modelfile
        cp "$TEMP_MODELFILE" "$PROJECT_ROOT/$MODEL.Modelfile"
    else
        echo -e "${RED}Error building model. Check the Modelfile for syntax errors.${NC}"
        echo -e "${YELLOW}Saving problematic Modelfile for debugging to $PROJECT_ROOT/debug-modelfile-lite.txt${NC}"
        cp "$TEMP_MODELFILE" "$PROJECT_ROOT/debug-modelfile-lite.txt"
        exit 1
    fi
    
    # Clean up
    rm "$TEMP_MODELFILE"
}

# Function to clean up unwanted files and commit changes
cleanup_and_commit() {
    echo -e "\n${YELLOW}Cleaning up project and committing changes...${NC}"
    cd "$PROJECT_ROOT" || exit
    
    # Show current git status
    echo -e "${CYAN}Current git status:${NC}"
    git status
    
    # Ask which files to ignore
    echo -e "\n${CYAN}Would you like to add any files to .gitignore? (y/n)${NC}"
    read -r add_to_gitignore
    
    if [[ "$add_to_gitignore" =~ ^[Yy]$ ]]; then
        echo -e "${CYAN}Enter filenames or patterns to add to .gitignore (one per line, empty line to finish):${NC}"
        while true; do
            read -r ignore_pattern
            if [ -z "$ignore_pattern" ]; then
                break
            fi
            echo "$ignore_pattern" >> "$PROJECT_ROOT/.gitignore"
            echo -e "${GREEN}Added '$ignore_pattern' to .gitignore${NC}"
        done
    fi
    
    # Ask which files to stage
    echo -e "\n${CYAN}Would you like to stage all files? (y/n)${NC}"
    read -r stage_all
    
    if [[ "$stage_all" =~ ^[Yy]$ ]]; then
        git add .
        echo -e "${GREEN}Staged all files${NC}"
    else
        echo -e "${CYAN}Enter filenames to stage (one per line, empty line to finish):${NC}"
        while true; do
            read -r stage_file
            if [ -z "$stage_file" ]; then
                break
            fi
            git add "$stage_file"
            echo -e "${GREEN}Staged '$stage_file'${NC}"
        done
    fi
    
    # Show updated git status
    echo -e "\n${CYAN}Updated git status:${NC}"
    git status
    
    # Ask for commit message
    echo -e "\n${CYAN}Enter commit message:${NC}"
    read -r commit_message
    
    if [ -n "$commit_message" ]; then
        git commit -m "$commit_message"
        echo -e "${GREEN}Changes committed with message: '$commit_message'${NC}"
    else
        echo -e "${YELLOW}No commit message provided. Changes remain staged but not committed.${NC}"
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -m|--model)
            MODEL="$2"
            shift 2
            ;;
        -b|--build)
            BUILD=true
            shift
            ;;
        --cleanup)
            CLEANUP=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Build the model if requested
if [ "$BUILD" = true ]; then
    build_model
fi

# Check if the model exists
if ! ollama list | grep -q "$MODEL"; then
    echo -e "${YELLOW}Model $MODEL not found. Building it now...${NC}"
    build_model
fi

# Verify the model works properly
echo -e "${YELLOW}Testing the model...${NC}"
if ! (echo "Test" | ollama run "$MODEL" "Reply with one word: Working" | grep -q "Working"); then
    echo -e "${RED}Error: The model doesn't seem to be working properly.${NC}"
    echo -e "${YELLOW}Attempting to rebuild the model...${NC}"
    build_model
    
    # Test again after rebuilding
    if ! (echo "Test" | ollama run "$MODEL" "Reply with one word: Working" | grep -q "Working"); then
        echo -e "${RED}Error: Model still not working after rebuild. Please check the Ollama installation.${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}Model is working properly!${NC}"

# Execute the requested action
if [ "$CLEANUP" = true ]; then
    cleanup_and_commit
else
    # Start the interactive shell agent with memory-efficient parameters
    echo -e "${BOLD}${CYAN}Smart Shell Agent Lite${NC} - ${GREEN}Ask me anything about DB-GPT!${NC}"
    echo -e "${YELLOW}Type 'exit' or 'quit' to end the session${NC}"
    echo -e "${YELLOW}Type 'help' for assistance${NC}"
    echo ""
    
    # Start the conversation loop
    while true; do
        # Display prompt and get user input
        echo -e "${GREEN}You:${NC} " 
        read -r user_input
        
        # Check for exit command
        if [[ "$user_input" =~ ^(exit|quit)$ ]]; then
            echo -e "${YELLOW}Goodbye!${NC}"
            break
        fi
        
        # Process user input and get response from ollama with reduced parameters
        echo -e "\n${BLUE}Smart Shell Agent:${NC}"
        ollama run "$MODEL" "$user_input"
        echo ""
    done
fi

exit 0
