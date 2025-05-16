#!/usr/bin/env bash
# Documentation Downloader for DB-GPT
# This script downloads all necessary documentation for offline reference

set -e

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR" && pwd)"
DOCS_DIR="$PROJECT_ROOT/docs"
DOWNLOAD_DIR="$PROJECT_ROOT/docs/references"

# Create download directory if it doesn't exist
mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$DOWNLOAD_DIR/ollama"
mkdir -p "$DOWNLOAD_DIR/models"

echo -e "${CYAN}Starting documentation download for DB-GPT Ollama integration...${NC}"

# Function to download with progress
download_with_progress() {
  local url="$1"
  local output="$2"
  echo -e "${YELLOW}Downloading: ${url}${NC}"
  curl -# -L "$url" -o "$output"
  echo -e "${GREEN}Downloaded: ${output}${NC}"
}

# Download Ollama documentation
echo -e "\n${CYAN}Downloading Ollama Documentation...${NC}"
download_with_progress "https://raw.githubusercontent.com/ollama/ollama/main/README.md" "$DOWNLOAD_DIR/ollama/README.md"
download_with_progress "https://raw.githubusercontent.com/ollama/ollama/main/docs/api.md" "$DOWNLOAD_DIR/ollama/api.md"
download_with_progress "https://raw.githubusercontent.com/ollama/ollama/main/docs/modelfile.md" "$DOWNLOAD_DIR/ollama/modelfile.md"

# Download CodeLlama information
echo -e "\n${CYAN}Downloading CodeLlama information...${NC}"
download_with_progress "https://raw.githubusercontent.com/facebookresearch/codellama/main/README.md" "$DOWNLOAD_DIR/models/codellama_README.md"

# Download Llama3 information
echo -e "\n${CYAN}Downloading Llama3 information...${NC}"
download_with_progress "https://raw.githubusercontent.com/meta-llama/llama3/main/README.md" "$DOWNLOAD_DIR/models/llama3_README.md"

# Generate summary of downloaded documentation
echo -e "\n${CYAN}Generating documentation summary...${NC}"
{
  echo "# DB-GPT Ollama Integration Documentation"
  echo ""
  echo "This directory contains reference documentation for DB-GPT Ollama integration."
  echo ""
  echo "## Contents"
  echo ""
  echo "### Ollama"
  echo "- [README.md](ollama/README.md) - General Ollama documentation"
  echo "- [api.md](ollama/api.md) - Ollama API reference"
  echo "- [modelfile.md](ollama/modelfile.md) - Modelfile documentation"
  echo ""
  echo "### Models"
  echo "- [codellama_README.md](models/codellama_README.md) - CodeLlama model information"
  echo "- [llama3_README.md](models/llama3_README.md) - Llama3 model information"
  echo ""
  echo "## Local DB-GPT Documentation"
  echo "- [OLLAMA_INTEGRATION.md](../../OLLAMA_INTEGRATION.md) - DB-GPT Ollama integration guide"
  echo "- [ALIASES_README.md](../../ALIASES_README.md) - Shell aliases documentation"
  echo ""
  echo "Documentation downloaded on: $(date)"
} > "$DOWNLOAD_DIR/index.md"

# Calculate total size
TOTAL_SIZE=$(du -sh "$DOWNLOAD_DIR" | cut -f1)

echo -e "\n${GREEN}Documentation download complete!${NC}"
echo -e "Total documentation size: ${YELLOW}${TOTAL_SIZE}${NC}"
echo -e "Documentation available at: ${CYAN}${DOWNLOAD_DIR}${NC}"
echo -e "Summary file: ${CYAN}${DOWNLOAD_DIR}/index.md${NC}"
