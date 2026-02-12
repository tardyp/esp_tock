#!/usr/bin/env python3
"""
Serial Monitor for ESP32-C6 Hardware Testing

Usage:
    python3 monitor_serial.py [PORT] [BAUDRATE] [DURATION]

Examples:
    python3 monitor_serial.py /dev/tty.usbmodem595B0538021 115200 10
    python3 monitor_serial.py  # Uses defaults

Defaults:
    PORT: /dev/tty.usbmodem595B0538021 (CH343 UART on macOS)
    BAUDRATE: 115200
    DURATION: 5 seconds
"""

import serial
import sys
import time
import os
from datetime import datetime


def wait_for_port(port, timeout=10, check_interval=0.5):
    """
    Wait for serial port device to exist in filesystem
    
    Args:
        port: Serial port device path
        timeout: Maximum time to wait in seconds
        check_interval: Time between checks in seconds
    
    Returns:
        True if port exists, False if timeout
    """
    start_time = time.time()
    while time.time() - start_time < timeout:
        if os.path.exists(port):
            return True
        time.sleep(check_interval)
    return False


def is_port_ready(port, baudrate, timeout=1):
    """
    Check if serial port is ready to be opened
    
    Args:
        port: Serial port device path
        baudrate: Baud rate to test with
        timeout: Timeout for open attempt
    
    Returns:
        True if port can be opened, False otherwise
    """
    try:
        ser = serial.Serial(
            port=port,
            baudrate=baudrate,
            timeout=timeout
        )
        ser.close()
        return True
    except OSError as e:
        # Errno 6: Device not configured (USB re-enumeration in progress)
        if e.errno == 6:
            return False
        return False
    except Exception:
        return False


def monitor_serial_with_retry(port, baudrate, duration, output_file=None, 
                               port_timeout=10, port_check_interval=0.5):
    """
    Monitor serial port with retry logic for port availability
    
    Args:
        port: Serial port device path
        baudrate: Baud rate (e.g., 115200)
        duration: Duration to monitor in seconds
        output_file: Optional file to write output to
        port_timeout: Maximum time to wait for port to be ready
        port_check_interval: Time between port availability checks
    
    Returns:
        Captured output as string, or None if port never became ready
    """
    print(f"[{datetime.now().strftime('%H:%M:%S')}] Waiting for port {port} to be ready...")
    
    # First, wait for port to exist in filesystem
    if not wait_for_port(port, timeout=port_timeout, check_interval=port_check_interval):
        print(f"ERROR: Port {port} did not appear within {port_timeout} seconds", file=sys.stderr)
        return None
    
    print(f"[{datetime.now().strftime('%H:%M:%S')}] Port exists, checking if ready to open...")
    
    # Then, wait for port to be ready to open (USB enumeration complete)
    start_time = time.time()
    while time.time() - start_time < port_timeout:
        if is_port_ready(port, baudrate):
            print(f"[{datetime.now().strftime('%H:%M:%S')}] Port ready!")
            break
        time.sleep(port_check_interval)
    else:
        print(f"ERROR: Port {port} not ready within {port_timeout} seconds", file=sys.stderr)
        return None
    
    # Port is ready, proceed with monitoring
    return monitor_serial(port, baudrate, duration, output_file)


def monitor_serial(port, baudrate, duration, output_file=None):
    """
    Monitor serial port and capture output
    
    Args:
        port: Serial port device path
        baudrate: Baud rate (e.g., 115200)
        duration: Duration to monitor in seconds
        output_file: Optional file to write output to
    
    Returns:
        Captured output as string
    """
    print(f"[{datetime.now().strftime('%H:%M:%S')}] Monitoring {port} at {baudrate} baud for {duration} seconds...")
    print("=" * 80)
    
    output_lines = []
    ser = None
    
    try:
        # Open serial port
        ser = serial.Serial(
            port=port,
            baudrate=baudrate,
            bytesize=serial.EIGHTBITS,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            timeout=1,
            xonxoff=False,
            rtscts=False,
            dsrdtr=False
        )
        
        start_time = time.time()
        bytes_received = 0
        
        # Monitor for specified duration
        while time.time() - start_time < duration:
            if ser.in_waiting > 0:
                data = ser.read(ser.in_waiting)
                bytes_received += len(data)
                
                try:
                    # Try to decode as UTF-8
                    text = data.decode('utf-8', errors='replace')
                    print(text, end='', flush=True)
                    output_lines.append(text)
                except Exception as e:
                    # Fall back to hex dump
                    hex_str = data.hex()
                    print(f"[HEX: {hex_str}]", flush=True)
                    output_lines.append(f"[HEX: {hex_str}]")
        
        ser.close()
        
        print("\n" + "=" * 80)
        print(f"[{datetime.now().strftime('%H:%M:%S')}] Monitor complete")
        print(f"Bytes received: {bytes_received}")
        
        # Write to file if specified
        if output_file:
            with open(output_file, 'w') as f:
                f.write(''.join(output_lines))
            print(f"Output saved to: {output_file}")
        
        return ''.join(output_lines)
        
    except serial.SerialException as e:
        print(f"Error opening serial port: {e}", file=sys.stderr)
        print(f"\nAvailable ports:", file=sys.stderr)
        try:
            from serial.tools import list_ports
            for port in list_ports.comports():
                print(f"  {port.device}: {port.description}", file=sys.stderr)
        except:
            pass
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n\nMonitoring interrupted by user")
        if ser:
            ser.close()
        sys.exit(0)
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        if ser:
            ser.close()
        sys.exit(1)

def main():
    # Parse command line arguments
    port = sys.argv[1] if len(sys.argv) > 1 else '/dev/tty.usbmodem595B0538021'
    baudrate = int(sys.argv[2]) if len(sys.argv) > 2 else 115200
    duration = int(sys.argv[3]) if len(sys.argv) > 3 else 5
    output_file = sys.argv[4] if len(sys.argv) > 4 else None
    
    # Use retry logic with 10 second timeout for port to be ready
    result = monitor_serial_with_retry(
        port, baudrate, duration, output_file,
        port_timeout=10, port_check_interval=0.5
    )
    
    if result is None:
        sys.exit(1)

if __name__ == '__main__':
    main()
