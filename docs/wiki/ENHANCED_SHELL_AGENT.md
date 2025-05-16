# Enhanced Shell Agent for DB-GPT

This document describes the enhanced shell agent implementation for DB-GPT. This version leverages the improved Enhanced MCP server with streaming capabilities for a more responsive experience.

## What's New in the Enhanced Shell Agent

The enhanced version provides several improvements over the standard shell agent:

1. **Real-time Streaming**: Immediate token-by-token responses for a more interactive experience
2. **Memory Integration**: Proper integration with agent memory system for persistent knowledge
3. **Improved UI/UX**: Better formatting and clearer terminal output
4. **Advanced Mode Selection**: More flexible operation modes (shell, code, creative)
5. **Task Management**: Built-in task tracking and management
6. **Better Error Handling**: Improved resilience to connection issues and other errors

## Prerequisites

1. DB-GPT installed and configured
2. Ollama installed and running (`ollama serve`)
3. Enhanced MCP server configured and available
4. Required models pulled (e.g., `ollama pull codellama`)

## Usage

### Quick Start

```bash
# Start the enhanced MCP server
mcp-enhanced-codellama

# Then in a new terminal, launch the enhanced shell agent
./enhanced-shell-agent.sh
```

### Command Line Options

The enhanced shell agent supports several command-line options:

```bash
./enhanced-shell-agent.sh [options]

Options:
  --model MODEL       Model to use (default: codellama)
  --port PORT         Enhanced MCP server port (default: 8000)
  --host HOST         Enhanced MCP server host (default: localhost)
  --mode MODE         Operation mode: shell, code, or creative (default: shell)
  --task "task text"  Specific task for the agent to accomplish
  --help              Show this help message
```

### Operation Modes

The enhanced shell agent supports different operation modes to optimize its behavior for specific tasks:

1. **Shell Mode** (`--mode shell`): Optimized for shell commands and operations
2. **Code Mode** (`--mode code`): Optimized for programming tasks
3. **Creative Mode** (`--mode creative`): Optimized for creative writing and brainstorming

### Memory Integration

The enhanced shell agent integrates with the agent memory system to maintain context and knowledge between sessions. To use this feature, you can:

1. Use the integrated memory commands:
   - `!remember [information]` - Store new information in memory
   - `!recall [query]` - Retrieve relevant information from memory
   - `!summary` - Generate a summary of all stored memories

2. Or use the dedicated memory agent:
   ```bash
   ./mcp-memory-agent.sh start
   ```

## Features and Commands

### Interactive Shell

Once the enhanced shell agent is running, you'll see a prompt where you can enter commands or questions:

```
Enhanced Shell Agent v1.1.0
Using model: codellama via Enhanced MCP server

> 
```

### Special Commands

The agent supports special commands in interactive mode:

- `!exit` or `!quit` - Exit the shell agent
- `!clear` - Clear the terminal screen
- `!help` - Display help information
- `!mode [shell|code|creative]` - Change the operation mode
- `!remember [information]` - Store information in agent memory
- `!recall [query]` - Recall information from agent memory
- `!task [description]` - Set a new task for the agent
- `!tasks` - List current tasks
- `!complete [task number]` - Mark a task as completed
- `!history` - Show command history
- `!save [filename]` - Save the current session to a file
- `!model [model name]` - Switch to a different model

## Integration with Enhanced MCP Server

The enhanced shell agent is designed to work seamlessly with the enhanced MCP server. Before using the agent, make sure the enhanced MCP server is running:

```bash
# Start the enhanced MCP server
mcp-enhanced-codellama

# Verify server is running
curl http://localhost:8000/v1/health
```

## Troubleshooting

### Common Issues

1. **Connection Errors**:
   - Ensure the enhanced MCP server is running
   - Check the host and port settings match

2. **Slow or Incomplete Responses**:
   - Try switching to a different model
   - Check system resources (CPU/memory usage)
   - Verify Ollama is running properly

3. **Memory Integration Issues**:
   - Ensure agent memory system is properly initialized
   - Check for proper permissions on memory files

### Logs and Debugging

The enhanced shell agent maintains logs that can help diagnose issues:

```bash
cat $PROJECT_ROOT/.shell_agent_logs_enhanced
```

## Performance Tips

1. Use smaller, faster models for simple shell tasks
2. For complex coding tasks, use specialized code models
3. Set appropriate timeouts based on your system capabilities
4. Use task-specific modes for optimized performance
5. Leverage the memory system for context-aware responses

## Next Steps and Future Improvements

- Voice command integration for hands-free operation
- Customizable agent personas with specialized knowledge
- Cross-session task management and planning
- Multi-agent collaboration capabilities
- Support for specialized domain knowledge and tools