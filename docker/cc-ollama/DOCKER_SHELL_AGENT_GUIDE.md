# DB-GPT Shell Agent Docker Guide

This guide explains how to use the DB-GPT Shell Agent Docker container.

## Building the Docker Container

From the project root directory, run:

```bash
cd docker/cc-ollama
docker-compose -f docker-compose.shell-agent.yml build
```

## Running the Container

```bash
cd docker/cc-ollama
docker-compose -f docker-compose.shell-agent.yml up -d
```

## Accessing the Container

```bash
docker exec -it dbgpt-shell-agent bash
```

## Using the Shell Agent

Once inside the container, you can use the following commands:

1. **Running the Shell Agent in Chat Mode:**
   ```bash
   run-shell-agent
   ```
   or
   ```bash
   docker-run-shell-agent
   ```

2. **Auditing Code Files:**
   ```bash
   run-shell-agent --audit /app/project/tools/ollama/mcp_ollama_server.py
   ```

3. **Managing Tasks:**
   ```bash
   run-shell-agent --tasks
   ```

4. **Viewing Command History:**
   ```bash
   run-shell-agent --history
   ```

5. **Building/Rebuilding the Agent Model:**
   ```bash
   build-shell-agent
   ```

## Troubleshooting

If you encounter any issues:

1. **Model Not Found:**
   If you see an error message saying the model is not found, run the build command:
   ```bash
   build-shell-agent
   ```

2. **Ollama Service Not Running:**
   The service should start automatically. If it doesn't, you can start it manually:
   ```bash
   ollama serve &
   ```

3. **Check Available Models:**
   ```bash
   ollama list
   ```

4. **Container Logs:**
   From the host machine:
   ```bash
   docker logs dbgpt-shell-agent
   ```

## Project Structure in Container

- `/app/agent/` - Contains all the agent scripts and Modelfiles
- `/app/project/` - Mount point for the DB-GPT project for code auditing
- `/root/.ollama/` - Persistent storage for Ollama models
