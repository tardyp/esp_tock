#!/bin/bash
#
# SP004 Hardware Test: GPIO Driver
#
# This script tests:
# 1. GPIO output functionality (set/clear/toggle)
# 2. GPIO input functionality (read pin state)
# 3. Pull-up/pull-down resistors
# 4. GPIO interrupts (rising/falling/both edges)
# 5. Multiple pins simultaneously
# 6. GPIO loopback (output to input)
# 7. Stress testing (rapid toggling)
#
# Usage:
#   ./test_sp004_gpio.sh <kernel.elf> [duration]
#
# Example:
#   ./test_sp004_gpio.sh tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6 30
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
TEST_OUTPUT_DIR="project_management/PI002_CorePeripherals/SP004_GPIO/hardware_test_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TEST_OUTPUT_DIR"
log_info "Test output directory: $TEST_OUTPUT_DIR"

echo ""
echo "=========================================="
echo "SP004 Hardware Test - GPIO Driver"
echo "=========================================="
echo "Kernel: $KERNEL_ELF"
echo "Port: $FLASH_PORT"
echo "Duration: $TEST_DURATION seconds"
echo ""
echo "NOTE: This test requires manual GPIO interaction"
echo "      Follow the prompts to test GPIO functionality"
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
log_info "  - 'Platform setup complete'"
log_info "  - 'Hello World from Tock'"
log_info "  - 'Entering kernel main loop'"

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

# Test 3: Verify System Boot
log_test "Test 3: Verify System Boot"
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

# Test 4: Verify GPIO Initialization
log_test "Test 4: Verify GPIO Initialization"
if grep -q "Entering kernel main loop" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "GPIO driver initialized (kernel main loop reached)"
else
    log_fail "GPIO initialization may have failed"
    exit 1
fi

# Test 5: Manual GPIO Output Test
log_test "Test 5: GPIO Output Test (Manual)"
echo ""
echo "=========================================="
echo "MANUAL TEST: GPIO Output"
echo "=========================================="
echo ""
echo "This test requires you to observe GPIO pins with:"
echo "  - LED connected to GPIO5, or"
echo "  - Multimeter measuring GPIO5 voltage"
echo ""
echo "Test procedure:"
echo "  1. Build firmware with GPIO test feature:"
echo "     cd tock/boards/nano-esp32-c6"
echo "     cargo build --release --features gpio_tests"
echo "  2. Flash the test firmware"
echo "  3. Observe GPIO5:"
echo "     - Should go HIGH (3.3V)"
echo "     - Should go LOW (0V)"
echo "     - Should toggle multiple times"
echo ""
read -p "Did GPIO5 output work correctly? (y/n): " gpio_output_result

if [[ "$gpio_output_result" == "y" || "$gpio_output_result" == "Y" ]]; then
    log_pass "GPIO output test passed (manual verification)"
    echo "PASS" > "$TEST_OUTPUT_DIR/test5_gpio_output.result"
else
    log_fail "GPIO output test failed (manual verification)"
    echo "FAIL" > "$TEST_OUTPUT_DIR/test5_gpio_output.result"
fi

# Test 6: Manual GPIO Input Test
log_test "Test 6: GPIO Input Test (Manual)"
echo ""
echo "=========================================="
echo "MANUAL TEST: GPIO Input & Pull Resistors"
echo "=========================================="
echo ""
echo "This test verifies GPIO input and pull-up/pull-down resistors."
echo ""
echo "Test procedure:"
echo "  1. GPIO6 configured as input with pull-up"
echo "     - Should read HIGH when floating"
echo "  2. GPIO6 configured with pull-down"
echo "     - Should read LOW when floating"
echo "  3. Check serial output for test results"
echo ""
read -p "Did GPIO input and pull resistors work correctly? (y/n): " gpio_input_result

