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
        sed -i '/# Paths and settings/,/OLLAMA_CONFIG_FILE/c\# Paths and settings\nSCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" \&\& pwd )"\nREPO_ROOT="$( cd "$SCRIPT_DIR/../.." \&\& pwd )"\nCONFIG_DIR="$REPO_ROOT/configs"\nOLLAMA_CONFIG_FILE="$CONFIG_DIR/dbgpt-proxy-ollama.toml"' "$script"
        echo -e "  - ${GREEN}Updated path variable definitions${NC}"
        
        # Fix cd commands
        sed -i "s|cd /home/[^/]*/Projects/DB-GPT|cd \"\$REPO_ROOT\"|g" "$script"
        sed -i "s|cd /Users/[^/]*/Projects/DB-GPT|cd \"\$REPO_ROOT\"|g" "$script"
        echo -e "  - ${GREEN}Updated cd commands${NC}"
    else
        echo -e "  - ${GREEN}No hardcoded paths found${NC}"
    fi
    
    echo -e "${GREEN}Done fixing ${script_name}${NC}"
}

# Fix the main Ollama scripts

# Fix all scripts in the directory
echo -e "\n${CYAN}Starting to fix paths in all scripts...${NC}\n"

# Process main scripts
fix_script "$SCRIPT_DIR/ollama_manager.sh"
fix_script "$SCRIPT_DIR/shell_helper.sh"
fix_script "$SCRIPT_DIR/ask.sh"

# Also fix root scripts that reference the Ollama tools
ROOT_SCRIPTS=(
    "$REPO_ROOT/ask.sh"
    "$REPO_ROOT/.aliases"
)

for script in "${ROOT_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        fix_script "$script"
    fi
done

# Look for any other scripts that might contain hardcoded paths
echo -e "\n${YELLOW}Scanning for other scripts with potential hardcoded paths...${NC}"
POTENTIAL_SCRIPTS=$(find "$REPO_ROOT" -type f -name "*.sh" | xargs grep -l "/home/\|/Users/" 2>/dev/null)

if [ ! -z "$POTENTIAL_SCRIPTS" ]; then
    echo -e "\n${CYAN}Additional scripts found with potential hardcoded paths:${NC}"
    echo "$POTENTIAL_SCRIPTS" | while read script; do
        echo -e "  - ${YELLOW}$(basename "$script")${NC} ($(dirname "$script" | sed "s|$REPO_ROOT|.|"))"
    done
    
    echo -e "\n${CYAN}Would you like to fix these scripts too? (y/n)${NC}"
    read -p "Fix additional scripts? " fix_additional
    
    if [[ $fix_additional =~ ^[Yy]$ ]]; then
        echo "$POTENTIAL_SCRIPTS" | while read script; do
            fix_script "$script"
        done
    fi
fi

# Create a symbolic link to the fixed scripts in the root directory
echo -e "\n${CYAN}Creating symbolic links in the repository root...${NC}"
if [ ! -L "$REPO_ROOT/fix_paths.sh" ]; then
    ln -sf "$SCRIPT_DIR/fix_paths.sh" "$REPO_ROOT/fix_paths.sh"
    echo -e "  - ${GREEN}Created symbolic link: fix_paths.sh${NC}"
fi

echo -e "\n${GREEN}All done!${NC} Fixed paths in all scripts."
echo -e "${CYAN}Original scripts backed up to:${NC} $BACKUP_DIR"
echo -e "${YELLOW}Please test the scripts to confirm they work correctly${NC}\n"
