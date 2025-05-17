#!/bin/bash
# filepath: /home/msalsouri/Projects/DB-GPT/tools/memory/enhanced-cleanup.sh
# Enhanced cleanup script for the DB-GPT project
# This script identifies and handles duplicate and unused files

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKUP_DIR="$PROJECT_ROOT/backup_cleanup"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR/modelfiles"
mkdir -p "$BACKUP_DIR/scripts"
mkdir -p "$BACKUP_DIR/docs"

echo -e "${BOLD}${BLUE}DB-GPT Enhanced Cleanup Tool${NC}\n"
echo -e "${YELLOW}This tool will identify and organize duplicate and unused files${NC}"
echo -e "${YELLOW}Files will be moved to: $BACKUP_DIR${NC}\n"

# Function to handle duplicate Modelfiles
cleanup_duplicate_modelfiles() {
  echo -e "\n${BOLD}Checking for duplicate Modelfiles...${NC}"
  
  # Models that should be in tools/memory/models
  MODEL_FILES=(
    "lite-test.Modelfile"
    "minimal-test.Modelfile"
    "minimal-shell-agent.Modelfile"
    "shell-agent.Modelfile"
    "smart-shell-agent.Modelfile"
    "smart-shell-agent-lite.Modelfile"
    "test-model.Modelfile"
  )
  
  # Check for duplicates in root directory
  for model in "${MODEL_FILES[@]}"; do
    if [ -f "$PROJECT_ROOT/$model" ] && [ -f "$PROJECT_ROOT/tools/memory/models/$model" ]; then
      echo -e "  ${YELLOW}Found duplicate:${NC} $model"
      # Compare the files
      if cmp -s "$PROJECT_ROOT/$model" "$PROJECT_ROOT/tools/memory/models/$model"; then
        echo -e "  ${GREEN}Files are identical. Moving duplicate to backup.${NC}"
        mv "$PROJECT_ROOT/$model" "$BACKUP_DIR/modelfiles/"
        echo -e "  ${GREEN}Moved${NC} $model ${GREEN}to${NC} backup_cleanup/modelfiles/"
      else
        echo -e "  ${RED}Warning:${NC} Files differ. Keeping both but renaming root version."
        mv "$PROJECT_ROOT/$model" "$BACKUP_DIR/modelfiles/$model.root"
        echo -e "  ${GREEN}Moved${NC} $model ${GREEN}to${NC} backup_cleanup/modelfiles/$model.root"
      fi
    fi
  done
}

# Function to handle duplicate shell scripts
cleanup_duplicate_scripts() {
  echo -e "\n${BOLD}Checking for duplicate shell scripts...${NC}"
  
  # Scripts that should be in tools/memory
  SCRIPTS=(
    "cleanup-ollama.sh"
    "monitor-memory.sh"
    "optimize-ollama-params.sh"
    "test-minimal-agent.sh"
  )
  
  # Check for duplicates in root directory
  for script in "${SCRIPTS[@]}"; do
    if [ -f "$PROJECT_ROOT/$script" ] && [ -f "$PROJECT_ROOT/tools/memory/$script" ]; then
      echo -e "  ${YELLOW}Found duplicate:${NC} $script"
      # Compare the files
      if cmp -s "$PROJECT_ROOT/$script" "$PROJECT_ROOT/tools/memory/$script"; then
        echo -e "  ${GREEN}Files are identical. Moving duplicate to backup.${NC}"
        mv "$PROJECT_ROOT/$script" "$BACKUP_DIR/scripts/"
        echo -e "  ${GREEN}Moved${NC} $script ${GREEN}to${NC} backup_cleanup/scripts/"
      else
        echo -e "  ${RED}Warning:${NC} Files differ. Keeping both but renaming root version."
        mv "$PROJECT_ROOT/$script" "$BACKUP_DIR/scripts/$script.root"
        echo -e "  ${GREEN}Moved${NC} $script ${GREEN}to${NC} backup_cleanup/scripts/$script.root"
      fi
    fi
  done
}

