#!/bin/bash
# filepath: /home/msalsouri/Projects/DB-GPT/run-smart-shell-agent.sh
# Smart Shell Agent - An intelligent assistant for DB-GPT
# This script provides a natural language interface to interact with the DB-GPT project

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
NC='\033[0m' # No Color

# Get project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default model
MODEL="smart-shell-agent"

# Function to display help
show_help() {
    echo -e "${BOLD}Smart Shell Agent - Natural Language Assistant for DB-GPT${NC}"
    echo ""
    echo -e "Usage: ${CYAN}$(basename "$0") [OPTIONS]${NC}"
    echo ""
    echo "OPTIONS:"
    echo -e "  ${GREEN}-h, --help${NC}             Show this help message"
    echo -e "  ${GREEN}-m, --model MODEL${NC}      Use a different model (default: smart-shell-agent)"
    echo -e "  ${GREEN}-b, --build${NC}            Build/rebuild the model before starting"
    echo -e "  ${GREEN}--background${NC}           Run a background task"
    echo -e "  ${GREEN}--suggest${NC}              Get suggestions for improvements"
    echo -e "  ${GREEN}--collaborate${NC}          Start a collaborative session"
    echo -e "  ${GREEN}--cleanup${NC}              Clean up unwanted files and commit changes"
    echo ""
    echo -e "Examples:"
    echo -e "  ${CYAN}$(basename "$0")${NC}                         # Start the smart shell agent"
    echo -e "  ${CYAN}$(basename "$0") --build${NC}                 # Build and start the smart shell agent"
    echo -e "  ${CYAN}$(basename "$0") --model codellama${NC}       # Use codellama instead"
    echo -e "  ${CYAN}$(basename "$0") --background${NC}            # Run a background task"
    echo -e "  ${CYAN}$(basename "$0") --cleanup${NC}               # Clean up and commit changes"
    echo ""
}

# Function to build the model
build_model() {
    echo -e "\n${YELLOW}Building Smart Shell Agent model...${NC}"
    
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
    
    # Check if the model file exists
    if [ ! -f "$PROJECT_ROOT/smart-shell-agent.Modelfile" ]; then
        echo -e "${RED}Error: Model file not found at $PROJECT_ROOT/smart-shell-agent.Modelfile${NC}"
        exit 1
    fi
    
    # Build the model
    cd "$PROJECT_ROOT" || exit
    
    # Add repository information to provide context
    TEMP_MODELFILE=$(mktemp)
    cat "$PROJECT_ROOT/smart-shell-agent.Modelfile" > "$TEMP_MODELFILE"
    
    # Add repository structure information
    echo -e "\n# Repository Structure" >> "$TEMP_MODELFILE"
    echo "SYSTEM \"\"\"" >> "$TEMP_MODELFILE"
    echo "Repository Structure:" >> "$TEMP_MODELFILE"
    find "$PROJECT_ROOT" -maxdepth 2 -type f -not -path "*/\.*" -not -path "*/node_modules/*" -not -path "*/venv/*" \
        | sort | sed 's|'"$PROJECT_ROOT"'|PROJECT_ROOT|g' | head -n 50 >> "$TEMP_MODELFILE"
    echo "\"\"\"" >> "$TEMP_MODELFILE"
    
    # Add key alias info without trying to include all documentation
    echo -e "\n# Alias Information" >> "$TEMP_MODELFILE"
    echo "SYSTEM \"\"\"" >> "$TEMP_MODELFILE"
    echo "DB-GPT provides various aliases for common operations:" >> "$TEMP_MODELFILE"
    echo "- Git aliases (gs, gco, gcb, gp, etc.)" >> "$TEMP_MODELFILE"
    echo "- Ollama manager aliases (om, om-list, om-pull, etc.)" >> "$TEMP_MODELFILE"
    echo "- Shell helper aliases (sh-help, sh-explain, etc.)" >> "$TEMP_MODELFILE"
    echo "- MCP server aliases (mcp-start, mcp-test, etc.)" >> "$TEMP_MODELFILE"
    echo "- Memory management aliases (memory-stats, memory-clean, etc.)" >> "$TEMP_MODELFILE"
    echo "\"\"\"" >> "$TEMP_MODELFILE"
    
    # Build the model with ollama
    if ollama create "$MODEL" -f "$TEMP_MODELFILE"; then
        echo -e "${GREEN}Model built successfully!${NC}"
    else
        echo -e "${RED}Error building model. Check the Modelfile for syntax errors.${NC}"
        echo -e "${YELLOW}Saving problematic Modelfile for debugging to $PROJECT_ROOT/debug-modelfile.txt${NC}"
        cp "$TEMP_MODELFILE" "$PROJECT_ROOT/debug-modelfile.txt"
        exit 1
    fi
    
    # Clean up
    rm "$TEMP_MODELFILE"
}

