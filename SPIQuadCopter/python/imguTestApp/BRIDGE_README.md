Imgui app bridge pattern
-----------------------

This package provides a small `ThreadBridge` utility for communicating between
background asyncio workers and an immediate-mode GUI (imgui). The bridge uses
thread-safe producers and a GUI-side consumer that drains queued `DataPacket`s
each frame.

Usage:

- Create a background event loop and `ThreadBridge(loop)` instance.
- Run background producers that call `bridge.push_to_gui(command, payload)`.
- In your GUI `show_gui` callback, drain `bridge.pop_from_gui()` until empty
  and handle `Cmd`-typed commands.

This keeps the GUI responsive and centralizes data packet semantics for all
imgui apps in this repo.
