# DB-GPT Project Aliases Cheatsheet

This cheatsheet provides a quick reference for all available aliases in the DB-GPT project, organized by category.

## 🔍 Finding Aliases

| Command | Description |
|---------|-------------|
| `cchelp` | List all available aliases in the project |
| `agent-help` | Show summary of agent-related aliases |

## 🔄 Git Aliases

| Alias | Full Command | Description |
|-------|-------------|-------------|
| `gs` | `git status` | Show the working tree status |
| `gco` | `git checkout` | Switch branches or restore working tree files |
| `gcb` | `git checkout -b` | Create and switch to a new branch |
| `gp` | `git pull` | Fetch from and integrate with another repository |
| `gpu` | `git push` | Update remote refs along with associated objects |
| `gf` | `git fetch` | Download objects and refs from another repository |
| `gl` | `git log --oneline --graph --decorate --all` | Show commit logs with graph representation |
| `glo` | `git log --oneline --decorate` | Show compact commit logs |
| `grs` | `git remote -v` | Show remote repositories |

## 🤖 Ollama Manager Aliases

| Alias | Full Command | Description |
|-------|-------------|-------------|
| `om` | `$PROJECT_ROOT/tools/ollama/ollama_manager.sh` | Run Ollama Manager with arguments |
| `om-list` | `$PROJECT_ROOT/tools/ollama/ollama_manager.sh list` | List all available Ollama models |
| `om-pull` | `$PROJECT_ROOT/tools/ollama/ollama_manager.sh pull` | Pull a specific Ollama model |
| `om-update` | `$PROJECT_ROOT/tools/ollama/ollama_manager.sh update` | Update an Ollama model |
| `om-start` | `$PROJECT_ROOT/tools/ollama/ollama_manager.sh start` | Start the Ollama service |
| `om-docker` | `$PROJECT_ROOT/tools/ollama/ollama_manager.sh docker` | Run Ollama in Docker |
| `om-recommend` | `$PROJECT_ROOT/tools/ollama/ollama_manager.sh recommend` | Show recommended models |

## 💬 Ollama Convenience Aliases

| Alias | Full Command | Description |
|-------|-------------|-------------|
| `ollama-help` | `$PROJECT_ROOT/ollama-commands.sh` | Show Ollama help commands |
| `ollama-start` | `$PROJECT_ROOT/ollama-docker-start.sh` | Start Ollama in Docker |
| `ask` | `ollama run codellama "$*"` | Ask CodeLlama a question (function) |
| `ask-llama` | `ollama run llama3 "$*"` | Ask Llama3 a question (function) |
| `ask-code` | `ollama run codellama "$*"` | Ask CodeLlama coding questions (function) |
| `ask-any` | `ollama run "$model" "$*"` | Ask any model a question (function) |
| `askm` | `$PROJECT_ROOT/tools/ollama/ask.sh` | Use advanced ask script |
| `ask-models` | `$PROJECT_ROOT/tools/ollama/ask.sh --list` | List models for asking questions |

## 🛠️ Shell Helper Aliases

| Alias | Full Command | Description |
|-------|-------------|-------------|
| `sh-help` | `$PROJECT_ROOT/tools/ollama/shell_helper.sh` | Get shell command assistance |
| `sh-explain` | `$PROJECT_ROOT/tools/ollama/shell_helper.sh --explain "$*"` | Explain a shell command (function) |
| `sh-script` | `$PROJECT_ROOT/tools/ollama/shell_helper.sh --script "$*"` | Generate a shell script (function) |

## 👨‍💻 Agent Command Aliases

| Alias | Full Command | Description |
|-------|-------------|-------------|
| `code-assistant` | `$PROJECT_ROOT/agent-commands.sh code` | Get coding assistance |
| `shell-helper` | `$PROJECT_ROOT/agent-commands.sh shell` | Get shell command assistance |
| `task-manager` | `$PROJECT_ROOT/agent-commands.sh tasks` | Manage tasks with AI assistance |
| `audit-code` | `$PROJECT_ROOT/agent-commands.sh audit` | Audit code with AI assistance |
| `git-helper` | `$PROJECT_ROOT/agent-commands.sh git` | Get Git assistance |
| `decision-audit` | `$PROJECT_ROOT/agent-commands.sh decision` | Get decision-making assistance |

## 🤝 Shell Agent Aliases

| Alias | Full Command | Description |
|-------|-------------|-------------|
| `shell-agent` | `$PROJECT_ROOT/run-shell-agent.sh` | Run the shell agent |
| `code-audit` | `$PROJECT_ROOT/run-shell-agent.sh --audit` | Run code audit with shell agent |
| `task-track` | `$PROJECT_ROOT/run-shell-agent.sh --tasks` | Track tasks with shell agent |
| `build-agent` | `$PROJECT_ROOT/build-shell-agent.sh` | Build the shell agent |
| `launch-agent` | `$PROJECT_ROOT/launch-shell-agent.sh` | Launch the shell agent |

## 📁 Navigation Aliases

| Alias | Full Command | Description |
|-------|-------------|-------------|
| `cdcc` | `cd $PROJECT_ROOT` | Navigate to project root |
| `cdcc-docs` | `cd $PROJECT_ROOT/docs` | Navigate to docs directory |
| `cdcc-configs` | `cd $PROJECT_ROOT/configs` | Navigate to configs directory |

