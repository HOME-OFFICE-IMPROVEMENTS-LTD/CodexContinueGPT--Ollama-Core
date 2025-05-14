# CodexContinueGPT™ Aliases

This document describes the aliases available in the CodexContinueGPT™ project.

## How to Use Aliases

To load the aliases, from the repository root, run:

```bash
source .aliases
```

You can add this command to your `.bashrc` or `.zshrc` file to load these aliases automatically when you start a terminal.

## Available Aliases

### Git Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `gs` | `git status` | Check the status of your working directory |
| `gco` | `git checkout` | Switch branches or restore working tree files |
| `gcb` | `git checkout -b` | Create a new branch and switch to it |
| `gp` | `git pull` | Fetch from and integrate with another repository |
| `gpu` | `git push` | Update remote refs along with associated objects |
| `gf` | `git fetch` | Download objects and refs from another repository |
| `gl` | `git log --oneline --graph --decorate --all` | Show commit logs in a graph format |
| `glo` | `git log --oneline --decorate` | Show commit logs in a compact format |
| `grs` | `git remote -v` | Show remote repositories with URLs |

### Ollama Manager Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `om` | `./tools/ollama/ollama_manager.sh` | Run the Ollama manager script |
| `om-list` | `./tools/ollama/ollama_manager.sh list` | List available Ollama models |
| `om-pull` | `./tools/ollama/ollama_manager.sh pull` | Pull a new model from Ollama library |
| `om-update` | `./tools/ollama/ollama_manager.sh update` | Update the active model |
| `om-start` | `./tools/ollama/ollama_manager.sh start` | Start CodexContinueGPT™ with Ollama |
| `om-docker` | `./tools/ollama/ollama_manager.sh docker` | Deploy with Docker |
| `om-recommend` | `./tools/ollama/ollama_manager.sh recommend` | Show recommended models |

### Direct Ollama Query Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `ask` | `ollama run codellama "$1"` | Ask a question to codellama model |
| `ask-llama` | `ollama run llama3 "$1"` | Ask a question to llama3 model |
| `ask-code` | `ollama run codellama "$1"` | Ask a coding question to codellama model |
| `ask-any` | `ollama run "$1" "$2"` | Ask any model a question (specify model name) |

### Advanced Ask Script Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `askm` | `./tools/ollama/ask.sh` | Advanced ask script with more options |
| `ask-models` | `./tools/ollama/ask.sh --list` | List all available models |

### Shell Helper Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `sh-help` | `./tools/ollama/shell_helper.sh` | Get help with shell commands |
| `sh-explain` | `./tools/ollama/shell_helper.sh --explain` | Explain a shell command |
| `sh-script` | `./tools/ollama/shell_helper.sh --script` | Generate a shell script |

### Navigation Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `cdcc` | `cd $(git rev-parse --show-toplevel)` | Navigate to repository root |
| `cdcc-docs` | `cd $(git rev-parse --show-toplevel)/docs` | Navigate to docs directory |
| `cdcc-configs` | `cd $(git rev-parse --show-toplevel)/configs` | Navigate to configs directory |

### Utility Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `cchelp` | `cat $(git rev-parse --show-toplevel)/.aliases | grep -E "^alias" | sed "s/alias //g" | sort` | Print all available aliases |