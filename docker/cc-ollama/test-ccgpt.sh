# filepath: /home/msalsouri/Projects/DB-GPT/docker/cc-ollama/test-ccgpt.sh
#!/bin/bash
# Test script for CodexContinueGPT (CCGpt)

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN}   Testing CodexContinueGPT Functionality    ${NC}"
echo -e "${CYAN}=============================================${NC}"
echo ""

# Create a test file
echo -e "${BLUE}Creating a test file for code audit...${NC}"
TEST_FILE="/tmp/test-ccgpt-file.sh"
cat > "$TEST_FILE" << 'EOF'
#!/bin/bash
# Example script with some issues for testing

# Global variables
USER_DATA="/tmp/userdata.txt"
LOG_FILE="/var/log/app.log"

# Function to process user data
process_data() {
    local data=$1
    
    # Write data to file without checking permissions
    echo $data > $USER_DATA
    
    # Use eval without proper validation
    eval "echo $data"
    
    # Log the operation
    echo "$(date): Processed data: $data" >> $LOG_FILE
}

# Main script
echo "Starting data processing..."

# No input validation
if [ -n "$1" ]; then
    process_data "$1"
else
    process_data "default value"
fi

echo "Processing complete"
EOF

chmod +x "$TEST_FILE"

echo -e "${GREEN}Test file created: $TEST_FILE${NC}"
echo ""

# Test both methods of invocation
echo -e "${MAGENTA}=== Testing Code Audit Functionality with ccgpt.sh ===${NC}"
./ccgpt.sh --audit "$TEST_FILE"
echo ""

echo -e "${MAGENTA}=== Testing Code Audit Functionality with cc command ===${NC}"
./cc --audit "$TEST_FILE"
echo ""

# Test task management
echo -e "${MAGENTA}=== Testing Task Management Functionality ===${NC}"
# Create a temporary task file for testing
TEMP_TASK_FILE="/app/agent/.ccgpt_tasks"
if [ ! -f "$TEMP_TASK_FILE" ]; then
    echo "Current tasks:" > "$TEMP_TASK_FILE"
    echo "- Test CodexContinueGPT" >> "$TEMP_TASK_FILE"
    echo "" >> "$TEMP_TASK_FILE"
    echo "Completed tasks:" >> "$TEMP_TASK_FILE"
    echo "" >> "$TEMP_TASK_FILE"
    echo "Next steps:" >> "$TEMP_TASK_FILE"
    echo "- Evaluate CCGpt performance" >> "$TEMP_TASK_FILE"
fi

# Run task management in non-interactive mode for testing
echo "n" | ./cc --tasks

# Test auto-selection feature
echo -e "${MAGENTA}=== Testing Auto-Model Selection ===${NC}"
echo "What is a good approach to debugging Python code?" | ./cc --auto

echo -e "${GREEN}Test completed!${NC}"
