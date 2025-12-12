import asyncio
import threading
import os
import tempfile

from imguTestApp.thread_bridge import ThreadBridge, Cmd
from imguTestApp.tang9k_imgui import ImgApp


def test_bridge_ordering():
    loop = asyncio.new_event_loop()
    bridge = ThreadBridge(loop)

    bridge.push_to_gui(Cmd.LOG_MESSAGE, "first")
    bridge.push_to_gui(Cmd.LOG_MESSAGE, "second")

    p1 = bridge.pop_from_gui()
    p2 = bridge.pop_from_gui()

    assert p1.payload == "first"
    assert p2.payload == "second"


def test_async_multiple_packets():
    loop = asyncio.new_event_loop()

    def run_loop():
        asyncio.set_event_loop(loop)
        loop.run_forever()

    t = threading.Thread(target=run_loop, daemon=True)
    t.start()
    try:
        bridge = ThreadBridge(loop)
        # push several packets quickly
        for i in range(5):
            bridge.push_to_async(Cmd.LOG_MESSAGE, f"m{i}")

        results = []
        for _ in range(5):
            fut = asyncio.run_coroutine_threadsafe(bridge.pop_from_async(), loop)
            pkt = fut.result(timeout=2.0)
            results.append(pkt.payload)

        assert results == [f"m{i}" for i in range(5)]
    finally:
        loop.call_soon_threadsafe(loop.stop)
        t.join(timeout=1.0)


def test_imgapp_save_log_headless(tmp_path):
    # ensure headless init and save_log writes file
    app = ImgApp()
    # append some log lines
    app._append_log("line1")
    app._append_log("line2")

    out = tmp_path / "outlog.txt"
    app.save_log(str(out))
    assert out.exists()
    data = out.read_text()
    assert "line1" in data
    assert "line2" in data
    app.shutdown()
