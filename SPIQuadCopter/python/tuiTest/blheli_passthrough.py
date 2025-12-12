"""
BLHeli Passthrough Module

Enables BLHeli passthrough mode on the Tang9K FPGA, allowing BLHeli tools
to communicate directly with ESCs through the Tang9K's serial port.

The Python app simply:
1. Switches the mux to serial mode (vs DSHOT)
2. Enables half-duplex serial mode
3. BLHeli tools connect to the actual serial port (USB-TTL adapter or FPGA serial)

No virtual devices or PTY needed - just hardware passthrough!
"""

from typing import Optional, Callable


class BLHeliPassthrough:
    """BLHeli ESC passthrough mode controller"""
    
    def __init__(self, tang9k, on_data_callback: Optional[Callable] = None):
        """
        Initialize BLHeli passthrough
        
        Args:
            tang9k: Tang9K hardware interface instance
            on_data_callback: Optional callback for status messages
        """
        self.tang9k = tang9k
        self.on_data_callback = on_data_callback
        self.passthrough_enabled = False
    
    def enable_passthrough(self):
        """Enable passthrough mode (switch mux to serial, enable half-duplex)"""
        # Set mux to serial mode (0 = serial, 1 = DSHOT)
        self.tang9k.set_serial_mode()
        
        # Enable half-duplex serial mode for ESC communication
        self.tang9k.serial_set_half_duplex(True)
        
        self.passthrough_enabled = True
        
        if self.on_data_callback:
            self.on_data_callback("Passthrough enabled: Serial mode active (115200 baud, half-duplex)")
            self.on_data_callback("Connect BLHeli tool to your serial port (e.g., /dev/ttyUSB0)")
    
    def disable_passthrough(self):
        """Disable passthrough mode (switch back to DSHOT)"""
        # Disable half-duplex mode
        self.tang9k.serial_set_half_duplex(False)
        
        # Set mux back to DSHOT mode
        self.tang9k.set_dshot_mode()
        
        self.passthrough_enabled = False
        
        if self.on_data_callback:
            self.on_data_callback("Passthrough disabled: DSHOT mode active")
    
    def close(self):
        """Cleanup - disable passthrough if enabled"""
        if self.passthrough_enabled:
            self.disable_passthrough()
