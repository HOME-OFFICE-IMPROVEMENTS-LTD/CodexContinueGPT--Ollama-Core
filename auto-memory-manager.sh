#!/bin/bash
# filepath: /home/msalsouri/Projects/DB-GPT/auto-memory-manager.sh
# Automatically selects the appropriate shell agent based on available memory

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check available memory and decide which agent to use
free_mem=$(free | grep Mem | awk '{print $4}')
total_mem=$(free | grep Mem | awk '{print $2}')
free_percent=$((free_mem * 100 / total_mem))

echo -e "${BOLD}DB-GPT Smart Memory Manager${NC}"
echo -e "${YELLOW}Analyzing system memory...${NC}"

# Display memory information
echo -e "\n${BOLD}Current Memory Status:${NC}"
echo -e "  Total Memory: $(($total_mem / 1024 / 1024)) GB"
echo -e "  Free Memory: $(($free_mem / 1024 / 1024)) GB"
echo -e "  Free Percentage: ${free_percent}%"

# Determine which agent to use based on available memory
if [ $free_mem -lt 2000000 ]; then
    # Less than 2GB free
    echo -e "\n${RED}Low memory detected!${NC}"
    echo -e "Recommendation: Use minimal shell agent or free up memory"
    
    echo -e "\n${BOLD}Options:${NC}"
    echo -e "1. ${YELLOW}Run minimal shell agent${NC} (recommended for low memory)"
    echo -e "2. ${YELLOW}Clean up memory first${NC}"
    echo -e "3. ${YELLOW}Force run smart shell agent lite${NC} (may be unstable)"
    echo -e "4. ${YELLOW}Create ultra-minimal test model${NC}"
    echo -e "5. ${YELLOW}Exit${NC}"
    
    echo -ne "\n${BOLD}Enter choice (1-5):${NC} "
    read -r choice
    
    case "$choice" in
        1)
            echo -e "${YELLOW}Starting minimal shell agent...${NC}"
            if [ -f "$PROJECT_ROOT/test-minimal-agent.sh" ]; then
                "$PROJECT_ROOT/test-minimal-agent.sh"
            else
                echo -e "${RED}Minimal shell agent not found.${NC}"
                exit 1
            fi
            ;;
        2)
            echo -e "${YELLOW}Cleaning up memory...${NC}"
            if [ -f "$PROJECT_ROOT/cleanup-ollama.sh" ]; then
                "$PROJECT_ROOT/cleanup-ollama.sh"
                exec "$0" # Re-run this script after cleanup
            else
                echo -e "${RED}Memory cleanup script not found.${NC}"
                echo -e "${YELLOW}Attempting basic cleanup...${NC}"
                
                # Basic cleanup operations
                echo -e "${YELLOW}Stopping Ollama processes...${NC}"
                pkill -f ollama
                
                echo -e "${YELLOW}Clearing system cache...${NC}"
                sudo sync && sudo echo 3 | sudo tee /proc/sys/vm/drop_caches
                
                echo -e "${GREEN}Basic cleanup completed. Re-running memory check...${NC}"
                exec "$0" # Re-run this script after cleanup
            fi
            ;;
        3)
            echo -e "${RED}Warning: Running with low memory may cause issues.${NC}"
            echo -e "${YELLOW}Starting smart shell agent lite...${NC}"
            "$PROJECT_ROOT/run-smart-shell-agent-lite.sh"
            ;;
        4)
            echo -e "${YELLOW}Creating ultra-minimal test model...${NC}"
            
            # Check if the lite-test.Modelfile exists
            if [ ! -f "$PROJECT_ROOT/lite-test.Modelfile" ]; then
                echo -e "${YELLOW}Creating lite-test.Modelfile...${NC}"
                cat > "$PROJECT_ROOT/lite-test.Modelfile" << 'EOF'
FROM llama3:8b

SYSTEM """
You are a simple test assistant. Keep your responses as short as possible.
"""

PARAMETER temperature 0.7
PARAMETER num_ctx 1536
EOF
                echo -e "${GREEN}Created lite-test.Modelfile.${NC}"
            fi
            
            # Build the test model
            echo -e "${YELLOW}Building test model...${NC}"
            ollama create lite-test -f "$PROJECT_ROOT/lite-test.Modelfile"
            
            # Create ultra-minimal test script
            if [ ! -f "$PROJECT_ROOT/run-lite-test.sh" ]; then
                echo -e "${YELLOW}Creating run-lite-test.sh...${NC}"
                cat > "$PROJECT_ROOT/run-lite-test.sh" << 'EOF'
