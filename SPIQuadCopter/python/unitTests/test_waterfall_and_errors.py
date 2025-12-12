import asyncio
import threading
import time

from imguTestApp.tang9k_imgui import ImgApp


def test_waterfall_start_stop():
    app = ImgApp()
    # start waterfall
    app.toggle_waterfall()
    assert app._waterfall_running is True
    # wait a short bit to let worker run
    time.sleep(0.2)
    app.toggle_waterfall()
    assert app._waterfall_running is False
    app.shutdown()


def test_error_handling_on_neopixel():
    # Replace tang9k with an object that raises on neopixel_update
    app = ImgApp()

    class BadTang:
        def neopixel_set_color(self, i, color):
            pass
        def neopixel_update(self):
            raise RuntimeError("update failed")
        def close(self):
            pass

    app.tang9k = BadTang()
    # calling toggle waterfall should not raise
    app.toggle_waterfall()
    time.sleep(0.1)
    app.toggle_waterfall()
    app.shutdown()
