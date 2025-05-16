#!/bin/bash
# DB-GPT Agent Co-working Demo
# This script demonstrates how to use the agent co-working capability

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if agent-memory.sh exists
if [ ! -f "$(dirname "$0")/agent-memory.sh" ]; then
    echo -e "${RED}Error: agent-memory.sh not found${NC}"
    exit 1
fi

echo -e "${CYAN}====================================${NC}"
echo -e "${CYAN}   DB-GPT Agent Co-working Demo   ${NC}"
echo -e "${CYAN}====================================${NC}"
echo ""

# Ensure memory system is initialized
echo -e "${BLUE}Step 1: Initializing memory system...${NC}"
bash "$(dirname "$0")/agent-memory.sh" initialize
echo ""

# Patch agent-commands.sh if not already patched
echo -e "${BLUE}Step 2: Patching agent-commands.sh...${NC}"
bash "$(dirname "$0")/agent-memory.sh" patch
echo ""

# Show current time
echo -e "${BLUE}Current time: $(date)${NC}"
echo ""

# Submit a task to each agent type
echo -e "${BLUE}Step 3: Submitting tasks to agents for co-working...${NC}"
echo -e "${YELLOW}Submitting task to code assistant...${NC}"
bash "$(dirname "$0")/agent-memory.sh" submit code "Create a Python function that finds all prime numbers up to a given limit using the Sieve of Eratosthenes algorithm."
echo ""

echo -e "${YELLOW}Submitting task to shell helper...${NC}"
bash "$(dirname "$0")/agent-memory.sh" submit shell "Create a shell script that monitors disk usage and sends an alert if it exceeds 85% capacity."
echo ""

echo -e "${YELLOW}Submitting task to decision auditor...${NC}"
bash "$(dirname "$0")/agent-memory.sh" submit decision "Analyze the pros and cons of using MongoDB vs PostgreSQL for a web application that needs to store user data, product information, and transaction history."
echo ""

echo -e "${YELLOW}Submitting task to git helper...${NC}"
bash "$(dirname "$0")/agent-memory.sh" submit git "Suggest a branching strategy for a team of 5 developers working on a web application with weekly releases."
echo ""

# List all tasks
echo -e "${BLUE}Step 4: Showing submitted tasks...${NC}"
bash "$(dirname "$0")/agent-memory.sh" tasks
echo ""

echo -e "${GREEN}Demo tasks have been submitted!${NC}"
echo -e "${YELLOW}The agents will now work on these tasks in the background.${NC}"
echo -e "${YELLOW}You can check the status of tasks with:${NC} ./agent-memory.sh tasks"
echo -e "${YELLOW}And view completed task results with:${NC} ./agent-memory.sh output <task_id>"
echo -e "${YELLOW}Or check notifications with:${NC} ./agent-memory.sh notifications"
echo ""
echo -e "${CYAN}====================================${NC}"
