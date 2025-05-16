# Model Context Protocol (MCP) Implementation for DB-GPT Ollama Integration

This document describes how to implement the Model Context Protocol (MCP) with the DB-GPT Ollama Integration.

## Overview

The Model Context Protocol (MCP) is a standardized way of interacting with language models, making it easier to swap between different models and providers. This implementation shows how to connect the DB-GPT platform with locally-hosted Ollama models using MCP.

## Prerequisites

1. DB-GPT installed and configured
2. Ollama installed and running (`ollama serve`)
3. Required models pulled (e.g., `ollama pull codellama`)

## Implementation Steps

### 1. Create MCP Server Configuration

Create a new file `mcp_ollama_server.py` in your project:

```python
#!/usr/bin/env python3
"""
MCP Server for Ollama integration with DB-GPT
"""
import json
import logging
import os
from typing import Dict, List, Optional, Union

import requests
from fastapi import FastAPI, HTTPException, Request
from pydantic import BaseModel, Field

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger("mcp-ollama")

# Constants
OLLAMA_API_BASE = os.environ.get("OLLAMA_API_BASE", "http://localhost:11434")
DEFAULT_MODEL = os.environ.get("OLLAMA_MODEL", "codellama")

# FastAPI app
app = FastAPI(title="MCP Ollama Server", version="1.0.0")


class CompletionRequest(BaseModel):
    """Request model for completions endpoint"""
    prompt: str
    model: Optional[str] = Field(default=DEFAULT_MODEL)
    stream: Optional[bool] = Field(default=False)
    options: Optional[Dict] = Field(default_factory=dict)
    temperature: Optional[float] = None
    max_tokens: Optional[int] = None
    context: Optional[List[int]] = None


class ChatMessage(BaseModel):
    """Chat message model"""
    role: str
    content: str


class ChatRequest(BaseModel):
    """Request model for chat endpoint"""
    messages: List[ChatMessage]
    model: Optional[str] = Field(default=DEFAULT_MODEL)
    stream: Optional[bool] = Field(default=False)
    options: Optional[Dict] = Field(default_factory=dict)
    temperature: Optional[float] = None
    max_tokens: Optional[int] = None
    context: Optional[List[int]] = None


class EmbeddingRequest(BaseModel):
    """Request model for embeddings endpoint"""
    input: Union[str, List[str]]
    model: Optional[str] = Field(default="bge-m3")


@app.get("/")
async def root():
    """Root endpoint"""
    return {"status": "ok", "message": "MCP Ollama Server is running"}


@app.get("/v1/models")
async def list_models():
    """List available models"""
    try:
        response = requests.get(f"{OLLAMA_API_BASE}/api/tags")
        if response.status_code == 200:
            models = response.json().get("models", [])
            return {
                "object": "list",
                "data": [
                    {
                        "id": model.get("name"),
                        "object": "model",
                        "created": 0,
                        "owned_by": "ollama",
                    }
                    for model in models
                ],
            }
        else:
            raise HTTPException(status_code=response.status_code, detail=response.text)
    except Exception as e:
        logger.error(f"Error listing models: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/v1/completions")
async def create_completion(request: CompletionRequest, raw_request: Request):
    """Create a completion"""
    try:
        # Map to Ollama API
        ollama_request = {
            "model": request.model,
            "prompt": request.prompt,
            "stream": request.stream,
            "options": request.options or {},
        }

        if request.temperature is not None:
            ollama_request["options"]["temperature"] = request.temperature
        if request.max_tokens is not None:
            ollama_request["options"]["num_predict"] = request.max_tokens
        if request.context is not None:
            ollama_request["context"] = request.context

        logger.info(f"Sending completion request to Ollama: {ollama_request}")
        response = requests.post(
            f"{OLLAMA_API_BASE}/api/generate",
            json=ollama_request,
        )

        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail=response.text)

        result = response.json()
        
        return {
            "id": "cmpl-ollama",
            "object": "text_completion",
            "created": 0,
            "model": request.model,
            "choices": [
                {
                    "text": result.get("response", ""),
                    "index": 0,
                    "finish_reason": result.get("done", True) and "stop" or "length",
                }
            ],
            "usage": {
                "prompt_tokens": result.get("prompt_eval_count", 0),
                "completion_tokens": result.get("eval_count", 0),
                "total_tokens": (
                    result.get("prompt_eval_count", 0) + result.get("eval_count", 0)
                ),
            },
        }

    except Exception as e:
        logger.error(f"Error creating completion: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/v1/chat/completions")
async def create_chat_completion(request: ChatRequest, raw_request: Request):
    """Create a chat completion"""
    try:
        # Convert chat messages to prompt
        messages_text = "\n".join([
            f"{msg.role}: {msg.content}" for msg in request.messages
        ])
        
        # Map to Ollama API
        ollama_request = {
            "model": request.model,
            "prompt": messages_text,
            "stream": request.stream,
            "options": request.options or {},
        }

        if request.temperature is not None:
            ollama_request["options"]["temperature"] = request.temperature
        if request.max_tokens is not None:
            ollama_request["options"]["num_predict"] = request.max_tokens
        if request.context is not None:
            ollama_request["context"] = request.context

        logger.info(f"Sending chat completion request to Ollama: {ollama_request}")
        response = requests.post(
            f"{OLLAMA_API_BASE}/api/generate",
            json=ollama_request,
        )

        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail=response.text)

        result = response.json()
        
        return {
            "id": "chatcmpl-ollama",
            "object": "chat.completion",
            "created": 0,
            "model": request.model,
            "choices": [
                {
                    "index": 0,
                    "message": {
                        "role": "assistant",
                        "content": result.get("response", ""),
                    },
                    "finish_reason": result.get("done", True) and "stop" or "length",
                }
            ],
            "usage": {
                "prompt_tokens": result.get("prompt_eval_count", 0),
                "completion_tokens": result.get("eval_count", 0),
                "total_tokens": (
                    result.get("prompt_eval_count", 0) + result.get("eval_count", 0)
                ),
            },
        }

    except Exception as e:
        logger.error(f"Error creating chat completion: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/v1/embeddings")
async def create_embeddings(request: EmbeddingRequest):
    """Create embeddings"""
    try:
        inputs = request.input if isinstance(request.input, list) else [request.input]
        
        all_embeddings = []
        for text in inputs:
            ollama_request = {
                "model": request.model,
                "prompt": text,
            }
            
            logger.info(f"Sending embedding request to Ollama: {ollama_request}")
            response = requests.post(
                f"{OLLAMA_API_BASE}/api/embeddings",
                json=ollama_request,
            )

            if response.status_code != 200:
                raise HTTPException(status_code=response.status_code, detail=response.text)

            result = response.json()
            all_embeddings.append(result.get("embedding", []))
        
        return {
            "object": "list",
            "data": [
                {
                    "object": "embedding",
                    "embedding": embedding,
                    "index": i,
                }
                for i, embedding in enumerate(all_embeddings)
            ],
            "model": request.model,
            "usage": {
                "prompt_tokens": sum(len(text.split()) for text in inputs),
                "total_tokens": sum(len(text.split()) for text in inputs),
            }
        }

    except Exception as e:
        logger.error(f"Error creating embeddings: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", "8000"))
    host = os.environ.get("HOST", "0.0.0.0")
    uvicorn.run(app, host=host, port=port)
```

