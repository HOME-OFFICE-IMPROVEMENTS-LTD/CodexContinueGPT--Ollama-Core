# Security Policy for CodexContinueGPT™

## Introduction

This document outlines the security considerations and best practices for using CodexContinueGPT™, especially when integrating with local LLM services like Ollama.

## Local Model Security

### Advantages of Local LLMs

Using local models through Ollama offers several security advantages:

1. **Data Privacy**: Your prompts and queries never leave your system
2. **No API Keys**: No need for API keys that could be leaked or compromised
3. **Network Isolation**: Can operate entirely offline, reducing attack surfaces
4. **Control**: Full control over model behavior and data handling

### Recommended Security Practices

When using local models:

1. **Keep Ollama Updated**: Regularly update Ollama to protect against vulnerabilities:
   ```bash
   ollama pull codellama:latest
   ```

2. **Network Security**: By default, Ollama listens on localhost. Do not expose the Ollama API to the public internet without proper authentication and encryption.

3. **Input Validation**: Even with local models, validate inputs to prevent injection attacks in generated code or commands.

## Script Execution Safety

CodexContinueGPT™ includes features to generate shell scripts and commands. For safety:

1. **Always Review Generated Code**: Never execute generated shell scripts without reviewing them first.

2. **Isolated Testing**: Test generated scripts in a controlled environment before using them in production.

3. **Restrict Permissions**: Run with minimal required permissions:
   ```bash
   # Example: Run with restricted user
   sudo -u restricted_user ./generated_script.sh
   ```

4. **Use `--explain` First**: When uncertain about a command, use the explain feature:
   ```bash
   sh-explain "complex command"  # Review explanation before executing
   ```

## Configuration Security

1. **Protect Config Files**: The Ollama configuration in `configs/dbgpt-proxy-ollama.toml` should have appropriate permissions:
   ```bash
   chmod 600 configs/dbgpt-proxy-ollama.toml
   ```

2. **Environment Variables**: Use environment variables for any sensitive values rather than hardcoding them.

## Docker Security

If using Docker deployment:

1. **Image Verification**: Always verify the integrity of Docker images before running them.

2. **Container Isolation**: Use appropriate isolation techniques:
   ```bash
   docker run --security-opt=no-new-privileges ...
   ```

3. **Resource Limiting**: Set resource limits on containers:
   ```bash
   docker run --memory=4g --cpus=2 ...
   ```

## Reporting Security Issues

If you discover a security vulnerability in CodexContinueGPT™:

1. **Do Not Disclose Publicly**: Please do not disclose security vulnerabilities publicly.

2. **Contact Maintainers**: Contact the maintainers directly through private channels.

3. **Provide Details**: Include detailed steps to reproduce the vulnerability.

## Regular Security Audits

We recommend:

1. **Code Review**: Regularly review the codebase for security issues.

2. **Dependency Updates**: Keep dependencies updated to mitigate known vulnerabilities.

3. **Permission Auditing**: Regularly audit file and directory permissions.

## Security Resources

- [Ollama Security Documentation](https://github.com/ollama/ollama/blob/main/docs/security.md)
- [Shell Script Security Best Practices](https://google.github.io/styleguide/shellguide.html)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)