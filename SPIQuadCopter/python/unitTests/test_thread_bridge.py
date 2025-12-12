import asyncio
import threading
import time

import pytest

from imguTestApp.thread_bridge import ThreadBridge, Cmd


def test_push_pop_gui():
    loop = asyncio.new_event_loop()
    bridge = ThreadBridge(loop)

    bridge.push_to_gui(Cmd.LOG_MESSAGE, "hello-gui")
    pkt = bridge.pop_from_gui()
    assert pkt is not None
    assert pkt.command == Cmd.LOG_MESSAGE
    assert pkt.payload == "hello-gui"


def test_push_pop_async():
    loop = asyncio.new_event_loop()

    def run_loop():
        asyncio.set_event_loop(loop)
        loop.run_forever()

    t = threading.Thread(target=run_loop, daemon=True)
    t.start()

    try:
        bridge = ThreadBridge(loop)

        # push into async queue from main thread
        bridge.push_to_async(Cmd.LOG_MESSAGE, "hello-async")

        # schedule a coroutine on the loop to pop the packet
        fut = asyncio.run_coroutine_threadsafe(bridge.pop_from_async(), loop)
        pkt = fut.result(timeout=2.0)

        assert pkt is not None
        assert pkt.command == Cmd.LOG_MESSAGE
        assert pkt.payload == "hello-async"
    finally:
        loop.call_soon_threadsafe(loop.stop)
        t.join(timeout=1.0)
