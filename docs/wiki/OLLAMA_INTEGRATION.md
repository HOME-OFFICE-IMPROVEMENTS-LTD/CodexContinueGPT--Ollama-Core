# CodexContinueGPT™ Ollama Integration

This document provides a comprehensive guide to the Ollama integration features in CodexContinueGPT™.

## Introduction

[Ollama](https://ollama.com/) is an open-source framework that lets you run large language models (LLMs) locally on your own hardware. CodexContinueGPT™ integrates seamlessly with Ollama to provide powerful AI capabilities for shell command guidance, code generation, and more.

## Quick Start

### 1. Install Ollama

If you haven't already installed Ollama, run:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### 2. Pull Recommended Models

Pull the main models used by CodexContinueGPT™:

```bash
ollama pull codellama   # Primary model for coding and shell commands
ollama pull llama3      # General-purpose model
```

### 3. Start Ollama Server

Make sure the Ollama server is running:

```bash
ollama serve
```

### 4. Load CodexContinueGPT™ Aliases

From the repository root:

```bash
source .aliases
```

### 5. Try It Out

```bash
# Get shell command help
sh-help "How do I find large files in Linux?"

# Ask a coding question
ask "How do I write a Python function to download a file?"
```

## Key Features

### 1. Shell Command Guidance

Get help with complex shell commands:

```bash
# Ask how to perform a task
sh-help "How to compress a directory with tar?"

# Get an explanation of a command
sh-explain "find / -type f -size +100M -exec ls -lh {} \;"

# Generate a complete shell script
sh-script "Create a backup script for MySQL databases"
```

### 2. Direct Model Access

Query Ollama models directly:

```bash
# Ask the default model (codellama)
ask "What is the difference between .bashrc and .bash_profile?"

# Use a specific model
ask-llama "Explain quantum computing in simple terms"
ask-code "Write a Python function to download files asynchronously"
ask-any wizardcoder "Create a React component with TypeScript"
```

### 3. Model Management

Manage your Ollama models:

```bash
# List installed and available models
om-list

# Pull a new model
om-pull mistral

# Configure CodexContinueGPT™ to use a different model
om-update wizardcoder

# Get model recommendations for different tasks
om-recommend
```

## Configuration

### Base Configuration

The base Ollama configuration is at `configs/dbgpt-proxy-ollama.toml`:

```toml
[models]
[[models.llms]]
name = "codellama"
provider = "proxy/ollama"
api_base = "http://localhost:11434"
api_key = ""

[[models.embeddings]]
name = "bge-m3:latest"
provider = "proxy/ollama"
```

### Custom Configuration

You can modify the model used by editing the configuration or using the `om-update` command:

```bash
# Change to a different model
om-update mistral
```

## Advanced Usage

### Creating Custom Aliases

You can add your own custom aliases by editing the `.aliases` file or creating a `.aliases.local` file with your personal aliases.

### Using Shell Helper for Complex Tasks

The shell helper can assist with complex tasks:

```bash
# Get help with advanced file operations
sh-help "How do I recursively find and replace text in files?"

# Generate complex scripts
sh-script "Create a monitoring script that alerts when disk space is low"
```

### Integrating with Development Workflow

Incorporate AI assistance into your development workflow:

```bash
# Get help with Git operations
ask "How do I undo the last three commits in git?"

# Generate code for specific tasks
ask-code "Write a Python function to parse CSV files with error handling"
```

## Advanced Features

### Model Context Protocol (MCP) Integration

For more advanced usage, CodexContinueGPT™ provides a Model Context Protocol (MCP) server that standardizes interactions between DB-GPT and Ollama. This enables more sophisticated API functionality.

To use the MCP integration:

```bash
# Start the MCP server with CodeLlama
mcp-start-codellama

# In a new terminal, start DB-GPT with MCP configuration
mcp-dbgpt
```

For full documentation on the MCP implementation, see [MCP_OLLAMA.md](MCP_OLLAMA.md).

## Troubleshooting

### Ollama Server Not Running

If you see an error about the Ollama server not running:

```
Error: Failed to connect to Ollama server
```

Start the server with:

```bash
ollama serve
```

### Model Not Found

If a model is not found:

```
Error: model 'codellama' not found
```

Pull the model:

```bash
ollama pull codellama
```

### Path Issues

If scripts can't be found, run the fix_paths script:

```bash
./fix_paths.sh
```

## Contributing

We welcome contributions to improve the Ollama integration! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Resources

- [Ollama GitHub Repository](https://github.com/ollama/ollama)
- [CodeLlama Model Documentation](https://ollama.com/library/codellama)
- [Llama3 Model Documentation](https://ollama.com/library/llama3)