#!/bin/bash
# Ultra-minimal test script
ollama run lite-test "$1"
EOF
                chmod +x "$PROJECT_ROOT/run-lite-test.sh"
                echo -e "${GREEN}Created run-lite-test.sh.${NC}"
            fi
            
            # Run the test model
            echo -e "${YELLOW}Running ultra-minimal test model...${NC}"
            "$PROJECT_ROOT/run-lite-test.sh" "Say hello"
            
            echo -e "\n${GREEN}Test completed. You can run the ultra-minimal model with:${NC}"
            echo -e "${YELLOW}./run-lite-test.sh \"your question here\"${NC}"
            ;;
        5)
            echo -e "${YELLOW}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice.${NC}"
            exit 1
            ;;
    esac
elif [ $free_mem -lt 4000000 ]; then
    # Less than 4GB free
    echo -e "\n${YELLOW}Moderate memory available.${NC}"
    echo -e "Recommendation: Use smart shell agent lite"
    
    echo -e "\n${BOLD}Options:${NC}"
    echo -e "1. ${GREEN}Run smart shell agent lite${NC} (recommended)"
    echo -e "2. ${YELLOW}Run standard smart shell agent${NC}"
    echo -e "3. ${YELLOW}Clean up memory first${NC}"
    echo -e "4. ${YELLOW}Exit${NC}"
    
    echo -ne "\n${BOLD}Enter choice (1-4):${NC} "
    read -r choice
    
    case "$choice" in
        1)
            echo -e "${GREEN}Starting smart shell agent lite...${NC}"
            "$PROJECT_ROOT/run-smart-shell-agent-lite.sh"
            ;;
        2)
            echo -e "${YELLOW}Warning: Running with moderate memory may cause slowdowns.${NC}"
            echo -e "${YELLOW}Starting standard smart shell agent...${NC}"
            "$PROJECT_ROOT/run-smart-shell-agent.sh"
            ;;
        3)
            echo -e "${YELLOW}Cleaning up memory...${NC}"
            if [ -f "$PROJECT_ROOT/integrated-memory-manager.sh" ]; then
                "$PROJECT_ROOT/integrated-memory-manager.sh" clean recommended
                exec "$0" # Re-run this script after cleanup
            else
                echo -e "${RED}Memory manager not found.${NC}"
                exit 1
            fi
            ;;
        4)
            echo -e "${YELLOW}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice.${NC}"
            exit 1
            ;;
    esac
else
    # More than 4GB free
    echo -e "\n${GREEN}Plenty of memory available.${NC}"
    echo -e "Recommendation: Use standard smart shell agent"
    
    echo -e "\n${BOLD}Options:${NC}"
    echo -e "1. ${GREEN}Run standard smart shell agent${NC} (recommended)"
    echo -e "2. ${GREEN}Run smart shell agent lite${NC}"
    echo -e "3. ${YELLOW}Optimize parameters${NC}"
    echo -e "4. ${YELLOW}Exit${NC}"
    
    echo -ne "\n${BOLD}Enter choice (1-4):${NC} "
    read -r choice
    
    case "$choice" in
        1)
            echo -e "${GREEN}Starting standard smart shell agent...${NC}"
            "$PROJECT_ROOT/run-smart-shell-agent.sh"
            ;;
        2)
            echo -e "${GREEN}Starting smart shell agent lite...${NC}"
            "$PROJECT_ROOT/run-smart-shell-agent-lite.sh"
            ;;
        3)
            echo -e "${YELLOW}Opening parameter optimizer...${NC}"
            if [ -f "$PROJECT_ROOT/optimize-ollama-params.sh" ]; then
                "$PROJECT_ROOT/optimize-ollama-params.sh" --interactive
            else
                echo -e "${RED}Parameter optimizer not found.${NC}"
                exit 1
            fi
            ;;
        4)
            echo -e "${YELLOW}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice.${NC}"
            exit 1
            ;;
    esac
fi

exit 0
