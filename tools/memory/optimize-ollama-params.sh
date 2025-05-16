#!/bin/bash
# filepath: /home/msalsouri/Projects/DB-GPT/optimize-ollama-params.sh
# Tool to adjust Ollama parameters for optimal memory usage

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Default parameters
MODEL="smart-shell-agent"
CTX_SIZE=4096
BATCH_SIZE=256
THREADS=$(nproc --all)
PARALLEL=1

# Function to display help
show_help() {
    echo -e "${BOLD}Ollama Parameter Optimizer${NC}"
    echo ""
    echo -e "Usage: ${CYAN}$(basename "$0") [OPTIONS]${NC}"
    echo ""
    echo "OPTIONS:"
    echo -e "  ${GREEN}-h, --help${NC}               Show this help message"
    echo -e "  ${GREEN}-m, --model MODEL${NC}        Specify model to use (default: smart-shell-agent)"
    echo -e "  ${GREEN}-c, --ctx SIZE${NC}           Set context window size (default: 4096)"
    echo -e "  ${GREEN}-b, --batch SIZE${NC}         Set batch size (default: 256)"
    echo -e "  ${GREEN}-t, --threads NUM${NC}        Set number of threads (default: auto)"
    echo -e "  ${GREEN}-p, --parallel NUM${NC}       Set parallel operations (default: 1)"
    echo -e "  ${GREEN}--preset low|medium|high${NC} Use predefined parameter set"
    echo -e "  ${GREEN}--test${NC}                   Run a memory usage test with parameters"
    echo -e "  ${GREEN}--interactive${NC}            Interactive memory optimization"
    echo ""
    echo -e "Examples:"
    echo -e "  ${CYAN}$(basename "$0") --preset low${NC}            # Use low memory preset"
    echo -e "  ${CYAN}$(basename "$0") --ctx 2048 --batch 128${NC}  # Custom parameters"
    echo -e "  ${CYAN}$(basename "$0") --test${NC}                  # Test memory usage"
    echo -e "  ${CYAN}$(basename "$0") --interactive${NC}           # Interactive mode"
    echo ""
}

# Function to apply preset configurations
apply_preset() {
    case "$1" in
        low)
            CTX_SIZE=2048
            BATCH_SIZE=128
            THREADS=$(($(nproc --all) / 2))
            PARALLEL=1
            echo -e "${GREEN}Applied low memory preset: ctx=$CTX_SIZE, batch=$BATCH_SIZE, threads=$THREADS, parallel=$PARALLEL${NC}"
            ;;
        medium)
            CTX_SIZE=4096
            BATCH_SIZE=256
            THREADS=$(nproc --all)
            PARALLEL=1
            echo -e "${GREEN}Applied medium memory preset: ctx=$CTX_SIZE, batch=$BATCH_SIZE, threads=$THREADS, parallel=$PARALLEL${NC}"
            ;;
        high)
            CTX_SIZE=8192
            BATCH_SIZE=512
            THREADS=$(nproc --all)
            PARALLEL=2
            echo -e "${GREEN}Applied high memory preset: ctx=$CTX_SIZE, batch=$BATCH_SIZE, threads=$THREADS, parallel=$PARALLEL${NC}"
            ;;
        *)
            echo -e "${RED}Unknown preset: $1${NC}"
            echo -e "${YELLOW}Available presets: low, medium, high${NC}"
            exit 1
            ;;
    esac
}

# Function to check if model exists
check_model() {
    if ! ollama list | grep -q "$MODEL"; then
        echo -e "${RED}Model '$MODEL' not found.${NC}"
        echo -e "${YELLOW}Available models:${NC}"
        ollama list
        exit 1
    fi
}

