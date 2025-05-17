#!/bin/bash
# filepath: /home/msalsouri/Projects/DB-GPT/tools/memory/cleanup-summary.sh
# Summary of cleanup actions performed

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKUP_DIR="$PROJECT_ROOT/backup_cleanup"

echo -e "${BOLD}${BLUE}DB-GPT Cleanup Summary${NC}\n"

# Check backup directory
if [ -d "$BACKUP_DIR" ]; then
    echo -e "${BOLD}Files moved to backup directory:${NC}"
    
    # Count backup files
    BAK_COUNT=$(find "$BACKUP_DIR" -maxdepth 1 -name "*.bak" | wc -l)
    TEMP_COUNT=$(find "$BACKUP_DIR" -maxdepth 1 -name "temp-*" | wc -l)
    TMP_COUNT=$(find "$BACKUP_DIR" -maxdepth 1 -name "*.tmp" | wc -l)
    
    echo -e "  ${GREEN}✓ ${BAK_COUNT}${NC} backup files (.bak)"
    echo -e "  ${GREEN}✓ ${TEMP_COUNT}${NC} temporary files (temp-*)"
    echo -e "  ${GREEN}✓ ${TMP_COUNT}${NC} temporary files (.tmp)"
    
    # List files in backup directory
    echo -e "\n${BOLD}Backup directory contents:${NC}"
    ls -la "$BACKUP_DIR" | grep -v "^total" | grep -v "^d"
    
    echo -e "\n${YELLOW}You can restore these files if needed, or remove them permanently with:${NC}"
    echo -e "  ${CYAN}rm -rf $BACKUP_DIR${NC}"
else
    echo -e "${RED}No backup directory found. No files have been moved.${NC}"
fi

# Check for organized model files
echo -e "\n${BOLD}Model file organization:${NC}"
MODEL_COUNT=$(find "$PROJECT_ROOT/tools/memory/models" -name "*.Modelfile" | wc -l)

if [ "$MODEL_COUNT" -gt 0 ]; then
    echo -e "  ${GREEN}✓ ${MODEL_COUNT}${NC} model files organized in tools/memory/models/"
    echo -e "  ${GREEN}Available models:${NC}"
    find "$PROJECT_ROOT/tools/memory/models" -name "*.Modelfile" | while read -r model; do
        echo -e "    - $(basename "$model")"
    done
else
    echo -e "  ${RED}No model files found in tools/memory/models/ directory.${NC}"
fi

# Check for memory management scripts
echo -e "\n${BOLD}Memory management scripts:${NC}"
if [ -f "$PROJECT_ROOT/tools/memory/memory-tools-manager.sh" ]; then
    echo -e "  ${GREEN}✓${NC} Memory tools manager installed"
else
    echo -e "  ${RED}✗${NC} Memory tools manager not found"
fi

if [ -f "$PROJECT_ROOT/tools/memory/cleanup-temp-files.sh" ]; then
    echo -e "  ${GREEN}✓${NC} Temporary file cleanup tool installed"
else
    echo -e "  ${RED}✗${NC} Temporary file cleanup tool not found"
fi

# Check documentation
echo -e "\n${BOLD}Memory management documentation:${NC}"
if [ -f "$PROJECT_ROOT/tools/memory/ORGANIZATION.md" ]; then
    echo -e "  ${GREEN}✓${NC} Organization documentation updated"
else
    echo -e "  ${RED}✗${NC} Organization documentation not found"
fi

if [ -f "$PROJECT_ROOT/tools/memory/models/README.md" ]; then
    echo -e "  ${GREEN}✓${NC} Model documentation updated"
else
    echo -e "  ${RED}✗${NC} Model documentation not found"
fi

echo -e "\n${BOLD}${GREEN}Project Cleanup Complete!${NC}"
echo -e "${YELLOW}For a better organized experience, use the memory tools manager:${NC}"
echo -e "  ${CYAN}$PROJECT_ROOT/tools/memory/memory-tools-manager.sh${NC}"
echo ""

exit 0
