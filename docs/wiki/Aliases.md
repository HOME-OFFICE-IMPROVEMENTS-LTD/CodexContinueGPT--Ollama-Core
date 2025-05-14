# CodexContinueGPT™ Aliases Wiki

## Introduction

Aliases are shorthand commands that make it easier and faster to work with the CodexContinueGPT™ project. This wiki page documents the available aliases and how to use them effectively.

## Getting Started

### Loading Aliases

To use the project aliases, you need to source the `.aliases` file from the repository root:

```bash
source .aliases
```

You should see a confirmation message: "CodexContinueGPT aliases loaded! Type 'cchelp' to see all available commands."

### Persistent Setup

To make the aliases available in all your terminal sessions, add this line to your shell configuration file:

**For Bash users:**
```bash
echo 'source /path/to/CodexContinueGPT/.aliases' >> ~/.bashrc
```

**For Zsh users:**
```bash
echo 'source /path/to/CodexContinueGPT/.aliases' >> ~/.zshrc
```

Replace `/path/to/CodexContinueGPT` with the actual path to your repository.

## Alias Categories

The aliases are organized into several categories:

### Git Workflow

Git aliases streamline common version control operations:

```bash
gs          # git status - check what files are changed/staged
gco main    # git checkout main - switch to main branch
gcb feature # git checkout -b feature - create and switch to new branch
gp          # git pull - get latest changes
gpu         # git push - push your changes
gl          # git log with visual graph - see commit history
```

### Ollama Integration

These aliases make it easy to work with Ollama models:

```bash
om-list      # List all available Ollama models
om-pull      # Pull a new model (e.g., om-pull codellama)
om-update    # Update configuration to use a different model
om-start     # Start CodexContinueGPT™ with Ollama configuration
om-recommend # Show recommended models for different tasks
```

### AI Assistant Commands

Get AI-powered help directly in your terminal:

```bash
ask "How do I write a Python function to download a file?"
ask-llama "What are the key features of Linux?"
ask-code "Create a React component for a login form"
ask-any wizardcoder "Generate a Python class for database access"
```

### Shell Helper

Get assistance with shell commands:

```bash
sh-help "How to find files modified in the last 24 hours?"
sh-explain "awk '{print $1}' file.txt | sort | uniq -c"
sh-script "Create a script that backs up MySQL database"
```

## Advanced Usage

### Custom Alias Creation

You can add your own aliases by editing the `.aliases` file or creating a `.aliases.local` file (which won't be tracked by git). For example:

```bash
# Add to your .aliases.local file
alias my-command='echo "This is my custom command"'
```

### Integrating with Other Tools

You can combine aliases with other tools. For example:

```bash
# Combine with fzf for fuzzy finding
alias gco-fzf='git checkout $(git branch | fzf)'
```

## Troubleshooting

### Path Issues

If aliases aren't finding scripts, verify the repository structure:

```bash
ls -la ./tools/ollama/  # Should contain ollama_manager.sh, shell_helper.sh, etc.
```

If needed, run the fix_paths script:

```bash
./fix_paths.sh
```

### Alias Conflicts

If you have alias conflicts with other tools, you can:

1. Rename the conflicting alias in `.aliases`
2. Temporarily disable aliases with `\command` (e.g., `\gs` to run the real `gs` command)

### Missing Dependencies

Many aliases require Ollama to be installed and running:

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Start Ollama server
ollama serve
```