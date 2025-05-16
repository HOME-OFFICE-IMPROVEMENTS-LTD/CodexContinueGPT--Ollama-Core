#!/bin/bash
# DB-GPT Agent Memory and Co-working System
# This script adds memory persistence and co-working capability to the DB-GPT agent system

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Memory base directory - stores agent memory and conversation history
MEMORY_BASE_DIR="$HOME/.dbgpt_agents"

# Task queue directory - stores pending and completed tasks
TASK_QUEUE_DIR="$MEMORY_BASE_DIR/tasks"

# Memory index file - keeps track of all memories and their metadata
MEMORY_INDEX="$MEMORY_BASE_DIR/memory_index.json"

# Default memory size limit in KB (10MB total across all agents by default)
MAX_MEMORY_SIZE=10240

# Default model - should match the model in agent-commands.sh
DEFAULT_MODEL="codellama:latest"

# Initialize the memory system directories
initialize_memory_system() {
    # Create base memory directory if it doesn't exist
    if [ ! -d "$MEMORY_BASE_DIR" ]; then
        mkdir -p "$MEMORY_BASE_DIR"
        echo -e "${GREEN}Created agent memory base directory: $MEMORY_BASE_DIR${NC}"
    fi
    
    # Create agent-specific memory directories
    for agent in "code" "shell" "tasks" "audit" "git" "decision"; do
        if [ ! -d "$MEMORY_BASE_DIR/$agent" ]; then
            mkdir -p "$MEMORY_BASE_DIR/$agent"
        fi
    done
    
    # Create task queue directories
    if [ ! -d "$TASK_QUEUE_DIR" ]; then
        mkdir -p "$TASK_QUEUE_DIR/pending"
        mkdir -p "$TASK_QUEUE_DIR/running"
        mkdir -p "$TASK_QUEUE_DIR/completed"
        mkdir -p "$TASK_QUEUE_DIR/failed"
    fi
    
    # Create or ensure the memory index exists
    if [ ! -f "$MEMORY_INDEX" ]; then
        echo '{
  "agents": {
    "code": {"conversations": [], "facts": [], "preferences": {}},
    "shell": {"conversations": [], "facts": [], "preferences": {}},
    "tasks": {"conversations": [], "facts": [], "preferences": {}},
    "audit": {"conversations": [], "facts": [], "preferences": {}},
    "git": {"conversations": [], "facts": [], "preferences": {}},
    "decision": {"conversations": [], "facts": [], "preferences": {}}
  },
  "global": {
    "facts": [],
    "preferences": {},
    "last_summarized": null
  }
}' > "$MEMORY_INDEX"
    fi
}

# Check if jq is installed (required for JSON operations)
check_jq_installed() {
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}Warning: jq is not installed. Memory features will be limited.${NC}"
        echo -e "${YELLOW}Please install jq for full functionality:${NC}"
        echo -e "${YELLOW}  sudo apt-get install jq (Debian/Ubuntu)${NC}"
        echo -e "${YELLOW}  brew install jq (macOS with Homebrew)${NC}"
        return 1
    fi
    return 0
}

# Save the conversation history for a specific agent
save_conversation() {
    local agent=$1
    local history_file=$2
    
    # Check if we have jq installed
    if ! check_jq_installed; then
        echo -e "${YELLOW}Cannot save conversation without jq. Installing memory will be skipped.${NC}"
        return 1
    fi
    
    # Create conversation ID based on timestamp
    local conversation_id=$(date +"%Y%m%d%H%M%S")
    local conversation_file="$MEMORY_BASE_DIR/$agent/conversation_$conversation_id.json"
    
    # Copy the history file to the permanent location
    cp "$history_file" "$conversation_file"
    
    # Add the conversation to the memory index
    local temp_index=$(mktemp)
    jq --arg agent "$agent" --arg id "$conversation_id" --arg file "$conversation_file" --arg date "$(date -Iseconds)" \
       '.agents[$agent].conversations += [{"id": $id, "file": $file, "date": $date}]' \
       "$MEMORY_INDEX" > "$temp_index" && mv "$temp_index" "$MEMORY_INDEX"
    
    echo -e "${GREEN}Conversation saved for $agent agent (ID: $conversation_id)${NC}"
    
    # Check if we need to summarize and prune old conversations
    check_and_prune_memory "$agent"
    
    return 0
}