### 2. Create a Shell Script to Start the MCP Server

Create a shell script `start_mcp_server.sh` to easily start the MCP server:

```bash
#!/bin/bash
# Start the MCP Ollama server

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

# Default settings
HOST="0.0.0.0"
PORT="8000"
MODEL="codellama"
OLLAMA_API_BASE="http://localhost:11434"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --port)
      PORT="$2"
      shift 2
      ;;
    --model)
      MODEL="$2"
      shift 2
      ;;
    --host)
      HOST="$2"
      shift 2
      ;;
    --ollama-api)
      OLLAMA_API_BASE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Check if Ollama is running
if ! curl -s "$OLLAMA_API_BASE/api/version" > /dev/null; then
  echo -e "${YELLOW}Warning: Ollama server doesn't seem to be running at $OLLAMA_API_BASE${NC}"
  echo -e "Start it with: ${CYAN}ollama serve${NC}"
  echo ""
  read -p "Would you like to try starting ollama now? (y/n): " yn
  case $yn in
      [Yy]* ) ollama serve & ;;
      * ) echo "Please start ollama before continuing"; exit 1 ;;
  esac
fi

# Check if model is available
if ! ollama list | grep -q "$MODEL"; then
  echo -e "${YELLOW}Model '$MODEL' is not available. Do you want to pull it now?${NC}"
  read -p "Pull model $MODEL? (y/n): " yn
  case $yn in
      [Yy]* )
        echo -e "${CYAN}Pulling model $MODEL...${NC}"
        ollama pull "$MODEL" 
        ;;
      * ) 
        echo "Using default model instead"
        ;;
  esac
fi

# Start the MCP server
echo -e "${GREEN}Starting MCP Ollama server on $HOST:$PORT with model $MODEL${NC}"
echo -e "${CYAN}API endpoint will be available at http://$HOST:$PORT/v1${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}"

# Export environment variables
export OLLAMA_API_BASE="$OLLAMA_API_BASE"
export OLLAMA_MODEL="$MODEL"
export HOST="$HOST"
export PORT="$PORT"

# Run the server
python3 "$REPO_ROOT/tools/ollama/mcp_ollama_server.py"
```

