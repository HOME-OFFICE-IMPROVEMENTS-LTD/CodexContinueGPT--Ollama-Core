# DB-GPT Memory-Optimized Models

This directory contains model definitions optimized for different memory constraints.

## Available Models

- **smart-shell-agent.Modelfile**: Full-featured smart shell agent
  - Suitable for systems with 8GB+ RAM
  - Provides comprehensive natural language interaction

- **smart-shell-agent-lite.Modelfile**: Memory-efficient version of the smart shell agent
  - Suitable for systems with 4GB+ RAM
  - Provides natural language interaction with lower memory requirements

- **shell-agent.Modelfile**: Standard shell agent with alias training
  - Suitable for systems with 4GB+ RAM
  - Focused on command assistance and aliases

- **minimal-shell-agent.Modelfile**: Minimal version for very low memory environments
  - Suitable for systems with 2GB+ RAM
  - Basic functionality with minimal memory footprint

- **lite-test.Modelfile**: Ultra-lightweight test model
  - Suitable for testing on systems with severe memory constraints
  - Not recommended for production use

- **minimal-test.Modelfile**: Minimal test model
  - Used for testing and verification of the memory management system
  - Extremely small memory footprint

- **test-model.Modelfile**: Basic test model
  - Used for testing and development purposes
  - Moderate memory requirements

## Usage

These models are automatically used by the memory management system based on available system resources. You can also manually select them:

```bash
# Run the full smart shell agent
../../../run-smart-shell-agent.sh

# Run the memory-efficient smart shell agent
../../../run-smart-shell-agent-lite.sh

# Run the minimal shell agent
../../../test-minimal-agent.sh
```

## Model Characteristics

| Model | Memory Usage | Context Window | Features |
|-------|-------------|---------------|----------|
| smart-shell-agent | 8GB+ | 8K | Natural language, proactive features |
| smart-shell-agent-lite | 4GB+ | 4K | Natural language, basic assistance |
| shell-agent | 4GB+ | 4K | Command assistance, aliases |
| minimal-shell-agent | 2GB+ | 2K | Simple command assistance |
| lite-test | 1GB+ | 1K | Basic functionality only |
| minimal-test | <1GB | 512 | Testing purposes only |
| test-model | 2GB+ | 2K | Development testing |

## Customizing Models

You can customize these models by editing the respective Modelfile. After editing, rebuild the model:

```bash
# For example, to rebuild the lite model
ollama create smart-shell-agent-lite -f smart-shell-agent-lite.Modelfile
```

## Auto-Selection

The auto-memory-manager.sh script automatically selects the appropriate model based on your system's available memory, ensuring optimal performance without overloading your system:

```bash
# Let the system choose the best model for your memory
../../../auto-memory-manager.sh
```
