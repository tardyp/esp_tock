#!/bin/bash
#
# SP001 Hardware Test: Watchdog Disable & PCR Clock Configuration
#
# This script tests:
# 1. Watchdog timers are successfully disabled (no resets for 60+ seconds)
# 2. Peripheral clocks are properly configured via PCR
# 3. System remains stable with new code
#
# Usage:
#   ./test_sp001_watchdog.sh <kernel.elf> [duration]
#
# Example:
#   ./test_sp001_watchdog.sh tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board 65
#

set -e

# Configuration
FLASH_PORT="${FLASH_PORT:-/dev/tty.usbmodem112201}"
TEST_DURATION="${2:-65}"  # Default 65 seconds (60s test + 5s margin)
KERNEL_ELF="$1"

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

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
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

# Create test output directory
TEST_OUTPUT_DIR="project_management/PI002_CorePeripherals/SP001_WatchdogClock/hardware_test_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TEST_OUTPUT_DIR"
log_info "Test output directory: $TEST_OUTPUT_DIR"

echo ""
echo "=========================================="
echo "SP001 Hardware Test"
echo "=========================================="
echo "Kernel: $KERNEL_ELF"
echo "Port: $FLASH_PORT"
echo "Duration: $TEST_DURATION seconds"
echo ""

# Test 1: Flash Firmware
log_test "Test 1: Flash Firmware"
if espflash flash --chip esp32c6 --port $FLASH_PORT "$KERNEL_ELF" > "$TEST_OUTPUT_DIR/flash.log" 2>&1; then
    log_pass "Flashing successful"
else
    log_fail "Flashing failed"
    cat "$TEST_OUTPUT_DIR/flash.log"
    exit 1
fi

# Test 2: Capture Serial Output
log_test "Test 2: Monitor Serial Output ($TEST_DURATION seconds)"
log_info "Capturing serial output..."
log_info "Expected messages:"
log_info "  - 'Disabling watchdogs...'"
log_info "  - 'Watchdogs disabled'"
log_info "  - 'Configuring peripheral clocks...'"
log_info "  - 'Peripheral clocks configured'"
log_info "  - 'Hello World from Tock!'"

timeout $TEST_DURATION script -q "$TEST_OUTPUT_DIR/serial_raw.log" \
    espflash flash --chip esp32c6 --port $FLASH_PORT --monitor "$KERNEL_ELF" \
    < /dev/null 2>&1 || true

# Clean up ANSI codes and extract text
cat "$TEST_OUTPUT_DIR/serial_raw.log" | strings > "$TEST_OUTPUT_DIR/serial_output.log"

if [ -s "$TEST_OUTPUT_DIR/serial_output.log" ]; then
    log_pass "Serial output captured ($(wc -l < "$TEST_OUTPUT_DIR/serial_output.log") lines)"
else
    log_fail "No serial output captured"
    exit 1
fi

# Test 3: Verify No Watchdog Resets
log_test "Test 3: Verify No Watchdog Resets"
RESET_COUNT=$(grep -c "rst:" "$TEST_OUTPUT_DIR/serial_output.log" || echo "0")
BOOT_COUNT=$(grep -c "ESP-ROM:" "$TEST_OUTPUT_DIR/serial_output.log" || echo "0")

log_info "Reset count: $RESET_COUNT"
log_info "Boot count: $BOOT_COUNT"

if [ "$RESET_COUNT" -le 1 ] && [ "$BOOT_COUNT" -le 1 ]; then
    log_pass "No watchdog resets detected (only initial boot)"
else
    log_fail "Multiple resets detected - watchdog may not be disabled"
    log_error "Expected: 1 reset (initial boot)"
    log_error "Found: $RESET_COUNT resets, $BOOT_COUNT boots"
    exit 1
fi

# Test 4: Verify Watchdog Disable Messages
log_test "Test 4: Verify Watchdog Disable Messages"
if grep -q "Disabling watchdogs" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "Found 'Disabling watchdogs' message"
else
    log_fail "Missing 'Disabling watchdogs' message"
    exit 1
fi

if grep -q "Watchdogs disabled" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "Found 'Watchdogs disabled' message"
else
    log_fail "Missing 'Watchdogs disabled' message"
    exit 1
fi

# Test 5: Verify PCR Clock Configuration Messages
log_test "Test 5: Verify PCR Clock Configuration Messages"
if grep -q "Configuring peripheral clocks" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "Found 'Configuring peripheral clocks' message"
else
    log_fail "Missing 'Configuring peripheral clocks' message"
    exit 1
fi

if grep -q "Peripheral clocks configured" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "Found 'Peripheral clocks configured' message"
else
    log_fail "Missing 'Peripheral clocks configured' message"
    exit 1
fi

# Test 6: Verify Kernel Initialization
log_test "Test 6: Verify Kernel Initialization"
if grep -q "Tock Kernel Starting" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "Found 'Tock Kernel Starting' message"
else
    log_fail "Missing 'Tock Kernel Starting' message"
    exit 1
fi

if grep -q "Hello World from Tock" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "Found 'Hello World from Tock!' message"
else
    log_fail "Missing 'Hello World from Tock!' message"
    exit 1
fi

# Test 7: Verify System Stability
log_test "Test 7: Verify System Stability"
if grep -q "Entering kernel main loop" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "Kernel entered main loop successfully"
else
    log_warn "Could not verify kernel main loop entry"
fi

# Check for panics
if grep -qi "panic" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_fail "Panic detected in output"
    grep -i "panic" "$TEST_OUTPUT_DIR/serial_output.log"
    exit 1
else
    log_pass "No panics detected"
fi

# Summary
echo ""
echo "=========================================="
echo "Test Summary - SP001 Hardware Validation"
echo "=========================================="
echo "✅ Test 1: Flash Firmware - PASS"
echo "✅ Test 2: Monitor Serial Output - PASS"
echo "✅ Test 3: No Watchdog Resets - PASS"
echo "✅ Test 4: Watchdog Disable Messages - PASS"
echo "✅ Test 5: PCR Clock Configuration - PASS"
echo "✅ Test 6: Kernel Initialization - PASS"
echo "✅ Test 7: System Stability - PASS"
echo ""
echo "Duration: $TEST_DURATION seconds"
echo "Output directory: $TEST_OUTPUT_DIR"
echo ""

# Show serial output preview
echo "Serial output preview (first 30 lines):"
echo "----------------------------------------"
head -30 "$TEST_OUTPUT_DIR/serial_output.log"
echo "----------------------------------------"
echo "(Full output in $TEST_OUTPUT_DIR/serial_output.log)"
echo ""

log_pass "ALL TESTS PASSED - SP001 HARDWARE VALIDATION SUCCESSFUL"
exit 0
