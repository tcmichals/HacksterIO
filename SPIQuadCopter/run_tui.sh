#!/bin/bash
# Launch the TUI App using the specific venv

VENV_PYTHON="/home/tcmichals/tools/python/python-spidev-imgui/bin/python"
APP_SCRIPT="python/tuiExample/tui_app.py"

if [ ! -x "$VENV_PYTHON" ]; then
    echo "Error: Python interpreter not found at $VENV_PYTHON"
    exit 1
fi

echo "Starting TUI App with $VENV_PYTHON..."
sudo $VENV_PYTHON $APP_SCRIPT
