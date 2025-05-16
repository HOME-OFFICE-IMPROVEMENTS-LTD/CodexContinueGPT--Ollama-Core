# CodexContinueGPT™ Ollama Integration Documentation

This document serves as the main index for all Ollama integration documentation and resources.

## Key Documentation

- [Ollama Integration Guide](docs/wiki/OLLAMA_INTEGRATION.md) - Main guide for using Ollama with DB-GPT
- [Ollama Shell Guidance](docs/ollama_shell_guidance.md) - How to use Ollama for shell commands
- [Model Context Protocol Guide](docs/wiki/MCP_OLLAMA.md) - Advanced API implementation
- [Aliases Documentation](docs/wiki/ALIASES_README.md) - Shell aliases for working with Ollama
- [Status Report](docs/wiki/OLLAMA_STATUS.md) - Current status of the integration
- [Complete Documentation Index](docs/wiki/Ollama-Index.md) - Index of all Ollama documentation

## Quick Start

1. Ensure Ollama is installed and running:
   ```bash
   # Check if installed
   which ollama
   
   # Start if needed
   ollama serve
   ```

2. Load the project aliases:
   ```bash
   source .aliases
   ```

3. Try some commands:
   ```bash
   # List available models
   om-list
   
   # Ask a shell question
   sh-help "How do I search for text in files?"
   
   # Start DB-GPT with Ollama
   om-start
   ```

## Directory Structure

- `/tools/ollama/` - Main scripts and implementation files
- `/configs/dbgpt-proxy-ollama.toml` - Ollama configuration for DB-GPT
- `/configs/dbgpt-proxy-ollama-mcp.toml` - MCP configuration
- `/docs/wiki/` - Documentation files
- `/docs/ollama_shell_guidance.md` - Detailed shell usage guide

## Testing

For testing the integration tomorrow, follow these steps:

1. Make sure Ollama is running: `ollama serve`
2. Verify models are available: `om-list`
3. Test basic queries: `ask "Hello, how are you?"`
4. Test shell guidance: `sh-help "How do I check disk usage?"`
5. Test MCP server: 
   ```bash
   mcp-start-codellama  # Terminal 1
   mcp-dbgpt            # Terminal 2
   ```

All components have been verified and are ready for comprehensive testing.
