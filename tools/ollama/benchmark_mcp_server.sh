#!/bin/bash
# DB-GPT Enhanced MCP Server Model Benchmark
# This script runs benchmarks on models available via the Enhanced MCP server

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Resolve the project root from the script location
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
SCRIPT_PATH="$PROJECT_ROOT/tools/ollama/benchmark_mcp_models.py"
RESULTS_DIR="$PROJECT_ROOT/benchmark_results"

# Create results directory if it doesn't exist
mkdir -p "$RESULTS_DIR"

# Default settings
DEFAULT_PORT=8000
DEFAULT_HOST="localhost"
DEFAULT_MODELS=("codellama")
DEFAULT_CATEGORIES=("code" "reasoning" "creative")
DEFAULT_MAX_TOKENS=250
DEFAULT_RUNS=1
USE_STREAMING=false
USE_CHAT=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --port)
            PORT="$2"
            shift 2
            ;;
        --host)
            HOST="$2"
            shift 2
            ;;
        --models)
            IFS=',' read -ra MODELS <<< "$2"
            shift 2
            ;;
        --categories)
            IFS=',' read -ra CATEGORIES <<< "$2"
            shift 2
            ;;
        --max-tokens)
            MAX_TOKENS="$2"
            shift 2
            ;;
        --runs)
            RUNS="$2"
            shift 2
            ;;
        --streaming)
            USE_STREAMING=true
            shift
            ;;
        --chat)
            USE_CHAT=true
            shift
            ;;
        --help)
            echo -e "${CYAN}DB-GPT Enhanced MCP Server Model Benchmark${NC}"
            echo ""
            echo "Usage: $(basename "$0") [options]"
            echo ""
            echo "Options:"
            echo "  --port PORT           Port number for MCP server (default: 8000)"
            echo "  --host HOST           Host address for MCP server (default: localhost)"
            echo "  --models m1,m2,...    Comma-separated list of models to benchmark (default: codellama)"
            echo "  --categories c1,c2    Comma-separated list of prompt categories to test (default: code,reasoning,creative)"
            echo "  --max-tokens N        Maximum tokens per response (default: 250)"
            echo "  --runs N              Number of runs per prompt for averaging (default: 1)"
            echo "  --streaming           Test streaming mode"
            echo "  --chat                Test chat completions instead of standard completions"
            echo "  --help                Show this help message"
            echo ""
            echo "Example:"
            echo "  $(basename "$0") --models codellama,llama3 --streaming --chat"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Set defaults for unspecified options
PORT=${PORT:-$DEFAULT_PORT}
HOST=${HOST:-$DEFAULT_HOST}
MODELS=${MODELS[@]:-${DEFAULT_MODELS[@]}}
CATEGORIES=${CATEGORIES[@]:-${DEFAULT_CATEGORIES[@]}}
MAX_TOKENS=${MAX_TOKENS:-$DEFAULT_MAX_TOKENS}
RUNS=${RUNS:-$DEFAULT_RUNS}

# Set up the API base URL
API_BASE="http://$HOST:$PORT"

# Construct the model list argument
MODELS_ARG=""
for model in "${MODELS[@]}"; do
    MODELS_ARG="$MODELS_ARG $model"
done

# Construct the categories list argument
CATEGORIES_ARG=""
for category in "${CATEGORIES[@]}"; do
    CATEGORIES_ARG="$CATEGORIES_ARG $category"
done

# Generate a timestamp for the results file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULT_FILE="$RESULTS_DIR/benchmark_${TIMESTAMP}.json"

# Construct streaming and chat mode flags
STREAM_FLAG=""
if $USE_STREAMING; then
    STREAM_FLAG="--streaming"
fi

CHAT_FLAG=""
if $USE_CHAT; then
    CHAT_FLAG="--chat"
fi

# Print benchmark configuration
echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN}   DB-GPT Enhanced MCP Benchmark Tool   ${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""
echo -e "${BLUE}Configuration:${NC}"
echo -e "  ${YELLOW}API Base:${NC} $API_BASE"
echo -e "  ${YELLOW}Models:${NC} ${MODELS[@]}"
echo -e "  ${YELLOW}Categories:${NC} ${CATEGORIES[@]}"
echo -e "  ${YELLOW}Max Tokens:${NC} $MAX_TOKENS"
echo -e "  ${YELLOW}Runs per prompt:${NC} $RUNS"
echo -e "  ${YELLOW}Mode:${NC} $(if $USE_CHAT; then echo "Chat"; else echo "Completion"; fi) - $(if $USE_STREAMING; then echo "Streaming"; else echo "Standard"; fi)"
echo -e "  ${YELLOW}Results file:${NC} $RESULT_FILE"
echo ""

# Check if python script exists
if [ ! -f "$SCRIPT_PATH" ]; then
    echo -e "${RED}Error: Benchmark script not found at $SCRIPT_PATH${NC}"
    exit 1
fi

# Check if the server is running
echo -e "${YELLOW}Checking if MCP server is running at $API_BASE...${NC}"
if ! curl -s "$API_BASE/v1/health" > /dev/null; then
    echo -e "${RED}Error: MCP server is not running at $API_BASE${NC}"
    echo -e "${YELLOW}Make sure to start the enhanced MCP server first with:${NC}"
    echo -e "  ${GREEN}mcp-enhanced-codellama${NC}"
    exit 1
fi

echo -e "${GREEN}MCP server is running. Starting benchmark...${NC}"
echo ""

# Make script executable if needed
chmod +x "$SCRIPT_PATH"

# Run the benchmark
python3 "$SCRIPT_PATH" \
    --api-base "$API_BASE" \
    --models $MODELS_ARG \
    --categories $CATEGORIES_ARG \
    --max-tokens "$MAX_TOKENS" \
    --runs "$RUNS" \
    --output "$RESULT_FILE" \
    $STREAM_FLAG $CHAT_FLAG

# Check if benchmark completed successfully
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}Benchmark completed successfully!${NC}"
    echo -e "Results saved to: ${YELLOW}$RESULT_FILE${NC}"
else
    echo ""
    echo -e "${RED}Benchmark failed.${NC}"
fi
