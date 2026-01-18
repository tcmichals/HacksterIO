#!/bin/bash
# Runner for wb_serial_dshot_mux_tb - delegates to top-level Makefile target
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"
echo "Invoking: make tb-wb-mux"
make tb-wb-mux
