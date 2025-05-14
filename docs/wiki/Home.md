# CodexContinueGPT™ Wiki Home

Welcome to the CodexContinueGPT™ Wiki! This wiki contains documentation for the project, which is a specialized fork of DB-GPT with Ollama integration for shell command guidance.

## Project Structure

The project is organized as follows:

### Core Components

- `/tools/ollama/` - Contains all Ollama integration tools and scripts
  - `ollama_manager.sh` - Script to manage Ollama models
  - `shell_helper.sh` - Script for shell command guidance
  - `ask.sh` - Script for direct model interaction
  - `fix_paths.sh` - Utility to fix hardcoded paths

### Documentation

- `/docs/wiki/` - Wiki documentation
  - `Home.md` - This wiki home page
  - `Ollama-Integration.md` - Documentation for Ollama integration
  - `Aliases.md` - Documentation for project aliases

### Configuration

- `/configs/dbgpt-proxy-ollama.toml` - Ollama proxy configuration for DB-GPT

## Quick Start

1. **Set up your environment**:
   ```bash
   cd /path/to/CodexContinueGPT
   source .aliases
   ```

2. **Check available Ollama models**:
   ```bash
   tools/ollama/ollama_manager.sh list
   ```

3. **Ask a question using the default model**:
   ```bash
   tools/ollama/ask.sh "How do I find large files in Linux?"
   ```

4. **Start CodexContinueGPT™ with Ollama integration**:
   ```bash
   tools/ollama/ollama_manager.sh start
   ```

See the specific documentation pages for more details on each component.

## Resources

- [Ollama Integration Guide](Ollama-Integration.md)
- [Project Aliases Documentation](Aliases.md)
- [Original DB-GPT Documentation](https://docs.dbgpt.site)
