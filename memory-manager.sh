#!/bin/bash
# filepath: /home/msalsouri/Projects/DB-GPT/memory-manager.sh
# Unified Memory Manager for DB-GPT Shell Agents

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to display help
show_help() {
    echo -e "${BOLD}DB-GPT Memory Manager - Unified Memory Management Tool${NC}"
    echo ""
    echo -e "Usage: ${CYAN}$(basename "$0") [COMMAND] [OPTIONS]${NC}"
    echo ""
    echo -e "${BOLD}COMMANDS:${NC}"
    echo -e "  ${GREEN}status${NC}              Show current memory usage and status"
    echo -e "  ${GREEN}monitor${NC}             Start real-time memory monitoring"
    echo -e "  ${GREEN}clean${NC} [level]       Clean up memory (levels: light, standard, aggressive)"
    echo -e "  ${GREEN}kill${NC}                Stop all Ollama processes"
    echo -e "  ${GREEN}optimize${NC}            Launch optimization tools"
    echo -e "  ${GREEN}auto${NC}                Auto-select agent based on memory"
    echo -e "  ${GREEN}help${NC}                Show this help message"
    echo ""
    echo -e "${BOLD}EXAMPLES:${NC}"
    echo -e "  ${CYAN}$(basename "$0") status${NC}           # Show current memory status"
    echo -e "  ${CYAN}$(basename "$0") clean aggressive${NC} # Perform aggressive memory cleanup"
    echo -e "  ${CYAN}$(basename "$0") monitor${NC}          # Start real-time memory monitoring"
    echo ""
}

# Function to show memory status
show_status() {
    echo -e "${BOLD}${BLUE}Memory Status:${NC}\n"
    
    # Get memory information
    total_mem=$(free -h | grep Mem | awk '{print $2}')
    used_mem=$(free -h | grep Mem | awk '{print $3}')
    free_mem=$(free -h | grep Mem | awk '{print $4}')
    free_percent=$(free | grep Mem | awk '{printf "%.1f", $4*100/$2}')
    
    # Get swap information
    total_swap=$(free -h | grep Swap | awk '{print $2}')
    used_swap=$(free -h | grep Swap | awk '{print $3}')
    
    # Get Ollama memory usage
    ollama_pid=$(pgrep -f "ollama serve")
    if [ -n "$ollama_pid" ]; then
        ollama_mem=$(ps -p "$ollama_pid" -o rss= | awk '{printf "%.1f GB", $1/1024/1024}')
        ollama_status="${GREEN}Running (PID: $ollama_pid)${NC}"
    else
        ollama_mem="N/A"
        ollama_status="${RED}Not running${NC}"
    fi
    
    # Get number of Ollama models
    if command -v ollama &> /dev/null; then
        ollama_models=$(ollama list | grep -v "NAME" | wc -l)
    else
        ollama_models="N/A"
    fi
    
    # Display memory information
    echo -e "${BOLD}System Memory:${NC}"
    echo -e "  Total:     $total_mem"
    echo -e "  Used:      $used_mem"
    echo -e "  Free:      $free_mem"
    echo -e "  Free (%):  $free_percent%"
    
    echo -e "\n${BOLD}Swap:${NC}"
    echo -e "  Total:     $total_swap"
    echo -e "  Used:      $used_swap"
    
    echo -e "\n${BOLD}Ollama:${NC}"
    echo -e "  Status:    $ollama_status"
    echo -e "  Memory:    $ollama_mem"
    echo -e "  Models:    $ollama_models"
    
    echo -e "\n${BOLD}Recommendation:${NC}"
    
    if (( $(echo "$free_percent < 10" | bc -l) )); then
        echo -e "${RED}Critical: Very low memory available. Immediate action required.${NC}"
        echo -e "${CYAN}Recommended action: ${NC}${YELLOW}$0 clean aggressive${NC}"
    elif (( $(echo "$free_percent < 20" | bc -l) )); then
        echo -e "${YELLOW}Warning: Low memory available.${NC}"
        echo -e "${CYAN}Recommended action: ${NC}${YELLOW}$0 clean standard${NC}"
    elif (( $(echo "$free_percent < 30" | bc -l) )); then
        echo -e "${YELLOW}Notice: Memory is getting low.${NC}"
        echo -e "${CYAN}Recommended action: ${NC}${YELLOW}$0 clean light${NC}"
    else
        echo -e "${GREEN}Good: Sufficient memory available.${NC}"
    fi
}

# Function to monitor memory in real-time
monitor_memory() {
    echo -e "${BOLD}${BLUE}Real-time Memory Monitor${NC}"
    echo -e "${YELLOW}Press Ctrl+C to exit${NC}\n"
    
    # Check if watch is installed
    if command -v watch &> /dev/null; then
        if [ -f "$PROJECT_ROOT/monitor-memory.sh" ]; then
            watch -n 2 "$PROJECT_ROOT/monitor-memory.sh"
        else
            watch -n 2 "free -h && echo '' && ps aux | grep ollama | grep -v grep"
        fi
    else
        echo -e "${YELLOW}The 'watch' command is not available. Using basic monitoring...${NC}"
        
        while true; do
            clear
            echo -e "${BOLD}${BLUE}Memory Status (refreshes every 2 seconds):${NC}\n"
            free -h
            echo ""
            ps aux | grep ollama | grep -v grep
            sleep 2
        done
    fi
}

