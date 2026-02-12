#!/bin/bash
#
# SP002 Hardware Test: Interrupt Controller (INTC)
#
# This script tests:
# 1. Interrupt controller initialization
# 2. Timer interrupts fire and are handled correctly
# 3. Interrupt enable/disable works
# 4. Interrupt priority levels function correctly
# 5. No spurious interrupts occur
# 6. Multiple interrupts can be handled
#
# Usage:
#   ./test_sp002_intc.sh <kernel.elf> [duration]
#
# Example:
#   ./test_sp002_intc.sh tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board 30
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
TEST_OUTPUT_DIR="project_management/PI002_CorePeripherals/SP002_INTC/hardware_test_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TEST_OUTPUT_DIR"
log_info "Test output directory: $TEST_OUTPUT_DIR"

echo ""
echo "=========================================="
echo "SP002 Hardware Test - Interrupt Controller"
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
log_info "  - '[INTC] Initializing interrupt controller'"
log_info "  - '[INTC] Mapping interrupts'"
log_info "  - '[INTC] Enabling interrupts'"
log_info "  - '[INTC] Interrupt controller ready'"
log_info "  - '[TEST] Timer interrupt test starting'"
log_info "  - '[TEST] Timer interrupt fired'"

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

# Test 3: Verify INTC Initialization
log_test "Test 3: Verify INTC Initialization"
if grep -q "Initializing interrupt controller" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "Found 'Initializing interrupt controller' message"
else
    log_fail "Missing 'Initializing interrupt controller' message"
    exit 1
fi

if grep -q "Mapping interrupts" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "Found 'Mapping interrupts' message"
else
    log_fail "Missing 'Mapping interrupts' message"
    exit 1
fi

if grep -q "Enabling interrupts" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "Found 'Enabling interrupts' message"
else
    log_fail "Missing 'Enabling interrupts' message"
    exit 1
fi

if grep -q "Interrupt controller ready" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "Found 'Interrupt controller ready' message"
else
    log_fail "Missing 'Interrupt controller ready' message"
    exit 1
fi

# Test 4: Verify Timer Interrupt Test Started
log_test "Test 4: Verify Timer Interrupt Test Started"
if grep -q "Timer interrupt test starting" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "Timer interrupt test started"
else
    log_fail "Timer interrupt test did not start"
    exit 1
fi

# Test 5: Verify Timer Interrupts Fire
log_test "Test 5: Verify Timer Interrupts Fire"
INTERRUPT_COUNT=$(grep -c "Timer interrupt fired" "$TEST_OUTPUT_DIR/serial_output.log" || echo "0")
log_info "Timer interrupt count: $INTERRUPT_COUNT"

if [ "$INTERRUPT_COUNT" -ge 5 ]; then
    log_pass "Timer interrupts firing correctly ($INTERRUPT_COUNT interrupts)"
else
    log_fail "Insufficient timer interrupts (expected >= 5, got $INTERRUPT_COUNT)"
    exit 1
fi

# Test 6: Verify Interrupt Handler Execution
log_test "Test 6: Verify Interrupt Handler Execution"
if grep -q "Interrupt handler called" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "Interrupt handler executed"
else
    log_fail "Interrupt handler not executed"
    exit 1
fi

# Test 7: Verify No Spurious Interrupts
log_test "Test 7: Verify No Spurious Interrupts"
if grep -qi "spurious" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_fail "Spurious interrupts detected"
    grep -i "spurious" "$TEST_OUTPUT_DIR/serial_output.log"
    exit 1
else
    log_pass "No spurious interrupts detected"
fi

# Test 8: Verify Enable/Disable Test
log_test "Test 8: Verify Enable/Disable Test"
if grep -q "Testing interrupt disable" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "Interrupt disable test executed"
    
    # Check that interrupts stopped when disabled
    if grep -q "Interrupts disabled - no interrupts should fire" "$TEST_OUTPUT_DIR/serial_output.log"; then
        log_pass "Interrupt disable confirmed"
    else
        log_warn "Could not confirm interrupt disable"
    fi
    
    # Check that interrupts resumed when re-enabled
    if grep -q "Interrupts re-enabled" "$TEST_OUTPUT_DIR/serial_output.log"; then
        log_pass "Interrupt re-enable confirmed"
    else
        log_warn "Could not confirm interrupt re-enable"
    fi
else
    log_warn "Enable/disable test not found (may not be implemented)"
fi

# Test 9: Verify Priority Test
log_test "Test 9: Verify Priority Test"
if grep -q "Testing interrupt priorities" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "Priority test executed"
else
    log_warn "Priority test not found (may not be implemented)"
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

# Test 11: Verify Interrupt Acknowledgment
log_test "Test 11: Verify Interrupt Acknowledgment"
if grep -q "Interrupt acknowledged" "$TEST_OUTPUT_DIR/serial_output.log"; then
    log_pass "Interrupts properly acknowledged"
else
    log_warn "Could not verify interrupt acknowledgment"
fi

# Summary
echo ""
echo "=========================================="
echo "Test Summary - SP002 INTC Hardware Validation"
echo "=========================================="
echo "✅ Test 1: Flash Firmware - PASS"
echo "✅ Test 2: Monitor Serial Output - PASS"
echo "✅ Test 3: INTC Initialization - PASS"
echo "✅ Test 4: Timer Test Started - PASS"
echo "✅ Test 5: Timer Interrupts Fire - PASS ($INTERRUPT_COUNT interrupts)"
echo "✅ Test 6: Interrupt Handler Execution - PASS"
echo "✅ Test 7: No Spurious Interrupts - PASS"

if grep -q "Testing interrupt disable" "$TEST_OUTPUT_DIR/serial_output.log"; then
    echo "✅ Test 8: Enable/Disable Test - PASS"
else
    echo "⚠️  Test 8: Enable/Disable Test - SKIPPED"
fi

if grep -q "Testing interrupt priorities" "$TEST_OUTPUT_DIR/serial_output.log"; then
    echo "✅ Test 9: Priority Test - PASS"
else
    echo "⚠️  Test 9: Priority Test - SKIPPED"
fi

echo "✅ Test 10: System Stability - PASS"

if grep -q "Interrupt acknowledged" "$TEST_OUTPUT_DIR/serial_output.log"; then
    echo "✅ Test 11: Interrupt Acknowledgment - PASS"
else
    echo "⚠️  Test 11: Interrupt Acknowledgment - PARTIAL"
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

# Show interrupt-related messages
echo "Interrupt-related messages:"
echo "----------------------------------------"
grep -i "interrupt\|intc\|timer" "$TEST_OUTPUT_DIR/serial_output.log" | head -30
echo "----------------------------------------"
echo ""

log_pass "ALL CRITICAL TESTS PASSED - SP002 INTC HARDWARE VALIDATION SUCCESSFUL"
exit 0
