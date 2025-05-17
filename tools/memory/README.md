# DB-GPT Memory Management Tools

This directory contains utilities for managing memory usage in DB-GPT, particularly focused on Ollama and shell agents.

## Available Tools

- **memory-tools-manager.sh**: Unified interface for all memory tools
- **cleanup-ollama.sh**: Manages Ollama processes and frees memory
- **cleanup-temp-files.sh**: Cleans up temporary and backup files
- **cleanup_temp_files.sh**: Alternate name for cleanup-temp-files.sh (symlinked)
- **cleanup-summary.sh**: Summary reports after cleanup
- **enhanced-cleanup.sh**: Identifies and organizes duplicate and unused files
- **monitor-memory.sh**: Real-time memory monitoring
- **ollama-memory-monitor.sh**: Advanced Ollama memory usage monitor
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

## Integrated Management

For an all-in-one interface to manage all memory tools:

```bash
# From the project root
./tools/memory/memory-tools-manager.sh
```

## Memory Optimization Tips

1. **Use the appropriate model for your system**:
   - 8GB+ RAM: smart-shell-agent
   - 4-8GB RAM: smart-shell-agent-lite or shell-agent
   - 2-4GB RAM: minimal-shell-agent
   - <2GB RAM: lite-test or minimal-test

2. **Monitor Ollama memory usage**:
   - Use `ollama-memory-monitor.sh` for detailed Ollama memory analysis
   - Set up alerts if Ollama exceeds 60% of system memory

3. **Clean up regularly**:
   - Run `cleanup-ollama.sh` to remove unused Ollama models and cache
   - Run `cleanup-temp-files.sh` to clean up temporary and backup files

4. **Optimize for low-memory environments**:
   - Use `optimize-ollama-params.sh` to tune parameters
   - Consider using smaller context windows with `--contextsize` flag

## Directory Structure

- **tools/memory/** - Contains all memory management utilities
- **tools/memory/models/** - Contains model definitions optimized for different memory constraints
- **tools/memory/ORGANIZATION.md** - Details the organization of memory management tools

## See Also

- `memory-efficient-README.md` - Documentation for memory-efficient agents
- `memory-management-report.md` - Comprehensive report on all memory tools
- `MEMORY_QUICK_GUIDE.md` - Quick reference guide for memory management