# Function to find and clean temporary files
cleanup_temp_files() {
  echo -e "\n${BOLD}Checking for temporary files...${NC}"
  
  # Temporary file patterns
  TEMP_PATTERNS=(
    "*.bak"
    "temp-*"
    "*.tmp"
    "*~"
    ".*.swp"
    ".shell_training*"
  )
  
  # Process each pattern
  for pattern in "${TEMP_PATTERNS[@]}"; do
    echo -e "  ${CYAN}Looking for${NC} $pattern ${CYAN}files...${NC}"
    
    # Find all matching files in the project (except in backup_cleanup)
    find "$PROJECT_ROOT" -path "$BACKUP_DIR" -prune -o -name "$pattern" -type f -print | while read -r file; do
      rel_path=${file#"$PROJECT_ROOT/"}
      echo -e "  ${YELLOW}Found:${NC} $rel_path"
      
      # Create directory structure in backup if needed
      dir_path=$(dirname "$rel_path")
      if [ "$dir_path" != "." ]; then
        mkdir -p "$BACKUP_DIR/$dir_path"
      fi
      
      # Move the file
      mv "$file" "$BACKUP_DIR/$rel_path"
      echo -e "  ${GREEN}Moved to${NC} backup_cleanup/$rel_path"
    done
  done
}

# Function to clean up redundant README files
cleanup_redundant_docs() {
  echo -e "\n${BOLD}Checking for possibly redundant documentation...${NC}"
  
  # Patterns for potentially redundant docs
  DOC_PATTERNS=(
    "*README*~*.md"
    "README_*.md"
    "*-README-*.md"
  )
  
  # Known documentation files to keep
  KEEP_DOCS=(
    "README.md"
    "README.zh.md"
    "README.ja.md"
    "ALIASES_README.md"
  )
  
  # Process each pattern
  for pattern in "${DOC_PATTERNS[@]}"; do
    echo -e "  ${CYAN}Looking for${NC} $pattern ${CYAN}files...${NC}"
    
    # Find all matching files in the project (except in backup_cleanup)
    find "$PROJECT_ROOT" -path "$BACKUP_DIR" -prune -o -name "$pattern" -type f -print | while read -r file; do
      # Skip the files in the keep list
      skip=false
      for keep in "${KEEP_DOCS[@]}"; do
        if [[ "$(basename "$file")" == "$keep" ]]; then
          skip=true
          break
        fi
      done
      
      if [ "$skip" = true ]; then
        continue
      fi
      
      rel_path=${file#"$PROJECT_ROOT/"}
      echo -e "  ${YELLOW}Found potential redundant doc:${NC} $rel_path"
      
      # Ask user if they want to backup the file
      echo -ne "  ${CYAN}Would you like to back up this file? (y/n):${NC} "
      read -r response
      
      if [[ "$response" =~ ^[Yy]$ ]]; then
        # Create directory structure in backup if needed
        dir_path=$(dirname "$rel_path")
        if [ "$dir_path" != "." ]; then
          mkdir -p "$BACKUP_DIR/$dir_path"
        fi
        
        # Move the file
        mv "$file" "$BACKUP_DIR/$rel_path"
        echo -e "  ${GREEN}Moved to${NC} backup_cleanup/$rel_path"
      else
        echo -e "  ${CYAN}Keeping file in place.${NC}"
      fi
    done
  done
}

# Function to run the basic cleanup script
run_basic_cleanup() {
  echo -e "\n${BOLD}Running standard cleanup procedure...${NC}"
  if [ -f "$SCRIPT_DIR/cleanup_temp_files.sh" ]; then
    "$SCRIPT_DIR/cleanup_temp_files.sh"
  elif [ -f "$SCRIPT_DIR/cleanup-temp-files.sh" ]; then
    "$SCRIPT_DIR/cleanup-temp-files.sh"
  else
    echo -e "${RED}Basic cleanup script not found.${NC}"
  fi
}

# Function to specifically clean shell training files
cleanup_shell_training() {
  echo -e "\n${BOLD}Looking specifically for shell training files...${NC}"
  
  # Create shell_training backup directory if it doesn't exist
  mkdir -p "$BACKUP_DIR/shell_training"
  
  # Find shell training files
  find "$PROJECT_ROOT" -path "$BACKUP_DIR" -prune -o -name ".shell_training*" -print | while read -r file; do
    rel_path=${file#"$PROJECT_ROOT/"}
    echo -e "  ${YELLOW}Found shell training file:${NC} $rel_path"
    
    # Move to backup
    mv "$file" "$BACKUP_DIR/shell_training/"
    echo -e "  ${GREEN}Moved to${NC} backup_cleanup/shell_training/$(basename "$file")"
  done
  
  # Check for shell-training* files (non-hidden)
  find "$PROJECT_ROOT" -path "$BACKUP_DIR" -prune -o -name "shell-training*" -print | while read -r file; do
    rel_path=${file#"$PROJECT_ROOT/"}
    echo -e "  ${YELLOW}Found shell training file:${NC} $rel_path"
    
    # Move to backup
    mv "$file" "$BACKUP_DIR/shell_training/"
    echo -e "  ${GREEN}Moved to${NC} backup_cleanup/shell_training/$(basename "$file")"
  done
}

# Main menu function
show_menu() {
  echo -e "\n${BOLD}${BLUE}Select a cleanup operation:${NC}"
  echo -e "  ${YELLOW}1${NC}. ${GREEN}Clean duplicate Modelfiles${NC}"
  echo -e "  ${YELLOW}2${NC}. ${GREEN}Clean duplicate scripts${NC}"
  echo -e "  ${YELLOW}3${NC}. ${GREEN}Clean temporary files${NC}"
  echo -e "  ${YELLOW}4${NC}. ${GREEN}Clean redundant documentation${NC}"
  echo -e "  ${YELLOW}5${NC}. ${GREEN}Clean shell training files${NC}"
  echo -e "  ${YELLOW}6${NC}. ${GREEN}Run basic cleanup${NC}"
  echo -e "  ${YELLOW}7${NC}. ${GREEN}Run all cleanup operations${NC}"
  echo -e "  ${YELLOW}0${NC}. ${RED}Exit${NC}"
  
  echo -ne "\n${BOLD}Enter your choice [0-7]:${NC} "
  read -r choice
  
  case $choice in
    1) cleanup_duplicate_modelfiles ;;
    2) cleanup_duplicate_scripts ;;
    3) cleanup_temp_files ;;
    4) cleanup_redundant_docs ;;
    5) cleanup_shell_training ;;
    6) run_basic_cleanup ;;
    7)
      cleanup_duplicate_modelfiles
      cleanup_duplicate_scripts
      cleanup_temp_files
      cleanup_redundant_docs
      cleanup_shell_training
      run_basic_cleanup
      ;;
    0) 
      echo -e "\n${GREEN}Exiting cleanup tool.${NC}"
      exit 0
      ;;
    *)
      echo -e "\n${RED}Invalid option. Please try again.${NC}"
      ;;
  esac
  
  # Run the summary script if it exists
  if [ -f "$SCRIPT_DIR/cleanup-summary.sh" ]; then
    echo -e "\n${CYAN}Generating cleanup summary...${NC}"
    "$SCRIPT_DIR/cleanup-summary.sh"
  fi
  
  echo -e "\n${BOLD}${GREEN}Cleanup operation completed!${NC}"
  echo -e "${YELLOW}Files have been backed up to: $BACKUP_DIR${NC}"
  echo -e "${CYAN}Review the backup directory before permanently deleting any files.${NC}"
}

# Run the menu
show_menu

exit 0
