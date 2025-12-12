import asyncio
import threading
import queue
import time
from dataclasses import dataclass
from enum import IntEnum
from typing import Union, Optional, Any

import numpy as np


class Cmd(IntEnum):
    LOG_MESSAGE = 1
    UPDATE_IMAGE = 2
    PROCESS_DATA = 3
    RESET = 4


@dataclass
class DataPacket:
    timestamp: float
    command: int
    payload: Union[str, np.ndarray, None]


class ThreadBridge:
    def __init__(self, loop: asyncio.AbstractEventLoop):
        self.loop = loop
        self.to_gui_queue: queue.Queue[DataPacket] = queue.Queue()
        self._to_async_queue: asyncio.Queue[DataPacket] = asyncio.Queue()

    def push_to_gui(self, command: int, payload: Union[str, np.ndarray, None]):
        packet = DataPacket(timestamp=time.time(), command=command, payload=payload)
        self.to_gui_queue.put(packet)

    def pop_from_gui(self) -> Optional[DataPacket]:
        try:
            return self.to_gui_queue.get_nowait()
        except queue.Empty:
            return None

    def push_to_async(self, command: int, payload: Any):
        packet = DataPacket(timestamp=time.time(), command=command, payload=payload)
        self.loop.call_soon_threadsafe(self._to_async_queue.put_nowait, packet)

    async def pop_from_async(self) -> DataPacket:
        return await self._to_async_queue.get()
