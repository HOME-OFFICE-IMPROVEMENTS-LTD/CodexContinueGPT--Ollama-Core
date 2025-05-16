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
