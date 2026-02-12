#!/bin/bash
#
# Flash ESP32-C6 Hardware Test Script
#
# Boot Flow: Embassy-style Direct Boot (NO ESP-IDF bootloader)
# ============================================================
# 1. ESP32-C6 ROM bootloader (in ROM, always runs first)
# 2. ROM reads flash offset 0x0 → CPU address 0x42000000
# 3. ROM validates espflash image header (32 bytes)
# 4. ROM jumps to entry point at 0x42000020
# 5. Tock kernel starts
#
# This approach matches embassy-rs and avoids ESP-IDF bootloader complexity.
# No partition table, no app descriptor, no 2nd stage bootloader required.
#
# Usage:
#   ./flash_esp32c6.sh <kernel.elf>
#
# Examples:
#   ./flash_esp32c6.sh tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board
#

set -e

# Configuration
FLASH_PORT="${FLASH_PORT:-/dev/tty.usbmodem112201}"  # ESP32-C6 native USB
CHIP="esp32c6"

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

# Check if espflash is available (required for direct boot)
if ! command -v espflash &> /dev/null; then
    log_error "espflash not found in PATH"
    log_info "Install with: cargo install espflash"
    log_info "Or use system espflash if available"
    exit 1
fi

log_info "Using espflash: $(which espflash)"
log_info "Version: $(espflash --version)"

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
if [ $# -ne 1 ]; then
    log_error "Usage: $0 <kernel.elf>"
    log_error "Example: $0 tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board"
    exit 1
fi

KERNEL_ELF="$1"

if [ ! -f "$KERNEL_ELF" ]; then
    log_error "Kernel ELF not found: $KERNEL_ELF"
    exit 1
fi

log_info "================================================"
log_info "ESP32-C6 Direct Boot Flash (Embassy-style)"
log_info "================================================"
log_info "Kernel ELF: $KERNEL_ELF"
log_info "Port: $FLASH_PORT"
log_info "Chip: $CHIP"
log_info ""

# Verify ELF entry point is correct for direct boot
ENTRY_POINT=$(llvm-readelf -h "$KERNEL_ELF" 2>/dev/null | grep "Entry point" | awk '{print $4}')
if [ "$ENTRY_POINT" != "0x42000020" ]; then
    log_warn "Entry point is $ENTRY_POINT (expected 0x42000020)"
    log_warn "This may indicate incorrect linker script configuration"
    log_warn "Check boards/nano-esp32-c6/layout.ld"
fi

# Flash using espflash direct mode
# This creates an ESP32 image with:
# - 32-byte espflash header at flash offset 0x0
# - Entry point at 0x42000020 (flash offset 0x20)
# - No bootloader, no partition table, no app descriptor
log_info "Flashing kernel with espflash (direct boot mode)..."
log_info "This will:"
log_info "  1. Convert ELF to ESP32 image format"
log_info "  2. Add 32-byte espflash header"
log_info "  3. Flash to offset 0x0"
log_info "  4. ROM bootloader will jump to 0x42000020"
log_info ""

espflash flash \
    --chip "$CHIP" \
    --port "$FLASH_PORT" \
    --flash-mode dio \
    --flash-freq 80mhz \
    --monitor \
    "$KERNEL_ELF"

log_info ""
log_info "✅ Flashing complete!"
log_info ""

# Show board info
log_info "Board information:"
espflash board-info --port "$FLASH_PORT"
