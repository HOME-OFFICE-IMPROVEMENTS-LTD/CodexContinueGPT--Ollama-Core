#!/bin/bash
# filepath: /home/msalsouri/Projects/DB-GPT/cleanup_repository.sh
# Script to remove duplicate and unused files from the DB-GPT repository

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$PROJECT_ROOT/cleanup_log.txt"

# Initialize log file
echo "Repository Cleanup Log - $(date)" > "$LOG_FILE"
echo "=================================" >> "$LOG_FILE"

echo -e "${BOLD}${CYAN}DB-GPT Repository Cleanup${NC}"
echo -e "${YELLOW}This script will remove duplicate and unused files${NC}\n"

# Function to log and display messages
log_message() {
  local level="$1"
  local message="$2"
  local color=""
  
  case "$level" in
    "INFO") color="$GREEN" ;;
    "WARNING") color="$YELLOW" ;;
    "ERROR") color="$RED" ;;
    *) color="$NC" ;;
  esac
  
  echo -e "${color}[$level] $message${NC}"
  echo "[$level] $message" >> "$LOG_FILE"
}

# Function to remove file and log it
remove_file() {
  local file="$1"
  
  if [ -f "$file" ]; then
    rm "$file"
    log_message "INFO" "Removed: $file"
  else
    log_message "WARNING" "File not found: $file"
  fi
}

# 1. Remove duplicate model files from root (keep ones in tools/memory/models)
log_message "INFO" "Removing duplicate model files from root..."
MODEL_FILES=(
  "lite-test.Modelfile"
  "minimal-test.Modelfile"
  "minimal-shell-agent.Modelfile"
  "shell-agent.Modelfile"
  "smart-shell-agent.Modelfile"
  "smart-shell-agent-lite.Modelfile"
)

for model in "${MODEL_FILES[@]}"; do
  if [ -f "$PROJECT_ROOT/$model" ] && [ -f "$PROJECT_ROOT/tools/memory/models/$model" ]; then
    remove_file "$PROJECT_ROOT/$model"
  fi
done

# 2. Remove duplicate script files from root (keep ones in tools/memory)
log_message "INFO" "Removing duplicate script files from root..."
SCRIPT_FILES=(
  "cleanup-ollama.sh"
  "monitor-memory.sh"
  "optimize-ollama-params.sh"
  "test-minimal-agent.sh"
)

for script in "${SCRIPT_FILES[@]}"; do
  if [ -f "$PROJECT_ROOT/$script" ] && [ -f "$PROJECT_ROOT/tools/memory/$script" ]; then
    remove_file "$PROJECT_ROOT/$script"
  fi
done

# 3. Remove temporary files
log_message "INFO" "Removing temporary files..."
TEMP_FILES=(
  "temp-shell-agent-manager.sh"
)

for temp in "${TEMP_FILES[@]}"; do
  remove_file "$PROJECT_ROOT/$temp"
done

# 4. Remove redundant README files
log_message "INFO" "Removing redundant documentation..."
README_FILES=(
  "DUPLICATE_FILES_REPORT.md"  # This was just created for reporting
)

for readme in "${README_FILES[@]}"; do
  remove_file "$PROJECT_ROOT/$readme"
done

# 5. Clean up backup_cleanup directory - removing redundant or outdated files
log_message "INFO" "Cleaning up backup_cleanup directory..."
if [ -d "$PROJECT_ROOT/backup_cleanup" ]; then
  rm -rf "$PROJECT_ROOT/backup_cleanup"
  log_message "INFO" "Removed backup_cleanup directory"
  # Recreate an empty one to maintain structure
  mkdir -p "$PROJECT_ROOT/backup_cleanup"
  log_message "INFO" "Created empty backup_cleanup directory"
else
  log_message "WARNING" "backup_cleanup directory not found"
fi

log_message "INFO" "Repository cleanup completed successfully"
echo -e "\n${BOLD}${GREEN}Repository cleanup completed!${NC}"
echo -e "Cleanup log saved to: ${CYAN}$LOG_FILE${NC}"

exit 0
