# Security Policy

## Overview

CodexContinueGPT-Ollama-Core is committed to maintaining the security and integrity of our software. This document outlines our security policy, supported versions, and vulnerability reporting procedures.

## Supported Versions

We currently provide security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 2.0.x   | :white_check_mark: |
| 1.5.x   | :white_check_mark: |
| 1.0.x   | :x:                |
| < 1.0   | :x:                |

## Security Considerations

CodexContinueGPT-Ollama-Core interacts with local files and can execute commands. When using this tool, please be aware of the following security considerations:

1. **File System Access**: The tool has access to read and write files on your system. Only use it in trusted environments and review the function calling implementations before use.

2. **Command Execution**: The tool can execute shell commands. Ensure that the `run_command` function in function_calling.sh includes proper sanitization and restrictions.

3. **Memory Management**: Conversation history is stored locally. Be mindful of sensitive information that might be stored in the memory files.

4. **Model Security**: The tool interacts with Ollama models. Use models from trusted sources and be aware of potential vulnerabilities in model responses.

5. **MCP Server**: When using the MCP server, ensure it's properly secured, especially if exposed beyond localhost.

## Reporting a Vulnerability

We take all security vulnerabilities seriously. We appreciate your efforts to responsibly disclose your findings.

### How to Report

1. **Email**: Send details of the vulnerability to info@hoiltd.com
2. **GitHub**: For less critical issues, open a GitHub issue with the label "security" after redacting any sensitive information

### What to Include

1. Description of the vulnerability
2. Steps to reproduce
3. Potential impact
4. Suggested mitigation or fix (if known)

### Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Fix Implementation**: Timeline varies based on severity and complexity

### What to Expect

- We will acknowledge receipt of your vulnerability report
- We will investigate and provide regular updates on our progress
- We will fix the issue in accordance with our prioritization schedule
- We will publicly acknowledge your responsible disclosure (unless you request otherwise)

## Security Best Practices for Users

1. **Regular Updates**: Keep the software updated to the latest supported version.
2. **Least Privilege**: Run the software with the minimal required permissions.
3. **Code Review**: Review any code changes, especially in the function_calling.sh file before implementation.
4. **API Security**: When integrating with other systems, use proper authentication and secure communication channels.
5. **Input Validation**: When developing extensions, ensure proper input validation to prevent injection attacks.

## Responsible Disclosure Policy

We follow a coordinated vulnerability disclosure process:

1. Reporter submits vulnerability details to the security team
2. We acknowledge receipt and begin investigation
3. We develop and test a fix
4. We release the fix to users
5. We publicly disclose the vulnerability (typically 30 days after the fix)

We're committed to addressing security issues transparently and promptly. Your assistance in keeping CodexContinueGPT-Ollama-Core secure is greatly appreciated.

## Security Updates

Security updates will be announced through:
- GitHub repository releases
- Our official documentation
- Security advisories on GitHub

---

This security policy is subject to change and improvement. Last updated: May 18, 2025.