### 3. Update DB-GPT Configuration

Create a new configuration file `dbgpt-proxy-ollama-mcp.toml`:

```toml
[system]
language = "${env:DBGPT_LANG:-en}"
api_keys = []
encrypt_key = "your_secret_key"

# Server Configurations
[service.web]
host = "0.0.0.0"
port = 5670

[service.web.database]
type = "sqlite"
path = "pilot/meta_data/dbgpt.db"

[rag.storage]
[rag.storage.vector]
type = "chroma"
persist_path = "pilot/data"

# Model Configurations
[models]
[[models.llms]]
name = "ollama-mcp"
provider = "openai"
api_base = "http://localhost:8000/v1"
api_key = "not-needed"

[[models.embeddings]]
name = "ollama-embeddings"
provider = "openai"
api_base = "http://localhost:8000/v1"
api_key = "not-needed"
model_name = "bge-m3"
```

## Usage

### Using Aliases (Recommended)

If you've sourced the project's `.aliases` file:

1. **Start the MCP Ollama server**:
   ```bash
   mcp-start-codellama
   ```
   
2. **In a new terminal, start DB-GPT with the MCP configuration**:
   ```bash
   mcp-dbgpt
   ```

### Manual Method

1. **Start the MCP Ollama server**:
   ```bash
   cd /path/to/DB-GPT
   ./tools/ollama/start_mcp_server.sh --model codellama --port 8000
   ```

2. **Start DB-GPT with the MCP configuration**:
   ```bash
   cd /path/to/DB-GPT
   uv run dbgpt start webserver --config configs/dbgpt-proxy-ollama-mcp.toml
   ```

3. **Access the DB-GPT web interface**:
   Open your browser and navigate to `http://localhost:5670`

## Testing

To test the MCP server directly:

```bash
# Test the models endpoint
curl http://localhost:8000/v1/models

# Test completion
curl -X POST http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Write a Python function to calculate factorial", "model": "codellama"}'

# Test chat completion
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages": [{"role": "user", "content": "What is the capital of France?"}], "model": "codellama"}'
```

## Troubleshooting

1. **Connection Issues**:
   - Ensure Ollama is running (`ollama serve`)
   - Check the OLLAMA_API_BASE URL is correct
   - Verify network connectivity between DB-GPT and Ollama

2. **Model Issues**:
   - Make sure the model is pulled (`ollama pull codellama`)
   - Check model name spelling in config files
   - Try different models if one is having issues

3. **Performance Issues**:
   - For large requests, increase timeout settings
   - Consider using a more powerful machine for running Ollama
   - Reduce max_tokens if responses take too long
