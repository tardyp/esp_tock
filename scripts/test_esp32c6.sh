#!/bin/bash
#
# ESP32-C6 Hardware Test Automation Script
#
# This script automates the process of flashing firmware and verifying
# serial output for ESP32-C6 hardware testing.
#
# Usage:
#   ./test_esp32c6.sh <kernel.elf> [test_duration]
#
# Example:
#   ./test_esp32c6.sh path/to/nano-esp32-c6-board 10
#

set -e

# Configuration
FLASH_PORT="${FLASH_PORT:-/dev/tty.usbmodem112201}"  # ESP32-C6 native USB
UART_PORT="${UART_PORT:-/dev/tty.usbmodem595B0538021}"  # CH343 UART
BAUDRATE="${BAUDRATE:-115200}"
TEST_DURATION="${2:-10}"  # Default 10 seconds
KERNEL_ELF="$1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ESPFLASH="$SCRIPT_DIR/../espflash/target/release/espflash"
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

# Check if espflash exists
if [ ! -f "$ESPFLASH" ]; then
    log_error "espflash not found at $ESPFLASH"
    log_info "Please build espflash first: cd espflash && cargo build --release"
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
if $ESPFLASH board-info --port $FLASH_PORT > "$TEST_OUTPUT_DIR/board_info.log" 2>&1; then
    log_info "✅ Board detected"
    cat "$TEST_OUTPUT_DIR/board_info.log"
else
    log_error "❌ Board detection failed"
    cat "$TEST_OUTPUT_DIR/board_info.log"
    exit 1
fi

# Test 2: Flash Firmware
log_test "Test 2: Flash Firmware"
log_info "Flashing $KERNEL_ELF..."
if $ESPFLASH flash --chip esp32c6 --port $FLASH_PORT "$KERNEL_ELF" > "$TEST_OUTPUT_DIR/flash.log" 2>&1; then
    log_info "✅ Flashing successful"
else
    log_error "❌ Flashing failed"
    cat "$TEST_OUTPUT_DIR/flash.log"
    exit 1
fi

# Test 3: Reset Board
log_test "Test 3: Reset Board"
if $ESPFLASH reset --port $FLASH_PORT > "$TEST_OUTPUT_DIR/reset.log" 2>&1; then
    log_info "✅ Reset successful"
else
    log_error "❌ Reset failed"
    cat "$TEST_OUTPUT_DIR/reset.log"
    exit 1
fi

# Wait a moment for board to boot
sleep 2

# Test 4: Monitor Serial Output
log_test "Test 4: Monitor Serial Output ($TEST_DURATION seconds)"
log_info "Monitoring $UART_PORT at $BAUDRATE baud..."

if python3 "$MONITOR_SCRIPT" "$UART_PORT" "$BAUDRATE" "$TEST_DURATION" "$TEST_OUTPUT_DIR/serial_output.log" > "$TEST_OUTPUT_DIR/monitor.log" 2>&1; then
    log_info "✅ Monitoring complete"
else
    log_warn "⚠️  Monitoring had issues (check logs)"
fi

# Test 5: Verify Output
log_test "Test 5: Verify Serial Output"

SERIAL_OUTPUT="$TEST_OUTPUT_DIR/serial_output.log"

if [ ! -f "$SERIAL_OUTPUT" ] || [ ! -s "$SERIAL_OUTPUT" ]; then
    log_warn "⚠️  No serial output captured"
    log_warn "This may be expected if firmware doesn't output to UART"
    TESTS_PASSED=3
    TESTS_TOTAL=4
else
    log_info "Serial output captured ($(wc -l < "$SERIAL_OUTPUT") lines)"
    
    # Check for expected messages
    TESTS_PASSED=3
    TESTS_TOTAL=5
    
    if grep -q "initialization complete" "$SERIAL_OUTPUT"; then
        log_info "✅ Found initialization message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_warn "⚠️  Initialization message not found"
    fi
    
    if grep -q "panic" "$SERIAL_OUTPUT"; then
        log_error "❌ Panic detected in output"
    else
        log_info "✅ No panics detected"
        TESTS_PASSED=$((TESTS_PASSED + 1))
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
