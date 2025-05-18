#!/bin/bash
# Final cleanup script to organize the DB-GPT repository
# This script runs all necessary cleanup operations and creates a summary

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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BOLD}${BLUE}DB-GPT Final Repository Cleanup${NC}\n"
echo -e "${YELLOW}This script will run all necessary cleanup operations to organize the DB-GPT repository${NC}\n"

# Backup directory
BACKUP_DIR="$PROJECT_ROOT/backup_cleanup"
mkdir -p "$BACKUP_DIR/shell_training"

# Run enhanced cleanup for all operations
if [ -f "$SCRIPT_DIR/enhanced-cleanup.sh" ]; then
  echo -e "${BOLD}Running enhanced cleanup tool...${NC}"
  # Automatically run all operations (option 7)
  echo "7" | "$SCRIPT_DIR/enhanced-cleanup.sh"
else
  echo -e "${RED}Enhanced cleanup tool not found!${NC}"
  exit 1
fi

# Git operations - stage all changes
echo -e "\n${BOLD}${CYAN}Staging all cleaned up files...${NC}"
cd "$PROJECT_ROOT"
git add .

# Generate commit message
COMMIT_MSG="Repository cleanup: Removed shell training files, organized memory tools, fixed Python code errors"
echo -e "\n${BOLD}${CYAN}Committing changes with message:${NC}"
echo -e "${YELLOW}$COMMIT_MSG${NC}"

# Commit changes
git commit -m "$COMMIT_MSG"

echo -e "\n${BOLD}${GREEN}All cleanup operations completed!${NC}"
echo -e "${CYAN}A git commit has been created with all the changes.${NC}"
echo -e "${YELLOW}You can now push these changes to the remote repository.${NC}"
echo -e "\n${BOLD}Use the following command to push:${NC}"
echo -e "${CYAN}git push origin <branch-name>${NC}\n"

exit 0
