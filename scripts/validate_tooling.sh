#!/bin/bash
#
# Tooling Validation Script
#
# This script validates that all ESP32-C6 tooling is properly set up
# and working correctly. Run this after initial setup or when
# troubleshooting issues.
#
# Usage:
#   ./validate_tooling.sh
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

log_pass() {
    echo -e "${GREEN}✅ PASS${NC} $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

log_fail() {
    echo -e "${RED}❌ FAIL${NC} $1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

log_warn() {
    echo -e "${YELLOW}⚠️  WARN${NC} $1"
    WARN_COUNT=$((WARN_COUNT + 1))
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

echo "=========================================="
echo "ESP32-C6 Tooling Validation"
echo "=========================================="
echo ""

# Test 1: Check espflash binary
log_info "Test 1: espflash binary"
if [ -f "./espflash/target/release/espflash" ]; then
    VERSION=$(./espflash/target/release/espflash --version 2>&1 || echo "error")
    if [[ "$VERSION" == espflash* ]]; then
        log_pass "espflash binary exists and works ($VERSION)"
    else
        log_fail "espflash binary exists but doesn't work"
    fi
else
    log_fail "espflash binary not found at ./espflash/target/release/espflash"
    log_info "Build with: cd espflash && cargo build --release"
fi
echo ""

# Test 2: Check Python
log_info "Test 2: Python installation"
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    log_pass "Python 3 installed ($PYTHON_VERSION)"
else
    log_fail "Python 3 not found"
fi
echo ""

# Test 3: Check uv
log_info "Test 3: uv package manager"
if command -v uv &> /dev/null; then
    UV_VERSION=$(uv --version 2>&1 | head -n1)
    log_pass "uv installed ($UV_VERSION)"
else
    log_fail "uv not installed"
    log_info "Install with: curl -LsSf https://astral.sh/uv/install.sh | sh"
fi
echo ""

# Test 4: Check pyserial
log_info "Test 4: pyserial module"
if python3 -c "import serial" 2>/dev/null; then
    PYSERIAL_VERSION=$(python3 -c "import serial; print(serial.__version__)" 2>/dev/null || echo "unknown")
    log_pass "pyserial installed (version $PYSERIAL_VERSION)"
else
    log_fail "pyserial not installed"
    log_info "Install with: uv pip install --system --native-tls pyserial"
    log_info "Or: uv pip install --system --native-tls -r requirements.txt"
fi
echo ""

# Test 5: Check esptool.py
log_info "Test 5: esptool.py (required for elf2image conversion)"
if command -v esptool.py &> /dev/null; then
    ESPTOOL_VERSION=$(esptool.py version 2>&1 | head -n1)
    log_pass "esptool.py installed ($ESPTOOL_VERSION)"
    
    # Verify it supports esp32c6
    if esptool.py --help 2>&1 | grep -q "esp32c6"; then
        log_pass "esptool.py supports ESP32-C6"
    else
        log_warn "esptool.py may not support ESP32-C6 (old version?)"
    fi
else
    log_fail "esptool.py not installed"
    log_info "Install with: uv pip install --system --native-tls esptool"
    log_info "Or: uv pip install --system --native-tls -r requirements.txt"
fi
echo ""

# Test 6: Check scripts exist
log_info "Test 6: Script files"
SCRIPTS=("flash_esp32c6.sh" "monitor_serial.py" "test_esp32c6.sh")
for script in "${SCRIPTS[@]}"; do
    if [ -f "scripts/$script" ]; then
        if [ -x "scripts/$script" ]; then
            log_pass "scripts/$script exists and is executable"
        else
            log_warn "scripts/$script exists but is not executable"
            log_info "Fix with: chmod +x scripts/$script"
        fi
    else
        log_fail "scripts/$script not found"
    fi
done
echo ""

# Test 7: Check Rust target
log_info "Test 7: Rust RISC-V target"
if rustup target list | grep -q "riscv32imc-unknown-none-elf (installed)"; then
    log_pass "riscv32imc-unknown-none-elf target installed"
else
    log_fail "riscv32imc-unknown-none-elf target not installed"
    log_info "Install with: rustup target add riscv32imc-unknown-none-elf"
fi
echo ""

# Test 8: Check Tock board directory
log_info "Test 8: Tock board directory"
if [ -d "tock/boards/nano-esp32-c6" ]; then
    log_pass "nano-esp32-c6 board directory exists"
    
    # Check for key files
    if [ -f "tock/boards/nano-esp32-c6/Cargo.toml" ]; then
        log_pass "Cargo.toml exists"
    else
        log_fail "Cargo.toml not found"
    fi
    
    if [ -f "tock/boards/nano-esp32-c6/Makefile" ]; then
        log_pass "Makefile exists"
    else
        log_fail "Makefile not found"
    fi
else
    log_fail "nano-esp32-c6 board directory not found"
fi
echo ""

# Test 9: Check for hardware (optional)
log_info "Test 9: Hardware detection (optional)"
if [ -f "./espflash/target/release/espflash" ]; then
    PORTS=$(./espflash/target/release/espflash list-ports 2>/dev/null || echo "")
    if [[ "$PORTS" == *"Espressif"* ]] || [[ "$PORTS" == *"ESP"* ]]; then
        log_pass "ESP32-C6 hardware detected"
        echo "$PORTS" | while read -r line; do
            log_info "  $line"
        done
    else
        log_warn "No ESP32-C6 hardware detected (this is OK if not connected)"
        if [ -n "$PORTS" ]; then
            log_info "Available ports:"
            echo "$PORTS" | while read -r line; do
                log_info "  $line"
            done
        fi
    fi
else
    log_warn "Cannot check hardware (espflash not built)"
fi
echo ""

# Test 10: Check documentation
log_info "Test 10: Documentation files"
DOCS=("HARDWARE_SETUP.md" "HARDWARE_CHECKLIST.md" "QUICKSTART_HARDWARE.md" "scripts/README.md")
for doc in "${DOCS[@]}"; do
    if [ -f "$doc" ]; then
        log_pass "$doc exists"
    else
        log_fail "$doc not found"
    fi
done
echo ""

# Summary
echo "=========================================="
echo "Validation Summary"
echo "=========================================="
echo -e "${GREEN}Passed:${NC} $PASS_COUNT"
echo -e "${YELLOW}Warnings:${NC} $WARN_COUNT"
echo -e "${RED}Failed:${NC} $FAIL_COUNT"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}✅ All critical checks passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Build kernel: cd tock/boards/nano-esp32-c6 && cargo build --release"
    echo "  2. Flash to hardware: make flash"
    echo "  3. Run tests: make hardware-test"
    exit 0
else
    echo -e "${RED}❌ Some checks failed. Please fix the issues above.${NC}"
    exit 1
fi
