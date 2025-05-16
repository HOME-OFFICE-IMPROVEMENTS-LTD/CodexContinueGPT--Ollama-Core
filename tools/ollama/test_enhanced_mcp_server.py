#!/usr/bin/env python3
"""
Test script for Enhanced MCP Ollama Server
This script tests the new features of the enhanced MCP server, particularly streaming
"""
import json
import os
import requests
import sys
import time
from typing import Dict, List, Optional, Union

# Configuration
API_BASE = os.environ.get("API_BASE", "http://localhost:8000/v1")
MODEL = os.environ.get("MODEL", "codellama")


def print_header(title):
    """Print a header for better readability"""
    print("\n" + "=" * 80)
    print(f"  {title}")
    print("=" * 80)


def test_health():
    """Test the health check endpoint"""
    print_header("Testing Health Check Endpoint")
    try:
        response = requests.get(f"{API_BASE}/health")
        if response.status_code == 200:
            print(f"Status: {response.json().get('status')}")
            print(f"Ollama Version: {response.json().get('ollama_version')}")
            print(f"Response Time: {response.json().get('response_time')}")
            return True
        else:
            print(f"Error: Status code {response.status_code}")
            print(response.text)
            return False
    except Exception as e:
        print(f"Error: {str(e)}")
        return False


def test_system_info():
    """Test the system info endpoint"""
    print_header("Testing System Info Endpoint")
    try:
        response = requests.get(f"{API_BASE}/system")
        if response.status_code == 200:
            data = response.json()
            print(f"Server Version: {data.get('server', {}).get('version')}")
            models = data.get('ollama', {}).get('models', [])
            print(f"Available Models: {', '.join(models)}")
            print(f"Default Model: {data.get('server', {}).get('default_model')}")
            return True
        else:
            print(f"Error: Status code {response.status_code}")
            print(response.text)
            return False
    except Exception as e:
        print(f"Error: {str(e)}")
        return False


def test_completion_streaming():
    """Test streaming completions"""
    print_header("Testing Streaming Completions")
    try:
        prompt = "Write a Python function to calculate factorial using recursion. Include comments."
        
        print(f"Prompt: {prompt}")
        print("\nResponse:")
        
        response = requests.post(
            f"{API_BASE}/completions",
            json={
                "model": MODEL,
                "prompt": prompt,
                "stream": True,
                "max_tokens": 500
            },
            stream=True
        )
        
        # Process streaming response
        full_response = ""
        for line in response.iter_lines():
            if not line:
                continue
                
            # Remove 'data: ' prefix and check for [DONE]
            line_text = line.decode('utf-8')
            if line_text == "data: [DONE]":
                break
                
            data_json = json.loads(line_text.replace('data: ', ''))
            if 'error' in data_json:
                print(f"Error: {data_json['error']}")
                return False
                
            choice = data_json.get('choices', [{}])[0]
            text = choice.get('text', '')
            full_response += text
            print(text, end='', flush=True)
        
        print("\n\nStreaming completed successfully.")
        return True
    except Exception as e:
        print(f"Error: {str(e)}")
        return False


def test_chat_completion():
    """Test chat completions (non-streaming)"""
    print_header("Testing Chat Completions (Non-streaming)")
    try:
        messages = [
            {"role": "system", "content": "You are a helpful assistant that specializes in shell scripting."},
            {"role": "user", "content": "How do I find all files modified in the last 24 hours?"}
        ]
        
        print("Messages:")
        for msg in messages:
            print(f"  {msg['role']}: {msg['content']}")
        
        response = requests.post(
            f"{API_BASE}/chat/completions",
            json={
                "model": MODEL,
                "messages": messages,
                "stream": False
            }
        )
        
        if response.status_code == 200:
            result = response.json()
            content = result.get('choices', [{}])[0].get('message', {}).get('content', '')
            print("\nResponse:")
            print(content)
            return True
        else:
            print(f"Error: Status code {response.status_code}")
            print(response.text)
            return False
    except Exception as e:
        print(f"Error: {str(e)}")
        return False


def test_chat_completion_streaming():
    """Test streaming chat completions"""
    print_header("Testing Streaming Chat Completions")
    try:
        messages = [
            {"role": "system", "content": "You are a helpful assistant that specializes in shell scripting."},
            {"role": "user", "content": "Write a bash script to backup all .txt files in a directory."}
        ]
        
        print("Messages:")
        for msg in messages:
            print(f"  {msg['role']}: {msg['content']}")
            
        print("\nResponse:")
        
        response = requests.post(
            f"{API_BASE}/chat/completions",
            json={
                "model": MODEL,
                "messages": messages,
                "stream": True,
                "max_tokens": 500
            },
            stream=True
        )
        
        # Process streaming response
        for line in response.iter_lines():
            if not line:
                continue
                
            # Remove 'data: ' prefix and check for [DONE]
            line_text = line.decode('utf-8')
            if line_text == "data: [DONE]":
                break
                
            # Clean the line and parse JSON
            try:
                data_json = json.loads(line_text.replace('data: ', ''))
                if 'error' in data_json:
                    print(f"Error: {data_json['error']}")
                    return False
                    
                choice = data_json.get('choices', [{}])[0]
                delta = choice.get('delta', {})
                if 'content' in delta:
                    print(delta['content'], end='', flush=True)
            except json.JSONDecodeError:
                pass
        
        print("\n\nStreaming completed successfully.")
        return True
    except Exception as e:
        print(f"Error: {str(e)}")
        return False


def main():
    """Run all tests"""
    print(f"Testing MCP Ollama Server at {API_BASE}")
    print(f"Using model: {MODEL}")
    
    tests = [
        ("Health Check", test_health),
        ("System Info", test_system_info),
        ("Completion Streaming", test_completion_streaming),
        ("Chat Completion", test_chat_completion),
        ("Chat Completion Streaming", test_chat_completion_streaming)
    ]
    
    results = {}
    
    for name, test_func in tests:
        print(f"\nRunning test: {name}")
        start_time = time.time()
        success = test_func()
        duration = time.time() - start_time
        results[name] = {
            "success": success,
            "duration": f"{duration:.2f}s"
        }
    
    # Print summary
    print_header("Test Summary")
    all_passed = True
    for name, result in results.items():
        status = "✅ PASS" if result["success"] else "❌ FAIL"
        all_passed = all_passed and result["success"]
        print(f"{status} - {name} ({result['duration']})")
    
    return 0 if all_passed else 1


if __name__ == "__main__":
    sys.exit(main())
