#!/bin/bash
# DB-GPT Agent Memory Manager
# This script provides utilities for managing the agent memory system

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Memory base directory
MEMORY_BASE_DIR="$HOME/.dbgpt_agents"
TASK_QUEUE_DIR="$MEMORY_BASE_DIR/tasks"

# Check if jq is installed
check_jq_installed() {
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}Error: jq is not installed.${NC}"
        echo -e "${YELLOW}Please install jq for full functionality:${NC}"
        echo -e "${YELLOW}  sudo apt-get install jq (Debian/Ubuntu)${NC}"
        echo -e "${YELLOW}  brew install jq (macOS with Homebrew)${NC}"
        return 1
    fi
    return 0
}

# Print memory usage statistics
memory_stats() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}   DB-GPT Agent Memory Statistics   ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo ""
    
    if [ ! -d "$MEMORY_BASE_DIR" ]; then
        echo -e "${RED}Memory system not initialized. Run ./agent-memory.sh initialize first.${NC}"
        return 1
    fi
    
    # Overall memory usage
    local total_size=$(du -sh "$MEMORY_BASE_DIR" | awk '{print $1}')
    echo -e "${YELLOW}Total memory usage:${NC} $total_size"
    echo ""
    
    # Memory usage by agent
    echo -e "${YELLOW}Memory usage by agent:${NC}"
    for agent in "code" "shell" "tasks" "audit" "git" "decision"; do
        if [ -d "$MEMORY_BASE_DIR/$agent" ]; then
            local agent_size=$(du -sh "$MEMORY_BASE_DIR/$agent" | awk '{print $1}')
            echo -e "  ${BLUE}$agent:${NC} $agent_size"
        fi
    done
    echo ""
    
    # Task statistics
    if [ -d "$TASK_QUEUE_DIR" ]; then
        echo -e "${YELLOW}Task statistics:${NC}"
        
        local pending_count=0
        local running_count=0
        local completed_count=0
        local failed_count=0
        
        if [ -d "$TASK_QUEUE_DIR/pending" ]; then
            pending_count=$(find "$TASK_QUEUE_DIR/pending" -name "*.json" | wc -l)
        fi
        
        if [ -d "$TASK_QUEUE_DIR/running" ]; then
            running_count=$(find "$TASK_QUEUE_DIR/running" -name "*.json" -not -name "*_output.txt" | wc -l)
        fi
        
        if [ -d "$TASK_QUEUE_DIR/completed" ]; then
            completed_count=$(find "$TASK_QUEUE_DIR/completed" -name "*.json" -not -name "*_output.txt" | wc -l)
        fi
        
        if [ -d "$TASK_QUEUE_DIR/failed" ]; then
            failed_count=$(find "$TASK_QUEUE_DIR/failed" -name "*.json" -not -name "*_output.txt" | wc -l)
        fi
        
        echo -e "  ${BLUE}Pending tasks:${NC} $pending_count"
        echo -e "  ${BLUE}Running tasks:${NC} $running_count"
        echo -e "  ${BLUE}Completed tasks:${NC} $completed_count"
        echo -e "  ${BLUE}Failed tasks:${NC} $failed_count"
    fi
    echo ""
    
    # Memory files count
    if check_jq_installed && [ -f "$MEMORY_BASE_DIR/memory_index.json" ]; then
        echo -e "${YELLOW}Memory index statistics:${NC}"
        
        for agent in "code" "shell" "tasks" "audit" "git" "decision"; do
            local conversation_count=$(jq -r ".agents.$agent.conversations | length" "$MEMORY_BASE_DIR/memory_index.json")
            local facts_count=$(jq -r ".agents.$agent.facts | length" "$MEMORY_BASE_DIR/memory_index.json")
            
            echo -e "  ${BLUE}$agent:${NC} $conversation_count conversations, $facts_count fact files"
        done
    fi
    echo ""
}

