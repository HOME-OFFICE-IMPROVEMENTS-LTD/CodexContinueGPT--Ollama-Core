# CodexContinueGPT™ Ollama Integration Documentation

This index page provides links to all documentation related to the Ollama integration in CodexContinueGPT™.

## Getting Started

- [Ollama Integration Guide](OLLAMA_INTEGRATION.md) - Main guide for using Ollama with DB-GPT
- [Ollama Shell Guidance](../ollama_shell_guidance.md) - How to use Ollama for shell command assistance
- [Ollama Status Report](OLLAMA_STATUS.md) - Current status of the Ollama integration
- [Aliases Documentation](ALIASES_README.md) - Shell aliases for working with Ollama

## Advanced Topics

- [Model Context Protocol (MCP) Implementation](MCP_OLLAMA.md) - Advanced API for standardized model interaction
- [Enhanced MCP Server](ENHANCED_MCP_OLLAMA.md) - Improved MCP server with streaming support
- [Enhanced Shell Agent](ENHANCED_SHELL_AGENT.md) - Shell agent with streaming capabilities
- [MCP Memory Agent Integration](MCP_MEMORY_AGENT.md) - MCP integration with agent memory system
- [Model Benchmarking Tool](BENCHMARK_TOOL.md) - Performance comparison of different models
- [Shell Training System](SHELL_TRAINING.md) - Interactive shell command training with AI assistance
- [Agent Memory Integration](AGENT_MEMORY_GUIDE.md) - Working with the agent memory system

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
- `mcp_ollama_server_enhanced.py` - Enhanced MCP server with streaming
- `start_enhanced_mcp_server.sh` - Script to start the enhanced MCP server
- `test_enhanced_mcp_server.py` - Test script for the enhanced server
- `benchmark_mcp_models.py` - Model benchmarking tool
- `benchmark_mcp_server.sh` - Script to run model benchmarks
- `mcp_memory_agent.sh` - MCP integration with agent memory
- `enhanced_shell_agent.sh` - Enhanced shell agent with streaming
- `shell-training.sh` - Interactive shell command training system
- `launch-shell-training.sh` - Launcher script for shell training
- `download_docs.sh` - Download reference documentation
- `fix_paths.sh` - Fix hardcoded paths in scripts

## Configuration

The following configuration files are available:

- `configs/dbgpt-proxy-ollama.toml` - Basic Ollama configuration for DB-GPT
- `configs/dbgpt-proxy-ollama-mcp.toml` - MCP-based configuration for DB-GPT
