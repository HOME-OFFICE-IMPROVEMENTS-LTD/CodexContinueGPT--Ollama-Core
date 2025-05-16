# MCP Memory Agent Integration

This document describes the integration between the Enhanced MCP Server and the Agent Memory System for DB-GPT.

## Overview

The MCP Memory Agent combines the streaming capabilities of the Enhanced MCP Server with the persistent memory features of the Agent Memory System. This integration allows agents to:

1. Provide real-time streaming responses with token-by-token output
2. Maintain persistent memory between sessions
3. Leverage memory context for more relevant responses
4. Track ongoing tasks and their progress

## Prerequisites

1. DB-GPT installed and configured
2. Ollama installed and running (`ollama serve`)
3. Required models pulled (e.g., `ollama pull codellama`)
4. Agent Memory System initialized (`./agent-memory.sh initialize`)
5. Enhanced MCP Server set up

## Using the MCP Memory Agent

### Starting the MCP Memory Agent

```bash
# First, start the Enhanced MCP server
mcp-enhanced-codellama

# Then, in another terminal, start the MCP memory agent
./mcp-memory-agent.sh start
```

### Command Line Options

```bash
./mcp-memory-agent.sh [action] [options]

Actions:
  start       Start an interactive memory-enabled agent session
  ask         Ask a question with memory context
  remember    Store new information in memory
  recall      Retrieve information from memory
  summarize   Generate a summary of all stored memories
  list        List all memory entries
  search      Search through memories
  help        Show this help message

Options:
  --model MODEL       Model to use (default: codellama)
  --port PORT         Enhanced MCP server port (default: 8000)
  --host HOST         Enhanced MCP server host (default: localhost)
  --memory-id ID      Memory ID to use (default: default)
  --help              Show help message
```

### Interactive Mode Commands

When in interactive mode (after running `./mcp-memory-agent.sh start`), you can use the following special commands:

- `!exit` or `!quit` - Exit the agent
- `!clear` - Clear the terminal screen
- `!help` - Display help information
- `!remember [information]` - Store new information in memory
- `!recall [query]` - Recall information from memory
- `!summary` - Generate a summary of memories
- `!list` - List all memory entries
- `!search [term]` - Search through memories
- `!model [model name]` - Switch to a different model

## Memory Management

### How Memory is Stored

The MCP Memory Agent stores information in the same memory system used by the standard agent memory system. Data is organized as follows:

- Memory files are stored in `~/.dbgpt_agents/[memory_id]/`
- Each memory has metadata including timestamp, source, and tags
- Long-term and short-term memories are managed separately
- Memory is automatically summarized to prevent excessive growth

### Memory Commands

```bash
# Store a new memory
./mcp-memory-agent.sh remember "The Enhanced MCP server has streaming capabilities"

# Retrieve information based on a query
./mcp-memory-agent.sh recall "What capabilities does the MCP server have?"

# Generate a summary of all memories
./mcp-memory-agent.sh summarize

# List all memory entries
./mcp-memory-agent.sh list

# Search for specific memories
./mcp-memory-agent.sh search "streaming"
```

## Integration with Enhanced MCP Server

The MCP Memory Agent leverages the Enhanced MCP Server's capabilities in the following ways:

1. **Streaming Responses**: All interactions use the streaming API for real-time output
2. **Health Checking**: The agent verifies the MCP server health before operations
3. **Efficient Context Management**: The agent optimizes context window usage
4. **Error Handling**: Improved handling of connection and model errors

## Example Use Cases

### Software Development Assistant

```bash
# Start the agent
./mcp-memory-agent.sh start

# Tell it about your project
> I'm working on a Python project that uses FastAPI and SQLAlchemy

# Later, ask about related technologies
> What ORM am I using in my project?
```

### System Administration Helper

```bash
# Record information about your system
./mcp-memory-agent.sh remember "Our production servers use Nginx 1.18 with custom SSL configuration"

# Later, ask about your setup
./mcp-memory-agent.sh ask "How is our SSL configured?"
```

### Research Assistant

```bash
# Start interactive session
./mcp-memory-agent.sh start

# Record your research findings
> !remember The study by Smith et al. (2024) found that model streaming reduces perceived latency by 30%

# Later, ask for a summary
> Can you summarize the key findings from the research I've recorded?
```

## Troubleshooting

### Common Issues

1. **Connection Errors**:
   - Verify the Enhanced MCP server is running
   - Check host and port settings

2. **Memory Access Issues**:
   - Ensure the agent memory system is initialized
   - Check permissions on the memory directory

3. **Model Response Issues**:
   - Try switching to a different model
   - Verify Ollama is running correctly

### Viewing Logs

Debug logs are available in the following location:
```bash
cat ~/.dbgpt_agents/logs/mcp_memory_agent.log
```

## Next Steps and Future Improvements

- Multi-agent memory sharing and collaboration
- Integration with external knowledge bases
- Advanced memory indexing for faster retrieval
- Custom memory templates for different domains
- UI-based memory visualization and management