# Function to clean up memory
clean_memory() {
    local level="$1"
    
    case "$level" in
        light|minimal)
            echo -e "${BOLD}${YELLOW}Performing light memory cleanup...${NC}\n"
            
            # Clear page cache
            echo -e "${YELLOW}Clearing page cache...${NC}"
            sync
            sudo sh -c 'echo 1 > /proc/sys/vm/drop_caches'
            
            echo -e "${GREEN}Light cleanup completed.${NC}"
            ;;
        
        standard|normal|default)
            echo -e "${BOLD}${YELLOW}Performing standard memory cleanup...${NC}\n"
            
            # Clear page cache and inode cache
            echo -e "${YELLOW}Clearing page and inode caches...${NC}"
            sync
            sudo sh -c 'echo 2 > /proc/sys/vm/drop_caches'
            
            # Restart Ollama if it's using too much memory
            ollama_pid=$(pgrep -f "ollama serve")
            if [ -n "$ollama_pid" ]; then
                ollama_mem=$(ps -p "$ollama_pid" -o rss= | awk '{print $1/1024/1024}')
                if (( $(echo "$ollama_mem > 4.0" | bc -l) )); then
                    echo -e "${YELLOW}Ollama is using a lot of memory (${ollama_mem} GB). Restarting...${NC}"
                    pkill -f "ollama serve"
                    sleep 2
                    ollama serve > /dev/null 2>&1 &
                    sleep 3
                fi
            fi
            
            echo -e "${GREEN}Standard cleanup completed.${NC}"
            ;;
        
        aggressive|full|urgent)
            echo -e "${BOLD}${RED}Performing aggressive memory cleanup...${NC}\n"
            
            # Kill Ollama processes
            echo -e "${YELLOW}Stopping all Ollama processes...${NC}"
            pkill -f ollama
            
            # Clear all caches
            echo -e "${YELLOW}Clearing all caches...${NC}"
            sync
            sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
            
            # Restart Ollama server
            echo -e "${YELLOW}Restarting Ollama server...${NC}"
            ollama serve > /dev/null 2>&1 &
            sleep 3
            
            echo -e "${GREEN}Aggressive cleanup completed.${NC}"
            ;;
        
        *)
            echo -e "${RED}Error: Unknown cleanup level '$level'${NC}"
            echo -e "${YELLOW}Available levels: light, standard, aggressive${NC}"
            return 1
            ;;
    esac
    
    # Show updated memory status
    echo -e "\n${BOLD}${BLUE}Updated Memory Status:${NC}\n"
    free -h
}

# Function to kill Ollama processes
kill_ollama() {
    echo -e "${BOLD}${YELLOW}Stopping all Ollama processes...${NC}\n"
    
    # Count Ollama processes
    ollama_count=$(pgrep -c -f ollama || echo 0)
    
    if [ "$ollama_count" -eq 0 ]; then
        echo -e "${YELLOW}No Ollama processes found.${NC}"
    else
        echo -e "${YELLOW}Found $ollama_count Ollama processes. Stopping them...${NC}"
        pkill -f ollama
        sleep 2
        
        # Check if any Ollama processes remain
        if pgrep -f ollama > /dev/null; then
            echo -e "${RED}Some Ollama processes are still running. Forcing termination...${NC}"
            pkill -9 -f ollama
            sleep 1
        fi
        
        echo -e "${GREEN}All Ollama processes stopped.${NC}"
    fi
}

# Function to optimize memory usage
optimize_memory() {
    echo -e "${BOLD}${BLUE}Memory Optimization Tools${NC}\n"
    
    echo -e "${BOLD}Available Optimization Tools:${NC}"
    echo -e "1. ${YELLOW}Parameter Optimizer${NC} - Find the optimal Ollama parameters"
    echo -e "2. ${YELLOW}Model Cleanup${NC} - Remove unused models"
    echo -e "3. ${YELLOW}Memory Profile Analysis${NC} - Analyze memory usage patterns"
    echo -e "4. ${YELLOW}Return to main menu${NC}"
    
    echo -ne "\n${BOLD}Select a tool (1-4):${NC} "
    read -r choice
    
    case "$choice" in
        1)
            if [ -f "$PROJECT_ROOT/optimize-ollama-params.sh" ]; then
                "$PROJECT_ROOT/optimize-ollama-params.sh" --interactive
            else
                echo -e "${RED}Error: Parameter optimizer not found.${NC}"
                return 1
            fi
            ;;
        
        2)
            echo -e "${YELLOW}Listing installed models:${NC}"
            ollama list
            
            echo -e "\n${YELLOW}Enter the name of a model to remove (or empty to cancel):${NC} "
            read -r model_name
            
            if [ -n "$model_name" ]; then
                echo -e "${YELLOW}Removing model '$model_name'...${NC}"
                ollama rm "$model_name"
                echo -e "${GREEN}Model removed.${NC}"
            fi
            ;;
        
        3)
            echo -e "${YELLOW}Analyzing memory profile...${NC}"
            echo -e "${GREEN}Current memory usage by process:${NC}"
            ps aux --sort=-%mem | head -11
            
            echo -e "\n${GREEN}Ollama-specific memory usage:${NC}"
            ps aux | grep ollama | grep -v grep
            
            echo -e "\n${GREEN}Memory usage over time (last 10 minutes):${NC}"
            vmstat 60 10
            ;;
        
        4)
            return 0
            ;;
        
        *)
            echo -e "${RED}Invalid choice.${NC}"
            return 1
            ;;
    esac
}

