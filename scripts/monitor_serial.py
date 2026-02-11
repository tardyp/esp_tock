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
from datetime import datetime

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
    
    monitor_serial(port, baudrate, duration, output_file)

if __name__ == '__main__':
    main()
