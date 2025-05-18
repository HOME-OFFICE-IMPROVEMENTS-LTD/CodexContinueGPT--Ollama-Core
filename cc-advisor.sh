#!/bin/bash
# cc-advisor.sh - A script to consult CodexContinueGPT before file operations
# This script helps facilitate consultation with CodexContinueGPT for file operations

# Color formatting
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function ask_cc() {
    echo -e "${CYAN}Consulting CodexContinueGPT about: ${YELLOW}$1${NC}"
    echo -e "${CYAN}--------------------------------------${NC}"
    /home/msalsouri/Projects/DB-GPT/launch-ccgpt.sh --auto "$1"
    echo -e "${CYAN}--------------------------------------${NC}"
    echo -e "${YELLOW}Does the advice make sense? Proceed with recommended action? (y/n)${NC}"
    read proceed
    if [[ $proceed == "y" ]]; then
        return 0
    else
        return 1
    fi
}

function verify_with_cc() {
    echo -e "${CYAN}Verifying with CodexContinueGPT: ${YELLOW}$1${NC}"
    echo -e "${CYAN}--------------------------------------${NC}"
    /home/msalsouri/Projects/DB-GPT/launch-ccgpt.sh --auto "$1"
    echo -e "${CYAN}--------------------------------------${NC}"
}

function move_file_with_cc() {
    local source_file="$1"
    local target_dir="$2"
    
    # Extract filename from path
    local filename=$(basename "$source_file")
    
    # Ask CC about this specific move
    if ask_cc "Should we move $filename from the project root to $target_dir? What dependencies might be affected?"; then
        # If CC approves, make a backup and move the file
        echo -e "${GREEN}Creating backup of ${YELLOW}$source_file${NC}"
        cp "$source_file" "$source_file.bak"
        
        echo -e "${GREEN}Moving ${YELLOW}$source_file${GREEN} to ${YELLOW}$target_dir${NC}"
        mv "$source_file" "$target_dir"
        
        # Verify the move was successful
        if [ -f "$target_dir/$filename" ]; then
            echo -e "${GREEN}Successfully moved file to $target_dir/$filename${NC}"
            # Ask CC to verify if we need to update any references
            verify_with_cc "Are there any references to $filename that need to be updated after moving it to $target_dir?"
            return 0
        else
            echo -e "${YELLOW}Failed to move file. Restoring from backup.${NC}"
            mv "$source_file.bak" "$source_file"
            rm -f "$source_file.bak"
            return 1
        fi
    else
        echo -e "${YELLOW}Operation canceled based on CodexContinueGPT recommendation.${NC}"
        return 1
    fi
}

function cleanup_file_with_cc() {
    local target_file="$1"
    
    # Extract filename from path
    local filename=$(basename "$target_file")
    
    # Ask CC about this deletion
    if ask_cc "Is it safe to delete $filename? Is this file referenced elsewhere or needed for any functionality?"; then
        # If CC approves, make a backup and delete the file
        echo -e "${GREEN}Creating backup of ${YELLOW}$target_file${NC}"
        cp "$target_file" "$target_file.bak"
        
        echo -e "${GREEN}Deleting ${YELLOW}$target_file${NC}"
        rm "$target_file"
        
        # Verify the deletion
        if [ ! -f "$target_file" ]; then
            echo -e "${GREEN}Successfully deleted $target_file${NC}"
            
            # Ask CC to verify if we need to update any references
            verify_with_cc "Are there any references to $filename that need to be updated after deleting it?"
            return 0
        else
            echo -e "${YELLOW}Failed to delete file.${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}Operation canceled based on CodexContinueGPT recommendation.${NC}"
        return 1
    fi
}

