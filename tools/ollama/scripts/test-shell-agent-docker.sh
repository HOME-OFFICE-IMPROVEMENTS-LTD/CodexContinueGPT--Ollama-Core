#!/bin/bash
# Test building and running the shell agent Docker container

# Set script to exit on error
set -e

echo "=== Testing DB-GPT Shell Agent Docker Setup ==="
echo

# Change to the docker directory
cd "$(dirname "$0")"/docker/cc-ollama

# Build the Docker image
echo "Building shell agent Docker image..."
docker-compose -f docker-compose.shell-agent.yml build

# Check build success
if [ $? -eq 0 ]; then
    echo "✅ Docker image build successful!"
else
    echo "❌ Docker image build failed!"
    exit 1
fi

echo
echo "=== Image Build Test Successful ==="
echo 
echo "To run the shell agent container, use:"
echo "cd docker/cc-ollama && docker-compose -f docker-compose.shell-agent.yml up -d"
echo
echo "To access the shell agent container, use:"
echo "docker exec -it dbgpt-shell-agent bash"
echo
echo "Once inside the container, you can run the shell agent with:"
echo "run-shell-agent"
echo
echo "For more detailed instructions, see:"
echo "./docker/cc-ollama/DOCKER_SHELL_AGENT_GUIDE.md"

exit 0
