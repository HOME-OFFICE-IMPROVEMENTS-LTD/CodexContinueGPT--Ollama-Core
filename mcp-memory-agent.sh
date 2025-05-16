#!/bin/bash
# Redirect to the actual script
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
$PROJECT_ROOT/tools/ollama/mcp_memory_agent.sh "$@"
