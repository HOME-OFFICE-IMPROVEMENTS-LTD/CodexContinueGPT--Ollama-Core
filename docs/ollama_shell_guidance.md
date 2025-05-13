# Using Ollama with DB-GPT for Shell Guidance

This guide explains how to effectively use Ollama models with DB-GPT for shell command guidance and other tasks.

## Configuration Setup

Your DB-GPT is already configured to use Ollama models through the proxy configuration file at:
```
/home/msalsouri/Projects/DB-GPT/configs/dbgpt-proxy-ollama.toml
```

The current configuration uses:
- LLM model: `codellama` (excellent for coding and shell commands)
- Embedding model: `bge-m3:latest`
- API connection: `http://localhost:11434`

## Starting DB-GPT with Ollama Integration

### Method 1: Direct Command

To start DB-GPT with the Ollama configuration:

```bash
cd /home/msalsouri/Projects/DB-GPT
uv run dbgpt start webserver --config configs/dbgpt-proxy-ollama.toml
```

Once started, you can access the DB-GPT web interface at: `http://localhost:5670`

### Method 2: Docker-Compose Deployment

You can also run DB-GPT using Docker-Compose:

```bash
# This example requires you provide a valid API key for the SiliconFlow API
# You can obtain one by signing up at SiliconFlow and creating an API key
SILICONFLOW_API_KEY=your_siliconflow_api_key docker compose up -d
```

You will see the following output if the deployment is successful:
```
[+] Running 3/3
 ✔ Network dbgptnet              Created                                            0.0s 
 ✔ Container db-gpt-db-1         Started                                            0.2s 
 ✔ Container db-gpt-webserver-1  Started                                            0.2s 
```

To view logs:
```bash
docker logs db-gpt-webserver-1 -f
```

For more configuration details, you can examine the `docker-compose.yml` file.

Once deployed, open your browser and visit `http://localhost:5670` to access the DB-GPT web interface.

## Available Ollama Models

You currently have these models installed:
- `codellama:latest` - Optimized for coding tasks and shell commands
- `llama3:latest` - General-purpose model with broad capabilities

## Switching Between Models

To switch between different Ollama models:

1. **Edit the configuration file**:
   ```bash
   nano /home/msalsouri/Projects/DB-GPT/configs/dbgpt-proxy-ollama.toml
   ```

2. **Modify the model name**:
   ```toml
   [[models.llms]]
   name = "codellama"  # Change to any available model like "llama3"
   provider = "proxy/ollama"
   api_base = "http://localhost:11434"
   api_key = ""
   ```

3. **Restart DB-GPT** for changes to take effect.

## Using the Shell Helper Script

We've created a dedicated shell helper script that leverages Ollama with CodeLlama for shell command guidance:

```bash
./shell_helper.sh "your shell question or command here"
```

### Examples:

1. **Ask about a shell task**:
   ```bash
   ./shell_helper.sh "How do I find and delete files older than 30 days?"
   ```

2. **Explain a complex command**:
   ```bash
   ./shell_helper.sh --explain "find /var/log -type f -mtime +30 -name \"*.log\" -exec rm {} \;"
   ```

3. **Generate a shell script**:
   ```bash
   ./shell_helper.sh --script "monitor system resources and send an email alert when CPU usage exceeds 90%"
   ```

## Integration Methods with DB-GPT

There are three ways to use Ollama for shell guidance with DB-GPT:

### 1. Direct Web Interface

Use the DB-GPT chat interface to ask shell-related questions directly:
- "Write a bash script to monitor disk usage"
- "How do I recursively change file permissions in Linux?"
- "Generate a command to find all large files in my home directory"

### 2. Shell Helper Script (Command Line)

Use the provided `shell_helper.sh` script for quick command-line access:
```bash
./shell_helper.sh "your shell question or command here"
```

### 3. Custom App Integration

You can create a custom DB-GPT app focused specifically on shell operations by:

1. Start DB-GPT with the Ollama configuration
2. Create a new app in the web interface with a system prompt like:
   ```
   You are an expert shell command assistant. Your primary role is to help users with Linux/Unix shell commands, 
   Bash scripting, and system administration tasks. Always provide clear explanations and examples for any commands 
   you suggest. When appropriate, include proper error handling in scripts.
   ```
3. Save this as a new app called "Shell Command Expert"

## Getting Additional Ollama Models

If you want to try other Ollama models:

```bash
# List available models
ollama list

# Pull a new model
ollama pull [model-name]

# Examples:
ollama pull llama3:70b
ollama pull mistral
ollama pull phi3
```

## Advanced Shell Guidance Examples

Here are some advanced examples of how to use DB-GPT with Ollama for shell tasks:

### System Monitoring Dashboard

```bash
./shell_helper.sh --script "create a simple shell dashboard that shows CPU, memory, disk and network usage in real-time"
```

### Database Backup Automation

```bash
./shell_helper.sh --script "create a script to back up all MySQL databases, compress them, and upload to S3 bucket"
```

### Log Analysis

```bash
./shell_helper.sh "How can I extract all ERROR and WARNING messages from multiple log files and sort them by timestamp?"
```

### Docker Management

```bash
./shell_helper.sh --script "create a script that monitors Docker container health and restarts any failed containers"
```

### Container Image Analysis

```bash
./shell_helper.sh --script "write a script that analyzes all Docker images, sorting them by size and showing their creation date"
```

### Network Diagnostics

```bash
./shell_helper.sh --script "create a comprehensive network diagnostics tool that checks connectivity, DNS resolution, and identifies network bottlenecks"
```

### Security Auditing

```bash
./shell_helper.sh --script "create a security audit script that checks for common system vulnerabilities, open ports, and weak file permissions"
```

### Automated Database Deployment

```bash
./shell_helper.sh --script "create a script that automatically sets up a PostgreSQL database with proper user permissions and initializes schema from SQL files"
```

## Troubleshooting

If you encounter issues:

1. Verify Ollama is running:
   ```bash
   curl http://localhost:11434/api/version
   ```

2. Check model availability:
   ```bash
   ollama list
   ```

3. Reset Ollama if needed:
   ```bash
   systemctl restart ollama
   # or if installed manually
   ollama serve
   ```

4. Check DB-GPT logs for connection errors to Ollama.

## Additional Resources

- Ollama Documentation: https://ollama.com/docs
- DB-GPT Documentation: http://docs.dbgpt.cn/docs/
- CodeLlama Model Card: https://ollama.com/library/codellama
