#!/bin/bash
# filepath: /home/msalsouri/Projects/DB-GPT/shell-agent-manager.sh
# Shell Agent Manager - A unified interface for managing DB-GPT shell agents

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to display help
show_help() {
    echo -e "${BOLD}Shell Agent Manager - Unified Interface for DB-GPT Agents${NC}"
    echo ""
    echo -e "Usage: ${CYAN}$(basename "$0") [COMMAND] [OPTIONS]${NC}"
    echo ""
    echo -e "${BOLD}COMMANDS:${NC}"
    echo -e "  ${GREEN}list${NC}                List available shell agents"
    echo -e "  ${GREEN}run AGENT${NC}           Run a specific shell agent"
    echo -e "  ${GREEN}build AGENT${NC}         Build or rebuild a specific agent model"
    echo -e "  ${GREEN}smart${NC}               Run smart shell agent (default)"
    echo -e "  ${GREEN}lite${NC}                Run memory-efficient smart shell agent"
    echo -e "  ${GREEN}auto${NC}                Auto-select agent based on memory"
    echo -e "  ${GREEN}memory${NC}              Show and manage memory usage"
    echo -e "  ${GREEN}compare${NC}             Compare different agent capabilities"
    echo -e "  ${GREEN}docs${NC}                Show agent documentation"
    echo -e "  ${GREEN}help${NC}                Show this help message"
    echo ""
    echo -e "${BOLD}EXAMPLES:${NC}"
    echo -e "  ${CYAN}$(basename "$0") list${NC}              # List all available agents"
    echo -e "  ${CYAN}$(basename "$0") run smart${NC}         # Run the smart shell agent"
    echo -e "  ${CYAN}$(basename "$0") lite${NC}              # Run the memory-efficient agent"
    echo -e "  ${CYAN}$(basename "$0") auto${NC}              # Auto-select based on memory"
    echo -e "  ${CYAN}$(basename "$0") build lite${NC}        # Build the lite agent model"
    echo -e "  ${CYAN}$(basename "$0") memory${NC}            # Show memory usage"
    echo ""
}

# Function to list available agents
list_agents() {
    echo -e "${BOLD}${BLUE}Available Shell Agents:${NC}\n"
    
    # Check for all agent scripts
    echo -e "${BOLD}Agent Scripts:${NC}"
    find "$PROJECT_ROOT" -maxdepth 1 -name "*shell-agent*.sh" -type f | sort | while read -r agent_script; do
        agent_name=$(basename "$agent_script" .sh)
        description=""
        
        # Try to extract description from the file
        if head -20 "$agent_script" | grep -q "# This script"; then
            description=$(head -20 "$agent_script" | grep "# This script" | head -1 | sed 's/# This script//')
        fi
        
        if [ -n "$description" ]; then
            echo -e "  ${GREEN}${agent_name}${NC} -$description"
        else
            echo -e "  ${GREEN}${agent_name}${NC}"
        fi
    done
    
    echo -e "\n${BOLD}Agent Models:${NC}"
    ollama list | grep -v "NAME" | awk '{print "  ",$1}'
    
    echo -e "\n${BOLD}Quick Start:${NC}"
    echo -e "  ${CYAN}$(basename "$0") run smart${NC}    - Run smart shell agent (natural language interface)"
    echo -e "  ${CYAN}$(basename "$0") run lite${NC}     - Run memory-efficient shell agent"
    echo -e "  ${CYAN}$(basename "$0") auto${NC}         - Auto-select agent based on memory"
}

