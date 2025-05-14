# CodexContinueGPT™ Ollama Tools

This directory contains tools and scripts for integrating Ollama LLMs with CodexContinueGPT™.

## Available Scripts

### ollama_manager.sh

Manages Ollama models for CodexContinueGPT™ integration.

```bash
./ollama_manager.sh list         # List available models
./ollama_manager.sh pull MODEL   # Pull a new model
./ollama_manager.sh update MODEL # Set model as active
./ollama_manager.sh recommend    # Show recommended models
./ollama_manager.sh start        # Start CodexContinueGPT™ with Ollama
./ollama_manager.sh docker       # Deploy with Docker
```

### shell_helper.sh

Provides shell command guidance using Ollama LLMs.

```bash
./shell_helper.sh "How do I find large files in Linux?"
./shell_helper.sh --explain "find / -type f -size +100M | sort -n"
./shell_helper.sh --script "create a backup script"
```

### ask.sh

Advanced tool for direct interaction with Ollama models.

```bash
./ask.sh "What is quantum computing?"
./ask.sh llama3 "Write a haiku about programming"
./ask.sh --list  # Show available models
```

### fix_paths.sh

Utility to fix hardcoded paths in scripts.

```bash
./fix_paths.sh  # Makes scripts use relative paths
```

## Documentation

For detailed documentation, visit the project wiki in `/docs/wiki/`.
