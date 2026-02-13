#!/usr/bin/env python3
"""
Simple serial monitor for ESP32-C6 that works in non-interactive mode.
"""
import serial
import sys
import time

def monitor(port, baudrate, duration):
    """Monitor serial port for specified duration."""
    print(f"Opening {port} at {baudrate} baud for {duration} seconds...")
    
    try:
        with serial.Serial(port, baudrate, timeout=1) as ser:
            start_time = time.time()
            print("=" * 80)
            print("SERIAL OUTPUT START")
            print("=" * 80)
            
            while time.time() - start_time < duration:
                if ser.in_waiting:
                    try:
                        data = ser.read(ser.in_waiting)
                        sys.stdout.buffer.write(data)
                        sys.stdout.buffer.flush()
                    except Exception as e:
                        print(f"\nError reading: {e}", file=sys.stderr)
                else:
                    time.sleep(0.1)
            
            print("\n" + "=" * 80)
            print("SERIAL OUTPUT END")
            print("=" * 80)
            
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print(f"Usage: {sys.argv[0]} <port> <baudrate> <duration>")
        sys.exit(1)
    
    port = sys.argv[1]
    baudrate = int(sys.argv[2])
    duration = int(sys.argv[3])
    
    monitor(port, baudrate, duration)
