# CodexContinueGPT™ Ollama Integration

This document serves as a reference guide for the Ollama integration features implemented in the `feature/ollama-shell-integration` branch.

## Repository Setup

The repository is configured with two remotes:
- `origin` points to `https://github.com/eosphoros-ai/DB-GPT.git` (original repository)
- `fork` points to `https://github.com/HOME-OFFICE-IMPROVEMENTS-LTD/CodexContinueGPT-Ollama-Core.git` (your fork)

### Recommended Remote Configuration

For better clarity, rename the remotes:
```bash
git remote rename origin upstream
git remote rename fork origin
```

## Files Added for Ollama Integration

1. **`ollama_manager.sh`**: Script to manage Ollama models for CodexContinueGPT™ integration
   - Lists available models
   - Pulls new models
   - Updates CodexContinueGPT™ configuration
   - Shows recommended models
   - Starts CodexContinueGPT™ with Ollama configuration
   - Deploys with Docker-Compose

2. **`shell_helper.sh`**: Script that leverages Ollama with CodeLlama for shell guidance
   - Answers shell questions
   - Explains shell commands
   - Generates shell scripts

3. **`docs/ollama_shell_guidance.md`**: Documentation for using Ollama with DB-GPT
   - Configuration setup
   - Usage instructions
   - Advanced examples
   - Troubleshooting

4. **`configs/dbgpt-proxy-ollama.toml`**: Configuration file for Ollama integration
   - Configured to use CodeLlama model
   - Uses bge-m3:latest for embeddings
   - Connects to Ollama API at localhost:11434

## Usage Examples

### Listing Models
```bash
./tools/ollama/ollama_manager.sh list
```

### Pulling New Models
```bash
./tools/ollama/ollama_manager.sh pull MODEL_NAME
```

### Updating Configuration
```bash
./tools/ollama/ollama_manager.sh update MODEL_NAME
```

### Starting DB-GPT with Ollama
```bash
./tools/ollama/ollama_manager.sh start
```

### Shell Helper
```bash
./tools/ollama/shell_helper.sh "your shell question or command here"
./tools/ollama/shell_helper.sh --explain "shell command to explain"
./tools/ollama/shell_helper.sh --script "description of script to generate"
```

### Direct Model Interaction

#### Using the Ask Script
The repository includes a powerful `ask.sh` script for directly querying Ollama models:

```bash
# Ask using default model (CodeLlama)
./ask.sh "How do I sort an array in Python?"

# Ask specific model
./ask.sh llama3 "Explain quantum computing"

# List available models
./ask.sh --list
```

#### Using Aliases
After loading aliases with `source .aliases`, you can use:

```bash
# Quick query with default model (CodeLlama)
ask "How do I find files modified in the last 24 hours?"

# Query with Llama3
ask-llama "Write a haiku about programming"

# Query with any model (first arg is model name)
ask-any llama3 "Explain Docker in simple terms"

# Use the advanced script via alias
askm llama3 "What are the benefits of functional programming?"
```

## Development Notes

- The current integration uses CodeLlama as the default model
- Path settings in scripts are currently hardcoded to `/home/msalsouri/Projects/DB-GPT/`
- Future improvements should use relative paths instead of hardcoded paths

## Project Aliases

We've included convenient aliases in a `.aliases` file in the repository root. To use them:

```bash
# Load the aliases in your current terminal session
source .aliases

# See all available aliases
cchelp
```

### Git Aliases
- `gs` - Git status
- `gco` - Git checkout
- `gcb` - Git checkout new branch
- `gp` - Git pull
- `gpu` - Git push
- `gf` - Git fetch
- `gl` - Git log (graph view)
- `grs` - Git remote list

### Ollama Manager Aliases
- `om` - Ollama Manager main command
- `om-list` - List available models
- `om-pull` - Pull new models
- `om-update` - Update active model
- `om-start` - Start DB-GPT with Ollama
- `om-docker` - Deploy with Docker
- `om-recommend` - Show recommended models

### Shell Helper Aliases
- `sh-help` - Get shell guidance
- `sh-explain` - Explain a shell command
- `sh-script` - Generate a shell script

### Navigation Aliases
- `cdcc` - Go to repository root
- `cdcc-docs` - Go to docs directory
- `cdcc-configs` - Go to configs directory
