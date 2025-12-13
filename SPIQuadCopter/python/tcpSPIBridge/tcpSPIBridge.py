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
        self.transfer_count = 0
        self.total_bytes = 0
        
        if spidev:
            try:
                self._spi = spidev.SpiDev()
                self._spi.open(bus, device)
                self._spi.max_speed_hz = max_speed_hz
                LOG.info("✓ SPI initialized: bus=%d device=%d speed=%d Hz", 
                        bus, device, max_speed_hz)
            except Exception as e:
                LOG.error("✗ Failed to open SPI bus=%d device=%d: %s", 
                         bus, device, e)
                self._spi = None
        else:
            LOG.warning("⚠ spidev module not available, using echo fallback")

    def transfer(self, data: bytes) -> bytes:
        self.transfer_count += 1
        self.total_bytes += len(data)
        
        if self._spi:
            try:
                LOG.debug("→ SPI TX [%d]: %s", len(data), data[:16].hex() + ('...' if len(data) > 16 else ''))
                out = self._spi.xfer2(list(data))
                result = bytes(out)
                LOG.debug("← SPI RX [%d]: %s", len(result), result[:16].hex() + ('...' if len(result) > 16 else ''))
                return result
            except Exception as e:
                LOG.error("✗ SPI transfer error (count=%d): %s", self.transfer_count, e)
                raise
        # fallback: echo the data
        LOG.debug("⚠ SPI fallback echo [%d bytes]", len(data))
        return bytes(data)

    def close(self):
        if self._spi:
            try:
                self._spi.close()
                LOG.info("✓ SPI closed (transfers=%d, bytes=%d)", 
                        self.transfer_count, self.total_bytes)
            except Exception as e:
                LOG.warning("⚠ Error closing SPI: %s", e)


async def handle_client(reader: asyncio.StreamReader, writer: asyncio.StreamWriter, spi: SPIDriver):
    addr = writer.get_extra_info('peername')
    LOG.info("🔗 Client connected: %s", addr)
    
    msg_count = 0
    start_time = asyncio.get_event_loop().time()

    try:
        while True:
            # Read 4-byte length
            hdr = await reader.readexactly(4)
            (length,) = struct.unpack('>I', hdr)
            
            if length == 0:
                # zero-length means keepalive/heartbeat — respond with zero
                LOG.debug("💓 Keepalive from %s", addr)
                writer.write(hdr)
                await writer.drain()
                continue

            data = await reader.readexactly(length)
            msg_count += 1

            # Unpack comm_proto message
            try:
                msg = unpack_message(data)
                LOG.debug("📨 Message #%d from %s: cmd=%d type=%d len=%d", 
                         msg_count, addr, msg.command, msg.content_type, len(msg.payload))
            except Exception as e:
                LOG.error("✗ Malformed message #%d from %s: %s", msg_count, addr, e)
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
                    LOG.debug("⚡ SPI transfer request: %d bytes", len(msg.payload))
                    resp_payload = spi.transfer(msg.payload)
                    LOG.debug("✓ SPI transfer complete: %d bytes received", len(resp_payload))
                except Exception as e:
                    LOG.exception("✗ SPI transfer failed for %s: %s", addr, e)
                    resp_payload = b""
                resp_msg = Message(command=Cmd.SPI_TRANSFER, content_type=ContentType.RAW, payload=resp_payload)
            elif msg.command == Cmd.PING:
                LOG.debug("🏓 Ping from %s", addr)
                resp_msg = Message(command=Cmd.PING, content_type=ContentType.TEXT, payload=b"pong")
            else:
                # unknown command echo
                LOG.warning("⚠ Unknown command %d from %s, echoing", msg.command, addr)
                resp_msg = Message(command=msg.command, content_type=msg.content_type, payload=msg.payload)

            out = pack_message(resp_msg)
            writer.write(struct.pack('>I', len(out)))
            writer.write(out)
            await writer.drain()
            LOG.debug("📤 Response sent: %d bytes", len(out))
            
    except asyncio.IncompleteReadError:
        elapsed = asyncio.get_event_loop().time() - start_time
        LOG.info("🔌 Client disconnected: %s (duration=%.1fs, messages=%d)", 
                addr, elapsed, msg_count)
    except Exception as e:
        elapsed = asyncio.get_event_loop().time() - start_time
        LOG.exception("✗ Error handling client %s (duration=%.1fs, messages=%d): %s", 
                     addr, elapsed, msg_count, e)
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
    LOG.info("🚀 Server ready on %s", addrs)

    async with server:
        await server.serve_forever()


def main():
    import argparse
    import sys

    parser = argparse.ArgumentParser(description='TCP to SPI Bridge Server')
    parser.add_argument('--host', default='0.0.0.0', help='Bind address (default: 0.0.0.0)')
    parser.add_argument('--port', type=int, default=9999, help='TCP port (default: 9999)')
    parser.add_argument('--bus', type=int, default=0, help='SPI bus number (default: 0)')
    parser.add_argument('--device', type=int, default=0, help='SPI device number (default: 0)')
    parser.add_argument('--log-level', default='INFO', 
                       choices=['DEBUG', 'INFO', 'WARNING', 'ERROR'],
                       help='Logging level (default: INFO)')
    args = parser.parse_args()

    # Enhanced logging for systemd/journal
    logging.basicConfig(
        level=getattr(logging, args.log_level),
        format='%(asctime)s [%(levelname)-8s] %(name)s: %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S',
        stream=sys.stdout
    )
    
    LOG.info("=" * 60)
    LOG.info("TCP to SPI Bridge Server")
    LOG.info("=" * 60)
    LOG.info("Configuration:")
    LOG.info("  Listen:   %s:%d", args.host, args.port)
    LOG.info("  SPI:      bus=%d device=%d", args.bus, args.device)
    LOG.info("  Log Level: %s", args.log_level)
    LOG.info("=" * 60)

    try:
        asyncio.run(run_server(args.host, args.port, args.bus, args.device))
    except KeyboardInterrupt:
        LOG.info("🛑 Shutting down (Ctrl+C received)")
    except Exception as e:
        LOG.exception("💥 Fatal error: %s", e)
        sys.exit(1)


if __name__ == '__main__':
    main()
