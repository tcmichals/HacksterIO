import asyncio
import threading
import time

from imguTestApp.thread_bridge import ThreadBridge, Cmd


def test_bridge_integration_loop():
    loop = asyncio.new_event_loop()

    def run_loop():
        asyncio.set_event_loop(loop)
        loop.run_forever()

    t = threading.Thread(target=run_loop, daemon=True)
    t.start()
    try:
        bridge = ThreadBridge(loop)

        # background producer: push logs periodically
        def producer():
            for i in range(3):
                bridge.push_to_gui(Cmd.LOG_MESSAGE, f"p{i}")
                time.sleep(0.01)

        p = threading.Thread(target=producer, daemon=True)
        p.start()

        # GUI side drain
        seen = []
        while True:
            pkt = bridge.pop_from_gui()
            if pkt is None:
                if not p.is_alive():
                    break
                time.sleep(0.01)
                continue
            seen.append(pkt.payload)

        assert seen == ["p0", "p1", "p2"]
    finally:
        loop.call_soon_threadsafe(loop.stop)
        t.join(timeout=1.0)
