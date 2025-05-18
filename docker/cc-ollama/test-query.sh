#!/bin/bash
# Test direct query script

echo "Arguments received: $@"

if [[ $# -gt 0 ]]; then
  echo "Direct query mode"
  echo "Query: $*"
else
  echo "Interactive mode"
  echo "Enter your query:"
  read -r input
  echo "You entered: $input"
fi