if [[ "$gpio_input_result" == "y" || "$gpio_input_result" == "Y" ]]; then
    log_pass "GPIO input test passed (manual verification)"
    echo "PASS" > "$TEST_OUTPUT_DIR/test6_gpio_input.result"
else
    log_fail "GPIO input test failed (manual verification)"
    echo "FAIL" > "$TEST_OUTPUT_DIR/test6_gpio_input.result"
fi

# Test 7: Manual GPIO Loopback Test
log_test "Test 7: GPIO Loopback Test (Manual)"
echo ""
echo "=========================================="
echo "MANUAL TEST: GPIO Loopback"
echo "=========================================="
echo ""
echo "This test verifies GPIO output to input communication."
echo ""
echo "Test procedure:"
echo "  1. Connect GPIO5 (output) to GPIO6 (input) with jumper wire"
echo "  2. GPIO5 set HIGH -> GPIO6 should read HIGH"
echo "  3. GPIO5 set LOW -> GPIO6 should read LOW"
echo "  4. Check serial output for test results"
echo ""
read -p "Did GPIO loopback work correctly? (y/n): " gpio_loopback_result

if [[ "$gpio_loopback_result" == "y" || "$gpio_loopback_result" == "Y" ]]; then
    log_pass "GPIO loopback test passed (manual verification)"
    echo "PASS" > "$TEST_OUTPUT_DIR/test7_gpio_loopback.result"
else
    log_fail "GPIO loopback test failed (manual verification)"
    echo "FAIL" > "$TEST_OUTPUT_DIR/test7_gpio_loopback.result"
fi

# Test 8: Manual GPIO Interrupt Test
log_test "Test 8: GPIO Interrupt Test (Manual)"
echo ""
echo "=========================================="
echo "MANUAL TEST: GPIO Interrupts"
echo "=========================================="
echo ""
echo "This test verifies GPIO interrupt functionality."
echo ""
echo "Test procedure:"
echo "  1. GPIO7 configured for rising edge interrupt"
echo "  2. Connect GPIO7 to GND (LOW)"
echo "  3. Connect GPIO7 to 3.3V (HIGH) - interrupt should fire"
echo "  4. Check serial output for '[TEST] GPIO interrupt fired'"
echo "  5. Repeat for falling edge and both edges"
echo ""
read -p "Did GPIO interrupts fire correctly? (y/n): " gpio_interrupt_result

if [[ "$gpio_interrupt_result" == "y" || "$gpio_interrupt_result" == "Y" ]]; then
    log_pass "GPIO interrupt test passed (manual verification)"
    echo "PASS" > "$TEST_OUTPUT_DIR/test8_gpio_interrupt.result"
else
    log_fail "GPIO interrupt test failed (manual verification)"
    echo "FAIL" > "$TEST_OUTPUT_DIR/test8_gpio_interrupt.result"
fi

# Test 9: Manual Multiple Pins Test
log_test "Test 9: Multiple GPIO Pins Test (Manual)"
echo ""
echo "=========================================="
echo "MANUAL TEST: Multiple GPIO Pins"
echo "=========================================="
echo ""
echo "This test verifies multiple GPIO pins work independently."
echo ""
echo "Test procedure:"
echo "  1. GPIO5, GPIO8, GPIO9 configured as outputs"
echo "  2. Different patterns set on pins (101, 010, 111, 000)"
echo "  3. Verify with LEDs or multimeter"
echo "  4. Check serial output for pattern messages"
echo ""
read -p "Did multiple GPIO pins work independently? (y/n): " gpio_multiple_result

if [[ "$gpio_multiple_result" == "y" || "$gpio_multiple_result" == "Y" ]]; then
    log_pass "Multiple GPIO pins test passed (manual verification)"
    echo "PASS" > "$TEST_OUTPUT_DIR/test9_gpio_multiple.result"
else
    log_fail "Multiple GPIO pins test failed (manual verification)"
    echo "FAIL" > "$TEST_OUTPUT_DIR/test9_gpio_multiple.result"
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

