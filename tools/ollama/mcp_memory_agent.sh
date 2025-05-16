#!/bin/bash
# DB-GPT Agent Memory + Enhanced MCP Server Integration
# This script provides integration between the Agent Memory System and the Enhanced MCP Server

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Detect project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default settings
DEFAULT_MODEL="codellama"
DEFAULT_PORT=8000
DEFAULT_HOST="localhost"
DEFAULT_MEMORY_ID="default"

# Parse command line arguments
model="$DEFAULT_MODEL"
port="$DEFAULT_PORT"
host="$DEFAULT_HOST"
memory_id="$DEFAULT_MEMORY_ID"
action=""

print_help() {
    echo -e "${CYAN}DB-GPT Agent Memory + Enhanced MCP Integration${NC}"
    echo ""
    echo "Usage: $(basename "$0") [action] [options]"
    echo ""
    echo "Actions:"
    echo "  ask [query]            - Ask a question with context from agent memory"
    echo "  remember [content]     - Store new information in agent memory"
    echo "  summarize              - Generate a summary of all stored memories"
    echo "  list                   - List all memory entries"
    echo "  search [keyword]       - Search memories for a keyword"
    echo "  clear                  - Clear all memories (with confirmation)"
    echo "  start                  - Start a new session with agent memory"
    echo ""
    echo "Options:"
    echo "  --model MODEL          - Model to use (default: codellama)"
    echo "  --port PORT            - MCP server port (default: 8000)"
    echo "  --host HOST            - MCP server host (default: localhost)"
    echo "  --memory-id ID         - Memory ID to use (default: default)"
    echo "  --help                 - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") ask \"What features have we added to the MCP server?\""
    echo "  $(basename "$0") remember \"We added streaming support to the MCP server on May 16, 2023\""
    echo "  $(basename "$0") summarize --model llama3"
    echo ""
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        ask|remember|summarize|list|search|clear|start)
            action="$1"
            shift
            ;;
        --model)
            model="$2"
            shift 2
            ;;
        --port)
            port="$2"
            shift 2
            ;;
        --host)
            host="$2"
            shift 2
            ;;
        --memory-id)
            memory_id="$2"
            shift 2
            ;;
        --help)
            print_help
            exit 0
            ;;
        *)
            # If action is set and this is not an option, treat as content
            if [[ -n "$action" && ! "$1" == --* ]]; then
                content="$1"
                shift
            else
                echo -e "${RED}Unknown option: $1${NC}"
                print_help
                exit 1
            fi
            ;;
    esac
done

# Set up the API base URL
API_BASE="http://$host:$port"

# Helper function to check if MCP server is running
check_mcp_server() {
    if ! curl -s "$API_BASE/v1/health" > /dev/null; then
        echo -e "${RED}Error: Enhanced MCP server is not running at $API_BASE${NC}"
        echo -e "${YELLOW}Start the server with:${NC} ${GREEN}mcp-enhanced-$model${NC}"
        exit 1
    fi
}

# Helper function to check if agent memory exists and create if needed
check_agent_memory() {
    # Call the agent-memory.sh script with status command
    if ! "$PROJECT_ROOT/agent-memory.sh" status "$memory_id" > /dev/null 2>&1; then
        echo -e "${YELLOW}Memory ID '$memory_id' does not exist. Creating...${NC}"
        "$PROJECT_ROOT/agent-memory.sh" create "$memory_id" > /dev/null 2>&1
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to create memory with ID '$memory_id'${NC}"
            exit 1
        fi
        
        echo -e "${GREEN}Memory created successfully.${NC}"
    fi
}

# Helper function to retrieve memories from agent memory system
get_memories() {
    "$PROJECT_ROOT/agent-memory.sh" export "$memory_id"
}

# Helper function to format memories as context for the model
format_memories_as_context() {
    local memories="$1"
    local query="$2"
    
    # Format the context for the model
    echo "You are an AI assistant with access to the following stored memories:"
    echo ""
    echo "$memories"
    echo ""
    echo "Using the above context, please respond to this question or request:"
    echo "$query"
}

