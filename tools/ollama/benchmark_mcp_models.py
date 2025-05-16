#!/usr/bin/env python3
# Model Performance Benchmarking Tool for Enhanced MCP
# This script benchmarks the performance of different models served via the Enhanced MCP server

import argparse
import json
import os
import sys
import time
import statistics
import requests
from datetime import datetime
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.progress import Progress

console = Console()

# Default test prompts organized by category
DEFAULT_PROMPTS = {
    "code": [
        "Write a Python function to calculate the Fibonacci sequence",
        "Create a JavaScript function that sorts an array of objects by a specified property",
        "Write a SQL query to find the top 5 customers by purchase amount",
        "Create a React component that displays a list of items with pagination",
        "Write a function to validate an email address in Python"
    ],
    "reasoning": [
        "Explain the concept of quantum computing to a 12-year-old",
        "What are the ethical implications of AI in healthcare?",
        "Compare and contrast functional and object-oriented programming",
        "Describe three approaches to solving the traveling salesman problem",
        "Explain the principles of database normalization with examples"
    ],
    "creative": [
        "Write a short story about a robot learning to paint",
        "Create a marketing slogan for a new eco-friendly water bottle",
        "Write a poem about coding late at night",
        "Design a game concept for teaching children about climate change",
        "Create a character profile for a protagonist in a cyberpunk novel"
    ]
}

def parse_arguments():
    parser = argparse.ArgumentParser(description="Benchmark models via Enhanced MCP Server")
    parser.add_argument("--api-base", default="http://localhost:8000", help="MCP Server base URL")
    parser.add_argument("--models", nargs="+", default=["codellama"], help="Models to benchmark")
    parser.add_argument("--categories", nargs="+", choices=["code", "reasoning", "creative", "all"], 
                        default=["all"], help="Categories of prompts to test")
    parser.add_argument("--max-tokens", type=int, default=250, help="Maximum number of tokens per response")
    parser.add_argument("--runs", type=int, default=1, help="Number of runs per prompt (for averaging)")
    parser.add_argument("--output", help="Output file for benchmark results (JSON)")
    parser.add_argument("--streaming", action="store_true", help="Test streaming mode")
    parser.add_argument("--chat", action="store_true", help="Test chat completions instead of regular completions")
    parser.add_argument("--timeout", type=int, default=60, help="Request timeout in seconds")
    return parser.parse_args()

def check_server_status(api_base):
    try:
        health_resp = requests.get(f"{api_base}/v1/health", timeout=5)
        health_resp.raise_for_status()
        health_data = health_resp.json()
        
        models_resp = requests.get(f"{api_base}/v1/models", timeout=5)
        models_resp.raise_for_status()
        models_data = models_resp.json()
        
        return True, health_data, models_data
    except Exception as e:
        return False, str(e), None

def print_header():
    console.print(Panel.fit(
        "[bold cyan]DB-GPT Enhanced MCP Server - Model Benchmark Tool[/]",
        border_style="blue"
    ))

def get_prompts(categories, custom_prompts=None):
    prompts = []
    if "all" in categories:
        for category_prompts in DEFAULT_PROMPTS.values():
            prompts.extend(category_prompts)
    else:
        for category in categories:
            if category in DEFAULT_PROMPTS:
                prompts.extend(DEFAULT_PROMPTS[category])
    
    # Add custom prompts if provided
    if custom_prompts:
        prompts.extend(custom_prompts)
        
    return prompts

def run_benchmark_completion(api_base, model, prompt, max_tokens, streaming, timeout):
    start_time = time.time()
    total_tokens = 0
    error = None
    response_content = ""
    
    try:
        data = {
            "model": model,
            "prompt": prompt,
            "max_tokens": max_tokens,
            "stream": streaming
        }
        
        if streaming:
            response = requests.post(
                f"{api_base}/v1/completions",
                json=data,
                stream=True,
                timeout=timeout
            )
            response.raise_for_status()
            
            # Process streaming response
            for line in response.iter_lines():
                if not line:
                    continue
                line_text = line.decode('utf-8')
                if line_text.startswith('data: '):
                    line_text = line_text[6:]  # Remove 'data: ' prefix
                if line_text == "[DONE]":
                    break
                try:
                    chunk = json.loads(line_text)
                    if 'choices' in chunk and len(chunk['choices']) > 0:
                        if 'text' in chunk['choices'][0]:
                            text = chunk['choices'][0]['text']
                            response_content += text
                except Exception as e:
                    pass  # Skip invalid JSON
        else:
            response = requests.post(
                f"{api_base}/v1/completions",
                json=data,
                timeout=timeout
            )
            response.raise_for_status()
            resp_data = response.json()
            
            if 'choices' in resp_data and len(resp_data['choices']) > 0:
                response_content = resp_data['choices'][0]['text']
            
            if 'usage' in resp_data:
                total_tokens = resp_data['usage'].get('total_tokens', 0)
    
    except Exception as e:
        error = str(e)
    
    end_time = time.time()
    elapsed = end_time - start_time
    
    return {
        "elapsed_time": elapsed,
        "total_tokens": total_tokens,
        "tokens_per_second": total_tokens / elapsed if total_tokens > 0 and elapsed > 0 else 0,
        "error": error,
        "response_length": len(response_content),
        "response_preview": response_content[:100] + "..." if len(response_content) > 100 else response_content
    }

