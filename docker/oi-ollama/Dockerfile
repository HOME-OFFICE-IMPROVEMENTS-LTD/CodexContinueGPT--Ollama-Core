FROM eosphorosai/dbgpt-openai:latest

# Install open-interpreter
RUN pip install open-interpreter

# Create script directory
WORKDIR /app/scripts

# Copy the ollama integration scripts
COPY ./scripts/open-interpreter-agent.py /app/scripts/
COPY ./scripts/oi-ollama.sh /app/scripts/

# Make scripts executable
RUN chmod +x /app/scripts/oi-ollama.sh

# Set environment variables
ENV PATH="/app/scripts:${PATH}"