# Helper function to send a prompt to the MCP server (chat completion)
send_prompt() {
    local prompt="$1"
    local use_streaming="$2"
    
    # Use streaming by default
    local stream_param="true"
    if [ "$use_streaming" == "false" ]; then
        stream_param="false"
    fi
    
    # Create a temporary file for the request payload
    local temp_file=$(mktemp)
    
    # Prepare the JSON request
    cat > "$temp_file" << EOF
{
    "model": "$model",
    "messages": [{"role": "user", "content": "$prompt"}],
    "stream": $stream_param
}
EOF
    
    if [ "$use_streaming" == "false" ]; then
        # Non-streaming request
        curl -s "$API_BASE/v1/chat/completions" \
            -H "Content-Type: application/json" \
            -d @"$temp_file" | jq -r '.choices[0].message.content' 
    else
        # Streaming request
        curl -s "$API_BASE/v1/chat/completions" \
            -H "Content-Type: application/json" \
            -d @"$temp_file" --no-buffer | while read -r line; do
            if [[ "$line" == data:*[DONE]* ]]; then
                continue
            fi
            
            if [[ "$line" == data:* ]]; then
                # Parse the delta content
                content=$(echo "$line" | sed 's/^data: //' | jq -r '.choices[0].delta.content // empty' 2>/dev/null)
                if [ -n "$content" ]; then
                    echo -n "$content"
                fi
            fi
        done
    fi
    
    # Clean up
    rm "$temp_file"
}

# Function to handle the "ask" action
handle_ask() {
    check_mcp_server
    check_agent_memory
    
    if [ -z "$content" ]; then
        echo -e "${RED}Error: No query provided${NC}"
        echo "Usage: $0 ask \"your question here\""
        exit 1
    fi
    
    echo -e "${BLUE}Retrieving memories...${NC}"
    memories=$(get_memories)
    
    echo -e "${BLUE}Generating response...${NC}"
    formatted_prompt=$(format_memories_as_context "$memories" "$content")
    
    echo -e "${GREEN}Response:${NC}"
    send_prompt "$formatted_prompt" "true"
    echo ""
}

# Function to handle the "remember" action
handle_remember() {
    check_agent_memory
    
    if [ -z "$content" ]; then
        echo -e "${RED}Error: No content provided to remember${NC}"
        echo "Usage: $0 remember \"information to store\""
        exit 1
    fi
    
    echo -e "${BLUE}Storing memory...${NC}"
    "$PROJECT_ROOT/agent-memory.sh" store "$memory_id" "$content"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Memory stored successfully.${NC}"
    else
        echo -e "${RED}Failed to store memory.${NC}"
        exit 1
    fi
}

# Function to handle the "summarize" action
handle_summarize() {
    check_mcp_server
    check_agent_memory
    
    echo -e "${BLUE}Retrieving memories...${NC}"
    memories=$(get_memories)
    
    if [ -z "$memories" ]; then
        echo -e "${YELLOW}No memories found to summarize.${NC}"
        exit 0
    fi
    
    echo -e "${BLUE}Generating summary...${NC}"
    prompt="Here are my stored memories:\n\n$memories\n\nPlease create a concise summary of all this information, highlighting the most important points and grouping related information together."
    
    echo -e "${GREEN}Summary:${NC}"
    send_prompt "$prompt" "true"
    echo ""
}

# Function to handle the "list" action
handle_list() {
    check_agent_memory
    
    echo -e "${BLUE}Retrieving memory list for ID '$memory_id'...${NC}"
    "$PROJECT_ROOT/agent-memory.sh" list "$memory_id"
}

# Function to handle the "search" action
handle_search() {
    check_agent_memory
    
    if [ -z "$content" ]; then
        echo -e "${RED}Error: No search keyword provided${NC}"
        echo "Usage: $0 search \"keyword\""
        exit 1
    fi
    
    echo -e "${BLUE}Searching memories for: ${YELLOW}$content${NC}"
    "$PROJECT_ROOT/agent-memory.sh" search "$memory_id" "$content"
}

