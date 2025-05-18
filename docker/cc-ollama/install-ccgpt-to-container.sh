# filepath: /home/msalsouri/Projects/DB-GPT/docker/cc-ollama/install-ccgpt-to-container.sh
#!/bin/bash
# Simple script to install CCGpt command in the Docker container

# Copy the ccgpt.sh file to the container
docker cp /home/msalsouri/Projects/DB-GPT/docker/cc-ollama/ccgpt.sh dbgpt-shell-agent:/app/agent/ccgpt.sh
docker cp /home/msalsouri/Projects/DB-GPT/docker/cc-ollama/cc dbgpt-shell-agent:/app/agent/cc_command

# Make the scripts executable in the container
docker exec -it dbgpt-shell-agent bash -c "chmod +x /app/agent/ccgpt.sh /app/agent/cc_command"

# Add ccgpt to the container's aliases
docker exec -it dbgpt-shell-agent bash -c "echo 'alias cc=\"/app/agent/cc_command\"' >> /app/agent/.aliases"
docker exec -it dbgpt-shell-agent bash -c "echo 'alias ccgpt=\"/app/agent/ccgpt.sh\"' >> /app/agent/.aliases"

echo "✅ CCGpt commands installed in the container."
echo "Please restart your shell session in the container with:"
echo "docker exec -it dbgpt-shell-agent bash"
echo "Then you can use 'ccgpt' or 'cc' to run CCGpt."