# Clean up old memory files
clean_memory() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}   DB-GPT Agent Memory Cleanup   ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo ""
    
    if [ ! -d "$MEMORY_BASE_DIR" ]; then
        echo -e "${RED}Memory system not initialized. Nothing to clean.${NC}"
        return 1
    fi
    
    read -p "Do you want to clean up completed tasks? (y/n): " clean_tasks
    if [[ "$clean_tasks" == "y" || "$clean_tasks" == "Y" ]]; then
        if [ -d "$TASK_QUEUE_DIR/completed" ]; then
            local completed_count=$(find "$TASK_QUEUE_DIR/completed" -type f | wc -l)
            if [ $completed_count -gt 0 ]; then
                echo -e "${YELLOW}Cleaning up $completed_count completed task files...${NC}"
                rm -f "$TASK_QUEUE_DIR/completed"/*
                echo -e "${GREEN}Completed tasks cleaned up.${NC}"
            else
                echo -e "${BLUE}No completed task files to clean up.${NC}"
            fi
        fi
    fi
    
    read -p "Do you want to clean up old conversation memories (keeps facts and summaries)? (y/n): " clean_convos
    if [[ "$clean_convos" == "y" || "$clean_convos" == "Y" ]]; then
        for agent in "code" "shell" "tasks" "audit" "git" "decision"; do
            if [ -d "$MEMORY_BASE_DIR/$agent" ]; then
                local convo_count=$(find "$MEMORY_BASE_DIR/$agent" -name "conversation_*.json" | wc -l)
                if [ $convo_count -gt 0 ]; then
                    echo -e "${YELLOW}Cleaning up $convo_count conversation files for $agent agent...${NC}"
                    rm -f "$MEMORY_BASE_DIR/$agent"/conversation_*.json
                fi
            fi
        done
        
        if check_jq_installed && [ -f "$MEMORY_BASE_DIR/memory_index.json" ]; then
            echo -e "${YELLOW}Updating memory index to remove conversation references...${NC}"
            local temp_index=$(mktemp)
            jq '.agents.code.conversations = [] | .agents.shell.conversations = [] | .agents.tasks.conversations = [] | .agents.audit.conversations = [] | .agents.git.conversations = [] | .agents.decision.conversations = []' "$MEMORY_BASE_DIR/memory_index.json" > "$temp_index" && mv "$temp_index" "$MEMORY_BASE_DIR/memory_index.json"
        fi
        
        echo -e "${GREEN}Conversation memories cleaned up. Facts and summaries are preserved.${NC}"
    fi
    
    read -p "Do you want to clean up everything and reset memory system? (y/n): " clean_all
    if [[ "$clean_all" == "y" || "$clean_all" == "Y" ]]; then
        echo -e "${RED}WARNING: This will delete all agent memories and tasks!${NC}"
        read -p "Are you absolutely sure? (yes/no): " confirm
        if [ "$confirm" == "yes" ]; then
            echo -e "${YELLOW}Removing all memory files...${NC}"
            rm -rf "$MEMORY_BASE_DIR"
            echo -e "${GREEN}Memory system has been completely reset.${NC}"
            echo -e "${BLUE}You can reinitialize it with ./agent-memory.sh initialize${NC}"
        fi
    fi
    
    echo -e "${GREEN}Memory cleanup completed.${NC}"
}

# Export memories to a single file
export_memories() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}   DB-GPT Agent Memory Export   ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo ""
    
    if [ ! -d "$MEMORY_BASE_DIR" ]; then
        echo -e "${RED}Memory system not initialized. Nothing to export.${NC}"
        return 1
    fi
    
    # Check if jq is available for JSON processing
    if ! check_jq_installed; then
        return 1
    fi
    
    # Create export file
    local export_file="$HOME/dbgpt_agent_memories_$(date +"%Y%m%d").json"
    
    echo -e "${YELLOW}Exporting memories to $export_file...${NC}"
    
    # Initialize export file with structure
    echo '{
  "exported_date": "'$(date -Iseconds)'",
  "agents": {
    "code": {"facts": [], "summaries": []},
    "shell": {"facts": [], "summaries": []},
    "tasks": {"facts": [], "summaries": []},
    "audit": {"facts": [], "summaries": []},
    "git": {"facts": [], "summaries": []},
    "decision": {"facts": [], "summaries": []}
  }
}' > "$export_file"
    
    # Export facts for each agent
    for agent in "code" "shell" "tasks" "audit" "git" "decision"; do
        if [ -d "$MEMORY_BASE_DIR/$agent" ]; then
            echo -e "${BLUE}Exporting facts for $agent agent...${NC}"
            
            # Get fact files
            local fact_files=($(find "$MEMORY_BASE_DIR/$agent" -name "facts_*.json"))
            
            for fact_file in "${fact_files[@]}"; do
                if [ -f "$fact_file" ]; then
                    local fact_content=$(cat "$fact_file")
                    local temp_export=$(mktemp)
                    
                    # Add fact to export file
                    jq --arg agent "$agent" --arg content "$fact_content" '.agents[$agent].facts += [$content]' "$export_file" > "$temp_export" && mv "$temp_export" "$export_file"
                fi
            done
            
            # Get summary files
            local summary_files=($(find "$MEMORY_BASE_DIR/$agent" -name "summary_*.txt"))
            
            for summary_file in "${summary_files[@]}"; do
                if [ -f "$summary_file" ]; then
                    local summary_content=$(cat "$summary_file")
                    local temp_export=$(mktemp)
                    
                    # Add summary to export file
                    jq --arg agent "$agent" --arg content "$summary_content" '.agents[$agent].summaries += [$content]' "$export_file" > "$temp_export" && mv "$temp_export" "$export_file"
                fi
            done
        fi
    done
    
    echo -e "${GREEN}Memories exported to $export_file${NC}"
    echo -e "${YELLOW}This file contains all facts and summaries from your agent memories.${NC}"
    echo -e "${YELLOW}You can use it to restore memories or transfer them to another system.${NC}"
}

# Function to check if the background worker is running
check_worker_status() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}   DB-GPT Agent Worker Status   ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo ""
    
    if [ -f "$MEMORY_BASE_DIR/worker.pid" ]; then
        local pid=$(cat "$MEMORY_BASE_DIR/worker.pid")
        if ps -p "$pid" > /dev/null; then
            echo -e "${GREEN}Background worker is running with PID $pid${NC}"
            
            # Check worker log file
            if [ -f "$MEMORY_BASE_DIR/worker.log" ]; then
                echo -e "${YELLOW}Last 5 log entries:${NC}"
                tail -n 5 "$MEMORY_BASE_DIR/worker.log"
            fi
        else
            echo -e "${RED}Background worker is not running.${NC}"
            echo -e "${YELLOW}PID file exists but process $pid is not active.${NC}"
            echo -e "${BLUE}You can start the worker with ./agent-memory.sh worker${NC}"
        fi
    else
        echo -e "${RED}Background worker is not running.${NC}"
        echo -e "${BLUE}You can start the worker with ./agent-memory.sh worker${NC}"
    fi
    
    # Check pending tasks
    if [ -d "$TASK_QUEUE_DIR/pending" ]; then
        local pending_count=$(find "$TASK_QUEUE_DIR/pending" -name "*.json" | wc -l)
        if [ $pending_count -gt 0 ]; then
            echo -e ""
            echo -e "${YELLOW}There are $pending_count pending tasks.${NC}"
            echo -e "${BLUE}Ensure the worker is running to process these tasks.${NC}"
        fi
    fi
}

# Show help message
print_help() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}   DB-GPT Agent Memory Manager   ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo ""
    echo -e "${GREEN}Available Commands:${NC}"
    echo -e "  ${YELLOW}$(basename "$0") stats${NC}     ${BLUE}# Show memory usage statistics${NC}"
    echo -e "  ${YELLOW}$(basename "$0") clean${NC}     ${BLUE}# Clean up old memory files${NC}"
    echo -e "  ${YELLOW}$(basename "$0") export${NC}    ${BLUE}# Export memories to a file${NC}"
    echo -e "  ${YELLOW}$(basename "$0") worker${NC}    ${BLUE}# Check background worker status${NC}"
    echo -e "  ${YELLOW}$(basename "$0") help${NC}      ${BLUE}# Show this help message${NC}"
    echo ""
    echo -e "${GREEN}Memory Location:${NC} $MEMORY_BASE_DIR"
}

# Main function to handle command line arguments
main() {
    # If no arguments provided, show help
    if [ $# -eq 0 ]; then
        print_help
        return 0
    fi
    
    # Process commands
    case "$1" in
        "stats")
            memory_stats
            ;;
        "clean")
            clean_memory
            ;;
        "export")
            export_memories
            ;;
        "worker")
            check_worker_status
            ;;
        "help")
            print_help
            ;;
        *)
            echo -e "${RED}Error: Unknown command '$1'${NC}"
            print_help
            return 1
            ;;
    esac
    
    return 0
}

# Run main function with all arguments
main "$@"
