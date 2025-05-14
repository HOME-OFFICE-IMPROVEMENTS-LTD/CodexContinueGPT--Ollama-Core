# CodexContinueGPT™ Ollama Tools

This directory contains tools and scripts for integrating Ollama LLMs with CodexContinueGPT™, providing an enhanced AI-powered development experience directly in your terminal.

## Quick Start

1. First, make sure Ollama is installed and running:
   ```bash
   # Install Ollama if needed
   curl -fsSL https://ollama.com/install.sh | sh
   
   # Start the Ollama server
   ollama serve
   ```

2. Pull recommended models:
   ```bash
   ollama pull codellama
   ollama pull llama3
   ```

3. Load the project aliases (from repository root):
   ```bash
   source .aliases
   ```

4. Start using the tools!
   ```bash
   # Get shell help
   sh-help "How do I find large files?"
   
   # Ask coding questions
   ask "Write a Python function to download a file"
   ```

## Available Scripts

### ollama_manager.sh

Manages Ollama models for CodexContinueGPT™ integration. This comprehensive tool helps you manage, configure and use Ollama models with CodexContinueGPT™.

```bash
# Using aliases (recommended)
om-list         # List available models
om-pull MODEL   # Pull a new model
om-update MODEL # Set model as active
om-recommend    # Show recommended models
om-start        # Start CodexContinueGPT™ with Ollama
om-docker       # Deploy with Docker

# Or using the script directly
./ollama_manager.sh list
./ollama_manager.sh pull MODEL
./ollama_manager.sh update MODEL
./ollama_manager.sh recommend
./ollama_manager.sh start
./ollama_manager.sh docker
```

Features:
- Lists installed and available Ollama models
- Pulls new models from Ollama library
- Updates configuration to use different models
- Provides curated model recommendations by task
- One-command start of CodexContinueGPT™ with Ollama
- Docker deployment support

### shell_helper.sh

Provides intelligent shell command guidance using Ollama LLMs. The tool can answer questions about shell commands, explain complex commands, and generate shell scripts based on natural language descriptions.

```bash
# Using aliases (recommended)
sh-help "How do I find large files in Linux?"
sh-explain "find / -type f -size +100M | sort -n"
sh-script "create a backup script for user directories"

# Or using the script directly
./shell_helper.sh "How do I find large files in Linux?"
./shell_helper.sh --explain "find / -type f -size +100M | sort -n"
./shell_helper.sh --script "create a backup script"
```

Features:
- Answers shell command questions with practical examples
- Explains complex shell commands in detail
- Generates complete shell scripts based on natural language descriptions
- Uses the CodeLlama model for accurate command generation
- Beautifully formatted output with syntax highlighting

### ask.sh

Advanced tool for direct interaction with Ollama models. This is useful for general questions or programming tasks that don't necessarily relate to shell commands.

```bash
# Using aliases (recommended)
ask "What is quantum computing?"
ask-llama "Write a haiku about programming"
ask-code "Explain the difference between promises and async/await"
ask-any llama3 "Tell me a story about AI"
ask-models  # Show available models

# Or using the script directly
./ask.sh "What is quantum computing?"
./ask.sh --model llama3 "Write a haiku about programming"
./ask.sh --list  # Show available models
```

Features:
- Direct access to different Ollama models
- Model-specific aliases for common tasks
- Support for all Ollama parameters
- List available models
- Stream responses for faster feedback

### fix_paths.sh

Utility to fix hardcoded paths in scripts. This is useful when deploying in different environments.

```bash
./fix_paths.sh  # Makes scripts use relative paths
```

Features:
- Updates hardcoded paths in all scripts
- Uses dynamic path resolution with `$(pwd)` and `dirname`
- Creates backups before modifications
- Can fix multiple scripts in one run

## Configuration

The Ollama integration is configured through:
- `configs/dbgpt-proxy-ollama.toml` - Main configuration file
- `.aliases` - Shell aliases for easier access to tools

## Documentation

For comprehensive documentation, see:
- Project wiki in `/docs/wiki/`
- [`docs/ollama_shell_guidance.md`](/docs/ollama_shell_guidance.md) - Detailed guide
- [`docs/wiki/Ollama-Integration.md`](/docs/wiki/Ollama-Integration.md) - Integration reference