## 🌐 MCP Server Aliases

| Alias | Full Command | Description |
|-------|-------------|-------------|
| `mcp-start` | `$PROJECT_ROOT/tools/ollama/start_mcp_server.sh` | Start MCP server |
| `mcp-start-codellama` | `$PROJECT_ROOT/tools/ollama/start_mcp_server.sh --model codellama --port 8000` | Start MCP with CodeLlama |
| `mcp-start-llama3` | `$PROJECT_ROOT/tools/ollama/start_mcp_server.sh --model llama3 --port 8000` | Start MCP with Llama3 |
| `mcp-dbgpt` | `cd $PROJECT_ROOT && uv run dbgpt start webserver --config configs/dbgpt-proxy-ollama-mcp.toml` | Start DB-GPT with MCP |

## 🚀 Enhanced MCP Server Aliases

| Alias | Full Command | Description |
|-------|-------------|-------------|
| `mcp-enhanced` | `$PROJECT_ROOT/tools/ollama/start_enhanced_mcp_server.sh` | Start enhanced MCP server |
| `mcp-enhanced-codellama` | `$PROJECT_ROOT/tools/ollama/start_enhanced_mcp_server.sh --model codellama --port 8000` | Start enhanced MCP with CodeLlama |
| `mcp-enhanced-llama3` | `$PROJECT_ROOT/tools/ollama/start_enhanced_mcp_server.sh --model llama3 --port 8000` | Start enhanced MCP with Llama3 |
| `mcp-test` | `$PROJECT_ROOT/tools/ollama/test_enhanced_mcp_server.py` | Test enhanced MCP server |
| `mcp-benchmark` | `$PROJECT_ROOT/tools/ollama/benchmark_mcp_server.sh` | Benchmark MCP server |

## 🧠 Enhanced Shell Agent Aliases

| Alias | Full Command | Description |
|-------|-------------|-------------|
| `shell-enhanced` | `$PROJECT_ROOT/tools/ollama/enhanced_shell_agent.sh` | Run enhanced shell agent |
| `shell-enhanced-code` | `$PROJECT_ROOT/tools/ollama/enhanced_shell_agent.sh --mode code` | Run enhanced shell agent in code mode |
| `shell-enhanced-creative` | `$PROJECT_ROOT/tools/ollama/enhanced_shell_agent.sh --mode creative` | Run enhanced shell agent in creative mode |

## 💭 MCP Memory Aliases

| Alias | Full Command | Description |
|-------|-------------|-------------|
| `mcp-memory` | `$PROJECT_ROOT/tools/ollama/mcp_memory_agent.sh` | Use MCP memory agent |
| `mcp-memory-start` | `$PROJECT_ROOT/tools/ollama/mcp_memory_agent.sh start` | Start MCP memory system |
| `mcp-memory-ask` | `$PROJECT_ROOT/tools/ollama/mcp_memory_agent.sh ask` | Ask the MCP memory system |
| `mcp-memory-remember` | `$PROJECT_ROOT/tools/ollama/mcp_memory_agent.sh remember` | Store memory in MCP system |

## 📝 Agent Memory System Aliases

| Alias | Full Command | Description |
|-------|-------------|-------------|
| `agent-memory` | `$PROJECT_ROOT/agent-memory.sh` | Use agent memory system |
| `agent-submit` | `$PROJECT_ROOT/agent-memory.sh submit` | Submit task to agent memory |
| `agent-tasks` | `$PROJECT_ROOT/agent-memory.sh tasks` | View agent tasks |
| `agent-output` | `$PROJECT_ROOT/agent-memory.sh output` | View agent output |
| `agent-notifications` | `$PROJECT_ROOT/agent-memory.sh notifications` | View agent notifications |
| `agent-init` | `$PROJECT_ROOT/agent-memory.sh initialize` | Initialize agent memory |
| `agent-patch` | `$PROJECT_ROOT/agent-memory.sh patch` | Apply patch to agent memory |

## 🗄️ Memory Manager Aliases

| Alias | Full Command | Description |
|-------|-------------|-------------|
| `memory-stats` | `$PROJECT_ROOT/agent-memory-manager.sh stats` | View memory stats |
| `memory-clean` | `$PROJECT_ROOT/agent-memory-manager.sh clean` | Clean memory |
| `memory-export` | `$PROJECT_ROOT/agent-memory-manager.sh export` | Export memory |
| `memory-worker` | `$PROJECT_ROOT/agent-memory-manager.sh worker` | Run memory worker |
| `memory-help` | `$PROJECT_ROOT/agent-memory-manager.sh help` | Get memory help |
| `demo-cowork` | `$PROJECT_ROOT/agent-coworking-demo.sh` | Run co-working demo |

## 👥 Co-working Function Aliases

| Function | Description |
|----------|-------------|
| `code-cowork` | Submit code task to co-working system |
| `shell-cowork` | Submit shell task to co-working system |
| `audit-cowork` | Submit code audit task to co-working system |
| `git-cowork` | Submit git task to co-working system |
| `decision-cowork` | Submit decision task to co-working system |
