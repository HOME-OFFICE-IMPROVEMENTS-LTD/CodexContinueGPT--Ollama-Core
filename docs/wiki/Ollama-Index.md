# CodexContinueGPT™ Ollama Integration Documentation

This index page provides links to all documentation related to the Ollama integration in CodexContinueGPT™.

## Getting Started

- [Ollama Integration Guide](OLLAMA_INTEGRATION.md) - Main guide for using Ollama with DB-GPT
- [Ollama Shell Guidance](../ollama_shell_guidance.md) - How to use Ollama for shell command assistance
- [Ollama Status Report](OLLAMA_STATUS.md) - Current status of the Ollama integration
- [Aliases Documentation](Aliases.md) - Shell aliases for working with Ollama

## Advanced Topics

- [Model Context Protocol (MCP) Implementation](MCP_OLLAMA.md) - Advanced API for standardized model interaction

## Setup Guides

- [Ollama Installation Guide](Ollama-Integration.md#repository-setup) - How to set up Ollama with DB-GPT

## Scripts Reference

All scripts referenced in the documentation can be found in the `/tools/ollama/` directory:

- `ollama_manager.sh` - Manage Ollama models for DB-GPT
- `shell_helper.sh` - Get help with shell commands using Ollama
- `ask.sh` - Direct interface to query Ollama models
- `mcp_ollama_server.py` - MCP server implementation
- `start_mcp_server.sh` - Script to start the MCP server
- `test_mcp_server.py` - Test script for the MCP server
- `download_docs.sh` - Download reference documentation
- `fix_paths.sh` - Fix hardcoded paths in scripts

## Configuration

The following configuration files are available:

- `configs/dbgpt-proxy-ollama.toml` - Basic Ollama configuration for DB-GPT
- `configs/dbgpt-proxy-ollama-mcp.toml` - MCP-based configuration for DB-GPT
