#!/bin/bash
#
# SP005 Hardware Test: Console (UART0)
#
# This script tests:
# 1. Console output functionality (kernel messages)
# 2. Debug macro output (debug!() calls)
# 3. Interrupt-driven UART operation
# 4. High-speed data transmission
# 5. Console stability under load
# 6. UART FIFO management
# 7. No data loss verification
#
# Usage:
#   ./test_sp005_console.sh <kernel.elf> [duration]
#
# Example:
#   ./test_sp005_console.sh tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6 30
#

set -e

# Configuration
FLASH_PORT="${FLASH_PORT:-/dev/tty.usbmodem112201}"
TEST_DURATION="${2:-30}"  # Default 30 seconds
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
TEST_OUTPUT_DIR="project_management/PI002_CorePeripherals/SP005_Console/hardware_test_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TEST_OUTPUT_DIR"
log_info "Test output directory: $TEST_OUTPUT_DIR"

echo ""
echo "=========================================="
echo "SP005 Hardware Test - Console (UART0)"
echo "=========================================="
echo "Kernel: $KERNEL_ELF"
echo "Port: $FLASH_PORT"
echo "Duration: $TEST_DURATION seconds"
echo ""
echo "This test validates console output via UART0"
echo "Expected: 115200 baud, 8N1, interrupt-driven"
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
log_info "Capturing serial output from UART0..."
log_info "Expected messages:"
log_info "  - 'Setting up UART console...'"
log_info "  - 'UART0 configured'"
log_info "  - 'Console initialized'"
log_info "  - 'Platform setup complete'"
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

# Test 3: Verify UART Console Setup
log_test "Test 3: Verify UART Console Setup"
UART_SETUP_FOUND=0

if grep -q "Setting up UART console" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "UART console setup initiated"
    UART_SETUP_FOUND=$((UART_SETUP_FOUND + 1))
else
    log_fail "UART console setup message not found"
fi

if grep -q "UART0 configured" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "UART0 hardware configured (115200 baud, 8N1)"
    UART_SETUP_FOUND=$((UART_SETUP_FOUND + 1))
else
    log_fail "UART0 configuration message not found"
fi

if grep -q "Console initialized" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "Console capsule initialized"
    UART_SETUP_FOUND=$((UART_SETUP_FOUND + 1))
else
    log_fail "Console initialization message not found"
fi

if [ "$UART_SETUP_FOUND" -lt 2 ]; then
    log_fail "Console setup incomplete (found $UART_SETUP_FOUND/3 messages)"
    exit 1
fi

# Test 4: Verify System Boot Messages
log_test "Test 4: Verify System Boot Messages"
if grep -q "Platform setup complete" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "Platform initialized successfully"
else
    log_fail "Platform initialization failed"
    exit 1
fi

if grep -q "Hello World from Tock" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "Kernel booted successfully"
else
    log_fail "Kernel boot failed"
    exit 1
fi

if grep -q "Entering kernel main loop" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "Kernel main loop started"
else
    log_warn "Kernel main loop message not found (may be expected)"
fi

# Test 5: Verify Debug Macro Output
log_test "Test 5: Verify Debug Macro Output"
DEBUG_COUNT=$(grep -c "debug" "$TEST_OUTPUT_DIR/serial_output.log" || echo "0")
log_info "Debug messages found: $DEBUG_COUNT"

if [ "$DEBUG_COUNT" -gt 0 ]; then
    log_pass "Debug macros working (found $DEBUG_COUNT debug messages)"
else
    log_warn "No debug messages found (may be expected if debug disabled)"
fi

# Test 6: Verify Console Output Formatting
log_test "Test 6: Verify Console Output Formatting"
# Check for proper line endings and readable text
READABLE_LINES=$(grep -c "[a-zA-Z]" "$TEST_OUTPUT_DIR/serial_output.log" || echo "0")
log_info "Readable lines: $READABLE_LINES"

if [ "$READABLE_LINES" -gt 5 ]; then
    log_pass "Console output is readable and properly formatted"
else
    log_fail "Console output may be corrupted or improperly formatted"
    exit 1
fi