# New function for bulk operations
function bulk_move_with_cc() {
    local pattern="$1"
    local target_dir="$2"
    
    # Get list of files matching pattern
    local files=($(find /home/msalsouri/Projects/DB-GPT -maxdepth 1 -name "$pattern" -type f))
    
    if [ ${#files[@]} -eq 0 ]; then
        echo -e "${RED}No files matching pattern '$pattern' found.${NC}"
        return 1
    fi
    
    # Show list of files to be moved
    echo -e "${CYAN}Files to be moved:${NC}"
    for file in "${files[@]}"; do
        echo -e "  ${YELLOW}$(basename "$file")${NC}"
    done
    
    # Ask CC about this bulk move
    if ask_cc "Should we move these files matching '$pattern' to $target_dir? What dependencies might be affected?"; then
        # Create bulk backup directory
        local timestamp=$(date +"%Y%m%d_%H%M%S")
        local backup_dir="/home/msalsouri/Projects/DB-GPT/backup_cleanup/bulk_move_$timestamp"
        mkdir -p "$backup_dir"
        
        echo -e "${GREEN}Creating backups in ${YELLOW}$backup_dir${NC}"
        
        # Process each file
        local success_count=0
        for file in "${files[@]}"; do
            local filename=$(basename "$file")
            # Backup file
            cp "$file" "$backup_dir/$filename"
            
            # Move file
            echo -e "${GREEN}Moving ${YELLOW}$filename${GREEN} to ${YELLOW}$target_dir${NC}"
            mv "$file" "$target_dir/"
            
            if [ -f "$target_dir/$filename" ]; then
                echo -e "  ${GREEN}Success!${NC}"
                ((success_count++))
            else
                echo -e "  ${RED}Failed!${NC}"
            fi
        done
        
        echo -e "${GREEN}Moved $success_count out of ${#files[@]} files.${NC}"
        
        # Verify references for all moved files
        verify_with_cc "Are there any references to these files that need to be updated after moving them to $target_dir?"
        
        return 0
    else
        echo -e "${YELLOW}Operation canceled based on CodexContinueGPT recommendation.${NC}"
        return 1
    fi
}

function organize_docs_with_cc() {
    echo -e "${CYAN}Organizing documentation files with CodexContinueGPT assistance...${NC}"
    
    # Ask CC for advice on organizing docs
    if ask_cc "How should we organize the various documentation files in the project root? Which ones should be moved to docs/ollama/ and which should remain?"; then
        # Ollama docs to docs/ollama
        bulk_move_with_cc "OLLAMA_*.md" "/home/msalsouri/Projects/DB-GPT/docs/ollama"
        
        # Move MCP-related docs
        bulk_move_with_cc "MCP_*.md" "/home/msalsouri/Projects/DB-GPT/docs/ollama"
        
        # Move shell agent docs
        if [ -d "/home/msalsouri/Projects/DB-GPT/docs/shell-agent" ] || mkdir -p "/home/msalsouri/Projects/DB-GPT/docs/shell-agent"; then
            bulk_move_with_cc "*shell*agent*.md" "/home/msalsouri/Projects/DB-GPT/docs/shell-agent"
        fi
        
        echo -e "${GREEN}Documentation organization completed!${NC}"
        verify_with_cc "Have we properly organized the documentation files? Are there any other files that should be moved or references that need to be updated?"
    else
        echo -e "${YELLOW}Documentation organization canceled.${NC}"
    fi
}

function organize_scripts_with_cc() {
    echo -e "${CYAN}Organizing script files with CodexContinueGPT assistance...${NC}"
    
    # Ask CC for advice on organizing scripts
    if ask_cc "How should we organize the various shell scripts in the project root? Which ones should be moved to docker/cc-ollama/ and which should remain?"; then
        # Move test scripts to appropriate locations
        move_file_with_cc "/home/msalsouri/Projects/DB-GPT/test-shell-agent-docker.sh" "/home/msalsouri/Projects/DB-GPT/docker/cc-ollama"
        
        # Move other scripts as recommended by CC
        echo -e "${GREEN}Script organization completed!${NC}"
        verify_with_cc "Have we properly organized the script files? Are there any other files that should be moved or references that need to be updated?"
    else
        echo -e "${YELLOW}Script organization canceled.${NC}"
    fi
}

# Main menu
echo -e "${CYAN}===============================================${NC}"
echo -e "${CYAN}  CodexContinueGPT File Operations Assistant  ${NC}"
echo -e "${CYAN}===============================================${NC}"
echo -e "This script helps you consult CodexContinueGPT before file operations"
echo -e ""
echo -e "${YELLOW}Usage examples:${NC}"
echo -e "  ./cc-advisor.sh ask \"What's the best place to store our Ollama documentation files?\""
echo -e "  ./cc-advisor.sh move /path/to/file.md /path/to/target/directory"
echo -e "  ./cc-advisor.sh cleanup /path/to/unnecessary/file.md"
echo -e "  ./cc-advisor.sh verify \"Did we correctly organize the shell agent files?\""
echo -e "  ./cc-advisor.sh bulk-move \"OLLAMA_*.md\" /path/to/target/directory"
echo -e "  ./cc-advisor.sh organize-docs"
echo -e "  ./cc-advisor.sh organize-scripts"
echo -e ""

# Process arguments
if [ "$1" == "ask" ] && [ -n "$2" ]; then
    ask_cc "$2"
elif [ "$1" == "move" ] && [ -n "$2" ] && [ -n "$3" ]; then
    move_file_with_cc "$2" "$3"
elif [ "$1" == "cleanup" ] && [ -n "$2" ]; then
    cleanup_file_with_cc "$2"
elif [ "$1" == "verify" ] && [ -n "$2" ]; then
    verify_with_cc "$2"
elif [ "$1" == "bulk-move" ] && [ -n "$2" ] && [ -n "$3" ]; then
    bulk_move_with_cc "$2" "$3"
elif [ "$1" == "organize-docs" ]; then
    organize_docs_with_cc
elif [ "$1" == "organize-scripts" ]; then
    organize_scripts_with_cc
else
    echo -e "${YELLOW}Invalid command. Use ask, move, cleanup, verify, bulk-move, organize-docs or organize-scripts.${NC}"
    exit 1
fi
