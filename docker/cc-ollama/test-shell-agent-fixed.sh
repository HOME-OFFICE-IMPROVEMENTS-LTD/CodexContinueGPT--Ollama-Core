# filepath: /home/msalsouri/Projects/DB-GPT/docker/cc-ollama/test-shell-agent-fixed.sh
#!/bin/bash
# Test script for shell agent advanced functionality
# This runs a basic audit and task management test

# Create a simple test file
echo '#!/bin/bash
# Test file
echo "Hello World"
# TODO: Add error handling
exit 0' > /tmp/test-file.sh

# Make it executable
chmod +x /tmp/test-file.sh

# Run a simple audit
echo -e "\n\033[1;36m=== Testing Code Audit Functionality ===\033[0m"
/app/agent/docker-run-shell-agent-fixed.sh --audit /tmp/test-file.sh

# Run task management
echo -e "\n\033[1;36m=== Testing Task Management Functionality ===\033[0m"
/app/agent/docker-run-shell-agent-fixed.sh --tasks

echo -e "\n\033[1;32mTest completed!\033[0m"
