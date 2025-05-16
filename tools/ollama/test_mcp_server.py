#!/usr/bin/env python3
"""
Test script for MCP Ollama Server
"""
import argparse
import json
import sys
from typing import Dict, Any, Optional

import requests

def print_color(text: str, color: str = "white") -> None:
    """Print colored text to console"""
    colors = {
        "red": "\033[91m",
        "green": "\033[92m",
        "yellow": "\033[93m",
        "blue": "\033[94m",
        "magenta": "\033[95m",
        "cyan": "\033[96m",
        "white": "\033[97m",
        "reset": "\033[0m"
    }
    print(f"{colors.get(color, colors['white'])}{text}{colors['reset']}")

def make_request(url: str, method: str = "GET", data: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """Make HTTP request to server"""
    print_color(f"Making {method} request to {url}", "blue")
    if data:
        print_color(f"Request data: {json.dumps(data, indent=2)}", "yellow")
    
    try:
        if method.upper() == "GET":
            response = requests.get(url)
        elif method.upper() == "POST":
            response = requests.post(url, json=data)
        else:
            raise ValueError(f"Unsupported HTTP method: {method}")
        
        if response.status_code == 200:
            result = response.json()
            print_color(f"Response ({response.status_code}):", "green")
            print_color(json.dumps(result, indent=2), "white")
            return result
        else:
            print_color(f"Error ({response.status_code}): {response.text}", "red")
            return {"error": response.text}
    except Exception as e:
        print_color(f"Request failed: {str(e)}", "red")
        return {"error": str(e)}

def test_server_root(base_url: str) -> bool:
    """Test server root endpoint"""
    print_color("\n=== Testing Server Root ===", "cyan")
    result = make_request(base_url)
    return "status" in result and result["status"] == "ok"

def test_list_models(base_url: str) -> bool:
    """Test models endpoint"""
    print_color("\n=== Testing Models Endpoint ===", "cyan")
    result = make_request(f"{base_url}/v1/models")
    return "data" in result and isinstance(result["data"], list)

def test_completion(base_url: str, model: str) -> bool:
    """Test completion endpoint"""
    print_color("\n=== Testing Completion Endpoint ===", "cyan")
    data = {
        "prompt": "Write a function to calculate the factorial of a number",
        "model": model,
        "max_tokens": 100
    }
    result = make_request(f"{base_url}/v1/completions", "POST", data)
    return "choices" in result and len(result["choices"]) > 0

def test_chat_completion(base_url: str, model: str) -> bool:
    """Test chat completion endpoint"""
    print_color("\n=== Testing Chat Completion Endpoint ===", "cyan")
    data = {
        "messages": [
            {"role": "user", "content": "What is the capital of France?"}
        ],
        "model": model,
        "max_tokens": 50
    }
    result = make_request(f"{base_url}/v1/chat/completions", "POST", data)
    return "choices" in result and len(result["choices"]) > 0

def test_embeddings(base_url: str, model: str) -> bool:
    """Test embeddings endpoint"""
    print_color("\n=== Testing Embeddings Endpoint ===", "cyan")
    data = {
        "input": "This is a test sentence for embeddings.",
        "model": model
    }
    result = make_request(f"{base_url}/v1/embeddings", "POST", data)
    return "data" in result and len(result["data"]) > 0

def main() -> None:
    """Main function"""
    parser = argparse.ArgumentParser(description="Test MCP Ollama Server")
    parser.add_argument("--url", default="http://localhost:8000", help="Server base URL")
    parser.add_argument("--model", default="codellama", help="Model to use for tests")
    args = parser.parse_args()
    
    print_color(f"Testing MCP Ollama Server at {args.url}", "magenta")
    print_color(f"Using model: {args.model}", "magenta")
    
    # Run tests
    tests = [
        ("Server Root", lambda: test_server_root(args.url)),
        ("List Models", lambda: test_list_models(args.url)),
        ("Completion", lambda: test_completion(args.url, args.model)),
        ("Chat Completion", lambda: test_chat_completion(args.url, args.model)),
        ("Embeddings", lambda: test_embeddings(args.url, args.model))
    ]
    
    results = []
    for name, test_func in tests:
        print_color(f"\nRunning test: {name}", "magenta")
        try:
            success = test_func()
            results.append((name, success))
            status = "PASSED" if success else "FAILED"
            color = "green" if success else "red"
            print_color(f"Test {name}: {status}", color)
        except Exception as e:
            results.append((name, False))
            print_color(f"Test {name}: ERROR - {str(e)}", "red")
    
    # Print summary
    print_color("\n=== Test Summary ===", "magenta")
    passed = sum(1 for _, success in results if success)
    print_color(f"Passed: {passed}/{len(results)}", "green" if passed == len(results) else "red")
    
    for name, success in results:
        status = "PASSED" if success else "FAILED"
        color = "green" if success else "red"
        print_color(f"  {name}: {status}", color)
    
    # Exit with proper code
    sys.exit(0 if passed == len(results) else 1)

if __name__ == "__main__":
    main()
