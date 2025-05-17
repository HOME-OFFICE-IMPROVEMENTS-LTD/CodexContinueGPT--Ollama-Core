#!/bin/bash
# filepath: /home/msalsouri/Projects/DB-GPT/tools/memory/ollama-memory-monitor.sh
# Monitor and manage Ollama's memory usage

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo -e "${BOLD}${BLUE}Ollama Memory Monitor${NC}\n"

# Check if Ollama is running
if ! pgrep -x "ollama" > /dev/null; then
    echo -e "${RED}Ollama is not running.${NC}"
    echo -e "Start Ollama with: ${CYAN}ollama serve${NC}"
    exit 1
fi

# Get Ollama process info
OLLAMA_PID=$(pgrep -x "ollama")
OLLAMA_MEM=$(ps -o rss= -p "$OLLAMA_PID" | awk '{print $1/1024}')
OLLAMA_MEM_ROUNDED=$(printf "%.2f" "$OLLAMA_MEM")

echo -e "${BOLD}Ollama Process:${NC}"
echo -e "  PID: ${CYAN}$OLLAMA_PID${NC}"
echo -e "  Memory Usage: ${CYAN}${OLLAMA_MEM_ROUNDED} MB${NC}"

# Get system memory info
TOTAL_MEM=$(free -m | grep Mem | awk '{print $2}')
FREE_MEM=$(free -m | grep Mem | awk '{print $4}')
AVAILABLE_MEM=$(free -m | grep Mem | awk '{print $7}')

echo -e "\n${BOLD}System Memory:${NC}"
echo -e "  Total: ${CYAN}$TOTAL_MEM MB${NC}"
echo -e "  Free: ${CYAN}$FREE_MEM MB${NC}"
echo -e "  Available: ${CYAN}$AVAILABLE_MEM MB${NC}"

# Calculate Ollama's percentage of total memory
OLLAMA_PERCENT=$(echo "scale=2; $OLLAMA_MEM_ROUNDED / $TOTAL_MEM * 100" | bc)

echo -e "\n${BOLD}Ollama Memory Usage:${NC}"
echo -e "  ${CYAN}$OLLAMA_PERCENT%${NC} of total system memory"

# Recommendations based on memory usage
echo -e "\n${BOLD}Recommendations:${NC}"
if (( $(echo "$OLLAMA_PERCENT > 50" | bc -l) )); then
    echo -e "  ${RED}High memory usage!${NC} Consider using a smaller model."
    echo -e "  Try: ${CYAN}$PROJECT_ROOT/run-smart-shell-agent-lite.sh${NC}"
elif (( $(echo "$OLLAMA_PERCENT > 30" | bc -l) )); then
    echo -e "  ${YELLOW}Moderate memory usage.${NC} Monitor if running other applications."
else
    echo -e "  ${GREEN}Low memory usage.${NC} Current model is suitable for your system."
fi

# List loaded models
echo -e "\n${BOLD}Loaded Models:${NC}"
ollama list

# Offer options to optimize memory
echo -e "\n${BOLD}Memory Optimization Options:${NC}"
echo -e "  ${CYAN}1.${NC} Unload unused models"
echo -e "  ${CYAN}2.${NC} Switch to a smaller model"
echo -e "  ${CYAN}3.${NC} Restart Ollama service"
echo -e "  ${CYAN}4.${NC} Monitor memory usage (live)"
echo -e "  ${CYAN}5.${NC} Exit"

read -p "Select an option (1-5): " option

case $option in
    1)
        echo -e "\n${BOLD}Unloading unused models...${NC}"
        if [ -f "$PROJECT_ROOT/tools/memory/cleanup-ollama.sh" ]; then
            "$PROJECT_ROOT/tools/memory/cleanup-ollama.sh"
        else
            echo -e "${RED}cleanup-ollama.sh not found.${NC}"
        fi
        ;;
    2)
        echo -e "\n${BOLD}Available lightweight models:${NC}"
        echo -e "  ${CYAN}1.${NC} smart-shell-agent-lite"
        echo -e "  ${CYAN}2.${NC} minimal-shell-agent"
        echo -e "  ${CYAN}3.${NC} lite-test"
        echo -e "  ${CYAN}4.${NC} minimal-test"
        read -p "Select a model (1-4): " model_option
        
        case $model_option in
            1) "$PROJECT_ROOT/run-smart-shell-agent-lite.sh" ;;
            2) "$PROJECT_ROOT/test-minimal-agent.sh" ;;
            3) echo "Running lite-test model..."; ollama run lite-test ;;
            4) echo "Running minimal-test model..."; ollama run minimal-test ;;
            *) echo -e "${RED}Invalid option.${NC}" ;;
        esac
        ;;
    3)
        echo -e "\n${BOLD}Restarting Ollama service...${NC}"
        pkill ollama
        sleep 2
        ollama serve &
        echo -e "${GREEN}Ollama service restarted.${NC}"
        ;;
    4)
        echo -e "\n${BOLD}Monitoring memory usage (press Ctrl+C to exit)...${NC}"
        while true; do
            clear
            echo -e "${BOLD}${BLUE}Ollama Memory Monitor - Live${NC}\n"
            OLLAMA_PID=$(pgrep -x "ollama")
            if [ -z "$OLLAMA_PID" ]; then
                echo -e "${RED}Ollama is not running.${NC}"
                exit 1
            fi
            OLLAMA_MEM=$(ps -o rss= -p "$OLLAMA_PID" | awk '{print $1/1024}')
            OLLAMA_MEM_ROUNDED=$(printf "%.2f" "$OLLAMA_MEM")
            FREE_MEM=$(free -m | grep Mem | awk '{print $4}')
            AVAILABLE_MEM=$(free -m | grep Mem | awk '{print $7}')
            echo -e "${BOLD}Ollama Memory:${NC} ${CYAN}${OLLAMA_MEM_ROUNDED} MB${NC}"
            echo -e "${BOLD}Free Memory:${NC} ${CYAN}$FREE_MEM MB${NC}"
            echo -e "${BOLD}Available Memory:${NC} ${CYAN}$AVAILABLE_MEM MB${NC}"
            sleep 3
        done
        ;;
    5)
        echo -e "\n${GREEN}Exiting Ollama Memory Monitor.${NC}"
        exit 0
        ;;
    *)
        echo -e "\n${RED}Invalid option.${NC}"
        ;;
esac

exit 0