def run_benchmark_chat_completion(api_base, model, prompt, max_tokens, streaming, timeout):
    start_time = time.time()
    total_tokens = 0
    error = None
    response_content = ""
    
    try:
        data = {
            "model": model,
            "messages": [{"role": "user", "content": prompt}],
            "max_tokens": max_tokens,
            "stream": streaming
        }
        
        if streaming:
            response = requests.post(
                f"{api_base}/v1/chat/completions",
                json=data,
                stream=True,
                timeout=timeout
            )
            response.raise_for_status()
            
            # Process streaming response
            for line in response.iter_lines():
                if not line:
                    continue
                line_text = line.decode('utf-8')
                if line_text.startswith('data: '):
                    line_text = line_text[6:]  # Remove 'data: ' prefix
                if line_text == "[DONE]":
                    break
                try:
                    chunk = json.loads(line_text)
                    if 'choices' in chunk and len(chunk['choices']) > 0:
                        if chunk['choices'][0].get('delta', {}).get('content'):
                            text = chunk['choices'][0]['delta']['content']
                            response_content += text
                except Exception as e:
                    pass  # Skip invalid JSON
        else:
            response = requests.post(
                f"{api_base}/v1/chat/completions",
                json=data,
                timeout=timeout
            )
            response.raise_for_status()
            resp_data = response.json()
            
            if 'choices' in resp_data and len(resp_data['choices']) > 0:
                response_content = resp_data['choices'][0]['message']['content']
            
            if 'usage' in resp_data:
                total_tokens = resp_data['usage'].get('total_tokens', 0)
    
    except Exception as e:
        error = str(e)
    
    end_time = time.time()
    elapsed = end_time - start_time
    
    return {
        "elapsed_time": elapsed,
        "total_tokens": total_tokens,
        "tokens_per_second": total_tokens / elapsed if total_tokens > 0 and elapsed > 0 else 0,
        "error": error,
        "response_length": len(response_content),
        "response_preview": response_content[:100] + "..." if len(response_content) > 100 else response_content
    }

