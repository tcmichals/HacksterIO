"""tcpSPIBridge package

Expose the TCP<->SPI bridge server implementation.
"""
import asyncio
import struct
from comm_proto import unpack_message, pack_message, Message, ContentType, Cmd
import logging
from typing import Optional

try:
    import spidev
except Exception:
    spidev = None

LOG = logging.getLogger("tcpSPIBridge")


class SPIDriver:
    def __init__(self, bus: int = 0, device: int = 0, max_speed_hz: int = 1000000):
        self.bus = bus
        self.device = device
        self.max_speed_hz = max_speed_hz
        self._spi = None
        if spidev:
            try:
                self._spi = spidev.SpiDev()
                self._spi.open(bus, device)
                self._spi.max_speed_hz = max_speed_hz
                LOG.info("Opened spidev on bus %s device %s", bus, device)
            except Exception as e:
                LOG.warning("Failed to open spidev: %s", e)
                self._spi = None

    def transfer(self, data: bytes) -> bytes:
        if self._spi:
            # spidev.xfer2 expects list of ints
            out = self._spi.xfer2(list(data))
            return bytes(out)
        # fallback: echo the data
        return bytes(data)

    def close(self):
        if self._spi:
            try:
                self._spi.close()
            except Exception:
                pass


async def handle_client(reader: asyncio.StreamReader, writer: asyncio.StreamWriter, spi: SPIDriver):
    addr = writer.get_extra_info('peername')
    LOG.info("Client connected: %s", addr)

    try:
        while True:
            # Read 4-byte length
            hdr = await reader.readexactly(4)
            (length,) = struct.unpack('>I', hdr)
            if length == 0:
                # zero-length means keepalive/heartbeat — respond with zero
                writer.write(hdr)
                await writer.drain()
                continue

            data = await reader.readexactly(length)

            # Unpack comm_proto message
            try:
                msg = unpack_message(data)
            except Exception as e:
                LOG.exception("Malformed message: %s", e)
                # respond with empty
                resp_msg = Message(command=0, content_type=ContentType.TEXT, payload=b"malformed")
                out = pack_message(resp_msg)
                writer.write(struct.pack('>I', len(out)))
                writer.write(out)
                await writer.drain()
                continue

            # Handle common commands
            if msg.command == Cmd.SPI_TRANSFER:
                # payload assumed RAW
                try:
                    resp_payload = spi.transfer(msg.payload)
                except Exception as e:
                    LOG.exception("SPI transfer error: %s", e)
                    resp_payload = b""
                resp_msg = Message(command=Cmd.SPI_TRANSFER, content_type=ContentType.RAW, payload=resp_payload)
            elif msg.command == Cmd.PING:
                resp_msg = Message(command=Cmd.PING, content_type=ContentType.TEXT, payload=b"pong")
            else:
                # unknown command echo
                resp_msg = Message(command=msg.command, content_type=msg.content_type, payload=msg.payload)

            out = pack_message(resp_msg)
            writer.write(struct.pack('>I', len(out)))
            writer.write(out)
            await writer.drain()
    except asyncio.IncompleteReadError:
        LOG.info("Client disconnected: %s", addr)
    except Exception:
        LOG.exception("Error handling client %s", addr)
    finally:
        try:
            writer.close()
            await writer.wait_closed()
        except Exception:
            pass


async def run_server(host: str = '0.0.0.0', port: int = 9999, spi_bus: int = 0, spi_dev: int = 0):
    spi = SPIDriver(spi_bus, spi_dev)

    server = await asyncio.start_server(lambda r, w: handle_client(r, w, spi), host, port)
    addrs = ', '.join(str(sock.getsockname()) for sock in server.sockets)
    LOG.info(f"Serving on {addrs}")

    async with server:
        await server.serve_forever()


def main():
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument('--host', default='0.0.0.0')
    parser.add_argument('--port', type=int, default=9999)
    parser.add_argument('--bus', type=int, default=0)
    parser.add_argument('--device', type=int, default=0)
    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO)

    try:
        asyncio.run(run_server(args.host, args.port, args.bus, args.device))
    except KeyboardInterrupt:
        LOG.info("Shutting down")


if __name__ == '__main__':
    main()
