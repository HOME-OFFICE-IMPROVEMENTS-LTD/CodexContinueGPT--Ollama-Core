#!/bin/bash
# Sample usage examples for CodexContinue-GPT

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}=====================================${NC}"
echo -e "${CYAN}   CodexContinue-GPT Usage Examples   ${NC}"
echo -e "${CYAN}=====================================${NC}"

# Define sample queries
CODE_QUERY="Write a JavaScript function to sort an array of objects by a specific property"
TASK_QUERY="Create a prioritized task list for implementing a new database feature"
GENERAL_QUERY="Explain the difference between SQL and NoSQL databases"

# Get current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
cd "$SCRIPT_DIR/.."

# Function to run a query
run_query() {
    local query="$1"
    local mode="$2"
    
    echo -e "\n${YELLOW}Query:${NC} $query"
    echo -e "${YELLOW}Command:${NC} ./launch-ccgpt.sh $mode"
    echo -e "${YELLOW}Expected Model:${NC} $3"
    echo -e "${YELLOW}Press Enter to run this example or Ctrl+C to exit...${NC}"
    read
    
    # Use echo to pipe the query into the command and add exit to terminate
    echo -e "$query\nexit" | ./launch-ccgpt.sh $mode
}

# Show menu
echo -e "\nSelect an example to run:"
echo -e "  ${GREEN}1${NC}. Code query with auto-selection (should use codellama)"
echo -e "  ${GREEN}2${NC}. Task query with auto-selection (should use mistral)"
echo -e "  ${GREEN}3${NC}. General query with auto-selection (should use llama3)"
echo -e "  ${GREEN}4${NC}. Force specific model (mistral) regardless of query"
echo -e "  ${GREEN}5${NC}. Run in test mode (no real API calls)"
echo -e "  ${GREEN}q${NC}. Quit"

# Process selection
while true; do
    echo -e "\n${CYAN}Enter your choice (1-5 or q):${NC} "
    read choice
    
    case "$choice" in
        1) run_query "$CODE_QUERY" "--auto" "codellama" ;;
        2) run_query "$TASK_QUERY" "--auto" "mistral" ;;
        3) run_query "$GENERAL_QUERY" "--auto" "llama3" ;;
        4) run_query "$CODE_QUERY" "--model mistral" "mistral (forced)" ;;
        5) run_query "$CODE_QUERY" "--auto --test" "codellama (test mode)" ;;
        q|Q) echo "Exiting examples."; exit 0 ;;
        *) echo -e "${RED}Invalid choice. Please try again.${NC}" ;;
    esac
done
