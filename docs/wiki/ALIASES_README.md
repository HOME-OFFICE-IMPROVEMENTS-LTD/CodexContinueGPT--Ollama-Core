# CodexContinueGPT™ Aliases README

## Recent Changes

The `.aliases` file has been updated to fix several issues:

1. **Path Independence**: Aliases now work from any directory, not just the project root
2. **Better Argument Handling**: The function-based aliases now properly handle multi-word arguments
3. **Enhanced Documentation**: This README provides guidance on how to use the aliases

## How to Use the Aliases

1. **Load the aliases** (from any directory):
   ```bash
   source /path/to/DB-GPT/.aliases
   ```

2. **Add to your shell profile** for automatic loading:
   ```bash
   echo 'source /path/to/DB-GPT/.aliases' >> ~/.bashrc
   # Or for Zsh
   echo 'source /path/to/DB-GPT/.aliases' >> ~/.zshrc
   ```

## Available Aliases

### Shell Helper Commands
- `sh-help "your question"` - Get help with shell commands
- `sh-explain "command"` - Explain a shell command
- `sh-script "description"` - Generate a shell script

### Direct Model Queries
- `ask "your question"` - Ask codellama model
- `ask-llama "your question"` - Ask llama3 model
- `ask-code "your coding question"` - Ask codellama about code
- `ask-any model_name "your question"` - Query any model

### Ollama Management
- `om` - Run Ollama manager script
- `om-list` - List available models
- `om-pull model_name` - Pull a new model
- `om-update model_name` - Set as active model
- `om-start` - Start DB-GPT with Ollama
- `om-docker` - Deploy with Docker
- `om-recommend` - Show recommended models

### Model Context Protocol (MCP)
- `mcp-start` - Start MCP server with default settings
- `mcp-start-codellama` - Start MCP server with codellama
- `mcp-start-llama3` - Start MCP server with llama3
- `mcp-dbgpt` - Start DB-GPT with MCP configuration

### Navigation
- `cdcc` - Go to project root
- `cdcc-docs` - Go to docs directory
- `cdcc-configs` - Go to configs directory

### Git Shortcuts
- `gs` - Git status
- `gco` - Git checkout
- `gp` - Git pull
- ...and more

## Troubleshooting

If you experience any issues:

1. **Check Ollama Installation**:
   ```bash
   which ollama
   ```

2. **Ensure Ollama is Running**:
   ```bash
   curl http://localhost:11434/api/version
   ```

3. **Verify Script Permissions**:
   ```bash
   ls -l $PROJECT_ROOT/tools/ollama/*.sh
   ```

4. **Fix Path Issues** if needed:
   ```bash
   $PROJECT_ROOT/tools/ollama/fix_paths.sh
   ```
