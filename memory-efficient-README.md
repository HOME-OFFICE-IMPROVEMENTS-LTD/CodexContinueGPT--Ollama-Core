# Memory-Efficient Smart Shell Agent for DB-GPT

This package provides memory-optimized alternatives to the standard Smart Shell Agent to help manage high memory usage situations.

## 🚀 The Problem: High Memory Usage

The standard Smart Shell Agent, while powerful, can consume significant memory resources:

- The Ollama runner can use 8GB+ of memory
- Multiple instances can quickly exhaust system resources
- Large context windows (8192) contribute to high memory usage
- Default batch sizes may be too large for some systems

## 💡 Memory-Efficient Solutions

This package includes several tools to help manage memory usage:

### 1. Smart Shell Agent Lite

A streamlined version of the Smart Shell Agent with reduced memory footprint:

- Smaller context window (4096 vs 8192)
- Reduced batch size (256 vs 512)
- Simplified system prompt
- Minimal repository context

```bash
./run-smart-shell-agent-lite.sh
```

### 2. Memory Monitor

A real-time monitor for Ollama and system memory usage:

```bash
./monitor-memory.sh
```

### 3. Ollama Cleanup Utility

Tools for managing Ollama processes and freeing memory:

```bash
./cleanup-ollama.sh
```

Features:
- Force kill runaway Ollama processes
- Delete unused models to free disk space
- Restart Ollama service
- Clear system cache

### 4. Ollama Parameter Optimizer

A tool to find the optimal Ollama parameters for your system:

```bash
./optimize-ollama-params.sh --interactive
```

Features:
- Test different parameter combinations
- Create presets for different memory profiles (low, medium, high)
- Generate custom runner scripts with optimized parameters
- Analyze system resources and recommend settings

### 5. Integrated Memory Manager

A comprehensive memory management solution:

```bash
./integrated-memory-manager.sh
```

Features:
- Monitor system and Ollama memory usage
- Clean up agent memory and system cache
- Manage Ollama processes and models
- Optimize memory parameters
- Provide real-time dashboard

## 📊 Memory Usage Comparison

| Version | Approx. Memory Usage | Context Size | Batch Size |
|---------|---------------------|--------------|------------|
| Standard Smart Shell Agent | 8GB+ | 8192 | 512 |
| Smart Shell Agent Lite | 4GB+ | 4096 | 256 |
| Minimal Shell Agent | 2GB+ | 2048 | 128 |

## 🔠 Agent Selection Commands

The `shell-agent-manager.sh` script provides easy ways to select the right agent:

```bash
# Auto-select agent based on memory
./shell-agent-manager.sh auto

# Run standard agent
./shell-agent-manager.sh smart

# Run memory-efficient agent
./shell-agent-manager.sh lite

# Run minimal agent
./shell-agent-manager.sh run minimal

# Compare agents
./shell-agent-manager.sh compare
```

## 🔧 When to Use Each Tool

1. **Smart Shell Agent Lite**
   - When you need the natural language capabilities but with lower memory usage
   - On systems with 8-16GB total RAM
   - For longer sessions without memory issues

2. **Memory Monitor**
   - When you need to track memory usage in real-time
   - To identify memory leaks or issues
   - During intensive operations

3. **Ollama Cleanup Utility**
   - When experiencing high memory usage
   - After running multiple models
   - When Ollama processes are stuck or using excessive resources

4. **Ollama Parameter Optimizer**
   - When setting up on a new system
   - To fine-tune performance
   - When experiencing slowdowns or crashes

5. **Integrated Memory Manager**
   - For comprehensive memory management
   - During development or testing
   - For regular maintenance

## 🧠 Memory Management Tools

We've created several tools to help manage memory:

### Memory Manager

The unified memory manager interface:

```bash
./memory-manager.sh
```

Features:
- Show memory status and usage statistics
- Monitor memory in real-time
- Clean memory (light, standard, or aggressive)
- Kill Ollama processes
- Optimize memory parameters
- Auto-select the appropriate agent

### Auto Memory Manager

Automatically selects the right agent based on available memory:

```bash
./auto-memory-manager.sh
```

Features:
- Analyzes available system memory
- Recommends the appropriate agent
- Provides cleanup options for low memory
- Creates ultra-minimal test models when needed

### Cleanup Ollama Utility

Quick tool to clean up Ollama processes and free memory:

```bash
./cleanup-ollama.sh
```

## 🏆 Best Practices

1. **Monitor Memory Usage**
   - Keep an eye on memory with `./monitor-memory.sh`
   - Consider setting up alerts for high memory usage

2. **Use the Right Tool for the Job**
   - Use lite version for everyday tasks
   - Reserve full version for complex operations

3. **Regular Maintenance**
   - Periodically run `./cleanup-ollama.sh`
   - Delete unused models
   - Clear system cache when needed

4. **Optimize Parameters**
   - Use `./optimize-ollama-params.sh --interactive` to find optimal settings
   - Create custom configurations for different scenarios

## 🤝 Contributing

Have ideas for improving memory efficiency? Feel free to contribute by:

1. Adding new memory optimization techniques
2. Improving existing tools
3. Sharing benchmark results
4. Documenting best practices

Remember, efficient memory usage means a smoother experience for everyone using DB-GPT!
- Interactive menu for common operations

## 📋 Usage Recommendations

1. **Monitor First**: Use `./monitor-memory.sh` to identify memory issues
2. **Try Lite Version**: Use `./run-smart-shell-agent-lite.sh` instead of the standard version when memory is limited
3. **Clean Up When Needed**: Run `./cleanup-ollama.sh` when you notice high memory usage or before switching models
4. **Manage Models**: Delete unused models with `./cleanup-ollama.sh --delete MODEL_NAME`
5. **Restart Service**: When Ollama becomes unresponsive, use `./cleanup-ollama.sh --force --restart`

## 🔄 Switching Between Versions

You can easily switch between the standard and lite versions based on your needs:

- Standard version: Full features, higher memory usage
- Lite version: Essential features, lower memory usage

Both versions maintain compatibility with the DB-GPT repository and provide natural language interaction.

## 🔧 Advanced Configuration

For even lower memory usage, you can edit the model parameters:

```bash
# In run-smart-shell-agent-lite.sh
ollama run --ctx 2048 --batch 128 "$MODEL" "$user_input"
```

Adjust parameters based on your system's resources:
- `--ctx`: Context window size (lower = less memory)
- `--batch`: Batch size (lower = less memory)
- `--threads`: CPU threads (lower = less CPU usage)

## 🤝 Contributing

Feel free to optimize these tools further or suggest additional memory-saving techniques.