# Function for auto-selecting agent
auto_select_agent() {
    if [ -f "$PROJECT_ROOT/auto-memory-manager.sh" ]; then
        "$PROJECT_ROOT/auto-memory-manager.sh"
    else
        echo -e "${RED}Error: Auto memory manager not found.${NC}"
        return 1
    fi
}

# Parse command line arguments
if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        clear
        echo -e "${BOLD}${BLUE}DB-GPT Memory Manager${NC}\n"
        
        # Show quick memory status
        total_mem=$(free -h | grep Mem | awk '{print $2}')
        used_mem=$(free -h | grep Mem | awk '{print $3}')
        free_mem=$(free -h | grep Mem | awk '{print $4}')
        free_percent=$(free | grep Mem | awk '{printf "%.1f", $4*100/$2}')
        
        echo -e "${BOLD}Memory Status:${NC} $used_mem used, $free_mem free ($free_percent% free)"
        
        echo -e "\n${BOLD}Available Commands:${NC}"
        echo -e "1. ${GREEN}Show detailed status${NC}"
        echo -e "2. ${GREEN}Start real-time monitor${NC}"
        echo -e "3. ${GREEN}Clean memory${NC}"
        echo -e "4. ${GREEN}Stop Ollama processes${NC}"
        echo -e "5. ${GREEN}Optimize memory usage${NC}"
        echo -e "6. ${GREEN}Auto-select agent${NC}"
        echo -e "7. ${GREEN}Exit${NC}"
        
        echo -ne "\n${BOLD}Enter choice (1-7):${NC} "
        read -r choice
        
        case "$choice" in
            1)
                clear
                show_status
                echo -e "\n${YELLOW}Press Enter to continue...${NC}"
                read -r
                ;;
            
            2)
                clear
                monitor_memory
                ;;
            
            3)
                clear
                echo -e "${BOLD}${BLUE}Memory Cleanup${NC}\n"
                
                echo -e "${BOLD}Cleanup Levels:${NC}"
                echo -e "1. ${GREEN}Light${NC} - Clear page cache"
                echo -e "2. ${YELLOW}Standard${NC} - Clear page and inode caches, restart Ollama if needed"
                echo -e "3. ${RED}Aggressive${NC} - Kill all Ollama processes, clear all caches"
                
                echo -ne "\n${BOLD}Select cleanup level (1-3):${NC} "
                read -r level_choice
                
                case "$level_choice" in
                    1) clean_memory "light" ;;
                    2) clean_memory "standard" ;;
                    3) clean_memory "aggressive" ;;
                    *) echo -e "${RED}Invalid choice.${NC}" ;;
                esac
                
                echo -e "\n${YELLOW}Press Enter to continue...${NC}"
                read -r
                ;;
            
            4)
                clear
                kill_ollama
                echo -e "\n${YELLOW}Press Enter to continue...${NC}"
                read -r
                ;;
            
            5)
                clear
                optimize_memory
                echo -e "\n${YELLOW}Press Enter to continue...${NC}"
                read -r
                ;;
            
            6)
                clear
                auto_select_agent
                ;;
            
            7)
                echo -e "${YELLOW}Exiting...${NC}"
                exit 0
                ;;
            
            *)
                echo -e "${RED}Invalid choice.${NC}"
                sleep 1
                ;;
        esac
    done
else
    # Command mode
    command="$1"
    shift
    
    case "$command" in
        status)
            show_status
            ;;
        
        monitor)
            monitor_memory
            ;;
        
        clean)
            level="${1:-standard}"
            clean_memory "$level"
            ;;
        
        kill)
            kill_ollama
            ;;
        
        optimize)
            optimize_memory
            ;;
        
        auto)
            auto_select_agent
            ;;
        
        help)
            show_help
            ;;
        
        *)
            echo -e "${RED}Unknown command: $command${NC}"
            show_help
            exit 1
            ;;
    esac
fi

exit 0