# Function to run a specific agent
run_agent() {
    agent_name="$1"
    shift
    
    case "$agent_name" in
        smart|smart-shell-agent)
            echo -e "${YELLOW}Running Smart Shell Agent...${NC}"
            "$PROJECT_ROOT/run-smart-shell-agent.sh" "$@"
            ;;
        
        lite|smart-shell-agent-lite)
            echo -e "${YELLOW}Running Memory-Efficient Smart Shell Agent...${NC}"
            "$PROJECT_ROOT/run-smart-shell-agent-lite.sh" "$@"
            ;;
        
        shell|regular|original|default)
            echo -e "${YELLOW}Running Regular Shell Agent...${NC}"
            "$PROJECT_ROOT/run-shell-agent.sh" "$@"
            ;;
        
        dbgpt|db-gpt)
            echo -e "${YELLOW}Running DBGPT Shell Agent...${NC}"
            "$PROJECT_ROOT/dbgpt-shell-agent.sh" "$@"
            ;;
        
        enhanced)
            echo -e "${YELLOW}Running Enhanced Shell Agent...${NC}"
            "$PROJECT_ROOT/enhanced-shell-agent.sh" "$@"
            ;;
        
        minimal)
            echo -e "${YELLOW}Running Minimal Shell Agent...${NC}"
            "$PROJECT_ROOT/test-minimal-agent.sh" "$@"
            ;;
        
        auto|auto-select|memory-based)
            echo -e "${YELLOW}Auto-selecting agent based on memory...${NC}"
            if [ -f "$PROJECT_ROOT/auto-memory-manager.sh" ]; then
                "$PROJECT_ROOT/auto-memory-manager.sh"
            else
                echo -e "${RED}Error: Auto memory manager not found.${NC}"
                return 1
            fi
            ;;
        
        *)
            # Check if the script exists
            if [ -f "$PROJECT_ROOT/${agent_name}.sh" ]; then
                echo -e "${YELLOW}Running ${agent_name}...${NC}"
                "$PROJECT_ROOT/${agent_name}.sh" "$@"
            elif [ -f "$PROJECT_ROOT/run-${agent_name}.sh" ]; then
                echo -e "${YELLOW}Running ${agent_name}...${NC}"
                "$PROJECT_ROOT/run-${agent_name}.sh" "$@"
            else
                echo -e "${RED}Error: Agent '${agent_name}' not found${NC}"
                echo -e "${YELLOW}Available agents:${NC}"
                list_agents
                return 1
            fi
            ;;
    esac
}

# Function to build an agent model
build_agent() {
    agent_name="$1"
    shift
    
    case "$agent_name" in
        smart|smart-shell-agent)
            echo -e "${YELLOW}Building Smart Shell Agent...${NC}"
            "$PROJECT_ROOT/run-smart-shell-agent.sh" --build "$@"
            ;;
        
        lite|smart-shell-agent-lite)
            echo -e "${YELLOW}Building Memory-Efficient Smart Shell Agent...${NC}"
            "$PROJECT_ROOT/run-smart-shell-agent-lite.sh" --build "$@"
            ;;
        
        shell|regular|original|default)
            echo -e "${YELLOW}Building Regular Shell Agent...${NC}"
            "$PROJECT_ROOT/build-shell-agent.sh" "$@"
            ;;
        
        minimal)
            echo -e "${YELLOW}Building Minimal Shell Agent...${NC}"
            if [ -f "$PROJECT_ROOT/test-minimal-agent.sh" ]; then
                "$PROJECT_ROOT/test-minimal-agent.sh" --build "$@"
            else
                echo -e "${RED}Error: Minimal shell agent build script not found${NC}"
                return 1
            fi
            ;;
        
        all)
            echo -e "${YELLOW}Building all shell agents...${NC}"
            
            # Build in sequence
            "$PROJECT_ROOT/build-shell-agent.sh" "$@"
            "$PROJECT_ROOT/run-smart-shell-agent.sh" --build "$@"
            "$PROJECT_ROOT/run-smart-shell-agent-lite.sh" --build "$@"
            
            if [ -f "$PROJECT_ROOT/test-minimal-agent.sh" ]; then
                "$PROJECT_ROOT/test-minimal-agent.sh" --build "$@"
            fi
            
            echo -e "${GREEN}All agents built successfully.${NC}"
            ;;
        
        *)
            echo -e "${RED}Error: Unknown agent '${agent_name}'${NC}"
            echo -e "${YELLOW}Available agents to build:${NC}"
            echo -e "  ${GREEN}smart${NC}      - Smart Shell Agent"
            echo -e "  ${GREEN}lite${NC}       - Memory-Efficient Smart Shell Agent"
            echo -e "  ${GREEN}shell${NC}      - Regular Shell Agent"
            echo -e "  ${GREEN}minimal${NC}    - Minimal Shell Agent"
            echo -e "  ${GREEN}all${NC}        - Build all agents"
            return 1
            ;;
    esac
}

