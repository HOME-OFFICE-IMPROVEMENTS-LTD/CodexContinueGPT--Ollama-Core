#!/usr/bin/env python3
"""
MCP Server for Ollama integration with DB-GPT
"""
import json
import logging
import os
import time
import asyncio
from typing import Dict, List, Optional, Union, Generator, AsyncGenerator

import requests
from fastapi import FastAPI, HTTPException, Request, Response
from fastapi.responses import JSONResponse, StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
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
DEFAULT_TIMEOUT = int(os.environ.get("OLLAMA_TIMEOUT", "60"))  # 60 seconds default timeout

# FastAPI app
app = FastAPI(title="MCP Ollama Server", version="1.0.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods
    allow_headers=["*"],  # Allow all headers
)

# Custom exception handlers
@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    """Custom handler for HTTPException"""
    logger.error(f"HTTP error: {exc.status_code} - {exc.detail}")
    return JSONResponse(
        status_code=exc.status_code,
        content={"error": {"message": exc.detail, "type": "http_error"}}
    )

@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    """Custom handler for general exceptions"""
    logger.error(f"General error: {str(exc)}")
    return JSONResponse(
        status_code=500,
        content={"error": {"message": str(exc), "type": "server_error"}}
    )

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
    return {
        "status": "ok", 
        "message": "MCP Ollama Server is running",
        "version": "1.0.0",
        "docs_url": "/docs",
    }


@app.get("/v1/health")
async def health_check():
    """Health check endpoint"""
    try:
        # Check if Ollama is responsive
        start_time = time.time()
        response = requests.get(f"{OLLAMA_API_BASE}/api/version", timeout=5)
        response_time = time.time() - start_time
        
        if response.status_code == 200:
            ollama_version = response.json().get("version", "unknown")
            return {
                "status": "healthy", 
                "ollama_version": ollama_version,
                "response_time": f"{response_time:.3f}s",
                "api_base": OLLAMA_API_BASE,
                "server_time": time.strftime("%Y-%m-%d %H:%M:%S"),
            }
        return {
            "status": "degraded", 
            "reason": f"Ollama API returned status code {response.status_code}",
            "response_time": f"{response_time:.3f}s",
            "api_base": OLLAMA_API_BASE,
        }
    except requests.exceptions.ConnectionError:
        return {
            "status": "unhealthy", 
            "reason": f"Cannot connect to Ollama at {OLLAMA_API_BASE}",
            "api_base": OLLAMA_API_BASE,
        }
    except requests.exceptions.Timeout:
        return {
            "status": "unhealthy", 
            "reason": f"Timeout connecting to Ollama at {OLLAMA_API_BASE}",
            "api_base": OLLAMA_API_BASE,
        }
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}")
        return {
            "status": "unhealthy", 
            "reason": str(e),
            "api_base": OLLAMA_API_BASE,
        }


@app.get("/v1/system")
async def system_info():
    """System information endpoint"""
    try:
        # Get available models
        models_response = requests.get(f"{OLLAMA_API_BASE}/api/tags", timeout=5)
        models = []
        if models_response.status_code == 200:
            models = [model.get("name") for model in models_response.json().get("models", [])]
        
        # Basic system information
        return {
            "server": {
                "version": "1.0.0",
                "start_time": time.strftime("%Y-%m-%d %H:%M:%S"),
                "api_base": OLLAMA_API_BASE,
                "default_model": DEFAULT_MODEL,
            },
            "ollama": {
                "available": models_response.status_code == 200,
                "models": models,
                "count": len(models),
            },
            "environment": {
                "host": os.environ.get("HOST", "0.0.0.0"),
                "port": os.environ.get("PORT", "8000"),
            }
        }
    except Exception as e:
        logger.error(f"Error retrieving system info: {str(e)}")
        return {
            "error": str(e),
            "server_version": "1.0.0",
        }


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


async def stream_completion_generator(request: CompletionRequest) -> AsyncGenerator[str, None]:
    """Generator for streaming completion responses"""
    try:
        # Map to Ollama API
        ollama_request = {
            "model": request.model,
            "prompt": request.prompt,
            "stream": True,
            "options": request.options or {},
        }

        if request.temperature is not None:
            ollama_request["options"]["temperature"] = request.temperature
        if request.max_tokens is not None:
            ollama_request["options"]["num_predict"] = request.max_tokens
        if request.context is not None:
            ollama_request["context"] = request.context

        logger.info(f"Starting streaming completion with Ollama: {request.model}")
        
        with requests.post(
            f"{OLLAMA_API_BASE}/api/generate",
            json=ollama_request,
            stream=True,
            timeout=DEFAULT_TIMEOUT
        ) as response:
            if response.status_code != 200:
                error_detail = response.text
                logger.error(f"Ollama API error: {error_detail}")
                error_json = json.dumps({"error": {"message": error_detail}})
                yield f"data: {error_json}\n\n"
                return
                
            # Variables to track progress
            completion_text = ""
            done = False
            
            for line in response.iter_lines():
                if not line:
                    continue
                    
                try:
                    chunk = json.loads(line)
                    piece = chunk.get("response", "")
                    completion_text += piece
                    done = chunk.get("done", False)
                    
                    # Format in the expected event stream format
                    response_json = {
                        "id": f"cmpl-{int(time.time())}",
                        "object": "text_completion.chunk",
                        "created": int(time.time()),
                        "model": request.model,
                        "choices": [
                            {
                                "text": piece,
                                "index": 0,
                                "finish_reason": None if not done else "stop",
                            }
                        ]
                    }
                    
                    yield f"data: {json.dumps(response_json)}\n\n"
                    
                    if done:
                        # Send the final [DONE] marker
                        yield "data: [DONE]\n\n"
                        break
                        
                except json.JSONDecodeError as e:
                    logger.error(f"Error parsing chunk: {e}")
                    continue
                    
    except Exception as e:
        logger.error(f"Streaming error: {str(e)}")
        error_json = json.dumps({"error": {"message": str(e)}})
        yield f"data: {error_json}\n\n"
        yield "data: [DONE]\n\n"


