# ESC Configurator Web App Setup

## ⚠️ Important Limitation

**The Web Serial API cannot detect PTY devices or symlinks to PTY devices.** This means `/dev/ttyBLH0` (which is a symlink to a PTY) **will NOT appear** in the browser's serial port list.

### Recommendation

**For ESC configuration, please use desktop applications:**
- **BLHeliSuite** (Windows, or Linux via Wine)
- **BLHeliConfigurator** (cross-platform)

These desktop tools work correctly with the `/dev/ttyBLH0` device created by the BLHeli passthrough mode.

### Why the Web App Doesn't Work

The Web Serial API (used by https://esc-configurator.com/) has security restrictions that limit it to **real hardware serial devices** only:
- ✅ Works with: `/dev/ttyUSB*`, `/dev/ttyACM*` (USB serial adapters)
- ❌ Does NOT work with: `/dev/pts/*` (PTY devices)
- ❌ Does NOT work with: Symlinks to PTY devices (like `/dev/ttyBLH0`)

This is a browser security limitation, not a bug in our implementation.

---

## Alternative: Direct PTY Access (Not Recommended)

If you absolutely must use the web app, you would need to expose the PTY device directly. However, this is **not recommended** because:
1. Browser security prevents PTY device access
2. Even with `raw-usb` permissions, Web Serial API filters out PTY devices
3. The desktop BLHeli tools are more reliable and full-featured

---

## Using Desktop BLHeli Tools (Recommended)

### Browser

**Chrome or Chromium browser is REQUIRED**

The ESC Configurator uses the Web Serial API, which is only available in Chrome/Chromium browsers. Other browsers (Firefox, Safari, Edge, etc.) do NOT support this API and will not work.

### Linux-Specific Setup

If you're using snap-installed Chromium on Linux, you must enable raw USB access:

```bash
# Enable raw USB access for Chromium snap
sudo snap connect chromium:raw-usb

# Verify the connection
snap connections chromium | grep raw-usb
```

Expected output:
```
raw-usb    chromium:raw-usb    :raw-usb    manual
```

### socat Device

The web app requires a standard serial device node. The BLHeli passthrough system creates `/dev/ttyBLH0` using socat.

See [BLHELI_PASSTHROUGH_SETUP.md](BLHELI_PASSTHROUGH_SETUP.md) for complete setup instructions.

## Usage

### Step-by-Step Guide

1. **Start the Tang9K TUI**:
   ```bash
   cd python/test
   python3 tang9k_tui.py --device /dev/spidev0.0
   ```

2. **Enable BLHeli Passthrough**:
   - Press `p` in the TUI
   - Enter your sudo password when prompted (for socat)
   - Verify the serial device is `/dev/ttyBLH0`

3. **Open ESC Configurator**:
   - Launch Chrome or Chromium browser
   - Navigate to: https://esc-configurator.com/
   - You should see the ESC Configurator interface

4. **Connect to ESC**:
   - Click the **"Connect"** button (usually in the top-right)
   - A browser dialog will appear showing available serial ports
   - Select `/dev/ttyBLH0` from the list
   - Click **"Connect"** in the dialog

5. **Configure Your ESC**:
   - Once connected, you can:
     - Read current ESC settings
     - Change motor direction
     - Update timing settings
     - Flash new firmware
     - Adjust PWM frequency
     - And more...

6. **Disconnect When Done**:
   - Click **"Disconnect"** in the ESC Configurator
   - Press `p` in the TUI to disable passthrough mode

## Troubleshooting

### Port Not Showing in Browser Dialog

**Problem:** `/dev/ttyBLH0` doesn't appear in the serial port selection dialog.

**Solutions:**

1. **Check device exists:**
   ```bash
   ls -l /dev/ttyBLH0
   ```
   Should show: `lrwxrwxrwx 1 root root ... /dev/ttyBLH0 -> /dev/pts/X`

2. **Check permissions:**
   ```bash
   stat /dev/ttyBLH0
   ```
   Mode should include read/write permissions (0666)

3. **Verify socat is running:**
   ```bash
   ps aux | grep socat
   ```
   Should show a socat process with `/dev/ttyBLH0`

4. **Try refreshing the browser** - sometimes the port list is cached

5. **Check browser permissions** - ensure Chrome has access to serial ports

### Raw USB Error in Linux

**Problem:** Error message about USB access when connecting.

**Solution:**
```bash
sudo snap connect chromium:raw-usb
```

Then restart Chromium.

### Web Serial API Not Available

**Problem:** Error message "Web Serial API not supported" or similar.

**Solution:**
- Ensure you're using Chrome or Chromium browser (version 89+)
- Other browsers (Firefox, Safari, etc.) do not support Web Serial API
- Update Chrome/Chromium to the latest version

### Connection Fails or Times Out

**Problem:** Browser connects but then loses connection or times out.

**Check:**

1. **Verify serial settings in Tang9K UART:**
   - 115200 baud rate
   - 8 data bits
   - No parity
   - 1 stop bit

2. **Check mux is in serial mode:**
   - Mux register at 0x0400 should be 0 (serial mode)
   - The TUI automatically sets this when enabling passthrough

3. **Check ESC is powered:**
   - ESC must have power to respond
   - Check wiring to ESC signal wire

4. **Monitor the serial log in TUI:**
   - Look for RX/TX activity
   - Errors or timeouts will be displayed

### Browser Shows Wrong Baud Rate

**Problem:** ESC Configurator shows or requires a different baud rate.

**Note:** The Web Serial API connection dialog may show various baud rates, but the actual communication uses the hardware UART settings (115200 baud in this implementation). The baud rate selection in the browser is typically ignored for virtual serial devices.

## Advanced Features

### Multiple ESCs

To configure multiple ESCs, you need to connect them one at a time to the half-duplex serial line. The system only supports one ESC connection at a time.

### Firmware Updates

The ESC Configurator can flash new BLHeli firmware to your ESCs:

1. Connect to the ESC (as described above)
2. Click **"Firmware Flasher"** or similar option
3. Select the firmware file (.hex or .bin)
4. Follow the on-screen instructions
5. Wait for the flash to complete (do NOT disconnect during flashing!)

**Warning:** Incorrect firmware can brick your ESC. Always verify you're using the correct firmware for your specific ESC model.

### Saving Settings

The ESC Configurator can save your settings for backup or to apply to multiple ESCs:

1. Read the current settings from an ESC
2. Click **"Save Settings"** or **"Export"**
3. Save the configuration file
4. To apply to another ESC:
   - Connect to the new ESC
   - Click **"Load Settings"** or **"Import"**
   - Select the saved configuration file
   - Write the settings to the ESC

## Comparison: Web App vs Desktop Apps

| Feature | ESC Configurator (Web) | BLHeliSuite/Configurator (Desktop) |
|---------|------------------------|-------------------------------------|
| Installation | None (browser-based) | Required (download & install) |
| Updates | Automatic | Manual download |
| Platform | Chrome/Chromium only | Windows primarily, Wine for Linux |
| USB Access | Requires snap connect on Linux | Direct access |
| Interface | Modern web UI | Traditional desktop UI |
| Features | Full BLHeli config | Full BLHeli config |
| Performance | Depends on browser | Native performance |

## Browser Compatibility

| Browser | Web Serial API | ESC Configurator Support |
|---------|----------------|--------------------------|
| Chrome/Chromium 89+ | ✅ Yes | ✅ Supported |
| Edge 89+ | ✅ Yes | ✅ Supported |
| Opera 76+ | ✅ Yes | ✅ Supported |
| Firefox | ❌ No | ❌ Not Supported |
| Safari | ❌ No | ❌ Not Supported |
| Brave | ✅ Yes | ✅ Supported (may need flags) |

## Security Considerations

### Why Raw USB Access?

The `raw-usb` snap connection allows Chromium to access USB devices directly. This is required for the Web Serial API to enumerate and connect to serial ports.

Without this permission, the browser cannot:
- List available serial ports
- Open connections to serial devices
- Send/receive data over serial

### Is It Safe?

The `raw-usb` permission is safe when used with trusted applications like Chrome/Chromium. However, it does give the browser low-level USB access.

**Best practices:**
1. Only connect to known, trusted serial devices
2. Only use the ESC Configurator from https://esc-configurator.com/ (official site)
3. Keep Chrome/Chromium updated
4. Don't grant raw USB access to untrusted applications

## Additional Resources

- **ESC Configurator**: https://esc-configurator.com/
- **BLHeli Documentation**: https://github.com/bitdump/BLHeli
- **Web Serial API**: https://developer.mozilla.org/en-US/docs/Web/API/Web_Serial_API
- **Chrome Serial Support**: https://web.dev/serial/

## See Also

- [BLHELI_PASSTHROUGH_SETUP.md](BLHELI_PASSTHROUGH_SETUP.md) - BLHeli passthrough setup
- [BLHELI_PASSTHROUGH.md](../../BLHELI_PASSTHROUGH.md) - Complete passthrough guide
- [SYSTEM_OVERVIEW.md](../../SYSTEM_OVERVIEW.md) - Full system architecture
