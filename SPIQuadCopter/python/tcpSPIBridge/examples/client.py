import asyncio
import struct
from comm_proto import Message, ContentType, Cmd, pack_message


async def run(host='127.0.0.1', port=9999, payload=b'\xAA\xBB'):
    reader, writer = await asyncio.open_connection(host, port)
    msg = Message(command=Cmd.SPI_TRANSFER, content_type=ContentType.RAW, payload=payload)
    data = pack_message(msg)
    writer.write(struct.pack('>I', len(data)) + data)
    await writer.drain()

    # read response
    hdr = await reader.readexactly(4)
    (length,) = struct.unpack('>I', hdr)
    data = await reader.readexactly(length)
    print('Response raw bytes:', data)
    writer.close()
    await writer.wait_closed()


if __name__ == '__main__':
    asyncio.run(run())
