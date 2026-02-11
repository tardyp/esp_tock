#!/bin/bash
#
# Flash ESP32-C6 Hardware Test Script
#
# Usage:
#   ./flash_esp32c6.sh <kernel.elf>
#   ./flash_esp32c6.sh <bootloader.bin> <partition.bin> <app.bin>
#
# Examples:
#   ./flash_esp32c6.sh path/to/nano-esp32-c6-board
#   ./flash_esp32c6.sh bootloader.bin partition-table.bin app.bin
#

set -e

# Configuration
FLASH_PORT="${FLASH_PORT:-/dev/tty.usbmodem112201}"  # ESP32-C6 native USB
CHIP="esp32c6"
ESPFLASH="./espflash/target/release/espflash"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if espflash exists
if [ ! -f "$ESPFLASH" ]; then
    log_error "espflash not found at $ESPFLASH"
    log_info "Building espflash..."
    cd espflash && cargo build --release --bin espflash && cd ..
fi

# Auto-detect port if not set
if [ ! -e "$FLASH_PORT" ]; then
    log_warn "Port $FLASH_PORT not found, attempting auto-detection..."
    
    # Try to find ESP32-C6 port
    if [ "$(uname)" == "Darwin" ]; then
        # macOS
        DETECTED_PORT=$(ls /dev/tty.usbmodem* 2>/dev/null | head -1)
    else
        # Linux
        DETECTED_PORT=$(ls /dev/ttyACM* /dev/ttyUSB* 2>/dev/null | head -1)
    fi
    
    if [ -n "$DETECTED_PORT" ]; then
        log_info "Detected port: $DETECTED_PORT"
        FLASH_PORT="$DETECTED_PORT"
    else
        log_error "No serial port found"
        exit 1
    fi
fi

log_info "Using port: $FLASH_PORT"

# Check arguments
if [ $# -eq 0 ]; then
    log_error "Usage: $0 <kernel.elf> OR $0 <bootloader.bin> <partition.bin> <app.bin>"
    exit 1
fi

# Determine flashing mode
if [ $# -eq 1 ]; then
    # Single ELF file mode
    KERNEL_ELF="$1"
    
    if [ ! -f "$KERNEL_ELF" ]; then
        log_error "Kernel ELF not found: $KERNEL_ELF"
        exit 1
    fi
    
    log_info "Flashing ELF file: $KERNEL_ELF"
    
    # Flash using espflash flash command (handles bootloader automatically)
    $ESPFLASH flash \
        --chip $CHIP \
        --port $FLASH_PORT \
        "$KERNEL_ELF"
    
    log_info "Resetting board..."
    $ESPFLASH reset --port $FLASH_PORT
    
    log_info "✅ Flashing complete!"
    
elif [ $# -eq 3 ]; then
    # Three binary files mode (bootloader, partition, app)
    BOOTLOADER="$1"
    PARTITION="$2"
    APP="$3"
    
    # Verify files exist
    for file in "$BOOTLOADER" "$PARTITION" "$APP"; do
        if [ ! -f "$file" ]; then
            log_error "File not found: $file"
            exit 1
        fi
    done
    
    log_info "Flashing bootloader: $BOOTLOADER"
    $ESPFLASH write-bin 0x0 "$BOOTLOADER" \
        --port $FLASH_PORT --chip $CHIP
    
    log_info "Flashing partition table: $PARTITION"
    $ESPFLASH write-bin 0x8000 "$PARTITION" \
        --port $FLASH_PORT --chip $CHIP
    
    log_info "Flashing application: $APP"
    $ESPFLASH write-bin 0x10000 "$APP" \
        --port $FLASH_PORT --chip $CHIP
    
    log_info "Resetting board..."
    $ESPFLASH reset --port $FLASH_PORT
    
    log_info "✅ Flashing complete!"
    
else
    log_error "Invalid number of arguments"
    log_error "Usage: $0 <kernel.elf> OR $0 <bootloader.bin> <partition.bin> <app.bin>"
    exit 1
fi

# Show board info
log_info "Board information:"
$ESPFLASH board-info --port $FLASH_PORT
