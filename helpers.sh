#!/bin/bash
# Shared helper functions

SCRIPT_DIR="$(dirname "$0")"
OUTPUTS_FILE="$SCRIPT_DIR/outputs.env"

# Load config and outputs
load_config() {
  source "$SCRIPT_DIR/config.env"
  if [ -f "$OUTPUTS_FILE" ]; then
    source "$OUTPUTS_FILE"
  fi
}

# Save a runtime output value
save_output() {
  local key="$1"
  local value="$2"
  
  # Remove existing line if present
  if [ -f "$OUTPUTS_FILE" ]; then
    sed -i '' "/^${key}=/d" "$OUTPUTS_FILE" 2>/dev/null || sed -i "/^${key}=/d" "$OUTPUTS_FILE"
  fi
  
  # Append new value
  echo "${key}=${value}" >> "$OUTPUTS_FILE"
  echo "  Saved: ${key}=${value}"
}
