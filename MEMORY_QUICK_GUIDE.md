# DB-GPT Memory Management Quick Guide

This guide provides a quick overview of the memory management options available in DB-GPT.

## Available Memory-Efficient Options

### 1. Auto-Select (Recommended)

Automatically selects the best agent based on available system memory:

```bash
./shell-agent-manager.sh auto
```

### 2. Memory Management Interface

Opens the unified memory management interface:

```bash
./shell-agent-manager.sh memory
```
or
```bash
./memory-manager.sh
```

### 3. Direct Agent Selection

Run specific agent variants:

```bash
# Full agent (8+ GB RAM recommended)
./shell-agent-manager.sh smart

# Memory-efficient version (4+ GB RAM recommended)
./shell-agent-manager.sh lite

# Minimal agent for very low memory (2+ GB RAM)
./shell-agent-manager.sh run minimal
```

## Memory Tools

### Monitor Memory Usage

```bash
./memory-manager.sh monitor
```

### Clean Up Memory

```bash
# Light cleanup
./memory-manager.sh clean light

# Standard cleanup
./memory-manager.sh clean standard

# Aggressive cleanup
./memory-manager.sh clean aggressive
```

### Kill All Ollama Processes

```bash
./memory-manager.sh kill
```

## Testing the System

To verify that all memory management components are installed correctly:

```bash
./test-memory-system.sh
```

## Documentation

For more detailed information:

- Memory-Efficient Shell Agent: `memory-efficient-README.md`
- Comprehensive Memory Tools: `memory-management-report.md`
