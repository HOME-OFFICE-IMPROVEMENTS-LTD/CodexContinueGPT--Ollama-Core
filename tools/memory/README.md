# DB-GPT Memory Management Tools

This directory contains utilities for managing memory usage in DB-GPT, particularly focused on Ollama and shell agents.

## Available Tools

- **cleanup-ollama.sh**: Manages Ollama processes and frees memory
- **monitor-memory.sh**: Real-time memory monitoring
- **optimize-ollama-params.sh**: Ollama parameter optimization for different memory constraints
- **test-minimal-agent.sh**: Minimal agent for very low memory situations
- **verify-ollama.sh**: Validates Ollama installation

## Usage

These tools are primarily used by the main memory management interface. For most use cases, you should use:

```bash
# From the project root
./memory-manager.sh
```

Or access via the unified shell agent manager:

```bash
./shell-agent-manager.sh memory
```

## See Also

- `memory-efficient-README.md` - Documentation for memory-efficient agents
- `memory-management-report.md` - Comprehensive report on all memory tools
- `MEMORY_QUICK_GUIDE.md` - Quick reference guide for memory management