# Extract key facts from a conversation using AI
extract_facts() {
    local agent=$1
    local conversation_file=$2
    local model=$DEFAULT_MODEL
    
    # Check if we have jq installed
    if ! check_jq_installed; then
        echo -e "${YELLOW}Cannot extract facts without jq.${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Extracting key facts from conversation...${NC}"
    
    # Read the conversation
    local conversation_json=$(cat "$conversation_file")
    
    # System prompt for fact extraction
    local system_prompt="You are a fact extraction AI. Your task is to extract important facts, code snippets, and user preferences from a conversation. Focus on:
1. Technical information that would be useful in future conversations
2. User preferences about coding style, tools, or approaches
3. Specific problems the user was trying to solve
4. Important code examples that were provided or generated
5. File paths, project structures, or system configurations mentioned

Return the facts in JSON format with these categories: 
{\"technical_info\": [\"fact1\", \"fact2\"], 
\"preferences\": [\"pref1\", \"pref2\"], 
\"problems\": [\"problem1\", \"problem2\"],
\"code_examples\": [\"example1\", \"example2\"],
\"system_details\": [\"detail1\", \"detail2\"]}

Keep each fact concise but include specifics like function names, file paths, etc."

    # User prompt
    local user_prompt="Extract key facts from this conversation:
$conversation_json"

    # Escape the prompts for JSON
    local escaped_system_prompt=$(echo "$system_prompt" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/\n/\\n/g')
    local escaped_user_prompt=$(echo "$user_prompt" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/\n/\\n/g')
    
    # Prepare JSON for Ollama API
    local json_data=$(cat <<EOF
{
  "model": "$model",
  "messages": [
    {"role": "system", "content": "$escaped_system_prompt"},
    {"role": "user", "content": "$escaped_user_prompt"}
  ]
}
EOF
)

    # Call Ollama API to extract facts
    local facts_json=$(curl -s "http://localhost:11434/api/chat" \
      -H "Content-Type: application/json" \
      -d "$json_data" | jq -r '.message.content')
    
    # Save facts to a file
    local facts_file="$MEMORY_BASE_DIR/$agent/facts_$(date +"%Y%m%d%H%M%S").json"
    echo "$facts_json" > "$facts_file"
    
    # Add the facts to the memory index
    local temp_index=$(mktemp)
    jq --arg agent "$agent" --arg file "$facts_file" --arg date "$(date -Iseconds)" \
       '.agents[$agent].facts += [{"file": $file, "date": $date}]' \
       "$MEMORY_INDEX" > "$temp_index" && mv "$temp_index" "$MEMORY_INDEX"
    
    echo -e "${GREEN}Key facts extracted and saved for $agent agent${NC}"
    
    return 0
}

# Check if memory needs pruning and perform summarization if needed
check_and_prune_memory() {
    local agent=$1
    
    # Check current memory size
    local total_size=0
    if [[ -d "$MEMORY_BASE_DIR/$agent" ]]; then
        total_size=$(du -sk "$MEMORY_BASE_DIR/$agent" | cut -f1)
    fi
    
    # If memory is below threshold, no need to prune
    if [ $total_size -lt $MAX_MEMORY_SIZE ]; then
        return 0
    fi
    
    echo -e "${YELLOW}Memory size for $agent agent exceeds threshold. Performing summarization...${NC}"
    
    # Count how many conversation files we have
    local conversation_count=$(ls -1 "$MEMORY_BASE_DIR/$agent"/conversation_*.json 2>/dev/null | wc -l)
    
    # If we have more than 10 conversations, summarize the oldest ones
    if [ $conversation_count -gt 10 ]; then
        # Get list of conversation files sorted by date (oldest first)
        local oldest_files=($(ls -t "$MEMORY_BASE_DIR/$agent"/conversation_*.json 2>/dev/null | tail -5))
        
        if [ ${#oldest_files[@]} -gt 0 ]; then
            echo -e "${BLUE}Summarizing ${#oldest_files[@]} oldest conversations...${NC}"
            
            # Combine and summarize these conversations
            summarize_conversations "$agent" "${oldest_files[@]}"
            
            # After summarizing, delete the original files
            for file in "${oldest_files[@]}"; do
                rm -f "$file"
                
                # Also remove from the index
                local basename=$(basename "$file")
                local conversation_id="${basename#conversation_}"
                conversation_id="${conversation_id%.json}"
                
                local temp_index=$(mktemp)
                jq --arg agent "$agent" --arg id "$conversation_id" \
                   '.agents[$agent].conversations = [.agents[$agent].conversations[] | select(.id != $id)]' \
                   "$MEMORY_INDEX" > "$temp_index" && mv "$temp_index" "$MEMORY_INDEX"
            done
        fi
    fi
    
    return 0
}

# Summarize multiple conversations into a single memory
summarize_conversations() {
    local agent=$1
    shift
    local files=("$@")
    
    # Create a summary of the conversations using AI
    echo -e "${BLUE}Creating summary of conversations...${NC}"
    
    # Prepare content from all files
    local all_content=""
    for file in "${files[@]}"; do
        all_content+=$(cat "$file")
        all_content+="\n\n---\n\n"
    done
    
    # System prompt for summarization
    local system_prompt="You are a conversation summarization AI. Your task is to create a concise summary of multiple conversations with an AI assistant. Focus on:
1. Key technical topics discussed
2. Solutions provided
3. Code examples that are reusable
4. User preferences or specific requirements
5. Problems that were solved

Create a summary that would be useful for future conversations about similar topics. Be specific but concise."

    # User prompt
    local user_prompt="Summarize these conversations:
$all_content"

    # Escape the prompts for JSON
    local escaped_system_prompt=$(echo "$system_prompt" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/\n/\\n/g')
    local escaped_user_prompt=$(echo "$user_prompt" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/\n/\\n/g')
    
    # Prepare JSON for Ollama API
    local json_data=$(cat <<EOF
{
  "model": "$DEFAULT_MODEL",
  "messages": [
    {"role": "system", "content": "$escaped_system_prompt"},
    {"role": "user", "content": "$escaped_user_prompt"}
  ]
}
EOF
)

    # Call Ollama API to create summary
    local summary=$(curl -s "http://localhost:11434/api/chat" \
      -H "Content-Type: application/json" \
      -d "$json_data" | jq -r '.message.content')
    
    # Save summary to a file
    local summary_id=$(date +"%Y%m%d%H%M%S")
    local summary_file="$MEMORY_BASE_DIR/$agent/summary_$summary_id.txt"
    echo "$summary" > "$summary_file"
    
    # Add the summary to the memory index
    local temp_index=$(mktemp)
    jq --arg agent "$agent" --arg id "$summary_id" --arg file "$summary_file" --arg date "$(date -Iseconds)" \
       '.agents[$agent].summaries += [{"id": $id, "file": $file, "date": $date}]' \
       "$MEMORY_INDEX" > "$temp_index" && mv "$temp_index" "$MEMORY_INDEX"
    
    echo -e "${GREEN}Created summary of conversations for $agent agent${NC}"
    
    return 0
}

# Generate a system prompt that includes relevant memory for an agent
generate_memory_enhanced_prompt() {
    local agent=$1
    local base_system_prompt=$2
    
    # Check if memory system is initialized
    if [ ! -d "$MEMORY_BASE_DIR" ]; then
        initialize_memory_system
    fi
    
    # Check if we have jq
    if ! check_jq_installed; then
        echo "$base_system_prompt"
        return 0
    fi
    
    # Get relevant facts for this agent
    local facts_content=""
    if [ -d "$MEMORY_BASE_DIR/$agent" ]; then
        # Get the most recent facts files (up to 3)
        local fact_files=($(ls -t "$MEMORY_BASE_DIR/$agent"/facts_*.json 2>/dev/null | head -3))
        
        if [ ${#fact_files[@]} -gt 0 ]; then
            facts_content+="Based on our previous conversations, here are some relevant facts:\n\n"
            
            for file in "${fact_files[@]}"; do
                if [ -f "$file" ]; then
                    facts_content+=$(cat "$file")
                    facts_content+="\n\n"
                fi
            done
        fi
    fi
    
    # Get summaries if available
    local summaries_content=""
    if [ -d "$MEMORY_BASE_DIR/$agent" ]; then
        # Get the most recent summary file (just one)
        local summary_file=$(ls -t "$MEMORY_BASE_DIR/$agent"/summary_*.txt 2>/dev/null | head -1)
        
        if [ -f "$summary_file" ]; then
            summaries_content+="Summary of our previous conversations:\n\n"
            summaries_content+=$(cat "$summary_file")
            summaries_content+="\n\n"
        fi
    fi
    
    # Generate enhanced prompt with memory content
    if [[ -n "$facts_content" || -n "$summaries_content" ]]; then
        local memory_prompt="$base_system_prompt

$facts_content
$summaries_content

The information above is from previous conversations with the user. Use it to provide more contextually relevant responses, but focus primarily on addressing the user's current question or task."
        
        echo "$memory_prompt"
    else
        echo "$base_system_prompt"
    fi
}

# Submit a task to be processed in the background
submit_background_task() {
    local agent=$1
    local task_description=$2
    local system_prompt=$3
    
    # Generate task ID
    local task_id="task_$(date +"%Y%m%d%H%M%S")"
    local task_file="$TASK_QUEUE_DIR/pending/$task_id.json"
    
    # Create task JSON
    cat > "$task_file" <<EOF
{
  "task_id": "$task_id",
  "agent": "$agent",
  "description": "$task_description",
  "system_prompt": "$system_prompt",
  "status": "pending",
  "created_at": "$(date -Iseconds)",
  "started_at": null,
  "completed_at": null
}
EOF
    
    echo -e "${GREEN}Task submitted: $task_id${NC}"
    echo -e "${BLUE}Description: $task_description${NC}"
    
    # Check if the background worker is running, start if not
    ensure_background_worker_running
    
    return 0
}

# Function to ensure the background worker is running
ensure_background_worker_running() {
    # Check if background worker is already running
    if pgrep -f "bash.*agent-memory.sh worker" > /dev/null; then
        return 0
    fi
    
    echo -e "${YELLOW}Starting background worker...${NC}"
    
    # Start the background worker in a detached process
    nohup bash -c "$(dirname "$0")/agent-memory.sh worker" > "$MEMORY_BASE_DIR/worker.log" 2>&1 &
    
    echo -e "${GREEN}Background worker started with PID $!${NC}"
    return 0
}

# Background worker process that processes tasks in the queue
background_worker() {
    echo "Starting background worker at $(date)"
    
    # Create an indicator file to show the worker is running
    echo $$ > "$MEMORY_BASE_DIR/worker.pid"
    
    # Infinite loop to process tasks
    while true; do
        # Check if there are any pending tasks
        local pending_tasks=($(ls -1 "$TASK_QUEUE_DIR/pending"/*.json 2>/dev/null))
        
        if [ ${#pending_tasks[@]} -gt 0 ]; then
            # Get the oldest task
            local task_file="${pending_tasks[0]}"
            local task_id=$(basename "$task_file" .json)
            
            echo "Processing task: $task_id at $(date)"
            
            # Move task to running state
            mv "$task_file" "$TASK_QUEUE_DIR/running/$(basename "$task_file")"
            task_file="$TASK_QUEUE_DIR/running/$(basename "$task_file")"
            
            # Update task status
            local temp_task=$(mktemp)
            jq '.status = "running" | .started_at = "'"$(date -Iseconds)"'"' "$task_file" > "$temp_task" && mv "$temp_task" "$task_file"
            
            # Extract task details
            local agent=$(jq -r '.agent' "$task_file")
            local description=$(jq -r '.description' "$task_file")
            local system_prompt=$(jq -r '.system_prompt' "$task_file")
            
            # Set up output file
            local output_file="$TASK_QUEUE_DIR/running/${task_id}_output.txt"
            
            # Process the task using Ollama API
            echo "Running Ollama for task $task_id with agent $agent"
            
            # Enhance the system prompt with memory
            local enhanced_prompt=$(generate_memory_enhanced_prompt "$agent" "$system_prompt")
            
            # Escape the prompts for JSON
            local escaped_system_prompt=$(echo "$enhanced_prompt" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/\n/\\n/g')
            local escaped_user_prompt=$(echo "$description" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/\n/\\n/g')
            
            # Prepare JSON for Ollama API
            local json_data=$(cat <<EOF
{
  "model": "$DEFAULT_MODEL",
  "messages": [
    {"role": "system", "content": "$escaped_system_prompt"},
    {"role": "user", "content": "$escaped_user_prompt"}
  ]
}
EOF
)

            # Call Ollama API to process task
            curl -s "http://localhost:11434/api/chat" \
              -H "Content-Type: application/json" \
              -d "$json_data" | jq -r '.message.content' > "$output_file"
            
            # Task completed successfully
            # Move to completed folder
            mv "$task_file" "$TASK_QUEUE_DIR/completed/$(basename "$task_file")"
            task_file="$TASK_QUEUE_DIR/completed/$(basename "$task_file")"
            
            # Update task status
            temp_task=$(mktemp)
            jq '.status = "completed" | .completed_at = "'"$(date -Iseconds)"'"' "$task_file" > "$temp_task" && mv "$temp_task" "$task_file"
            
            # Move output file to completed folder too
            mv "$output_file" "$TASK_QUEUE_DIR/completed/$(basename "$output_file")"
            
            # Generate notification
            notify_task_completed "$task_id" "$agent" "$description"
            
            # Save this as a memory
            local history_file=$(mktemp)
            echo "{\"role\":\"system\",\"content\":\"$escaped_system_prompt\"}" > "$history_file"
            echo "{\"role\":\"user\",\"content\":\"$escaped_user_prompt\"}" >> "$history_file"
            echo "{\"role\":\"assistant\",\"content\":\"$(cat "$TASK_QUEUE_DIR/completed/$(basename "$output_file")" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/\n/\\n/g')\"}" >> "$history_file"
            
            # Save the conversation
            save_conversation "$agent" "$history_file"
            rm -f "$history_file"
            
            echo "Task $task_id completed at $(date)"
        fi
        
        # Sleep for a short while before checking for more tasks
        sleep 5
    done
}

# Notify user about completed task
notify_task_completed() {
    local task_id=$1
    local agent=$2
    local description=$3
    
    # Create notification file
    local notification_file="$MEMORY_BASE_DIR/notifications_$(date +"%Y%m%d").txt"
    
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Task $task_id completed by $agent agent" >> "$notification_file"
    echo "Description: $description" >> "$notification_file"
    echo "Output available in: $TASK_QUEUE_DIR/completed/${task_id}_output.txt" >> "$notification_file"
    echo "-----------------------------------" >> "$notification_file"
    
    # Try to send desktop notification if available
    if command -v notify-send &> /dev/null; then
        notify-send "DB-GPT Agent Task Completed" "Task $task_id completed by $agent agent"
    fi
}

# List notifications for the user
list_notifications() {
    local notification_file="$MEMORY_BASE_DIR/notifications_$(date +"%Y%m%d").txt"
    
    if [ -f "$notification_file" ]; then
        echo -e "${CYAN}====================================${NC}"
        echo -e "${CYAN}   DB-GPT Agent Notifications   ${NC}"
        echo -e "${CYAN}====================================${NC}"
        echo ""
        cat "$notification_file"
    else
        echo -e "${YELLOW}No notifications for today.${NC}"
    fi
}

# List all pending and running tasks
list_tasks() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}   DB-GPT Agent Tasks   ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo ""
    
    # Check pending tasks
    echo -e "${YELLOW}Pending Tasks:${NC}"
    local pending_tasks=($(ls -1 "$TASK_QUEUE_DIR/pending"/*.json 2>/dev/null))
    if [ ${#pending_tasks[@]} -gt 0 ]; then
        for task in "${pending_tasks[@]}"; do
            local task_id=$(basename "$task" .json)
            local description=$(jq -r '.description' "$task")
            local agent=$(jq -r '.agent' "$task")
            local created_at=$(jq -r '.created_at' "$task")
            
            echo -e "${BLUE}ID:${NC} $task_id"
            echo -e "${BLUE}Agent:${NC} $agent"
            echo -e "${BLUE}Created:${NC} $created_at"
            echo -e "${BLUE}Description:${NC} $description"
            echo -e "-----------------------------------"
        done
    else
        echo -e "${GREEN}No pending tasks${NC}"
    fi
    
    echo ""
    
    # Check running tasks
    echo -e "${YELLOW}Running Tasks:${NC}"
    local running_tasks=($(ls -1 "$TASK_QUEUE_DIR/running"/*.json 2>/dev/null))
    if [ ${#running_tasks[@]} -gt 0 ]; then
        for task in "${running_tasks[@]}"; do
            # Skip output files
            if [[ $task == *"_output.txt" ]]; then
                continue
            fi
            
            local task_id=$(basename "$task" .json)
            local description=$(jq -r '.description' "$task")
            local agent=$(jq -r '.agent' "$task")
            local started_at=$(jq -r '.started_at' "$task")
            
            echo -e "${BLUE}ID:${NC} $task_id"
            echo -e "${BLUE}Agent:${NC} $agent"
            echo -e "${BLUE}Started:${NC} $started_at"
            echo -e "${BLUE}Description:${NC} $description"
            echo -e "-----------------------------------"
        done
    else
        echo -e "${GREEN}No running tasks${NC}"
    fi
}

# Show output of a completed task
show_task_output() {
    local task_id=$1
    
    if [ -z "$task_id" ]; then
        echo -e "${RED}Error: No task ID specified${NC}"
        return 1
    fi
    
    # Check if the output file exists
    local output_file="$TASK_QUEUE_DIR/completed/${task_id}_output.txt"
    
    if [ -f "$output_file" ]; then
        echo -e "${CYAN}====================================${NC}"
        echo -e "${CYAN}   Task Output: $task_id   ${NC}"
        echo -e "${CYAN}====================================${NC}"
        echo ""
        
        # Get task details
        local task_file="$TASK_QUEUE_DIR/completed/${task_id}.json"
        if [ -f "$task_file" ]; then
            local description=$(jq -r '.description' "$task_file")
            local agent=$(jq -r '.agent' "$task_file")
            local created_at=$(jq -r '.created_at' "$task_file")
            local completed_at=$(jq -r '.completed_at' "$task_file")
            
            echo -e "${BLUE}Task:${NC} $description"
            echo -e "${BLUE}Agent:${NC} $agent"
            echo -e "${BLUE}Created:${NC} $created_at"
            echo -e "${BLUE}Completed:${NC} $completed_at"
            echo -e "-----------------------------------"
            echo ""
        fi
        
        # Show the output
        cat "$output_file"
    else
        echo -e "${RED}Error: Output for task $task_id not found${NC}"
        return 1
    fi
}

# Function to modify the run_ollama_prompt function in agent-commands.sh to use memory
patch_agent_commands() {
    local agent_commands_file="$(dirname "$0")/agent-commands.sh"
    
    if [ ! -f "$agent_commands_file" ]; then
        echo -e "${RED}Error: agent-commands.sh not found${NC}"
        return 1
    fi
    
    # Check if already patched
    if grep -q "# DB-GPT Agent Memory Integration" "$agent_commands_file"; then
        echo -e "${YELLOW}agent-commands.sh already patched with memory integration${NC}"
        return 0
    fi
    
    echo -e "${BLUE}Patching agent-commands.sh with memory integration...${NC}"
    
    # Create a backup
    cp "$agent_commands_file" "$agent_commands_file.bak"
    
    # Find the end of the run_ollama_prompt function
    local end_line=$(grep -n "}" "$agent_commands_file" | grep -A1 "run_ollama_prompt" | tail -1 | cut -d: -f1)
    
    # Insert code just before the closing brace
    local temp_file=$(mktemp)
    head -n $((end_line-1)) "$agent_commands_file" > "$temp_file"
    
    # Add memory integration code
    cat >> "$temp_file" <<'EOF'
    
    # DB-GPT Agent Memory Integration
    # Save conversation to persistent memory if applicable
    local agent_type="unknown"
    if [[ "$FUNCNAME" == *"code_assistant"* ]]; then
        agent_type="code"
    elif [[ "$FUNCNAME" == *"shell_helper"* ]]; then
        agent_type="shell"
    elif [[ "$FUNCNAME" == *"task_manager"* ]]; then
        agent_type="tasks"
    elif [[ "$FUNCNAME" == *"audit_code"* ]]; then
        agent_type="audit"
    elif [[ "$FUNCNAME" == *"git_helper"* ]]; then
        agent_type="git"
    elif [[ "$FUNCNAME" == *"decision_audit"* ]]; then
        agent_type="decision"
    fi
    
    # Check if memory integration script exists and save the conversation
    local memory_script="$(dirname "$0")/agent-memory.sh"
    if [ -f "$memory_script" ] && [ "$agent_type" != "unknown" ]; then
        # Save conversation to memory
        bash "$memory_script" save "$agent_type" "$history_file"
    fi
EOF
    
    # Add the rest of the file
    tail -n +$end_line "$agent_commands_file" >> "$temp_file"
    
    # Replace the original file
    mv "$temp_file" "$agent_commands_file"
    chmod +x "$agent_commands_file"
    
    echo -e "${GREEN}Successfully patched agent-commands.sh with memory integration${NC}"
    return 0
}

# Help function
print_help() {
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}   DB-GPT Agent Memory System   ${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo ""
    echo -e "${GREEN}Available Commands:${NC}"
    echo -e "  ${YELLOW}$(basename "$0") initialize${NC}            ${BLUE}# Set up memory system${NC}"
    echo -e "  ${YELLOW}$(basename "$0") save <agent> <file>${NC}   ${BLUE}# Save conversation to memory${NC}"
    echo -e "  ${YELLOW}$(basename "$0") facts <agent> <file>${NC}  ${BLUE}# Extract facts from conversation${NC}"
    echo -e "  ${YELLOW}$(basename "$0") submit <agent> \"task\"${NC}  ${BLUE}# Submit a background task${NC}"
    echo -e "  ${YELLOW}$(basename "$0") tasks${NC}                 ${BLUE}# List pending and running tasks${NC}"
    echo -e "  ${YELLOW}$(basename "$0") output <task_id>${NC}      ${BLUE}# Show output of completed task${NC}"
    echo -e "  ${YELLOW}$(basename "$0") notifications${NC}         ${BLUE}# Show task completion notifications${NC}"
    echo -e "  ${YELLOW}$(basename "$0") worker${NC}                ${BLUE}# Run background worker (internal)${NC}"
    echo -e "  ${YELLOW}$(basename "$0") patch${NC}                 ${BLUE}# Patch agent-commands.sh with memory support${NC}"
    echo -e "  ${YELLOW}$(basename "$0") help${NC}                  ${BLUE}# Show this help message${NC}"
    echo ""
    echo -e "${GREEN}Memory Location:${NC} $MEMORY_BASE_DIR"
    echo -e "${GREEN}Task Queue:${NC} $TASK_QUEUE_DIR"
    echo ""
    echo -e "${YELLOW}Note: Install jq for full functionality${NC}"
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
        "initialize")
            initialize_memory_system
            ;;
        "save")
            if [ $# -lt 3 ]; then
                echo -e "${RED}Error: Missing arguments${NC}"
                echo -e "Usage: $(basename "$0") save <agent> <file>"
                return 1
            fi
            save_conversation "$2" "$3"
            ;;
        "facts")
            if [ $# -lt 3 ]; then
                echo -e "${RED}Error: Missing arguments${NC}"
                echo -e "Usage: $(basename "$0") facts <agent> <file>"
                return 1
            fi
            extract_facts "$2" "$3"
            ;;
        "submit")
            if [ $# -lt 3 ]; then
                echo -e "${RED}Error: Missing arguments${NC}"
                echo -e "Usage: $(basename "$0") submit <agent> \"task description\" [system_prompt]"
                return 1
            fi
            
            local agent="$2"
            local task="$3"
            local system_prompt=""
            
            # Check if system prompt is provided
            if [ $# -ge 4 ]; then
                system_prompt="$4"
            else
                # Use default system prompt based on agent type
                case "$agent" in
                    "code")
                        system_prompt="You are an expert programming assistant. Help the user write high-quality, secure, and efficient code. Provide examples, explain concepts, and suggest improvements."
                        ;;
                    "shell")
                        system_prompt="You are an expert in shell scripting and command-line operations. Your primary goal is to help the user with shell commands, explain their usage, and create shell scripts. Always provide clear explanations and make sure commands are secure and follow best practices."
                        ;;
                    "tasks")
                        system_prompt="You are a project management assistant focused on helping developers organize their tasks and workflow. Help the user prioritize tasks, break down large tasks into smaller steps, and keep track of progress."
                        ;;
                    "audit")
                        system_prompt="You are a code auditor with expertise in identifying security vulnerabilities, performance issues, and code quality concerns. Analyze the provided code and report: 1. Security vulnerabilities 2. Performance bottlenecks 3. Code quality issues 4. Best practice violations 5. Suggested improvements"
                        ;;
                    "git")
                        system_prompt="You are a Git expert who helps developers with Git commands and workflows. Your guidance should be accurate, secure, and follow Git best practices. Consider branching strategies, commit message conventions, merge vs. rebase workflows, and resolving conflicts."
                        ;;
                    "decision")
                        system_prompt="You are an impartial and objective code auditor and decision reviewer. Your task is to critically analyze the provided implementation decisions or architectural choices."
                        ;;
                    *)
                        system_prompt="You are an AI assistant. Provide helpful, accurate, and concise responses to the user's requests."
                        ;;
                esac
            fi
            
            # Initialize memory system if needed
            if [ ! -d "$MEMORY_BASE_DIR" ]; then
                initialize_memory_system
            fi
            
            submit_background_task "$agent" "$task" "$system_prompt"
            ;;
        "tasks")
            # Initialize memory system if needed
            if [ ! -d "$MEMORY_BASE_DIR" ]; then
                initialize_memory_system
            fi
            list_tasks
            ;;
        "output")
            if [ $# -lt 2 ]; then
                echo -e "${RED}Error: Missing task ID${NC}"
                echo -e "Usage: $(basename "$0") output <task_id>"
                return 1
            fi
            show_task_output "$2"
            ;;
        "notifications")
            list_notifications
            ;;
        "worker")
            # Initialize memory system if needed
            if [ ! -d "$MEMORY_BASE_DIR" ]; then
                initialize_memory_system
            fi
            background_worker
            ;;
        "patch")
            patch_agent_commands
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