# Function to handle the "clear" action
handle_clear() {
    check_agent_memory
    
    echo -e "${RED}WARNING: This will delete all memories with ID '$memory_id'${NC}"
    read -p "Are you sure you want to continue? (y/N) " confirm
    
    if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
        echo -e "${BLUE}Clearing memories...${NC}"
        "$PROJECT_ROOT/agent-memory.sh" clear "$memory_id"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Memories cleared successfully.${NC}"
        else
            echo -e "${RED}Failed to clear memories.${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}Operation cancelled.${NC}"
    fi
}

# Function to handle the "start" action
handle_start() {
    check_mcp_server
    check_agent_memory
    
    echo -e "${CYAN}=========================================${NC}"
    echo -e "${CYAN}    DB-GPT Memory-Enhanced Assistant    ${NC}"
    echo -e "${CYAN}=========================================${NC}"
    echo ""
    echo -e "${BLUE}Starting new session with memory ID: ${YELLOW}$memory_id${NC}"
    echo -e "${BLUE}Using model: ${YELLOW}$model${NC}"
    echo -e "${BLUE}MCP server: ${YELLOW}$API_BASE${NC}"
    echo ""
    echo -e "Type ${YELLOW}exit${NC} to quit, ${YELLOW}help${NC} for available commands."
    echo ""
    
    # Loop for interactive session
    while true; do
        read -e -p "> " user_input
        
        case "$user_input" in
            exit|quit)
                echo -e "${GREEN}Session ended.${NC}"
                break
                ;;
            help)
                echo -e "${YELLOW}Available commands:${NC}"
                echo -e "  ${GREEN}help${NC}                - Show this help message"
                echo -e "  ${GREEN}exit${NC} or ${GREEN}quit${NC}       - End the session"
                echo -e "  ${GREEN}remember${NC} [info]     - Store new information in memory"
                echo -e "  ${GREEN}list${NC}                - List all stored memories"
                echo -e "  ${GREEN}search${NC} [keyword]    - Search memories for a keyword"
                echo -e "  ${GREEN}summarize${NC}           - Generate a summary of all memories"
                echo -e "  ${GREEN}clear${NC}               - Clear all memories (with confirmation)"
                echo -e "Any other input will be treated as a question to the assistant."
                ;;
            remember*)
                # Extract the content after "remember "
                memory_content="${user_input#remember }"
                if [ "$memory_content" == "remember" ]; then
                    echo -e "${RED}Error: No content provided to remember${NC}"
                    echo -e "Usage: ${GREEN}remember${NC} [information to store]"
                else
                    echo -e "${BLUE}Storing memory...${NC}"
                    "$PROJECT_ROOT/agent-memory.sh" store "$memory_id" "$memory_content"
                    echo -e "${GREEN}Memory stored successfully.${NC}"
                fi
                ;;
            list)
                handle_list
                ;;
            search*)
                # Extract the content after "search "
                search_keyword="${user_input#search }"
                if [ "$search_keyword" == "search" ]; then
                    echo -e "${RED}Error: No search keyword provided${NC}"
                    echo -e "Usage: ${GREEN}search${NC} [keyword]"
                else
                    echo -e "${BLUE}Searching memories for: ${YELLOW}$search_keyword${NC}"
                    "$PROJECT_ROOT/agent-memory.sh" search "$memory_id" "$search_keyword"
                fi
                ;;
            summarize)
                handle_summarize
                ;;
            clear)
                handle_clear
                ;;
            "")
                # Empty input, do nothing
                ;;
            *)
                # Treat as a question
                content="$user_input"
                handle_ask
                ;;
        esac
    done
}

# Main execution
if [ -z "$action" ]; then
    print_help
    exit 1
fi

case "$action" in
    ask)
        handle_ask
        ;;
    remember)
        handle_remember
        ;;
    summarize)
        handle_summarize
        ;;
    list)
        handle_list
        ;;
    search)
        handle_search
        ;;
    clear)
        handle_clear
        ;;
    start)
        handle_start
        ;;
    *)
        echo -e "${RED}Unknown action: $action${NC}"
        print_help
        exit 1
        ;;
esac