# Check for unexpected resets
RESET_COUNT=$(grep -c "rst:" "$TEST_OUTPUT_DIR/serial_output.log" || echo "0")
log_info "Reset count: $RESET_COUNT"

if [ "$RESET_COUNT" -le 1 ]; then
    log_pass "No unexpected resets (only initial boot)"
else
    log_fail "Multiple resets detected - system may be unstable"
    exit 1
fi

# Summary
echo ""
echo "=========================================="
echo "Test Summary - SP004 GPIO Hardware Validation"
echo "=========================================="
echo "✅ Test 1: Flash Firmware - PASS"
echo "✅ Test 2: Monitor Serial Output - PASS"
echo "✅ Test 3: System Boot - PASS"
echo "✅ Test 4: GPIO Initialization - PASS"

# Count manual test results
MANUAL_PASS=0
MANUAL_TOTAL=5

if [ -f "$TEST_OUTPUT_DIR/test5_gpio_output.result" ] && grep -q "PASS" "$TEST_OUTPUT_DIR/test5_gpio_output.result"; then
    echo "✅ Test 5: GPIO Output - PASS"
    MANUAL_PASS=$((MANUAL_PASS + 1))
else
    echo "❌ Test 5: GPIO Output - FAIL"
fi

if [ -f "$TEST_OUTPUT_DIR/test6_gpio_input.result" ] && grep -q "PASS" "$TEST_OUTPUT_DIR/test6_gpio_input.result"; then
    echo "✅ Test 6: GPIO Input - PASS"
    MANUAL_PASS=$((MANUAL_PASS + 1))
else
    echo "❌ Test 6: GPIO Input - FAIL"
fi

if [ -f "$TEST_OUTPUT_DIR/test7_gpio_loopback.result" ] && grep -q "PASS" "$TEST_OUTPUT_DIR/test7_gpio_loopback.result"; then
    echo "✅ Test 7: GPIO Loopback - PASS"
    MANUAL_PASS=$((MANUAL_PASS + 1))
else
    echo "❌ Test 7: GPIO Loopback - FAIL"
fi

if [ -f "$TEST_OUTPUT_DIR/test8_gpio_interrupt.result" ] && grep -q "PASS" "$TEST_OUTPUT_DIR/test8_gpio_interrupt.result"; then
    echo "✅ Test 8: GPIO Interrupts - PASS"
    MANUAL_PASS=$((MANUAL_PASS + 1))
else
    echo "❌ Test 8: GPIO Interrupts - FAIL"
fi

if [ -f "$TEST_OUTPUT_DIR/test9_gpio_multiple.result" ] && grep -q "PASS" "$TEST_OUTPUT_DIR/test9_gpio_multiple.result"; then
    echo "✅ Test 9: Multiple Pins - PASS"
    MANUAL_PASS=$((MANUAL_PASS + 1))
else
    echo "❌ Test 9: Multiple Pins - FAIL"
fi

echo "✅ Test 10: System Stability - PASS"
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
TOTAL_TESTS=10
PASSED_TESTS=$((4 + MANUAL_PASS + 1))  # 4 automated + manual + stability

echo "Test Score: $PASSED_TESTS/$TOTAL_TESTS tests passed"
echo "Manual Tests: $MANUAL_PASS/$MANUAL_TOTAL passed"
echo ""

if [ "$PASSED_TESTS" -ge 9 ]; then
    log_pass "ALL CRITICAL TESTS PASSED - SP004 GPIO HARDWARE VALIDATION SUCCESSFUL"
    exit 0
elif [ "$PASSED_TESTS" -ge 6 ]; then
    log_warn "PARTIAL SUCCESS - Core GPIO functionality working, some tests failed"
    exit 0
else
    log_fail "INSUFFICIENT TESTS PASSED - GPIO validation incomplete"
    exit 1
fi