@app.post("/v1/completions")
async def create_completion(request: CompletionRequest, raw_request: Request):
    """Create a completion"""
    # Handle streaming request
    if request.stream:
        return StreamingResponse(
            stream_completion_generator(request),
            media_type="text/event-stream"
        )
        
    # Non-streaming request
    try:
        # Map to Ollama API
        ollama_request = {
            "model": request.model,
            "prompt": request.prompt,
            "stream": False,
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


async def stream_chat_completion_generator(request: ChatRequest) -> AsyncGenerator[str, None]:
    """Generator for streaming chat completion responses"""
    try:
        # Convert chat messages to prompt
        messages_text = "\n".join([
            f"{msg.role}: {msg.content}" for msg in request.messages
        ])
        
        # Map to Ollama API
        ollama_request = {
            "model": request.model,
            "prompt": messages_text,
            "stream": True,
            "options": request.options or {},
        }

        if request.temperature is not None:
            ollama_request["options"]["temperature"] = request.temperature
        if request.max_tokens is not None:
            ollama_request["options"]["num_predict"] = request.max_tokens
        if request.context is not None:
            ollama_request["context"] = request.context

        logger.info(f"Starting streaming chat completion with Ollama: {request.model}")
        
        with requests.post(
            f"{OLLAMA_API_BASE}/api/generate",
            json=ollama_request,
            stream=True,
            timeout=DEFAULT_TIMEOUT
        ) as response:
            if response.status_code != 200:
                error_detail = response.text
                logger.error(f"Ollama API error: {error_detail}")
                error_json = json.dumps({"error": {"message": error_detail}})
                yield f"data: {error_json}\n\n"
                return
                
            # Variables to track progress
            completion_text = ""
            done = False
            
            for line in response.iter_lines():
                if not line:
                    continue
                    
                try:
                    chunk = json.loads(line)
                    piece = chunk.get("response", "")
                    completion_text += piece
                    done = chunk.get("done", False)
                    
                    # Format in the expected event stream format
                    response_json = {
                        "id": f"chatcmpl-{int(time.time())}",
                        "object": "chat.completion.chunk",
                        "created": int(time.time()),
                        "model": request.model,
                        "choices": [
                            {
                                "index": 0,
                                "delta": {
                                    "role": "assistant" if not completion_text else "",
                                    "content": piece
                                },
                                "finish_reason": None if not done else "stop",
                            }
                        ]
                    }
                    
                    yield f"data: {json.dumps(response_json)}\n\n"
                    
                    if done:
                        # Send the final [DONE] marker
                        yield "data: [DONE]\n\n"
                        break
                        
                except json.JSONDecodeError as e:
                    logger.error(f"Error parsing chunk: {e}")
                    continue
                    
    except Exception as e:
        logger.error(f"Streaming error: {str(e)}")
        error_json = json.dumps({"error": {"message": str(e)}})
        yield f"data: {error_json}\n\n"
        yield "data: [DONE]\n\n"


@app.post("/v1/chat/completions")
async def create_chat_completion(request: ChatRequest, raw_request: Request):
    """Create a chat completion"""
    # Handle streaming request
    if request.stream:
        return StreamingResponse(
            stream_chat_completion_generator(request),
            media_type="text/event-stream"
        )
    
    try:
        # Convert chat messages to prompt
        messages_text = "\n".join([
            f"{msg.role}: {msg.content}" for msg in request.messages
        ])
        
        # Map to Ollama API
        ollama_request = {
            "model": request.model,
            "prompt": messages_text,
            "stream": False,
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
    
    # Verify Ollama is running before starting
    try:
        response = requests.get(f"{OLLAMA_API_BASE}/api/version", timeout=5)
        if response.status_code == 200:
            ollama_version = response.json().get("version", "unknown")
            logger.info(f"✅ Connected to Ollama version {ollama_version} at {OLLAMA_API_BASE}")
        else:
            logger.warning(f"⚠️ Ollama is not responding correctly at {OLLAMA_API_BASE}")
            logger.warning("  Server will start, but API calls may fail")
    except Exception as e:
        logger.warning(f"⚠️ Could not connect to Ollama at {OLLAMA_API_BASE}: {str(e)}")
        logger.warning("  Server will start, but API calls may fail")
        logger.warning("  Make sure Ollama is running with: ollama serve")

    # Log server startup with info header
    logger.info(f"┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    logger.info(f"┃ 🚀 Starting MCP Ollama Server v1.0.0")
    logger.info(f"┃ 📡 API available at http://{host}:{port}/v1")
    logger.info(f"┃ 📚 Default model: {DEFAULT_MODEL}")
    logger.info(f"┃ 📘 Documentation: http://{host}:{port}/docs")
    logger.info(f"┃ 🏥 Health check: http://{host}:{port}/v1/health")
    logger.info(f"┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    
    # Run the server
    uvicorn.run(app, host=host, port=port)