# Function to manage memory
manage_memory() {
    # Check if memory manager exists
    if [ -f "$PROJECT_ROOT/integrated-memory-manager.sh" ]; then
        "$PROJECT_ROOT/integrated-memory-manager.sh" "$@"
    elif [ -f "$PROJECT_ROOT/agent-memory-manager.sh" ]; then
        "$PROJECT_ROOT/agent-memory-manager.sh" "$@"
    else
        echo -e "${RED}Error: Memory manager scripts not found${NC}"
        return 1
    fi
}

# Function to compare agent capabilities
compare_agents() {
    echo -e "${BOLD}${BLUE}Shell Agent Comparison:${NC}\n"
    
    echo -e "${BOLD}Smart Shell Agent:${NC}"
    echo -e "  ${GREEN}Advantages:${NC}"
    echo -e "  - Natural language interface"
    echo -e "  - Deep repository knowledge"
    echo -e "  - Proactive suggestions"
    echo -e "  - Collaborative capabilities"
    echo -e "  ${YELLOW}Limitations:${NC}"
    echo -e "  - Higher memory usage (8GB+)"
    echo -e "  - Longer load times"
    echo -e "  ${CYAN}Best for:${NC} Natural interaction and complex tasks"
    echo ""
    
    echo -e "${BOLD}Memory-Efficient Smart Shell Agent:${NC}"
    echo -e "  ${GREEN}Advantages:${NC}"
    echo -e "  - Natural language interface"
    echo -e "  - Lower memory footprint (4GB+)"
    echo -e "  - Faster responses"
    echo -e "  ${YELLOW}Limitations:${NC}"
    echo -e "  - More limited context understanding"
    echo -e "  - Fewer proactive features"
    echo -e "  ${CYAN}Best for:${NC} Systems with memory constraints"
    echo ""
    
    echo -e "${BOLD}Regular Shell Agent:${NC}"
    echo -e "  ${GREEN}Advantages:${NC}"
    echo -e "  - Structured alias training"
    echo -e "  - Consistent responses"
    echo -e "  - Moderate memory usage"
    echo -e "  ${YELLOW}Limitations:${NC}"
    echo -e "  - Limited to predefined training"
    echo -e "  - Less flexible interaction"
    echo -e "  ${CYAN}Best for:${NC} Learning specific commands and aliases"
    echo ""
    
    echo -e "${BOLD}Minimal Shell Agent:${NC}"
    echo -e "  ${GREEN}Advantages:${NC}"
    echo -e "  - Very low memory usage"
    echo -e "  - Fast startup time"
    echo -e "  - Simple implementation"
    echo -e "  ${YELLOW}Limitations:${NC}"
    echo -e "  - Basic functionality only"
    echo -e "  - Limited context understanding"
    echo -e "  ${CYAN}Best for:${NC} Testing and minimal environments"
    echo ""
    
    echo -e "${BOLD}Recommendation:${NC}"
    
    # Check available memory
    free_mem=$(free | grep Mem | awk '{print $4}')
    
    if [ $free_mem -lt 2000000 ]; then
        echo -e "Based on your available memory ($(($free_mem / 1024)) MB), use the ${BOLD}Minimal Shell Agent${NC}"
        echo -e "${CYAN}$(basename "$0") run minimal${NC}"
    elif [ $free_mem -lt 4000000 ]; then
        echo -e "Based on your available memory ($(($free_mem / 1024)) MB), use the ${BOLD}Memory-Efficient Smart Shell Agent${NC}"
        echo -e "${CYAN}$(basename "$0") run lite${NC}"
    else
        echo -e "Based on your available memory ($(($free_mem / 1024)) MB), you can use the ${BOLD}Smart Shell Agent${NC}"
        echo -e "${CYAN}$(basename "$0") run smart${NC}"
    fi
}

