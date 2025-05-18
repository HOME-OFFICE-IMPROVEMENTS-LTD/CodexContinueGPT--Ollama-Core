# CodexContinueGPT File Organization Plan

## Overview

This plan outlines the steps to organize CodexContinueGPT-related files and documentation
in a more structured and maintainable way.

## Organization Structure

1. **Documentation Files**
   - `/docs/ollama/` - All Ollama and MCP documentation
   - `/docs/shell-agent/` - Shell agent documentation

2. **Script Files**
   - `/docker/cc-ollama/` - CodexContinueGPT scripts and Ollama integration
   - Root directory - Only essential launcher scripts

## Implementation Steps

### Step 1: Prepare Directories

```bash
# Create necessary directories if they don't exist
mkdir -p /home/msalsouri/Projects/DB-GPT/docs/ollama
mkdir -p /home/msalsouri/Projects/DB-GPT/docs/shell-agent
```

### Step 2: Organize Documentation Files

Use the cc-advisor.sh script's new organize-docs function:

```bash
# Organize documentation with CC-GPT assistance
./cc-advisor.sh organize-docs
```

This will:
- Move all OLLAMA_*.md files to docs/ollama/
- Move all MCP_*.md files to docs/ollama/
- Move shell agent documentation to docs/shell-agent/

### Step 3: Organize Script Files

Use the cc-advisor.sh script's new organize-scripts function:

```bash
# Organize scripts with CC-GPT assistance
./cc-advisor.sh organize-scripts
```

This will move test scripts and related tools to appropriate locations.

### Step 4: Update References

1. Check for and update any references to moved files:

```bash
# Ask CC-GPT to help identify references
./cc-advisor.sh ask "Now that we've moved files, what references need to be updated?"
```

2. Update readme files and documentation to reflect new organization

### Step 5: Verify Organization

```bash
# Verify organization was successful
./cc-advisor.sh verify "Have we properly organized all CodexContinueGPT related files and documentation?"
```

## Safety Measures

- The cc-advisor.sh script creates backups before any file operations
- Bulk moves are backed up in time-stamped directories in backup_cleanup/
- All operations require confirmation before proceeding

## Future Maintenance

- Use the cc-advisor.sh script for all future file operations
- Before creating new files, consult CC-GPT on their proper location
- Update documentation to reflect any organization changes