# Function to start a background task
run_background_task() {
    echo -e "\n${YELLOW}Starting background task...${NC}"
    echo -e "${CYAN}What task would you like to run in the background?${NC}"
    read -r task_description
    
    # Generate a unique identifier for this task
    task_id=$(date +%s)
    
    # Create a background task file
    mkdir -p "$PROJECT_ROOT/.background_tasks"
    task_file="$PROJECT_ROOT/.background_tasks/task_${task_id}.txt"
    
    # Write task description to file
    echo "Task ID: ${task_id}" > "$task_file"
    echo "Created: $(date)" >> "$task_file"
    echo "Description: ${task_description}" >> "$task_file"
    echo "Status: Running" >> "$task_file"
    
    # Here you'd typically launch an actual background process
    # For now, we'll simulate it with a placeholder
    
    echo -e "${GREEN}Background task started with ID: ${task_id}${NC}"
    echo -e "${CYAN}You can check its status later with: bg-task-status ${task_id}${NC}"
}

# Function to get suggestions
get_suggestions() {
    echo -e "\n${YELLOW}Generating project improvement suggestions...${NC}"
    echo -e "${CYAN}What area would you like suggestions for?${NC}"
    echo -e "1. ${GREEN}Performance${NC}"
    echo -e "2. ${GREEN}Architecture${NC}"
    echo -e "3. ${GREEN}User Experience${NC}"
    echo -e "4. ${GREEN}Development Workflow${NC}"
    echo -e "5. ${GREEN}All Areas${NC}"
    read -r suggestion_area
    
    # Here we would typically analyze the project and generate real suggestions
    # For now, we'll use ollama to generate them
    
    case "$suggestion_area" in
        1|performance|Performance) area="performance" ;;
        2|architecture|Architecture) area="architecture" ;;
        3|user|experience|User|Experience) area="user experience" ;;
        4|development|workflow|Development|Workflow) area="development workflow" ;;
        5|all|All) area="all areas of the project" ;;
        *) area="the project" ;;
    esac
    
    echo -e "\n${YELLOW}Analyzing $area...${NC}"
    ollama run "$MODEL" "Generate 3-5 specific suggestions to improve $area in the DB-GPT project. Focus on practical, actionable items."
}

# Function to start a collaborative session
start_collaboration() {
    echo -e "\n${YELLOW}Starting collaborative session...${NC}"
    echo -e "${CYAN}What would you like to collaborate on?${NC}"
    read -r collab_topic
    
    # Here we would typically set up a real collaborative environment
    # For now, we'll simulate it with ollama
    
    echo -e "\n${GREEN}Collaborative session started on: ${collab_topic}${NC}"
    echo -e "${CYAN}I'll help guide this session. Let's begin by breaking down the topic.${NC}\n"
    
    ollama run "$MODEL" "Let's collaborate on this topic: $collab_topic. First, let's break this down into smaller tasks and create a plan. What are the key components or steps we need to address?"
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
        
        # Ask if user wants to push
        echo -e "\n${CYAN}Would you like to push these changes? (y/n)${NC}"
        read -r push_changes
        
        if [[ "$push_changes" =~ ^[Yy]$ ]]; then
            git push
            echo -e "${GREEN}Changes pushed to remote repository${NC}"
        fi
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
        --background)
            BACKGROUND=true
            shift
            ;;
        --suggest)
            SUGGEST=true
            shift
            ;;
        --collaborate)
            COLLABORATE=true
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
if ! echo "Hello" | ollama run "$MODEL" 2>/dev/null; then
    echo -e "${RED}Error: The model doesn't seem to be working properly.${NC}"
    echo -e "${YELLOW}Attempting to rebuild the model...${NC}"
    build_model
    
    # Test again after rebuilding
    if ! echo "Hello" | ollama run "$MODEL" 2>/dev/null; then
        echo -e "${RED}Error: Model still not working after rebuild. Please check the Ollama installation.${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}Model is working properly!${NC}"

# Execute the requested action
if [ "$BACKGROUND" = true ]; then
    run_background_task
elif [ "$SUGGEST" = true ]; then
    get_suggestions
elif [ "$COLLABORATE" = true ]; then
    start_collaboration
elif [ "$CLEANUP" = true ]; then
    cleanup_and_commit
else
    # Start the interactive shell agent
    echo -e "${BOLD}${CYAN}Smart Shell Agent${NC} - ${GREEN}Ask me anything about DB-GPT!${NC}"
    echo -e "${YELLOW}Type 'exit' or 'quit' to end the session${NC}"
    echo -e "${YELLOW}Type 'help' for assistance with using aliases and commands${NC}"
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
        
        # Process user input and get response from ollama
        echo -e "\n${BLUE}Smart Shell Agent:${NC}"
        ollama run "$MODEL" "$user_input"
        echo ""
    done
fi

exit 0
