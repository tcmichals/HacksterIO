import spidev
import struct
import time

class MockSpi:
    def open(self, bus, device):
        print(f"[MockSPI] Opened bus={bus}, device={device}")
        self.max_speed_hz = 0
        self.mode = 0

    def close(self):
        print("[MockSPI] Closed")

    def xfer2(self, data):
        # Return dummy data of same length
        # debug: print(f"[MockSPI] xfer2: {list(data)}")
        return [0] * len(data)

class WishboneDriver:
    def __init__(self, bus=0, device=0, speed_hz=1000000):
        """
        Initialize SPI Wishbone driver.
        Default speed: 1MHz.
        """
        self.spi = spidev.SpiDev()
        try:
            self.spi.open(bus, device)
            self.spi.max_speed_hz = speed_hz
            self.spi.mode = 0
            self.mock = False
        except FileNotFoundError:
            print("[Warning] SPI device not found. Using Mock driver.")
            self.spi = MockSpi()
            self.spi.open(bus, device)
            self.mock = True

    def close(self):
        self.spi.close()

    def _transfer(self, data):
        # spidev xfer2 maintains CS active during the entire transfer
        if self.mock:
             # Basic debug for mock
             # print(f"TX: {[hex(b) for b in data]}")
             pass
        return self.spi.xfer2(list(data))

    def write(self, addr, data: bytes):
        """
        Write data to a Wishbone address.
        Protocol: 0xA2 + [LEN 2B LE] + [ADDR 4B LE] + [DATA N] + [0xDA]
        Response: [DA] [0x22] [len echo] [addr echo] [0xEE ack per word]
        
        NOTE: All multi-byte values are Little Endian.
        """
        cmd = 0xA2
        sync = 0xDA
        length = len(data)
        
        # Structure: Cmd (1B), Len (2B, LE), Addr (4B, LE)
        header = struct.pack('<BHI', cmd, length, addr)
        
        # Full payload: Header + Data + Sync (0xDA)
        payload = header + data + bytes([sync])
        
        self._transfer(payload)

    def read(self, addr, length):
        """
        Read data from a Wishbone address.
        Protocol: 0xA1 + [LEN 2B LE] + [ADDR 4B LE] + [0x55 pads N] + [0xDA]
        Response: [DA] [0x21] [len echo 2B] [addr echo 4B] [data N] [DA echo?]
        
        Response is shifted by 1 byte (SPI full-duplex).
        """
        cmd = 0xA1
        pad = 0x55
        sync = 0xDA
        
        # Structure: Cmd (1B), Len (2B, LE), Addr (4B, LE)
        header = struct.pack('<BHI', cmd, length, addr)
        
        # Pad bytes for data clocking (0x55)
        pad_bytes = bytes([pad] * length)
        
        # Full TX: Header(7) + Pads(length) + Sync(1)
        # RX offset: [DA][0x21][len0][len1][addr0][addr1][addr2][addr3][data...]
        # Data starts at byte index 8
        tx_data = header + pad_bytes + bytes([sync])
        rx_data = self._transfer(tx_data)
        
        # The first 8 bytes are: [DA][resp][len0][len1][addr0][addr1][addr2][addr3]
        # Data comes after that (bytes 8 to 8+length-1)
        return bytes(rx_data[8:8+length])

    # --- Convenience Methods ---

    def get_version(self):
        # Version is at 0x0000 (SPI bus slave 0 in wb_mux_6)
        # Returns 4 bytes (32-bit register) - should be 0xDEADBEEF
        return self.read(0x0000, 4)

    # --- Peripheral Methods ---

    def read_pwm_inputs(self):
        """
        Reads 6 PWM input channels from 0x200 (Wishbone Slave 1).
        Map: 0x00-0x14 = Ch0-Ch5 (16-bit values).
        Returns a list of 6 integers (microseconds).
        """
        # Read 24 bytes (6 channels * 4 bytes per word alignment)
        # Note: Address decode uses wb_adr_i[6:2], so addresses are 0x00, 0x04... etc.
        # We can burst read 24 bytes starting at 0x200.
        raw_data = self.read(0x200, 24)
        
        values = []
        for i in range(6):
            # Each word is 4 bytes (Big Endian from our read() method logic? No, spidev is bytewise.
            # Host CPU is LE (usually), FPGA might pack data.
            # Wait, wb_dat_o in pwmdecoder_wb is assigned: {16'h0, pwm_value}.
            # If we read 4 bytes, we get 0,0,Hi,Lo (if BE) or Lo,Hi,0,0 (if LE)?
            # Wishbone is generally Big Endian on the bus or Native?
            # Standard Wishbone B3 doesn't enforce endianness, but OpenCores often uses Big Endian.
            # Let's assume the bytes come in [0, 0, MSB, LSB] order byte-streamwise if we treat it as BE.
            # Spidev xfer returns bytes in order.
            # Let's look at the read(): struct.pack('>BIH', ...) for header.
            # The Payload returned is raw bytes.
            # If the FPGA is standard logic, `wb_dat_o` is 32-bit.
            # `axis_wb_master` serializes:
            # STATE_READ_2 sends data_reg[AXIS_DATA_WORD_SIZE*count_reg +: ...].
            # Count counts 0 upwards.
            # If AXIS_DATA_WIDTH=8, WB=32.
            # It sends Byte 0, Byte 1, Byte 2, Byte 3 of the 32-bit word.
            # Verilog slices [7:0] as byte 0? Typically [7:0] is LSB.
            # `data_reg[8*0 +: 8]` is `data_reg[7:0]`.
            # So Byte 0 sent is LSB.
            # So the stream is Little Endian (LSB first).
            
            offset = i * 4
            # LSB is at offset, MSB at offset+3 (if full 32-bit used).
            # Decoder returns {16'h0, pwm_value[15:0]}.
            # pwm_value is at bottom.
            # So [7:0] (Byte 0) is stored at offset.
            # [15:8] (Byte 1) is stored at offset+1.
            # [23:16] (Byte 2) is 0.
            # [31:24] (Byte 3) is 0.
            
            val = raw_data[offset] | (raw_data[offset+1] << 8)
            values.append(val)
        return values

    def set_dshot(self, motor_idx, value):
        """
        Set DSHOT value for a motor.
        Base: 0x300.
        Registers: 0x00 (M1), 0x04 (M2), 0x08 (M3), 0x0C (M4).
        motor_idx: 1-4
        value: 0-2047
        """
        if not (1 <= motor_idx <= 4):
            return
        
        offset = (motor_idx - 1) * 4
        addr = 0x300 + offset
        
        # Helper to pack 32-bit LE (LSB first) because of the LSB-first transmission analysis above.
        data = struct.pack('<I', value)
        self.write(addr, data)

    def set_neopixel(self, index, r, g, b, w=0):
        """
        Set NeoPixel color.
        Base: 0x500.
        wb_neoPx.v Map:
          0x00, 0x04...0x1C for indices 0..7.
          Writes must be to the specific address for the pixel index.
        Format: 32-bit GRBW for SK6812 (G=MSB, W=LSB)
        """
        if index > 7:
            return
            
        addr = 0x500 + (index * 4)
        
        # Pack G R B W (Most common SK6812 order)
        # MSB ....... LSB
        # G . R . B . W
        val = (g << 24) | (r << 16) | (b << 8) | w
        
        # Pack as Little Endian for the bus write 
        data = struct.pack('<I', val)
        self.write(addr, data)

    def get_neopixels(self):
        """
        Read all 8 NeoPixel colors from the FPGA.
        Returns a list of 8 tuples: (r, g, b, w)
        """
        # Read 32 bytes (8 pixels * 4 bytes)
        raw_data = self.read(0x500, 32)
        
        results = []
        for i in range(8):
            offset = i * 4
            # We packed it as (g << 24) | (r << 16) | (b << 8) | w
            # Our read() returns bytes in LSB-first order (Little Endian).
            # Byte 0 = w, Byte 1 = b, Byte 2 = r, Byte 3 = g
            w = raw_data[offset]
            b = raw_data[offset+1]
            r = raw_data[offset+2]
            g = raw_data[offset+3]
            results.append((r, g, b, w))
        return results

    def trigger_neopixel_update(self):
        """
        Write to an address outside 0x00-0x1C (e.g., 0x20) relative to 0x500
        to trigger the update logic in wb_neoPx.v.
        """
        addr = 0x520 # 0x500 + 0x20
        self.write(addr, b'\x00\x00\x00\x00')

    # --- LED Methods ---
    def set_leds(self, val):
        """
        Set on-board LEDs (4 bits for LED 1-4).
        Base: 0x100 (Slave 1 - LED Controller). Offset 0x00.
        """
        # Pack 32-bit (byte 0 is LSB, which is what we want)
        data = struct.pack('<I', val & 0x0F)  # 4 bits for 4 LEDs
        self.write(0x100, data)

    def get_leds(self):
        """
        Read on-board LEDs state (4 bits for LED 1-4).
        Base: 0x100 (Slave 1 - LED Controller). Offset 0x00.
        """
        data = self.read(0x100, 4)
        # Assume byte 0 is LSB
        return data[0] & 0x0F  # 4 bits for 4 LEDs

    def toggle_leds(self, mask):
        """
        Toggle LEDs based on mask (4 bits for LED 1-4).
        Base: 0x100 (Slave 1 - LED Controller). Offset 0x04 = Toggle register.
        """
        offset = 0x104
        data = struct.pack('<I', mask & 0x0F)  # 4 bits for 4 LEDs
        self.write(offset, data)
