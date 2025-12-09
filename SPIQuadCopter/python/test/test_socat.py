#!/usr/bin/env python3
"""
Test script to verify /dev/ttyBLH0 symlink creation
"""
import time
import subprocess
import os
import pty

def test_device_symlink():
    """Test creating a /dev/ttyBLH0 symlink to a PTY"""
    device_name = "/dev/ttyBLH0"
    
    print(f"Creating /dev symlink: {device_name}")
    print("This requires sudo privileges...\n")
    
    try:
        # Create a PTY first
        master_fd, slave_fd = pty.openpty()
        slave_name = os.ttyname(slave_fd)
        
        print(f"Created PTY: {slave_name}")
        
        # Remove existing symlink if present
        if os.path.exists(device_name) or os.path.islink(device_name):
            print(f"Removing existing {device_name}...")
            subprocess.run(["sudo", "rm", "-f", device_name], check=True)
        
        # Create symlink
        print(f"Creating symlink: {device_name} -> {slave_name}")
        subprocess.run(
            ["sudo", "ln", "-s", slave_name, device_name],
            check=True,
            capture_output=True,
            text=True
        )
        
        # Set permissions
        print(f"Setting permissions on {slave_name}...")
        subprocess.run(
            ["sudo", "chmod", "666", slave_name],
            check=True,
            capture_output=True,
            text=True
        )
        
        # Wait a moment
        time.sleep(0.2)
        
        # Check if symlink exists
        if os.path.exists(device_name):
            print(f"\n✓ SUCCESS: Device {device_name} created!")
            
            # Get device info
            result = subprocess.run(["ls", "-l", device_name], capture_output=True, text=True)
            print(f"\nSymlink info:\n{result.stdout}")
            
            # Show that it's accessible
            result = subprocess.run(["file", device_name], capture_output=True, text=True)
            print(f"File type:\n{result.stdout}")
            
            # Show PTY info
            result = subprocess.run(["ls", "-l", slave_name], capture_output=True, text=True)
            print(f"PTY info:\n{result.stdout}")
            
            print(f"\nDevice is ready for BLHeliSuite/BLHeliConfigurator!")
            print(f"Connect to: {device_name}\n")
            
            # Keep running for 10 seconds
            print("Symlink will remain active for 10 seconds...")
            for i in range(10, 0, -1):
                print(f"{i}...", end=" ", flush=True)
                time.sleep(1.0)
            print("\n")
            
        else:
            print(f"✗ FAILED: Device {device_name} not created")
        
        # Cleanup
        print("Cleaning up...")
        if os.path.exists(device_name):
            subprocess.run(["sudo", "rm", "-f", device_name], check=True)
            print(f"✓ Removed {device_name}")
        
        os.close(master_fd)
        os.close(slave_fd)
        
    except subprocess.CalledProcessError as e:
        print(f"✗ FAILED: {e}")
        if e.stderr:
            print(f"Error: {e.stderr}")
        
    except Exception as e:
        print(f"✗ ERROR: {e}")

if __name__ == "__main__":
    print("=" * 60)
    print("BLHeli Passthrough - /dev/ttyBLH0 Symlink Test")
    print("=" * 60)
    print()
    
    print("This test will:")
    print("  1. Create a PTY device")
    print("  2. Create a symlink at /dev/ttyBLH0 (requires sudo)")
    print("  3. Verify the symlink works")
    print("  4. Clean up after 10 seconds")
    print()
    
    test_device_symlink()
    
    print("\n" + "=" * 60)
    print("Test complete!")
    print("=" * 60)
