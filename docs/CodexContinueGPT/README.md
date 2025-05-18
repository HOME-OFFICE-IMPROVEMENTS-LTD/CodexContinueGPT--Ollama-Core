# CodexContinue-GPT

CodexContinue-GPT is an intelligent shell-based AI assistant with automatic model selection capabilities. It intelligently chooses between different Ollama models (codellama, mistral, llama3) based on the context of your input queries.

## Features

- **Auto-Model Selection**: Automatically selects the most appropriate model based on query content:
  - `codellama`: For code-related queries, programming questions, and debugging
  - `mistral`: For task management, planning, and organization
  - `llama3`: For general conversation and information

- **Simple Interface**: Use simple command-line commands:
  - `cc`: Quick access to the assistant
  - `ccgpt`: Full command with the same functionality

- **Docker Integration**: Seamlessly works within the DB-GPT Docker container environment

## Usage

1. **Basic Usage**:
   ```bash
   cc
   ```

2. **With Auto-Model Selection**:
   ```bash
   cc --auto
   ```

3. **With Specific Model**:
   ```bash
   cc --model codellama
   cc --model mistral
   cc --model llama3
   ```

4. **Test Mode** (without making real Ollama API calls):
   ```bash
   cc --auto --test
   ```

5. **Help Information**:
   ```bash
   cc --help
   ```

## How Auto-Selection Works

The auto-selection feature uses keyword detection to determine the most appropriate model:

1. **Code-related** words trigger `codellama`:
   - code, function, class, bug, error, syntax, variable, algorithm, javascript, python, etc.

2. **Task Management** words trigger `mistral`:
   - task, todo, priority, deadline, project, schedule, planning, organize, etc.

3. **General queries** default to `llama3`

## Installation

The script is automatically installed in the Docker container. You can reinstall or update using:

```bash
./install-ccgpt-complete.sh
```

## Integration with DB-GPT

CodexContinue-GPT integrates with the larger DB-GPT ecosystem, providing quick access to AI assistance directly from your terminal while working with the database tools.

This feature was implemented to streamline the development workflow by providing context-aware AI assistance without switching contexts.
