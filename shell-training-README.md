# DB-GPT Shell Training System

This training system helps you learn Linux shell commands and scripting through guided exercises with the assistance of an AI shell agent.

## Overview

The DB-GPT Shell Training System provides a structured approach to learning shell commands and scripting. It combines:

1. An interactive shell agent that can explain commands and generate scripts
2. A progressive lesson plan covering basic to advanced shell topics
3. Practical exercises that become more challenging as you advance
4. Reference materials including command cheat sheets and example exercises

## Getting Started

Make sure you have the Enhanced MCP server running before starting your training:

```bash
mcp-enhanced-codellama
```

Then start the training guide:

```bash
./shell-training.sh
```

## Available Options

You can customize your training experience:

```bash
# List all available lessons
./shell-training.sh --list

# Start from a specific lesson
./shell-training.sh --lesson 3

# Use a different language model
./shell-training.sh --model llama3

# Reset your progress
./shell-training.sh --reset
```

## Training Materials

This system includes several resources:

1. **shell-training.sh** - The main training script
2. **shell-commands-cheatsheet.md** - Quick reference guide for shell commands
3. **shell-training-exercises.md** - Example exercises for each lesson

## Lesson Topics

The training covers these key areas:

1. Basic Navigation
2. File Operations
3. Text Processing
4. Pipes and Redirection
5. Shell Scripting Basics
6. Process Management
7. User and Permissions
8. Environment Variables
9. Regular Expressions
10. Advanced Scripting

## How It Works

The training system uses the DB-GPT Enhanced Shell Agent to create customized exercises based on your current lesson. For each lesson:

1. The system generates 5 practical exercises
2. Each exercise includes a task, hints, and explanations
3. You can practice commands in real-time
4. The shell agent provides feedback and answers questions
5. Your progress is tracked between sessions

## Requirements

- Bash shell environment
- Enhanced MCP server running
- Internet connection for model access

## Tips for Effective Learning

1. Practice each command as you learn it
2. Try variations of commands to deepen understanding
3. Create your own simple scripts to reinforce concepts
4. Review the cheat sheet regularly
5. Challenge yourself to solve real problems using shell commands
