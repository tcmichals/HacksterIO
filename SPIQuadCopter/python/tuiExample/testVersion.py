from wb_driver import WishboneDriver
import time
import argparse

def main():
    parser = argparse.ArgumentParser(description="Read Wishbone version register via SPI")
    parser.add_argument("--bus", type=int, default=0, help="SPI bus number (default: 0)")
    parser.add_argument("--device", type=int, default=0, help="SPI device number (default: 0)")
    args = parser.parse_args()

    wb = WishboneDriver(bus=args.bus, device=args.device)
    try:
        for i in range(10):
            version = wb.get_version()
            version_int = int.from_bytes(version, 'little')
            print(f"Read {i+1}: Version = 0x{version_int:08X}")
            time.sleep(0.1)
    finally:
        wb.close()

if __name__ == "__main__":
    main()
