# DB-GPT Memory Management Tools

## Overview

This document provides a comprehensive list of the memory management tools implemented for the DB-GPT project to help manage memory usage when running different shell agents.

## Available Tools

### 1. Memory-Efficient Shell Agent

**File**: `run-smart-shell-agent-lite.sh`

A streamlined version of the Smart Shell Agent with reduced memory footprint:
- Smaller context window
- Optimized for systems with limited memory
- Same natural language interface as the full version

**Usage**:
```bash
./run-smart-shell-agent-lite.sh
```

### 2. Auto Memory Manager

**File**: `auto-memory-manager.sh`

Automatically selects the appropriate shell agent based on available memory:
- Analyzes system memory
- Recommends the optimal agent (standard, lite, or minimal)
- Provides memory cleanup options
- Can create ultra-minimal test models for very low-memory systems

**Usage**:
```bash
./auto-memory-manager.sh
```

### 3. Memory Manager

**File**: `memory-manager.sh`

A comprehensive memory management tool with both interactive and command-line modes:
- Display memory status
- Real-time memory monitoring
- Clean up memory (light, standard, aggressive levels)
- Kill Ollama processes
- Optimize memory parameters

**Usage**:
```bash
# Interactive mode
./memory-manager.sh

# Command-line mode
./memory-manager.sh status
./memory-manager.sh clean aggressive
./memory-manager.sh monitor
```

### 4. Ollama Cleanup Utility

**File**: `cleanup-ollama.sh`

A specialized tool for cleaning up Ollama processes and freeing memory:
- Stop Ollama processes
- Force kill stuck processes
- Delete unused models
- Restart Ollama service

**Usage**:
```bash
./cleanup-ollama.sh
./cleanup-ollama.sh --force
./cleanup-ollama.sh --delete MODEL_NAME
```

### 5. Memory Monitor

**File**: `monitor-memory.sh`

A real-time monitor for system and Ollama memory usage:
- Shows overall system memory
- Displays Ollama process memory
- Updates in real-time

**Usage**:
```bash
./monitor-memory.sh
```

### 6. Optimized Ollama Parameters

**File**: `optimize-ollama-params.sh`

A tool to find and apply the optimal Ollama parameters for your system:
- Test different parameter combinations
- Create presets for different memory profiles
- Generate custom runner scripts

**Usage**:
```bash
./optimize-ollama-params.sh --interactive
./optimize-ollama-params.sh --preset low|medium|high
```

## Integration with Shell Agent Manager

The shell-agent-manager.sh script has been updated to include all memory management features:

**File**: `shell-agent-manager.sh`

**New commands**:
```bash
# Auto-select agent based on memory
./shell-agent-manager.sh auto

# Manage memory
./shell-agent-manager.sh memory

# Compare agent memory usage
./shell-agent-manager.sh compare
```

## Memory Usage Comparison

| Agent Version | Approx. Memory Usage | Best For |
|---------------|---------------------|----------|
| Smart Shell Agent | 8GB+ | Systems with plenty of memory, complex tasks |
| Smart Shell Agent Lite | 4GB+ | General usage, moderate memory systems |
| Minimal Shell Agent | 2GB+ | Low-memory systems, basic tasks |
| Ultra-Minimal Test | <1GB | Testing, extremely memory-constrained systems |

## Best Practices

1. Use `./shell-agent-manager.sh auto` to automatically select the right agent for your system
2. Monitor memory usage with `./monitor-memory.sh`
3. Clean up memory regularly with `./cleanup-ollama.sh`
4. For very low memory systems, consider using the minimal agent or creating an ultra-minimal test model

## Troubleshooting

If you encounter memory issues:
1. Try `./memory-manager.sh clean aggressive` to free up memory
2. Use `./cleanup-ollama.sh --force` to kill all Ollama processes
3. Switch to a more memory-efficient agent with `./shell-agent-manager.sh lite`
4. Remove unused models to free disk space
