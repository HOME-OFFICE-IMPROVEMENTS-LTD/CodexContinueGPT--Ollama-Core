# Enhanced Model Context Protocol (MCP) Server for Ollama Integration

This document describes the enhanced MCP server implementation for Ollama integration with DB-GPT. This version includes streaming support, better error handling, and additional endpoints.

## What's New in the Enhanced MCP Server

The enhanced version provides several improvements over the standard MCP server:

1. **Streaming Support**: Real-time streaming responses for both `/completions` and `/chat/completions` endpoints
2. **Improved Error Handling**: Better error messages and handling of edge cases
3. **Health Check Endpoints**: Monitor server and Ollama connection status
4. **System Information**: View available models and configuration
5. **CORS Support**: Cross-Origin Resource Sharing for web application integration
6. **Configurable Timeouts**: Set custom timeout values for long-running requests

## Prerequisites

1. DB-GPT installed and configured
2. Ollama installed and running (`ollama serve`)
3. Required models pulled (e.g., `ollama pull codellama`)
4. Python packages: `fastapi`, `uvicorn`, `requests`

## Usage

### Using Aliases (Recommended)

If you've sourced the project's `.aliases` file:

1. **Start the Enhanced MCP Ollama server**:
   ```bash
   mcp-enhanced-codellama
   ```
   
2. **In a new terminal, start DB-GPT with the MCP configuration**:
   ```bash
   mcp-dbgpt
   ```

3. **Test the enhanced server**:
   ```bash
   mcp-test
   ```

### Manual Method

1. **Start the Enhanced MCP Ollama server**:
   ```bash
   cd /path/to/DB-GPT
   ./tools/ollama/start_enhanced_mcp_server.sh --model codellama --port 8000
   ```

2. **Start DB-GPT with the MCP configuration**:
   ```bash
   cd /path/to/DB-GPT
   uv run dbgpt start webserver --config configs/dbgpt-proxy-ollama-mcp.toml
   ```

3. **Access the DB-GPT web interface**:
   Open your browser and navigate to `http://localhost:5670`

## API Endpoints

The enhanced MCP server provides the following API endpoints:

### Standard OpenAI-Compatible Endpoints

- `GET /v1/models` - List available models
- `POST /v1/completions` - Create a completion
- `POST /v1/chat/completions` - Create a chat completion
- `POST /v1/embeddings` - Create embeddings

### New Endpoints

- `GET /v1/health` - Health check endpoint
- `GET /v1/system` - System information endpoint

## Streaming Support

The enhanced server supports streaming responses for both completions and chat completions. To use streaming:

```python
import requests

# For completions
response = requests.post(
    "http://localhost:8000/v1/completions",
    json={
        "model": "codellama",
        "prompt": "Write a Python function to calculate factorial",
        "stream": True,
    },
    stream=True
)

for line in response.iter_lines():
    if not line:
        continue
    line_text = line.decode('utf-8')
    if line_text == "data: [DONE]":
        break
    # Process the streaming data
    print(line_text)

# For chat completions
response = requests.post(
    "http://localhost:8000/v1/chat/completions",
    json={
        "model": "codellama",
        "messages": [{"role": "user", "content": "Hello, how are you?"}],
        "stream": True,
    },
    stream=True
)

for line in response.iter_lines():
    # Same processing as above
```

## Advanced Configuration

The start script for the enhanced MCP server supports several configuration options:

```bash
./tools/ollama/start_enhanced_mcp_server.sh --help
```

Available options:

- `--port PORT` - Set the server port (default: 8000)
- `--model MODEL` - Set the default Ollama model (default: codellama)
- `--host HOST` - Set the server host (default: 0.0.0.0)
- `--ollama-api URL` - Set the Ollama API base URL (default: http://localhost:11434)
- `--timeout SECONDS` - Set request timeout in seconds (default: 60)
- `--standard` - Use standard MCP server instead of enhanced version
- `--help` - Show help message

## Troubleshooting

### Common Issues

1. **Connection Issues**:
   - Ensure Ollama is running (`ollama serve`)
   - Check the OLLAMA_API_BASE URL is correct
   - Verify network connectivity between DB-GPT and Ollama

2. **Model Issues**:
   - Make sure the model is pulled (`ollama pull codellama`)
   - Check model name spelling in config files
   - Try different models if one is having issues

3. **Performance Issues**:
   - For large requests, increase timeout settings
   - Consider using a more powerful machine for running Ollama
   - Reduce max_tokens if responses take too long

### Checking Server Status

Use the health check endpoint to verify the server and Ollama connection:

```bash
curl http://localhost:8000/v1/health
```

Sample response:

```json
{
  "status": "healthy",
  "ollama_version": "0.1.14",
  "response_time": "0.056s",
  "api_base": "http://localhost:11434",
  "server_time": "2025-05-16 10:30:45"
}
```

## Next Steps and Future Improvements

- Add support for function calling capabilities
- Implement token counting for better token usage reporting
- Add authentication for multi-user setups
- Create a web-based admin interface for server management
- Support for custom system prompts in chat completions
