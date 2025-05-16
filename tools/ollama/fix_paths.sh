#!/bin/bash
# Script to fix hardcoded paths in CodexContinueGPT™ scripts
# This ensures that scripts work in any installation directory

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the current script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"
cd "$SCRIPT_DIR"

# Create a backup directory for original files
BACKUP_DIR="$SCRIPT_DIR/backup_scripts_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo -e "${GREEN}CodexContinueGPT™ Path Fixer${NC}"
echo -e "${CYAN}Script directory:${NC} $SCRIPT_DIR"
echo -e "${CYAN}Repository root:${NC} $REPO_ROOT"
echo -e "${CYAN}Backup directory:${NC} $BACKUP_DIR"

# Function to fix a script's paths
fix_script() {
    local script=$1
    local script_name=$(basename "$script")
    
    if [ ! -f "$script" ]; then
        echo -e "${RED}Error: Script $script does not exist${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Fixing paths in ${script_name}...${NC}"
    
    # Create backup
    cp "$script" "$BACKUP_DIR/${script_name}.backup"
    echo -e "  - Created backup: $BACKUP_DIR/${script_name}.backup"
    
    # Check for hardcoded paths
    if grep -q "/home/" "$script" || grep -q "/Users/" "$script"; then
        # Find home directory patterns
        local patterns=$(grep -o "/home/[^/]*/[^/]*/[^/ \"']*" "$script" | sort | uniq)
        if [ -z "$patterns" ]; then
            patterns=$(grep -o "/Users/[^/]*/[^/]*/[^/ \"']*" "$script" | sort | uniq)
        fi
        
        # If patterns found, replace them
        if [ ! -z "$patterns" ]; then
            echo -e "  - Found hardcoded paths:"
            echo "$patterns" | while read path; do
                echo -e "      ${RED}$path${NC}"
                # Fix path with the appropriate replacement
                if echo "$path" | grep -q "/Projects/DB-GPT"; then
                    sed -i "s|$path|$REPO_ROOT|g" "$script"
                    echo -e "      ${GREEN}→ Replaced with \$REPO_ROOT${NC}"
                else
                    echo -e "      ${YELLOW}→ Not replacing (not a project path)${NC}"
                fi
            done
        fi
        
        # Replace path construction patterns