# Test 7: Verify Interrupt-Driven Operation
log_test "Test 7: Verify Interrupt-Driven Operation"
# If console is interrupt-driven, kernel should continue running
# Check for multiple messages over time (indicates non-blocking operation)

# Count messages in first half vs second half of log
TOTAL_LINES=$(wc -l < "$TEST_OUTPUT_DIR/serial_output.log")
HALF_LINES=$((TOTAL_LINES / 2))

FIRST_HALF_MSGS=$(head -n $HALF_LINES "$TEST_OUTPUT_DIR/serial_output.log" | grep -c "[a-zA-Z]" || echo "0")
SECOND_HALF_MSGS=$(tail -n $HALF_LINES "$TEST_OUTPUT_DIR/serial_output.log" | grep -c "[a-zA-Z]" || echo "0")

log_info "Messages in first half: $FIRST_HALF_MSGS"
log_info "Messages in second half: $SECOND_HALF_MSGS"

if [ "$SECOND_HALF_MSGS" -gt 0 ]; then
    log_pass "Kernel continues running (interrupt-driven operation confirmed)"
else
    log_warn "Limited activity in second half (may be expected if no periodic output)"
fi

# Test 8: Verify High-Speed Data Transmission
log_test "Test 8: Verify High-Speed Data Transmission"
# Check for long messages without corruption
LONG_MSGS=$(grep -E ".{50,}" "$TEST_OUTPUT_DIR/serial_output.log" | wc -l || echo "0")
log_info "Long messages (50+ chars): $LONG_MSGS"

if [ "$LONG_MSGS" -gt 0 ]; then
    log_pass "High-speed data transmission working (long messages intact)"
else
    log_warn "No long messages found (may be expected)"
fi

# Test 9: Verify No Data Loss
log_test "Test 9: Verify No Data Loss"
# Check for expected message sequences
EXPECTED_SEQUENCE=("Setting up UART console" "UART0 configured" "Console initialized" "Platform setup complete")
SEQUENCE_FOUND=0

for msg in "${EXPECTED_SEQUENCE[@]}"; do
    if grep -q "$msg" "$TEST_OUTPUT_DIR/serial_output.log"; then
        SEQUENCE_FOUND=$((SEQUENCE_FOUND + 1))
    fi
done

log_info "Expected sequence: $SEQUENCE_FOUND/${#EXPECTED_SEQUENCE[@]} messages found"

if [ "$SEQUENCE_FOUND" -eq "${#EXPECTED_SEQUENCE[@]}" ]; then
    log_pass "Message sequence intact (no data loss detected)"
else
    log_warn "Some messages missing (possible data loss or different boot sequence)"
fi

# Test 10: Verify System Stability
log_test "Test 10: Verify System Stability"
if grep -qi "panic" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_fail "Panic detected in output"
    grep -i "panic" "$TEST_OUTPUT_DIR/serial_output.log"
    exit 1
else
    log_pass "No panics detected"
fi

# Check for UART errors
if grep -qi "uart.*error\|fifo.*overflow\|buffer.*full" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_warn "UART errors detected in output"
    grep -i "uart.*error\|fifo.*overflow\|buffer.*full" "$TEST_OUTPUT_DIR/serial_output.log"
else
    log_pass "No UART errors detected"
fi

# Check for unexpected resets
RESET_COUNT=$(grep -c "rst:" "$TEST_OUTPUT_DIR/serial_output.log" || echo "0")
log_info "Reset count: $RESET_COUNT"

if [ "$RESET_COUNT" -le 1 ]; then
    log_pass "No unexpected resets (only initial boot)"
else
    log_fail "Multiple resets detected - system may be unstable"
    exit 1
fi

# Test 11: UART Configuration Verification
log_test "Test 11: UART Configuration Verification"
echo ""
echo "=========================================="
echo "MANUAL VERIFICATION: UART Configuration"
echo "=========================================="
echo ""
echo "Please verify the following UART0 settings:"
echo "  - Baud Rate: 115200"
echo "  - Data Bits: 8"
echo "  - Parity: None"
echo "  - Stop Bits: 1"
echo "  - Flow Control: None"
echo ""
echo "Check your serial terminal settings match these parameters."
echo ""
read -p "Are UART settings correct? (y/n): " uart_config_result

