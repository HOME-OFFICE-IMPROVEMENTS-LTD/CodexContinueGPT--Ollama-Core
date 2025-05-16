# Model Benchmarking Tool for Enhanced MCP Server

This tool allows you to benchmark and compare different Ollama models served through the Enhanced MCP server.

## Features

- Benchmark multiple models in a single run
- Test both streaming and non-streaming modes
- Support for completions and chat completions
- Customizable prompt categories (code, reasoning, creative)
- Performance metrics including response time and tokens/second
- Output results to JSON for further analysis
- Visual result presentation in terminal

## Prerequisites

1. Enhanced MCP server running
2. Python packages: requests, rich

## Usage

### Quick Start

```bash
# Start the Enhanced MCP server
mcp-enhanced-codellama

# Run benchmark with default settings
./tools/ollama/benchmark_mcp_server.sh
```

### Command Line Options

```bash
./tools/ollama/benchmark_mcp_server.sh [options]

Options:
  --port PORT            Port number for MCP server (default: 8000)
  --host HOST            Host address for MCP server (default: localhost)
  --models m1,m2,...     Comma-separated list of models to benchmark (default: codellama)
  --categories c1,c2     Comma-separated list of prompt categories to test 
                         (default: code,reasoning,creative)
  --max-tokens N         Maximum tokens per response (default: 250)
  --runs N               Number of runs per prompt for averaging (default: 1)
  --streaming            Test streaming mode
  --chat                 Test chat completions instead of standard completions
  --help                 Show this help message
```

### Examples

```bash
# Compare multiple models
./tools/ollama/benchmark_mcp_server.sh --models codellama,llama3

# Test streaming chat responses
./tools/ollama/benchmark_mcp_server.sh --streaming --chat

# More runs for better averages
./tools/ollama/benchmark_mcp_server.sh --runs 3

# Only test code-related prompts
./tools/ollama/benchmark_mcp_server.sh --categories code

# Custom port
./tools/ollama/benchmark_mcp_server.sh --port 8001
```

## Output

The benchmark tool will generate a JSON file with detailed results in the `benchmark_results` directory. The filename will include a timestamp:

```
benchmark_results/benchmark_20250516_123456.json
```

The tool also displays a summary table in the terminal:

```
╭───────────┬──────────────────┬──────────────────┬──────────────────────────────╮
│ Model     │ Avg Response     │ Avg Tokens/      │ Mode                         │
│           │ Time (s)         │ Second           │                              │
├───────────┼──────────────────┼──────────────────┼──────────────────────────────┤
│ codellama │ 3.25             │ 12.75            │ Completion - Standard        │
│ llama3    │ 2.78             │ 14.30            │ Completion - Standard        │
╰───────────┴──────────────────┴──────────────────┴──────────────────────────────╯
```

## Advanced Usage

### Using the Python Script Directly

You can also run the Python script directly for more control:

```bash
python3 ./tools/ollama/benchmark_mcp_models.py \
  --api-base http://localhost:8000 \
  --models codellama llama3 \
  --categories code reasoning creative \
  --max-tokens 250 \
  --runs 1 \
  --output ./benchmark_results/custom_benchmark.json \
  --streaming \
  --chat
```

### Adding Custom Prompts

To add custom prompts beyond the built-in categories, you can modify the script to include your own prompts:

1. Edit the `DEFAULT_PROMPTS` dictionary in `benchmark_mcp_models.py`
2. Add your own category or extend existing categories with new prompts

## Interpreting Results

### Key Metrics

- **Average Response Time**: How long it takes for the model to generate a complete response
- **Average Tokens/Second**: How many tokens the model can generate per second
- **Response Length**: The length of the generated text (for streaming mode)

### Comparing Models

When comparing models, consider:

1. **Speed vs. Quality**: Faster models might produce lower quality outputs
2. **Streaming Performance**: Some models might be optimized for streaming
3. **Task Suitability**: Different models excel at different types of tasks

## Troubleshooting

### Common Issues

1. **Connection Issues**:
   - Ensure Enhanced MCP server is running
   - Check host and port settings

2. **Missing Models**:
   - Verify models are pulled in Ollama
   - Check model name spelling

3. **Performance Issues**:
   - Try reducing max_tokens
   - Consider system resource limitations
