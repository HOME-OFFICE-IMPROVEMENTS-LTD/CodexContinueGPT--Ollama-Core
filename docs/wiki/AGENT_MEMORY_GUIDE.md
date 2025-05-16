# DB-GPT Agent Memory & Co-working System

This guide explains how to use the DB-GPT Agent Memory System, which adds two powerful capabilities to your existing Ollama agents:

1. **Memory Persistence** - Agents now remember information between sessions
2. **Co-working Capability** - Agents can work on tasks while you're away

## Quick Setup

```bash
# Initialize the memory system
./agent-memory.sh initialize

# Patch the agent-commands.sh file to integrate memory capabilities
./agent-memory.sh patch

# Source the aliases file to get convenient shortcuts
source .aliases
```

## Memory Persistence

Your agents now maintain memory between sessions. This means:

- Conversations are saved to `~/.dbgpt_agents/[agent_type]/`
- Key facts are automatically extracted and stored
- Older conversations are summarized to maintain a compact memory
- When you start a new conversation, the agent recalls relevant information

The memory system works automatically in the background once set up. No additional actions are required to benefit from it.

## Enhanced MCP Server Integration

The agent memory system now fully integrates with the Enhanced MCP Server, which adds streaming capabilities and improved performance.

### Using Memory with Enhanced MCP

```bash
# Start the enhanced MCP server
mcp-enhanced-codellama

# Start the memory-integrated agent with the enhanced MCP server
./mcp-memory-agent.sh start
```

### Commands for Memory Management

The memory-integrated agent provides a rich set of commands:

```bash
# Store information in memory
./mcp-memory-agent.sh remember "The Enhanced MCP server supports streaming responses"

# Ask a question with context from memory
./mcp-memory-agent.sh ask "What features does the Enhanced MCP server have?"

# Generate a summary of all memories
./mcp-memory-agent.sh summarize

# List all memory entries
./mcp-memory-agent.sh list

# Search memories for a keyword
./mcp-memory-agent.sh search "MCP"

# Start an interactive session
./mcp-memory-agent.sh start
```

### Benefits of Enhanced MCP Integration

1. **Streaming Responses** - Get token-by-token real-time responses
2. **Better Context Handling** - More efficient use of context window
3. **Health Monitoring** - Integrated health checks for the MCP server
4. **Improved Error Handling** - More resilient to connection issues
5. **Performance Metrics** - Better insights into model performance

## Co-working Capability

You can now submit tasks to be processed while you're away, allowing your agents to work asynchronously.

### Submitting Tasks

```bash
# Submit a coding task
code-cowork "Create a Python function that downloads files from S3"

# Submit a shell script task
shell-cowork "Write a script to find and delete duplicate files"

# Submit a code audit task
audit-cowork /path/to/file.py "Check for security vulnerabilities"

# Submit a git operation task
git-cowork "Create a strategy for organizing feature branches"

# Submit a decision review task
decision-cowork "Evaluate whether to use SQLite or PostgreSQL for this project"
```

### Managing Tasks

```bash
# List all pending and running tasks
agent-tasks

# View the output of a completed task
agent-output task_20250516123045

# See notifications about completed tasks
agent-notifications
```

## How It Works

### Memory System

1. **Conversation Storage**: Each conversation is saved as a JSON file
2. **Fact Extraction**: Key information is extracted using AI
3. **Memory Summarization**: Older conversations are summarized
4. **Context Enhancement**: When you start a new conversation, relevant memories are added to the agent's context

### Co-working System

1. **Task Queue**: Tasks are stored in `~/.dbgpt_agents/tasks/`
2. **Background Worker**: A worker process runs in the background to process tasks
3. **Notification System**: Completed tasks generate notifications
4. **Output Storage**: Results are stored and can be viewed later

## Directory Structure

```
~/.dbgpt_agents/
├── code/                    # Code assistant agent memory
├── shell/                   # Shell helper agent memory
├── tasks/                   # Task manager agent memory
├── audit/                   # Code auditor agent memory
├── git/                     # Git helper agent memory
├── decision/                # Decision auditor agent memory
├── tasks/                   # Task queue
│   ├── pending/             # Pending tasks
│   ├── running/             # Currently running tasks
│   ├── completed/           # Completed tasks
│   └── failed/              # Failed tasks
├── memory_index.json        # Index of all memories
├── notifications_*.txt      # Daily notification logs
└── worker.log               # Background worker log
```

## Available Commands

| Command | Description |
|---------|-------------|
| `agent-memory initialize` | Set up memory system |
| `agent-memory save <agent> <file>` | Save conversation to memory |
| `agent-memory facts <agent> <file>` | Extract facts from conversation |
| `agent-memory submit <agent> "task"` | Submit a background task |
| `agent-memory tasks` | List pending and running tasks |
| `agent-memory output <task_id>` | Show output of completed task |
| `agent-memory notifications` | Show task completion notifications |
| `agent-memory patch` | Patch agent-commands.sh with memory support |

## Aliases

For convenience, the following aliases are provided:

| Alias | Description |
|-------|-------------|
| `agent-memory` | Access the memory system |
| `agent-submit` | Submit a background task |
| `agent-tasks` | List pending and running tasks |
| `agent-output` | Show output of completed task |
| `agent-notifications` | Show task completion notifications |
| `agent-init` | Initialize memory system |
| `agent-patch` | Patch agent-commands.sh with memory |
| `code-cowork` | Submit task to code assistant |
| `shell-cowork` | Submit task to shell helper |
| `audit-cowork` | Submit task to code auditor |
| `git-cowork` | Submit task to git helper |
| `decision-cowork` | Submit task to decision auditor |
| `agent-help` | Show available agent commands |

## Tips for Effective Use

1. **Be specific with tasks**: The more specific your task description, the better the result.
2. **Check notifications regularly**: Run `agent-notifications` to see what tasks have been completed.
3. **Use agent-specific commands**: Different agents are specialized for different tasks.
4. **Maintain your memory**: If memory files grow too large, you can manually delete old conversations.

## Requirements

- Ollama must be installed and functioning
- `jq` is highly recommended for full functionality (`sudo apt install jq`)
- `notify-send` is optional for desktop notifications
