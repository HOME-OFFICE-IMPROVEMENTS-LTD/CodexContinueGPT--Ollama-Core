#!/bin/bash
# Script to update .gitignore and stage important files

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}====================================${NC}"
echo -e "${CYAN}   DB-GPT Git Cleanup   ${NC}"
echo -e "${CYAN}====================================${NC}"
echo ""

# Change to the repository directory
cd "$(dirname "$0")" || exit

# 1. Files that should be committed - important for the project
echo -e "${GREEN}Staging important files for commit...${NC}"
git add \
  build-shell-agent.sh \
  cleanup_docs.sh \
  cleanup_git.sh \
  dbgpt-shell-agent.sh \
  docs_manager.sh \
  docker-compose-ollama.yml \
  docker-compose.deepseek.yml \
  docker/cc-ollama/Dockerfile \
  docker/cc-ollama/Dockerfile.shell-agent \
  docker/cc-ollama/docker-compose.shell-agent.yml \
  docs/ollama_shell_guidance.md \
  docs/wiki/AGENT_MEMORY_GUIDE.md \
  docs/wiki/ALIASES.md \
  docs/wiki/ALIASES_README.md \
  docs/wiki/BENCHMARK_TOOL.md \
  docs/wiki/CONTRIBUTING.md \
  docs/wiki/DISCKAIMER.md \
  docs/wiki/Documentation-Index.md \
  docs/wiki/ENHANCED_MCP_OLLAMA.md \
  docs/wiki/ENHANCED_SHELL_AGENT.md \
  docs/wiki/MCP_MEMORY_AGENT.md \
  docs/wiki/MCP_OLLAMA.md \
  docs/wiki/OLLAMA_ENHANCEMENTS.md \
  docs/wiki/OLLAMA_INDEX.md \
  docs/wiki/OLLAMA_INTEGRATION.md \
  docs/wiki/OLLAMA_STATUS.md \
  docs/wiki/Ollama-Index.md \
  docs/wiki/Ollama-Integration.md \
  docs/wiki/SECURITY.md \
  docs/wiki/TODAY_ENHANCEMENTS.md \
  enhanced-shell-agent.sh \
  launch-shell-agent.sh \
  mcp-memory-agent.sh \
  organize_docs.sh \
  run-shell-agent.sh \
  run_dbgpt_docker.sh \
  shell-agent.Modelfile \
  start_dbgpt.sh \
  tools/ollama/README_UPDATED.md \
  tools/ollama/benchmark_mcp_models.py \
  tools/ollama/benchmark_mcp_server.sh \
  tools/ollama/download_docs.sh \
  tools/ollama/mcp_ollama_server.py \
  tools/ollama/mcp_ollama_server_enhanced.py \
  tools/ollama/start_enhanced_mcp_server.sh \
  tools/ollama/start_mcp_server.sh \
  tools/ollama/test_enhanced_mcp_server.py \
  tools/ollama/test_mcp_server.py \
  .aliases

# 2. Update .gitignore with patterns for files that should be ignored
echo -e "${YELLOW}Updating .gitignore file...${NC}"
echo "" >> .gitignore
echo "# Added automatically on $(date)" >> .gitignore
echo "*.bak" >> .gitignore
echo "auto-commit.sh" >> .gitignore
echo "analyze_untracked.sh" >> .gitignore
echo ".vscode-ctags" >> .gitignore
echo "**/backup_scripts_*/" >> .gitignore

# 3. Commit the updated .gitignore
echo -e "${BLUE}Committing updated .gitignore...${NC}"
git add .gitignore
git commit -m "Update .gitignore with patterns for backup and temporary files"

# 4. Commit the remaining important files
echo -e "${GREEN}Committing staged important files...${NC}"
git commit -m "Organize documentation and update scripts

This commit includes:
- Shell agent scripts and configurations
- Docker configurations for Ollama integration
- Documentation moved to docs/wiki directory
- Documentation management scripts (organize_docs.sh, cleanup_docs.sh, docs_manager.sh)
- Updated guides and documentation for Model Context Protocol server"

echo -e "${GREEN}All files processed. The source control count should be reduced now.${NC}"
echo -e "${YELLOW}Remember to push your changes to the remote repository.${NC}"