# Function to show documentation
show_docs() {
    agent_name="$1"
    
    case "$agent_name" in
        smart|smart-shell-agent)
            if [ -f "$PROJECT_ROOT/smart-shell-agent-README.md" ]; then
                if command -v bat &> /dev/null; then
                    bat --style=plain "$PROJECT_ROOT/smart-shell-agent-README.md"
                elif command -v mdless &> /dev/null; then
                    mdless "$PROJECT_ROOT/smart-shell-agent-README.md"
                else
                    cat "$PROJECT_ROOT/smart-shell-agent-README.md"
                fi
            else
                echo -e "${RED}Error: Documentation not found for Smart Shell Agent${NC}"
                return 1
            fi
            ;;
        
        lite|memory-efficient)
            if [ -f "$PROJECT_ROOT/memory-efficient-README.md" ]; then
                if command -v bat &> /dev/null; then
                    bat --style=plain "$PROJECT_ROOT/memory-efficient-README.md"
                elif command -v mdless &> /dev/null; then
                    mdless "$PROJECT_ROOT/memory-efficient-README.md"
                else
                    cat "$PROJECT_ROOT/memory-efficient-README.md"
                fi
            else
                echo -e "${RED}Error: Documentation not found for Memory-Efficient Agent${NC}"
                return 1
            fi
            ;;
        
        shell)
            echo -e "${YELLOW}Shell training has been removed as it's no longer needed with the talking chatbot.${NC}"
            echo -e "${GREEN}Use the interactive chatbot instead for shell assistance.${NC}"
            ;;
            ;;
        
        *)
            echo -e "${BOLD}${BLUE}Shell Agent Documentation:${NC}\n"
            
            echo -e "${BOLD}Available Documentation:${NC}"
            find "$PROJECT_ROOT" -maxdepth 1 -name "*README.md" -type f | sort | while read -r doc_file; do
                doc_name=$(basename "$doc_file" .md)
                echo -e "  ${GREEN}${doc_name}${NC}"
            done
            
            echo -e "\n${BOLD}Usage:${NC}"
            echo -e "  ${CYAN}$(basename "$0") docs AGENT${NC}  - Show documentation for specific agent"
            
            echo -e "\n${BOLD}Examples:${NC}"
            echo -e "  ${CYAN}$(basename "$0") docs smart${NC}  - Show Smart Shell Agent documentation"
            echo -e "  ${CYAN}$(basename "$0") docs lite${NC}   - Show Memory-Efficient Agent documentation"
            ;;
    esac
}

# Parse command line arguments
case "$1" in
    list)
        list_agents
        ;;
    
    run)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Please specify an agent to run${NC}"
            echo -e "${YELLOW}Usage:${NC} $(basename "$0") run AGENT [OPTIONS]"
            list_agents
            exit 1
        fi
        
        agent_name="$2"
        shift 2
        run_agent "$agent_name" "$@"
        ;;
    
    build)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Please specify an agent to build${NC}"
            echo -e "${YELLOW}Usage:${NC} $(basename "$0") build AGENT [OPTIONS]"
            echo -e "${YELLOW}Available agents:${NC} smart, lite, shell, minimal, all"
            exit 1
        fi
        
        agent_name="$2"
        shift 2
        build_agent "$agent_name" "$@"
        ;;
    
    smart)
        shift
        run_agent "smart" "$@"
        ;;
    
    lite)
        shift
        run_agent "lite" "$@"
        ;;
    
    auto)
        shift
        run_agent "auto" "$@"
        ;;
    
    memory)
        shift
        manage_memory "$@"
        ;;
    
    compare)
        compare_agents
        ;;
    
    docs)
        shift
        show_docs "$@"
        ;;
    
    help)
        show_help
        ;;
    
    *)
        # If no command is provided, show help
        if [ -z "$1" ]; then
            # No specific action requested, show interactive menu
            echo -e "${BOLD}${BLUE}Shell Agent Manager${NC}\n"
            echo -e "${YELLOW}Quick commands:${NC}"
            echo -e "  ${CYAN}$(basename "$0") smart${NC}    - Run smart shell agent"
            echo -e "  ${CYAN}$(basename "$0") lite${NC}     - Run memory-efficient shell agent"
            echo -e "  ${CYAN}$(basename "$0") auto${NC}     - Auto-select agent based on memory"
            echo -e "  ${CYAN}$(basename "$0") list${NC}     - List available agents"
            echo -e "  ${CYAN}$(basename "$0") memory${NC}   - Manage memory usage"
            echo -e "  ${CYAN}$(basename "$0") help${NC}     - Show detailed help"
        else
            echo -e "${RED}Unknown command: $1${NC}"
            show_help
            exit 1
        fi
        ;;
esac

exit 0
