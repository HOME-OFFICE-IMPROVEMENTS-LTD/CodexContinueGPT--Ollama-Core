# CodexContinueGPT™ Ollama Integration Tools

This directory contains scripts and tools for the Ollama integration with DB-GPT.

## Shell Scripts

| Script | Description |
| ------ | ----------- |
| `ask.sh` | Direct interface for querying Ollama models with advanced options |
| `download_docs.sh` | Downloads reference documentation for offline use |
| `fix_paths.sh` | Utility to fix hardcoded paths in scripts |
| `ollama_manager.sh` | Main script for managing Ollama models and DB-GPT integration |
| `shell_helper.sh` | Tool for getting shell command help using Ollama models |
| `start_mcp_server.sh` | Starts the Model Context Protocol server |
| `test_mcp_server.py` | Test script for verifying MCP server functionality |

## MCP Implementation

The `mcp_ollama_server.py` file implements a Model Context Protocol (MCP) server that translates between OpenAI-compatible API and Ollama API, providing a standardized way to interact with Ollama models.

## Usage

All scripts in this directory can be run directly or through the provided aliases (see `.aliases` file in the project root).

Example:

```bash
# Direct usage
./ollama_manager.sh list

# Via alias (after sourcing .aliases)
om-list
```

## Documentation

For comprehensive documentation, see the wiki directory:

- `/docs/wiki/OLLAMA_INTEGRATION.md` - Main integration guide
- `/docs/wiki/MCP_OLLAMA.md` - MCP implementation details
- `/docs/wiki/Ollama-Index.md` - Documentation index
