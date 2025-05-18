# CodexContinue-GPT for Docker

This directory contains the installation scripts and files for CodexContinue-GPT, a shell-based AI assistant with auto-model selection capabilities.

## Files Overview

- `ccgpt-final.sh`: The main script with full auto-model selection and Ollama API integration
- `ccgpt-help.sh`: A quick usage guide script
- `ccgpt-minimal.sh`: A minimalist version for testing
- `ccgpt-complete.sh`: A complete version without direct API integration
- `verify-ccgpt.sh`: Script to verify installation
- `install-ccgpt-final.sh`: Final installation script that sets up everything

## Installation

To install CodexContinue-GPT in your Docker container, run:

```bash
./install-ccgpt-final.sh
```

## Usage

Once installed, you can use CodexContinue-GPT in two ways:

1. **From the host machine**:
   ```bash
   ./launch-ccgpt.sh [OPTIONS]
   ```

2. **Inside the container**:
   ```bash
   cc [OPTIONS]
   ```

### Options

- `--auto`: Enable auto-model selection
- `--model MODEL`: Specify a model (codellama, mistral, llama3)
- `--test`: Run in test mode without real Ollama API calls
- `--help`: Show help information
- `--guide`: Show usage guide

## Auto-Model Selection

The auto-selection feature intelligently chooses between:

- `codellama`: For code-related queries
- `mistral`: For task management
- `llama3`: For general conversation

## Verification

To verify your installation, run:

```bash
./verify-ccgpt.sh
```

## Troubleshooting

If you encounter issues:

1. Check if the container is running:
   ```bash
   docker ps | grep dbgpt-shell-agent
   ```

2. Verify script permissions:
   ```bash
   docker exec -it dbgpt-shell-agent bash -c "ls -la /app/agent/"
   ```

3. Try running in test mode:
   ```bash
   cc --auto --test
   ```

4. Reinstall with:
   ```bash
   ./install-ccgpt-final.sh
   ```
