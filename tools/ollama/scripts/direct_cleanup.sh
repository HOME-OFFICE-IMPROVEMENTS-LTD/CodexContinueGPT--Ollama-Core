#!/bin/bash
# Direct cleanup script for duplicate and unused files

PROJECT_ROOT="/home/msalsouri/Projects/DB-GPT"
BACKUP_DIR="/tmp/dbgpt_cleanup_$(date +%Y%m%d%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "DB-GPT Repository Cleanup"
echo "Backing up removed files to $BACKUP_DIR"

# 1. Remove duplicate model files (keep only in tools/memory/models/)
MODEL_FILES=(
  "lite-test.Modelfile"
  "minimal-test.Modelfile"
  "minimal-shell-agent.Modelfile"
  "shell-agent.Modelfile"
  "smart-shell-agent.Modelfile"
  "smart-shell-agent-lite.Modelfile"
  "test-model.Modelfile"
)

for model in "${MODEL_FILES[@]}"; do
  if [ -f "$PROJECT_ROOT/$model" ]; then
    echo "Moving $model from root to backup"
    mv "$PROJECT_ROOT/$model" "$BACKUP_DIR/"
  fi
done

# 2. Remove duplicate script files (keep only in tools/memory/)
SCRIPT_FILES=(
  "cleanup-ollama.sh"
  "monitor-memory.sh"
  "optimize-ollama-params.sh"
  "test-minimal-agent.sh"
  "verify-ollama.sh"
)

for script in "${SCRIPT_FILES[@]}"; do
  if [ -f "$PROJECT_ROOT/$script" ]; then
    echo "Moving $script from root to backup"
    mv "$PROJECT_ROOT/$script" "$BACKUP_DIR/"
  fi
done

# 3. Remove temporary files and redundant backups
TEMP_FILES=(
  "temp-shell-agent-manager.sh"
  "DUPLICATE_FILES_REPORT.md"
)

for temp in "${TEMP_FILES[@]}"; do
  if [ -f "$PROJECT_ROOT/$temp" ]; then
    echo "Moving temporary file $temp to backup"
    mv "$PROJECT_ROOT/$temp" "$BACKUP_DIR/"
  fi
done

# 4. Clean up backup_cleanup directory
if [ -d "$PROJECT_ROOT/backup_cleanup" ]; then
  echo "Moving backup_cleanup directory contents to backup"
  cp -r "$PROJECT_ROOT/backup_cleanup" "$BACKUP_DIR/"
  rm -rf "$PROJECT_ROOT/backup_cleanup"/*
  # Just keep an empty directory for future use
  mkdir -p "$PROJECT_ROOT/backup_cleanup"
fi

echo "Repository cleanup completed successfully"
echo "Removed files backed up to: $BACKUP_DIR"
