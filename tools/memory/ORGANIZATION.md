# Memory Management System Organization

The memory management system for DB-GPT is now organized as follows:

## Main Scripts (Project Root)

- `manage-memory.sh` - Main entry point for all memory management operations
- `memory-manager.sh` - Unified memory management interface
- `auto-memory-manager.sh` - Auto-selection based on available memory
- `run-smart-shell-agent-lite.sh` - Memory-efficient shell agent
- `memory-setup.sh` - Setup and verification script
- `test-memory-system.sh` - Testing and validation script
- `agent-memory-manager.sh` - Agent-specific memory management
- `agent-memory.sh` - Agent memory storage and retrieval

## Documentation (Project Root)

- `memory-efficient-README.md` - Documentation for memory-efficient operation
- `memory-management-report.md` - Comprehensive report on all memory tools
- `MEMORY_QUICK_GUIDE.md` - Quick reference guide

## Utilities (tools/memory/)

- `memory-tools-manager.sh` - Unified interface for all memory tools
- `enhanced-cleanup.sh` - Advanced tool for finding and organizing duplicate files
- `cleanup-ollama.sh` - Manages Ollama processes and frees memory
- `cleanup-temp-files.sh` - Cleans up temporary and backup files (symlinked to cleanup_temp_files.sh)
- `cleanup_temp_files.sh` - Alternate name for cleanup-temp-files.sh
- `cleanup-summary.sh` - Generates summary reports after cleanup
- `monitor-memory.sh` - Real-time memory monitoring
- `ollama-memory-monitor.sh` - Advanced Ollama memory usage monitor
- `optimize-ollama-params.sh` - Parameter optimization for different memory constraints
- `test-minimal-agent.sh` - Minimal agent for very low memory situations
- `verify-ollama.sh` - Validates Ollama installation

## Model Definitions (tools/memory/models/)

- `smart-shell-agent.Modelfile` - Full-featured smart shell agent
- `smart-shell-agent-lite.Modelfile` - Memory-efficient smart shell agent
- `minimal-shell-agent.Modelfile` - Minimal agent for very low memory
- `shell-agent.Modelfile` - Standard shell agent with alias training
- `lite-test.Modelfile` - Ultra-minimal test model
- `minimal-test.Modelfile` - Test configuration for minimal resources
- `test-model.Modelfile` - Basic test model for development

## Directory Structure

```
/home/msalsouri/Projects/DB-GPT/
├── memory-manager.sh                  # Main memory management interface
├── auto-memory-manager.sh             # Auto-select agent based on memory
├── manage-memory.sh                   # Entry point for memory management
├── agent-memory-manager.sh            # Agent-specific memory management
├── agent-memory.sh                    # Agent memory storage
├── integrated-memory-manager.sh       # Integrated memory management dashboard
├── test-memory-system.sh              # Tests all memory components
├── memory-setup.sh                    # Installation and setup script
├── tools/
│   ├── memory/                        # Memory utility scripts
│   │   ├── memory-tools-manager.sh    # Unified interface for all memory tools
│   │   ├── cleanup-ollama.sh          # Ollama cleanup utilities
│   │   ├── cleanup-temp-files.sh      # Temporary file cleanup
│   │   ├── cleanup_temp_files.sh      # Alternate name for cleanup script
│   │   ├── cleanup-summary.sh         # Summary reports after cleanup
│   │   ├── enhanced-cleanup.sh        # Find and organize duplicate files
│   │   ├── monitor-memory.sh          # Memory monitoring tools
│   │   ├── ollama-memory-monitor.sh   # Advanced Ollama memory monitoring
│   │   ├── optimize-ollama-params.sh  # Parameter optimization
│   │   ├── test-minimal-agent.sh      # Minimal agent for low memory
│   │   ├── verify-ollama.sh           # Ollama installation verification
│   │   ├── models/                    # Model definitions
│   │   │   ├── lite-test.Modelfile    # Lightweight test model
│   │   │   ├── minimal-shell-agent.Modelfile  # Minimal agent model
│   │   │   ├── minimal-test.Modelfile # Test model for minimal resources
│   │   │   ├── shell-agent.Modelfile  # Standard shell agent model
│   │   │   ├── smart-shell-agent.Modelfile    # Full-featured model
│   │   │   ├── smart-shell-agent-lite.Modelfile  # Lite agent model
│   │   │   └── test-model.Modelfile   # Test model for development
├── backup_cleanup/                    # Backup and temporary files
│   ├── shell-agent-manager.sh.bak     # Backup of shell agent manager
│   ├── agent-commands.sh.bak          # Backup of agent commands
│   ├── temp-shell-agent-manager.sh    # Temporary version of manager
```

## Backup Files

All temporary and backup files are stored in:
- `backup_cleanup/` - Main backup directory

```bash
./manage-memory.sh
```

This will provide a menu-based interface to all memory management functions.

## For Utility Scripts Only

To access only the utility scripts:

```bash
./tools/memory/memory-tools-manager.sh
```

## Advanced Usage

See `MEMORY_QUICK_GUIDE.md` for specific command examples.