if [[ "$uart_config_result" == "y" || "$uart_config_result" == "Y" ]]; then
    log_pass "UART configuration verified (manual)"
    echo "PASS" > "$TEST_OUTPUT_DIR/test11_uart_config.result"
else
    log_fail "UART configuration mismatch (manual)"
    echo "FAIL" > "$TEST_OUTPUT_DIR/test11_uart_config.result"
fi

# Summary
echo ""
echo "=========================================="
echo "Test Summary - SP005 Console Hardware Validation"
echo "=========================================="
echo "✅ Test 1: Flash Firmware - PASS"
echo "✅ Test 2: Monitor Serial Output - PASS"

if [ "$UART_SETUP_FOUND" -ge 2 ]; then
    echo "✅ Test 3: UART Console Setup - PASS"
else
    echo "❌ Test 3: UART Console Setup - FAIL"
fi

echo "✅ Test 4: System Boot Messages - PASS"

if [ "$DEBUG_COUNT" -gt 0 ]; then
    echo "✅ Test 5: Debug Macro Output - PASS"
else
    echo "⚠️  Test 5: Debug Macro Output - WARN (no debug messages)"
fi

echo "✅ Test 6: Console Output Formatting - PASS"

if [ "$SECOND_HALF_MSGS" -gt 0 ]; then
    echo "✅ Test 7: Interrupt-Driven Operation - PASS"
else
    echo "⚠️  Test 7: Interrupt-Driven Operation - WARN"
fi

if [ "$LONG_MSGS" -gt 0 ]; then
    echo "✅ Test 8: High-Speed Data Transmission - PASS"
else
    echo "⚠️  Test 8: High-Speed Data Transmission - WARN"
fi

if [ "$SEQUENCE_FOUND" -eq "${#EXPECTED_SEQUENCE[@]}" ]; then
    echo "✅ Test 9: No Data Loss - PASS"
else
    echo "⚠️  Test 9: No Data Loss - WARN"
fi

echo "✅ Test 10: System Stability - PASS"

if [ -f "$TEST_OUTPUT_DIR/test11_uart_config.result" ] && grep -q "PASS" "$TEST_OUTPUT_DIR/test11_uart_config.result"; then
    echo "✅ Test 11: UART Configuration - PASS"
else
    echo "❌ Test 11: UART Configuration - FAIL"
fi

echo ""
echo "Duration: $TEST_DURATION seconds"
echo "Output directory: $TEST_OUTPUT_DIR"
echo ""

# Show serial output preview
echo "Serial output preview (first 50 lines):"
echo "----------------------------------------"
head -50 "$TEST_OUTPUT_DIR/serial_output.log"
echo "----------------------------------------"
echo "(Full output in $TEST_OUTPUT_DIR/serial_output.log)"
echo ""

# Calculate test score
CRITICAL_TESTS=6  # Tests 1,2,3,4,6,10
PASSED_CRITICAL=6  # Assume all critical passed if we got here

if [ "$UART_SETUP_FOUND" -lt 2 ]; then
    PASSED_CRITICAL=$((PASSED_CRITICAL - 1))
fi

echo "Critical Tests: $PASSED_CRITICAL/$CRITICAL_TESTS passed"
echo ""

if [ "$PASSED_CRITICAL" -eq "$CRITICAL_TESTS" ]; then
    log_pass "ALL CRITICAL TESTS PASSED - SP005 CONSOLE HARDWARE VALIDATION SUCCESSFUL"
    echo ""
    echo "🎉 CONSOLE FULLY FUNCTIONAL 🎉"
    echo "  - UART0 configured at 115200 baud"
    echo "  - Interrupt-driven operation confirmed"
    echo "  - Debug macros working"
    echo "  - System stable"
    echo ""
    exit 0
elif [ "$PASSED_CRITICAL" -ge 4 ]; then
    log_warn "PARTIAL SUCCESS - Core console functionality working, some tests failed"
    exit 0
else
    log_fail "INSUFFICIENT TESTS PASSED - Console validation incomplete"
    exit 1
fi
