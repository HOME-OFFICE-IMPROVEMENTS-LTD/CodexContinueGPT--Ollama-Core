# filepath: /home/msalsouri/Projects/DB-GPT/docker/cc-ollama/test-codexcontinue-gpt.sh
#!/bin/bash
# Test script for CodexContinue-GPT

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN}   Testing CodexContinue-GPT Functionality   ${NC}"
echo -e "${CYAN}=============================================${NC}"
echo ""

# Create a test file
echo -e "${BLUE}Creating a test file for code audit...${NC}"
TEST_FILE="/tmp/test-codexcontinue-file.py"
cat > "$TEST_FILE" << 'EOF'
import os
import subprocess
import sys

# Example Python script with some issues for testing

# Global variables
USER_DATA = "/tmp/userdata.txt"
LOG_FILE = "/var/log/app.log"

# Function with security issues
def process_data(data):
    # Write data to file without checking permissions
    with open(USER_DATA, 'w') as f:
        f.write(data)
    
    # Use exec without proper validation (security risk)
    exec(data)
    
    # Log the operation
    os.system(f"echo 'Processed data: {data}' >> {LOG_FILE}")

# Main script
print("Starting data processing...")

# No input validation
if len(sys.argv) > 1:
    process_data(sys.argv[1])
else:
    process_data("default value")

print("Processing complete")
EOF

chmod +x "$TEST_FILE"

echo -e "${GREEN}Test file created: $TEST_FILE${NC}"
echo ""

# Test different ways to run the CodexContinue-GPT
echo -e "${MAGENTA}=== Testing with direct script ===${NC}"
./direct-shell-agent.sh --audit "$TEST_FILE" --auto

echo -e "${MAGENTA}=== Testing with ccgpt command ===${NC}"
./ccgpt --audit "$TEST_FILE" --auto

echo -e "${GREEN}Testing completed!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Install CodexContinue-GPT in the container:"
echo "   ./install-codexcontinue-gpt.sh"
echo ""
echo "2. Connect to the container and try it:"
echo "   docker exec -it dbgpt-shell-agent bash"
echo "   cc --auto"
