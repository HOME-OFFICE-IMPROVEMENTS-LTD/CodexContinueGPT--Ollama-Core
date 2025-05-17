#!/bin/bash
# filepath: /home/msalsouri/Projects/DB-GPT/enhanced_analyze_untracked.sh
# Enhanced script to analyze untracked files and provide recommendations

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

echo -e "${BOLD}${CYAN}====================================${NC}"
echo -e "${BOLD}${CYAN}   Enhanced Git Analysis Tool      ${NC}"
echo -e "${BOLD}${CYAN}====================================${NC}"
echo ""

# Change to the repository directory
cd "$(dirname "$0")" || exit

# Get all untracked files
mapfile -t untracked_files < <(git ls-files --others --exclude-standard)

if [ ${#untracked_files[@]} -eq 0 ]; then
    echo -e "${GREEN}No untracked files found.${NC}"
    exit 0
fi

echo -e "${YELLOW}Found ${#untracked_files[@]} untracked files.${NC}\n"

# Define categories for better organization
declare -A file_categories
declare -A recommendations

# Analyze each file and categorize
for file in "${untracked_files[@]}"; do
    # Get file size
    size=$(du -h "$file" 2>/dev/null | cut -f1)
    
    # Categorize the file
    if [[ $file == *.md || $file == README* || $file == LICENSE* ]]; then
        file_categories["$file"]="Documentation"
        recommendations["$file"]="${GREEN}✓ Commit${NC}"
    elif [[ $file == *.py || $file == *.sh || $file == *.js || $file == *.html || $file == *.css ]]; then
        file_categories["$file"]="Source Code"
        recommendations["$file"]="${GREEN}✓ Commit${NC}"
    elif [[ $file == *.log || $file == logs/* ]]; then
        file_categories["$file"]="Log Files"
        recommendations["$file"]="${RED}✗ Add to .gitignore${NC}"
    elif [[ $file == *.pyc || $file == __pycache__/* || $file == .pytest_cache/* ]]; then
        file_categories["$file"]="Cache Files"
        recommendations["$file"]="${RED}✗ Add to .gitignore${NC}"
    elif [[ $file == *.tmp || $file == *~ || $file == *.bak ]]; then
        file_categories["$file"]="Temporary Files"
        recommendations["$file"]="${RED}✗ Add to .gitignore${NC}"
    elif [[ $file == .env* || $file == *.ini || $file == *.cfg ]]; then
        file_categories["$file"]="Configuration"
        recommendations["$file"]="${YELLOW}? Check for secrets${NC}"
    elif [[ $file == *.sqlite || $file == *.db || $file == *.json ]]; then
        file_categories["$file"]="Data Files"
        recommendations["$file"]="${YELLOW}? Review content${NC}"
    elif [[ $file == dist/* || $file == build/* || $file == node_modules/* ]]; then
        file_categories["$file"]="Build Artifacts"
        recommendations["$file"]="${RED}✗ Add to .gitignore${NC}"
    elif [[ $file == *_history* || $file == .shell_agent_* || $file == *_enhanced ]]; then
        file_categories["$file"]="Shell Agent Files"
        recommendations["$file"]="${RED}✗ Add to .gitignore${NC}"
    else
        # For other files, try to determine based on content
        if file "$file" | grep -q "text"; then
            # For text files, check content to make better decisions
            if head -n 20 "$file" | grep -q -E "import|def|class|function"; then
                file_categories["$file"]="Source Code"
                recommendations["$file"]="${GREEN}✓ Commit${NC}"
            else
                file_categories["$file"]="Miscellaneous"
                recommendations["$file"]="${YELLOW}? Review content${NC}"
            fi
        else
            file_categories["$file"]="Binary Files"
            recommendations["$file"]="${RED}✗ Add to .gitignore${NC}"
        fi
    fi
done

# Display files by category
echo -e "${BOLD}${UNDERLINE}Analysis Results:${NC}\n"

# Collect all categories
categories=(
    "Documentation"
    "Source Code"
    "Configuration"
    "Data Files"
    "Log Files"
    "Cache Files"
    "Temporary Files"
    "Build Artifacts"
    "Shell Agent Files"
    "Miscellaneous"
    "Binary Files"
)

# Files to commit and to ignore
files_to_commit=()
files_to_ignore=()

# Display files by category
for category in "${categories[@]}"; do
    echo -e "${BOLD}${BLUE}$category:${NC}"
    
    found=false
    for file in "${!file_categories[@]}"; do
        if [[ "${file_categories[$file]}" == "$category" ]]; then
            echo -e "  - ${file} $([ -n "${size}" ] && echo "(${size})") - ${recommendations[$file]}"
            found=true
            
            # Add to appropriate list based on recommendation
            if [[ "${recommendations[$file]}" == *"Commit"* ]]; then
                files_to_commit+=("$file")
            elif [[ "${recommendations[$file]}" == *"Add to .gitignore"* ]]; then
                files_to_ignore+=("$file")
            fi
        fi
    done
    
    if [ "$found" = false ]; then
        echo -e "  ${CYAN}None${NC}"
    fi
    
    echo ""
done

# Interactive section for actions
echo -e "${BOLD}${UNDERLINE}Actions:${NC}\n"

# Function to update .gitignore
update_gitignore() {
    echo -e "\n${CYAN}Updating .gitignore file...${NC}"
    
    # Ensure .gitignore exists
    touch .gitignore
    
    # Add common patterns for shell agent files
    patterns=(
        ".shell_agent_*"
        "*_history"
        "*_enhanced"
        "*.pyc"
        "__pycache__/"
        "*.log"
        "logs/"
        "*.tmp"
        "*.swp"
        "*.swo"
        "*~"
        "*.bak"
    )
    
    # Add the recommended files to ignore
    for file in "${files_to_ignore[@]}"; do
        # Convert file path to a pattern
        if [[ -d "$file" ]]; then
            pattern="${file}/"
        else
            pattern="$file"
        fi
        patterns+=("$pattern")
    done
    
    # Add each pattern if not already in .gitignore
    for pattern in "${patterns[@]}"; do
        if ! grep -q "^${pattern}$" .gitignore 2>/dev/null; then
            echo "$pattern" >> .gitignore
            echo -e "${GREEN}Added '$pattern' to .gitignore${NC}"
        fi
    done
    
    echo -e "${GREEN}Done updating .gitignore!${NC}"
}

# Function to stage recommended files
stage_recommended_files() {
    echo -e "\n${CYAN}Staging recommended files...${NC}"
    
    if [ ${#files_to_commit[@]} -eq 0 ]; then
        echo -e "${YELLOW}No files recommended for commit.${NC}"
        return
    fi
    
    for file in "${files_to_commit[@]}"; do
        git add "$file"
        echo -e "${GREEN}Staged: $file${NC}"
    done
    
    echo -e "${GREEN}Done staging files!${NC}"
}

# Ask about updating .gitignore
echo -e "${CYAN}Would you like to update .gitignore with recommended patterns? (y/n)${NC}"
read -r update_ignore_response
if [[ "$update_ignore_response" =~ ^[Yy]$ ]]; then
    update_gitignore
fi

# Ask about staging recommended files
echo -e "\n${CYAN}Would you like to stage the recommended files for commit? (y/n)${NC}"
read -r stage_response
if [[ "$stage_response" =~ ^[Yy]$ ]]; then
    stage_recommended_files
    
    # Show current git status
    echo -e "\n${CYAN}Current git status:${NC}"
    git status
    
    # Ask about committing
    echo -e "\n${CYAN}Would you like to commit these changes? (y/n)${NC}"
    read -r commit_response
    if [[ "$commit_response" =~ ^[Yy]$ ]]; then
        echo -e "${CYAN}Enter commit message:${NC}"
        read -r commit_message
        
        if [ -n "$commit_message" ]; then
            git commit -m "$commit_message"
            echo -e "${GREEN}Changes committed with message: '$commit_message'${NC}"
        else
            echo -e "${YELLOW}No commit message provided. Changes remain staged.${NC}"
        fi
    fi
fi

echo -e "\n${BOLD}${GREEN}Analysis and processing complete!${NC}"
