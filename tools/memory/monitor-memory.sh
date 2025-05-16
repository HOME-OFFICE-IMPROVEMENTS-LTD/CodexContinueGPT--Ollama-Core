#!/bin/bash
# filepath: /home/msalsouri/Projects/DB-GPT/monitor-memory.sh
# Memory monitor for Ollama and DB-GPT processes

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

clear
echo -e "${BOLD}${BLUE}DB-GPT Memory Monitor${NC}"
echo -e "${YELLOW}Press Ctrl+C to exit${NC}\n"

while true; do
    clear
    echo -e "${BOLD}${BLUE}DB-GPT Memory Monitor${NC}"
    echo -e "${YELLOW}Press Ctrl+C to exit${NC}\n"
    
    # Overall memory usage
    echo -e "${BOLD}System Memory${NC}"
    free -h | awk 'NR==1{print $1,$2,$3,$4,$7} NR==2{print $1,$2,$3,$4,$7}'
    echo ""
    
    # Ollama processes
    echo -e "${BOLD}Ollama Processes${NC}"
    ps aux | grep ollama | grep -v grep | sort -k 4 -r
    echo ""
    
    # Top memory processes
    echo -e "${BOLD}Top Memory Processes${NC}"
    ps aux --sort=-%mem | head -6
    
    sleep 5
done