def main():
    args = parse_arguments()
    print_header()
    
    # Check if server is running
    console.print("[bold yellow]Checking MCP server status...[/]")
    server_ok, health_data, models_data = check_server_status(args.api_base)
    
    if not server_ok:
        console.print(f"[bold red]Error: Could not connect to MCP server at {args.api_base}[/]")
        console.print(f"[red]{health_data}[/]")
        return 1
    
    console.print(f"[bold green]Server is running:[/] {health_data['status']}")
    console.print(f"[bold green]Ollama version:[/] {health_data.get('ollama_version', 'unknown')}")
    console.print(f"[bold green]API base:[/] {health_data.get('api_base', args.api_base)}")
    
    # Get available models
    available_models = [model['id'] for model in models_data.get('data', [])]
    console.print(f"[bold green]Available models:[/] {', '.join(available_models)}")
    
    # Validate requested models
    invalid_models = [model for model in args.models if model not in available_models]
    if invalid_models:
        console.print(f"[bold red]Warning: The following models are not available: {', '.join(invalid_models)}[/]")
        console.print("[yellow]Proceeding with available models only.[/]")
        args.models = [model for model in args.models if model in available_models]
    
    if not args.models:
        console.print("[bold red]Error: No valid models specified for benchmarking.[/]")
        return 1
    
    prompts = get_prompts(args.categories)
    total_tests = len(args.models) * len(prompts) * args.runs
    
    console.print(f"\n[bold cyan]Starting benchmark with {len(args.models)} models, {len(prompts)} prompts, {args.runs} runs per prompt ({total_tests} total tests)[/]")
    console.print(f"[bold cyan]Mode:[/] {'Chat' if args.chat else 'Completion'} - {'Streaming' if args.streaming else 'Standard'}")
    
    results = {}
    
    with Progress() as progress:
        task = progress.add_task("[cyan]Running benchmarks...", total=total_tests)
        
        for model in args.models:
            model_results = []
            console.print(f"\n[bold blue]Benchmarking model:[/] {model}")
            
            for prompt in prompts:
                prompt_results = []
                
                for run in range(args.runs):
                    console.print(f"[dim]Running prompt {prompts.index(prompt)+1}/{len(prompts)}, run {run+1}/{args.runs}...[/]", end="\r")
                    
                    if args.chat:
                        result = run_benchmark_chat_completion(
                            args.api_base, model, prompt, args.max_tokens, args.streaming, args.timeout
                        )
                    else:
                        result = run_benchmark_completion(
                            args.api_base, model, prompt, args.max_tokens, args.streaming, args.timeout
                        )
                    
                    prompt_results.append(result)
                    progress.update(task, advance=1)
                
                # Calculate average metrics for this prompt
                if args.runs > 1:
                    avg_time = statistics.mean([r["elapsed_time"] for r in prompt_results])
                    avg_tokens = statistics.mean([r["total_tokens"] for r in prompt_results if r["total_tokens"] > 0]) if any(r["total_tokens"] > 0 for r in prompt_results) else 0
                    avg_tokens_per_sec = statistics.mean([r["tokens_per_second"] for r in prompt_results if r["tokens_per_second"] > 0]) if any(r["tokens_per_second"] > 0 for r in prompt_results) else 0
                    
                    summary = {
                        "prompt": prompt,
                        "avg_elapsed_time": avg_time,
                        "avg_total_tokens": avg_tokens,
                        "avg_tokens_per_second": avg_tokens_per_sec,
                        "runs": prompt_results
                    }
                else:
                    summary = {
                        "prompt": prompt,
                        "elapsed_time": prompt_results[0]["elapsed_time"],
                        "total_tokens": prompt_results[0]["total_tokens"],
                        "tokens_per_second": prompt_results[0]["tokens_per_second"],
                        "error": prompt_results[0]["error"],
                        "response_preview": prompt_results[0]["response_preview"]
                    }
                
                model_results.append(summary)
            
            # Calculate overall model metrics
            model_times = []
            model_token_rates = []
            
            for result in model_results:
                if args.runs > 1:
                    model_times.append(result["avg_elapsed_time"])
                    if result["avg_tokens_per_second"] > 0:
                        model_token_rates.append(result["avg_tokens_per_second"])
                else:
                    model_times.append(result["elapsed_time"])
                    if result["tokens_per_second"] > 0:
                        model_token_rates.append(result["tokens_per_second"])
            
            model_avg_time = statistics.mean(model_times) if model_times else 0
            model_avg_token_rate = statistics.mean(model_token_rates) if model_token_rates else 0
            
            results[model] = {
                "avg_response_time": model_avg_time,
                "avg_tokens_per_second": model_avg_token_rate,
                "prompt_results": model_results
            }
    
    # Display results summary
    console.print("\n[bold green]Benchmark Results:[/]")
    
    table = Table(show_header=True, header_style="bold magenta")
    table.add_column("Model")
    table.add_column("Avg Response Time (s)", justify="right")
    table.add_column("Avg Tokens/Second", justify="right")
    table.add_column("Mode")
    
    for model, data in results.items():
        table.add_row(
            model,
            f"{data['avg_response_time']:.2f}",
            f"{data['avg_tokens_per_second']:.2f}",
            f"{'Chat' if args.chat else 'Completion'} - {'Streaming' if args.streaming else 'Standard'}"
        )
    
    console.print(table)
    
    # Save results to file if requested
    if args.output:
        output_data = {
            "timestamp": datetime.now().isoformat(),
            "configuration": {
                "api_base": args.api_base,
                "max_tokens": args.max_tokens,
                "runs_per_prompt": args.runs,
                "streaming": args.streaming,
                "chat_mode": args.chat,
                "timeout": args.timeout
            },
            "models": args.models,
            "prompts": prompts,
            "results": results
        }
        
        with open(args.output, 'w') as f:
            json.dump(output_data, f, indent=2)
        
        console.print(f"[bold green]Results saved to {args.output}[/]")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
