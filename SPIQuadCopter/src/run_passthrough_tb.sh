#!/bin/bash
# Wrapper for UART Passthrough Bridge Testbench
# Standardizes on the top-level Makefile for consistent tool discovery.
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "Running UART bridge simulation via root Makefile..."
make tb-bridge
