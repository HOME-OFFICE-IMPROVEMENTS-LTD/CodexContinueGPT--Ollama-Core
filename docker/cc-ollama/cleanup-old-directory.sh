#!/bin/bash
# Clean up old oi-ollama directory after migration to cc-ollama

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}====================================${NC}"
echo -e "${CYAN}  oi-ollama Directory Cleanup       ${NC}"
echo -e "${CYAN}====================================${NC}"
echo ""

OLD_DIR="/home/msalsouri/Projects/DB-GPT/docker/oi-ollama"
NEW_DIR="/home/msalsouri/Projects/DB-GPT/docker/cc-ollama"

# Check if new directory exists and has content
if [ ! -d "$NEW_DIR" ]; then
    echo -e "${RED}Error: New directory $NEW_DIR does not exist!${NC}"
    echo "The migration was not completed correctly. Aborting cleanup."
    exit 1
fi

# Count files in both directories
OLD_FILE_COUNT=$(find "$OLD_DIR" -type f | wc -l)
NEW_FILE_COUNT=$(find "$NEW_DIR" -type f | wc -l)

echo -e "Old directory ($OLD_DIR) contains ${YELLOW}$OLD_FILE_COUNT${NC} files"
echo -e "New directory ($NEW_DIR) contains ${YELLOW}$NEW_FILE_COUNT${NC} files"

# Verify file counts match or new directory has more files
if [ $NEW_FILE_COUNT -lt $OLD_FILE_COUNT ]; then
    echo -e "${RED}Warning: New directory has fewer files than the old directory!${NC}"
    echo "This might indicate that not all files were copied correctly."
    echo ""
    echo -e "Would you like to continue anyway? (y/N): "
    read -r CONTINUE
    if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
        echo "Cleanup aborted."
        exit 1
    fi
fi

# Check for any remaining references to oi-ollama
echo -e "\nChecking for remaining references to old directory name..."
REFERENCES=$(grep -r "oi-ollama" --include="*.sh" --include="*.yml" --include="*.md" --exclude-dir="docker/oi-ollama" /home/msalsouri/Projects/DB-GPT/ 2>/dev/null)

if [ -n "$REFERENCES" ]; then
    echo -e "${YELLOW}Warning: Found references to the old directory:${NC}"
    echo "$REFERENCES"
    echo ""
    echo -e "These references should be updated before deleting the old directory."
    echo -e "Would you like to continue anyway? (y/N): "
    read -r CONTINUE
    if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
        echo "Cleanup aborted."
        exit 1
    fi
else
    echo -e "${GREEN}No references to old directory found.${NC}"
fi

# Create backup before deletion
echo -e "\nCreating backup of old directory..."
BACKUP_DIR="/home/msalsouri/Projects/DB-GPT/backup_cleanup/oi-ollama-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r "$OLD_DIR"/* "$BACKUP_DIR"/ 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Backup created at $BACKUP_DIR${NC}"
else
    echo -e "${RED}Failed to create backup!${NC}"
    echo "Cleanup aborted."
    exit 1
fi

# Delete old directory
echo -e "\nDeleting old directory..."
rm -rf "$OLD_DIR"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Successfully deleted $OLD_DIR${NC}"
    echo -e "\n${CYAN}Cleanup completed successfully!${NC}"
    echo -e "The old directory has been removed and a backup was created at:"
    echo -e "${YELLOW}$BACKUP_DIR${NC}"
    echo -e "\nIf you need to restore any files, you can find them in the backup."
else
    echo -e "${RED}Failed to delete old directory!${NC}"
    echo "Please check permissions and try again."
    exit 1
fi
