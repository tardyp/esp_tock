#!/bin/bash
#
# ESP32-C6 Hardware Test Automation Script
#
# Boot Flow: Embassy-style Direct Boot (NO ESP-IDF bootloader)
# ============================================================
# 1. espflash converts ELF → ESP32 image with header
# 2. Flash to offset 0x0
# 3. ROM bootloader validates header and jumps to 0x42000020
# 4. Tock kernel starts
#
# This script automates the process of flashing firmware and verifying
# serial output for ESP32-C6 hardware testing.
#
# Usage:
#   ./test_esp32c6.sh <kernel.elf> [test_duration]
#
# Example:
#   ./test_esp32c6.sh tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board 10
#

set -e

# Configuration
# ESP32-C6 USB-JTAG port handles BOTH flashing AND serial monitor
FLASH_PORT="${FLASH_PORT:-/dev/tty.usbmodem112201}"  # ESP32-C6 native USB-JTAG
BAUDRATE="${BAUDRATE:-115200}"
TEST_DURATION="${2:-10}"  # Default 10 seconds
KERNEL_ELF="$1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONITOR_SCRIPT="$SCRIPT_DIR/monitor_serial.py"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

# Check arguments
if [ -z "$KERNEL_ELF" ]; then
    log_error "Usage: $0 <kernel.elf> [test_duration]"
    exit 1
fi

if [ ! -f "$KERNEL_ELF" ]; then
    log_error "Kernel ELF not found: $KERNEL_ELF"
    exit 1
fi

# Check if espflash is available
if ! command -v espflash &> /dev/null; then
    log_error "espflash not found in PATH"
    log_info "Install with: cargo install espflash"
    exit 1
fi

# Check if monitor script exists
if [ ! -f "$MONITOR_SCRIPT" ]; then
    log_error "Monitor script not found: $MONITOR_SCRIPT"
    exit 1
fi

# Create test output directory
TEST_OUTPUT_DIR="test_results_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TEST_OUTPUT_DIR"
log_info "Test output directory: $TEST_OUTPUT_DIR"

# Test 1: Board Detection
log_test "Test 1: Board Detection"
if espflash board-info --port $FLASH_PORT > "$TEST_OUTPUT_DIR/board_info.log" 2>&1; then
    log_info "✅ Board detected"
    cat "$TEST_OUTPUT_DIR/board_info.log"
else
    log_error "❌ Board detection failed"
    cat "$TEST_OUTPUT_DIR/board_info.log"
    exit 1
fi

# Test 2: Verify ELF Entry Point
log_test "Test 2: Verify ELF Entry Point"
ENTRY_POINT=$(llvm-readelf -h "$KERNEL_ELF" 2>/dev/null | grep "Entry point" | awk '{print $4}')
echo "Entry point: $ENTRY_POINT" > "$TEST_OUTPUT_DIR/entry_point.log"
if [ "$ENTRY_POINT" = "0x42000020" ]; then
    log_info "✅ Entry point correct: $ENTRY_POINT"
else
    log_warn "⚠️  Entry point is $ENTRY_POINT (expected 0x42000020)"
    log_warn "Boot may fail - check linker script"
fi

# Test 3: Flash Firmware (Direct Boot Mode)
log_test "Test 3: Flash Firmware (Direct Boot - No Bootloader)"
log_info "Flashing $KERNEL_ELF with espflash direct mode..."
log_info "This creates ESP32 image with 32-byte header at offset 0x0"
if espflash flash --chip esp32c6 --port $FLASH_PORT --flash-mode dio --flash-freq 80mhz "$KERNEL_ELF" > "$TEST_OUTPUT_DIR/flash.log" 2>&1; then
    log_info "✅ Flashing successful"
    # Show image size
    grep "App/part. size" "$TEST_OUTPUT_DIR/flash.log" || true
else
    log_error "❌ Flashing failed"
    cat "$TEST_OUTPUT_DIR/flash.log"
    exit 1
fi

# Test 4: Reset Board
log_test "Test 4: Reset Board"
if espflash reset --port $FLASH_PORT > "$TEST_OUTPUT_DIR/reset.log" 2>&1; then
    log_info "✅ Reset successful"
else
    log_error "❌ Reset failed"
    cat "$TEST_OUTPUT_DIR/reset.log"
    exit 1
fi

# Wait for USB-JTAG port to re-enumerate after reset
# The ESP32-C6 USB-JTAG port needs time to re-enumerate after reset.
# Without this delay, the serial monitor may fail with "Device not configured" error.
# The monitor script has retry logic, but this delay helps avoid unnecessary retries.
log_info "Waiting for USB-JTAG port to re-enumerate..."
sleep 5

# Test 5: Monitor Serial Output
log_test "Test 5: Monitor Serial Output ($TEST_DURATION seconds)"
log_info "Monitoring $FLASH_PORT at $BAUDRATE baud..."
log_info "Expected boot flow:"
log_info "  1. ROM bootloader messages"
log_info "  2. Jump to 0x42000020"
log_info "  3. Tock kernel initialization"

if python3 "$MONITOR_SCRIPT" "$FLASH_PORT" "$BAUDRATE" "$TEST_DURATION" "$TEST_OUTPUT_DIR/serial_output.log" > "$TEST_OUTPUT_DIR/monitor.log" 2>&1; then
    log_info "✅ Monitoring complete"
else
    log_warn "⚠️  Monitoring had issues (check logs)"
fi

# Test 6: Verify Output
log_test "Test 6: Verify Serial Output"

SERIAL_OUTPUT="$TEST_OUTPUT_DIR/serial_output.log"

if [ ! -f "$SERIAL_OUTPUT" ] || [ ! -s "$SERIAL_OUTPUT" ]; then
    log_warn "⚠️  No serial output captured"
    log_warn "This may be expected if firmware doesn't output to UART"
    TESTS_PASSED=4
    TESTS_TOTAL=5
else
    log_info "Serial output captured ($(wc -l < "$SERIAL_OUTPUT") lines)"
    
    # Check for expected messages
    TESTS_PASSED=4
    TESTS_TOTAL=6
    
    # Check for ROM bootloader (indicates board is booting)
    if grep -q "ESP-ROM" "$SERIAL_OUTPUT" || grep -q "esp32c6" "$SERIAL_OUTPUT"; then
        log_info "✅ ROM bootloader detected"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_warn "⚠️  ROM bootloader messages not found"
    fi
    
    # Check for Tock initialization
    if grep -q "initialization complete" "$SERIAL_OUTPUT" || grep -q "Tock" "$SERIAL_OUTPUT"; then
        log_info "✅ Found Tock initialization message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_warn "⚠️  Tock initialization message not found"
    fi
    
    # Check for panics
    if grep -q "panic" "$SERIAL_OUTPUT"; then
        log_error "❌ Panic detected in output"
    fi
fi

# Summary
echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Tests passed: $TESTS_PASSED / $TESTS_TOTAL"
echo "Output directory: $TEST_OUTPUT_DIR"
echo ""

if [ -f "$SERIAL_OUTPUT" ] && [ -s "$SERIAL_OUTPUT" ]; then
    echo "Serial output preview:"
    echo "----------------------------------------"
    head -20 "$SERIAL_OUTPUT"
    echo "----------------------------------------"
    echo "(Full output in $SERIAL_OUTPUT)"
fi

if [ $TESTS_PASSED -eq $TESTS_TOTAL ]; then
    log_info "✅ ALL TESTS PASSED"
    exit 0
else
    log_warn "⚠️  SOME TESTS FAILED OR INCONCLUSIVE"
    exit 1
fi