# Function to run memory usage test
test_memory_usage() {
    check_model
    
    echo -e "${YELLOW}Testing memory usage with parameters:${NC}"
    echo -e "  ${CYAN}Model:${NC} $MODEL"
    echo -e "  ${CYAN}Context size:${NC} $CTX_SIZE"
    echo -e "  ${CYAN}Batch size:${NC} $BATCH_SIZE"
    echo -e "  ${CYAN}Threads:${NC} $THREADS"
    echo -e "  ${CYAN}Parallel:${NC} $PARALLEL\n"
    
    # Record initial memory usage
    echo -e "${YELLOW}Initial memory usage:${NC}"
    free -h
    
    # Run test query
    echo -e "\n${YELLOW}Running test query...${NC}"
    ollama run --ctx $CTX_SIZE --batch $BATCH_SIZE --threads $THREADS --parallel $PARALLEL "$MODEL" "Explain in 3 sentences what DB-GPT is."
    
    # Record final memory usage
    echo -e "\n${YELLOW}Final memory usage:${NC}"
    free -h
    
    # Show Ollama processes
    echo -e "\n${YELLOW}Ollama processes:${NC}"
    ps aux | grep ollama | grep -v grep | sort -k 4 -r
}

# Function for interactive memory optimization
interactive_optimization() {
    check_model
    
    clear
    echo -e "${BOLD}${BLUE}Interactive Memory Optimization${NC}\n"
    
    echo -e "${YELLOW}Starting with model: ${CYAN}$MODEL${NC}"
    echo -e "${YELLOW}Testing different parameter combinations...${NC}\n"
    
    # Test low memory preset
    echo -e "${BOLD}Test 1: Low Memory Preset${NC}"
    apply_preset "low"
    echo -e "${YELLOW}Running test...${NC}"
    before_mem=$(free | grep Mem | awk '{print $3}')
    ollama run --ctx $CTX_SIZE --batch $BATCH_SIZE --threads $THREADS --parallel $PARALLEL "$MODEL" "Hello" > /dev/null
    after_mem=$(free | grep Mem | awk '{print $3}')
    mem_usage=$((after_mem - before_mem))
    echo -e "${GREEN}Memory usage: $(($mem_usage / 1024)) MB${NC}\n"
    
    # Test medium memory preset
    echo -e "${BOLD}Test 2: Medium Memory Preset${NC}"
    apply_preset "medium"
    echo -e "${YELLOW}Running test...${NC}"
    before_mem=$(free | grep Mem | awk '{print $3}')
    ollama run --ctx $CTX_SIZE --batch $BATCH_SIZE --threads $THREADS --parallel $PARALLEL "$MODEL" "Hello" > /dev/null
    after_mem=$(free | grep Mem | awk '{print $3}')
    mem_usage=$((after_mem - before_mem))
    echo -e "${GREEN}Memory usage: $(($mem_usage / 1024)) MB${NC}\n"
    
    # Test high memory preset (if enough memory available)
    free_mem=$(free | grep Mem | awk '{print $4}')
    if [ $free_mem -gt 10000000 ]; then
        echo -e "${BOLD}Test 3: High Memory Preset${NC}"
        apply_preset "high"
        echo -e "${YELLOW}Running test...${NC}"
        before_mem=$(free | grep Mem | awk '{print $3}')
        ollama run --ctx $CTX_SIZE --batch $BATCH_SIZE --threads $THREADS --parallel $PARALLEL "$MODEL" "Hello" > /dev/null
        after_mem=$(free | grep Mem | awk '{print $3}')
        mem_usage=$((after_mem - before_mem))
        echo -e "${GREEN}Memory usage: $(($mem_usage / 1024)) MB${NC}\n"
    else
        echo -e "${YELLOW}Skipping high memory test due to insufficient memory${NC}\n"
    fi
    
    # Recommend optimal settings
    echo -e "${BOLD}${GREEN}Recommendation:${NC}"
    free_mem=$(free | grep Mem | awk '{print $4}')
    
    if [ $free_mem -lt 2000000 ]; then
        echo -e "Based on your available memory, use the ${BOLD}low memory preset:${NC}"
        echo -e "./optimize-ollama-params.sh --preset low"
    elif [ $free_mem -lt 6000000 ]; then
        echo -e "Based on your available memory, use the ${BOLD}medium memory preset:${NC}"
        echo -e "./optimize-ollama-params.sh --preset medium"
    else
        echo -e "Based on your available memory, you can use the ${BOLD}high memory preset:${NC}"
        echo -e "./optimize-ollama-params.sh --preset high"
    fi
    
    # Create a profile based on system resources
    echo -e "\n${YELLOW}Creating a custom profile based on your system...${NC}"
    
    total_mem=$(free | grep Mem | awk '{print $2}')
    available_mem=$(free | grep Mem | awk '{print $7}')
    cpu_cores=$(nproc --all)
    
    # Calculate optimal parameters
    if [ $available_mem -lt 2000000 ]; then
        # Very low memory
        custom_ctx=2048
        custom_batch=128
        custom_threads=$((cpu_cores / 2))
        custom_parallel=1
    elif [ $available_mem -lt 4000000 ]; then
        # Low memory
        custom_ctx=4096
        custom_batch=128
        custom_threads=$((cpu_cores * 2 / 3))
        custom_parallel=1
    elif [ $available_mem -lt 8000000 ]; then
        # Medium memory
        custom_ctx=4096
        custom_batch=256
        custom_threads=$cpu_cores
        custom_parallel=1
    else
        # High memory
        custom_ctx=8192
        custom_batch=512
        custom_threads=$cpu_cores
        custom_parallel=2
    fi
    
    echo -e "${GREEN}Custom profile generated:${NC}"
    echo -e "${CYAN}Context size:${NC} $custom_ctx"
    echo -e "${CYAN}Batch size:${NC} $custom_batch"
    echo -e "${CYAN}Threads:${NC} $custom_threads"
    echo -e "${CYAN}Parallel:${NC} $custom_parallel"
    
    echo -e "\n${YELLOW}To use this custom profile:${NC}"
    echo -e "./optimize-ollama-params.sh --ctx $custom_ctx --batch $custom_batch --threads $custom_threads --parallel $custom_parallel"
    
    # Ask if user wants to create a shell script with these parameters
    echo -e "\n${CYAN}Would you like to create a custom runner script with these parameters? (y/n)${NC}"
    read -r create_script
    
    if [[ "$create_script" =~ ^[Yy]$ ]]; then
        script_path="$HOME/Projects/DB-GPT/run-smart-shell-agent-custom.sh"
        cp "$HOME/Projects/DB-GPT/run-smart-shell-agent.sh" "$script_path"
        
        # Update parameters in the script
        sed -i "s/ollama run \"\$MODEL\"/ollama run --ctx $custom_ctx --batch $custom_batch --threads $custom_threads --parallel $custom_parallel \"\$MODEL\"/g" "$script_path"
        
        echo -e "${GREEN}Custom runner script created at:${NC} $script_path"
        echo -e "${YELLOW}Run it with:${NC} ./run-smart-shell-agent-custom.sh"
        chmod +x "$script_path"
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -m|--model)
            MODEL="$2"
            shift 2
            ;;
        -c|--ctx)
            CTX_SIZE="$2"
            shift 2
            ;;
        -b|--batch)
            BATCH_SIZE="$2"
            shift 2
            ;;
        -t|--threads)
            THREADS="$2"
            shift 2
            ;;
        -p|--parallel)
            PARALLEL="$2"
            shift 2
            ;;
        --preset)
            apply_preset "$2"
            shift 2
            ;;
        --test)
            TEST=true
            shift
            ;;
        --interactive)
            INTERACTIVE=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Execute the requested action
if [ "$TEST" = true ]; then
    test_memory_usage
elif [ "$INTERACTIVE" = true ]; then
    interactive_optimization
else
    # Just show the current parameters if no action specified
    echo -e "${YELLOW}Current parameters:${NC}"
    echo -e "  ${CYAN}Model:${NC} $MODEL"
    echo -e "  ${CYAN}Context size:${NC} $CTX_SIZE"
    echo -e "  ${CYAN}Batch size:${NC} $BATCH_SIZE"
    echo -e "  ${CYAN}Threads:${NC} $THREADS"
    echo -e "  ${CYAN}Parallel:${NC} $PARALLEL"
    
    echo -e "\n${YELLOW}To use these parameters:${NC}"
    echo -e "ollama run --ctx $CTX_SIZE --batch $BATCH_SIZE --threads $THREADS --parallel $PARALLEL \"$MODEL\" \"your prompt\""
    
    echo -e "\n${YELLOW}To test memory usage with these parameters:${NC}"
    echo -e "$(basename "$0") --test"
fi

exit 0
