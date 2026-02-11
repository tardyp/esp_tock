# PI001/SP002 - Analysis Report: Tooling Requirements for ESP32-C6 Hardware Debugging

**Sprint:** PI001/SP002_Tooling  
**Report Number:** 006  
**Date:** 2026-02-11  
**Analyst:** @analyst  
**Status:** COMPLETE

---

## Executive Summary

This report specifies the tooling requirements for automated ESP32-C6 hardware testing and debugging. The analysis reveals that while `espflash` is excellent for interactive development, its UX is not well-suited for agentic workflows. We recommend creating lightweight wrapper scripts and documentation to enable automated testing without modifying `espflash` itself.

**Key Findings:**
- ✅ Hardware identified: ESP32-C6 on `/dev/tty.usbmodem112201` (confirmed via `espflash board-info`)
- ✅ Second port `/dev/tty.usbmodem595B0538021` is the direct USB-JTAG port (not suitable for flashing)
- ⚠️ `espflash` is interactive-first, lacks non-interactive automation features
- ✅ Standard Unix tools (`cat`, `screen`, `minicom`) can capture serial output
- 📋 Recommend wrapper scripts + documentation approach (not modifying `espflash`)

---

## Research Summary

### 1. Hardware Port Identification

#### Test Results

**Port 1: `/dev/tty.usbmodem112201`** ✅ **PRIMARY PORT**

```bash
$ espflash board-info --port /dev/tty.usbmodem112201
[2026-02-11T18:26:33Z INFO ] Serial port: '/dev/tty.usbmodem112201'
[2026-02-11T18:26:33Z INFO ] Connecting...
[2026-02-11T18:26:33Z INFO ] Using flash stub
Chip type:         esp32c6 (revision v0.1)
Crystal frequency: 40 MHz
Flash size:        16MB
Features:          WiFi 6, BT 5
MAC address:       40:4c:ca:5e:ae:b8
```

**Status:** ✅ **This is the CH343 USB-to-Serial converter port**
- Use for flashing firmware
- Use for serial console output
- Supports bootloader protocol
- Reliable for automated workflows

**Port 2: `/dev/tty.usbmodem595B0538021`** ❌ **NOT FOR FLASHING**

```bash
$ espflash board-info --port /dev/tty.usbmodem595B0538021
[2026-02-11T18:26:36Z INFO ] Serial port: '/dev/tty.usbmodem595B0538021'
[2026-02-11T18:26:36Z INFO ] Connecting...
[2026-02-11T18:26:37Z INFO ] Using flash stub
Error:   × The bootloader returned an error
  ├─▶ Error while running MemData command
  ╰─▶ Other
```

**Status:** ❌ **This is the direct ESP32-C6 USB port (USB-JTAG-Serial)**
- Cannot be used for flashing (resets disconnect the USB peripheral)
- Could potentially be used for serial output AFTER boot
- Not reliable for automated workflows
- **Recommendation:** Ignore this port, use only `/dev/tty.usbmodem112201`

#### Hardware Configuration

**Board:** nanoESP32-C6 (WeAct Studio / MuseLab)
- **Chip:** ESP32-C6 (RISC-V RV32IMC, revision v0.1)
- **Flash:** 16MB (detected, larger than expected 8MB)
- **Crystal:** 40 MHz
- **USB Interfaces:**
  - CH343 USB-to-Serial converter → `/dev/tty.usbmodem112201` ✅
  - ESP32-C6 native USB-JTAG-Serial → `/dev/tty.usbmodem595B0538021` ❌

**Port Naming on macOS:**
- Pattern: `/dev/tty.usbmodem<serial_number>`
- CH343 port has shorter serial: `112201`
- Direct USB port has longer serial: `595B0538021`

**Recommendation for Scripts:**
```bash
# Hardcode the working port for reliability
ESP32_PORT="/dev/tty.usbmodem112201"

# Or auto-detect by trying board-info on each port
# (but hardcoding is more reliable for automation)
```

---

### 2. espflash Capabilities Analysis

#### What espflash Does Well ✅

**Core Flashing Operations:**
```bash
# Flash ELF binary to board
espflash flash --chip esp32c6 --port /dev/tty.usbmodem112201 firmware.elf

# Flash with automatic monitor
espflash flash --chip esp32c6 --port /dev/tty.usbmodem112201 --monitor firmware.elf

# Reset board
espflash reset --port /dev/tty.usbmodem112201

# Read board information
espflash board-info --port /dev/tty.usbmodem112201

# Erase flash
espflash erase-flash --port /dev/tty.usbmodem112201
```

**Strengths:**
- ✅ Reliable flashing for ESP32-C6
- ✅ Automatic chip detection
- ✅ Handles bootloader protocol complexity
- ✅ Built-in flash stub for speed
- ✅ Supports ELF files directly (no conversion needed)
- ✅ Configurable via `espflash.toml` and `espflash_ports.toml`
- ✅ Good error messages for humans

#### What espflash Lacks for Agentic Workflows ⚠️

**Problem 1: Interactive Monitor**
```bash
# This enters interactive mode - can't capture to file easily
espflash flash --monitor firmware.elf

# Monitor runs until Ctrl+C - no timeout option
espflash monitor --port /dev/tty.usbmodem112201
```

**Problem 2: No Non-Interactive Serial Capture**
- `--monitor` flag is interactive only
- No `--monitor-timeout` option
- No `--monitor-output <file>` option
- Cannot redirect monitor output reliably

**Problem 3: No Test Result Parsing**
- Outputs human-friendly logs, not machine-parseable
- No `--quiet` mode for scripting
- No structured output (JSON, etc.)

**Problem 4: Serial Port Locking**
- `espflash flash` locks the port during operation
- Cannot read serial output during flash
- Must wait for flash to complete before monitoring

**Problem 5: macOS-Specific Issues**
- No `timeout` command (GNU coreutils not standard)
- Serial port behavior differs from Linux
- Need macOS-compatible approaches

#### espflash Library API Analysis

**Library Structure:**
```rust
// espflash can be used as a library
espflash = { version = "3.3", default-features = false }

// Key modules:
// - connection: Serial port communication
// - flasher: Flashing operations
// - command: Low-level ESP32 commands
// - target: Chip-specific logic
```

**Library Usage Complexity:**
- ⚠️ No high-level examples in repository
- ⚠️ CLI module has no SemVer guarantees
- ⚠️ Would require significant Rust code to wrap
- ⚠️ Overkill for simple "flash and capture" workflow

**Recommendation:** **Do NOT use espflash as a library**
- Too complex for our needs
- Shell scripts are simpler and more maintainable
- Library API may change (no SemVer for CLI module)

---

### 3. Alternative Tools Assessment

#### Standard Unix Serial Tools

**`cat` (Built-in)** ✅ **RECOMMENDED**
```bash
# Simple, works on all platforms
cat /dev/tty.usbmodem112201 > output.log &
PID=$!
sleep 10
kill $PID
```

**Pros:**
- ✅ Available everywhere
- ✅ Simple to use in scripts
- ✅ Easy to capture to file

**Cons:**
- ⚠️ No baud rate setting (uses port defaults)
- ⚠️ No timeout built-in (need `sleep` + `kill`)

**`screen` (Available on macOS)** ✅ **GOOD FOR INTERACTIVE**
```bash
# Interactive use
screen /dev/tty.usbmodem112201 115200

# With logging (macOS)
screen -L -Logfile output.log /dev/tty.usbmodem112201 115200
```

**Pros:**
- ✅ Available on macOS by default
- ✅ Can set baud rate
- ✅ Supports logging to file

**Cons:**
- ⚠️ Interactive by default
- ⚠️ Leaves screen session running (need cleanup)
- ⚠️ Complex for automation

**`minicom` (Available via Homebrew)** ⚠️ **REQUIRES INSTALL**
```bash
# Install: brew install minicom
minicom -D /dev/tty.usbmodem112201 -b 115200 -C output.log
```

**Pros:**
- ✅ Good baud rate control
- ✅ Capture to file

**Cons:**
- ⚠️ Not installed by default
- ⚠️ Interactive configuration
- ⚠️ Overkill for simple capture

**`stty` + `cat`** ✅ **BEST FOR AUTOMATION**
```bash
# Configure port settings, then read
stty -f /dev/tty.usbmodem112201 115200 raw -echo
cat /dev/tty.usbmodem112201 > output.log &
PID=$!
sleep 10
kill $PID
```

**Pros:**
- ✅ Full control over serial settings
- ✅ Works on macOS
- ✅ Non-interactive
- ✅ Easy to script

**Cons:**
- ⚠️ Requires two commands (stty + cat)

**Recommendation:** **Use `stty` + `cat` for automation**

---

### 4. Tock Architecture Context

#### Existing Tock Testing Patterns

From the `hardware_testing` skill and SP001 integration report:

**Test Output Protocol:**
```rust
// In Tock kernel code
debug!("[TEST] {name}: start");
debug!("[TEST] {name}: {step}");
debug!("[TEST] {name}: PASS");
debug!("[TEST] {name}: FAIL - {reason}");
debug!("[INFO] {message}");
debug!("[ERROR] {message}");
```

**Expected Boot Output (from SP001):**
```
ESP32-C6 initialization complete. Entering main loop
```

**Panic Output:**
```
panicked at '<reason>', <file>:<line>:<col>
```

#### Integration with Tock Workflow

**Build → Flash → Test Cycle:**
```bash
# 1. Build (in tock/boards/nano-esp32-c6/)
cargo build --release

# 2. Flash
espflash flash --chip esp32c6 --port /dev/tty.usbmodem112201 \
  ../../target/riscv32imc-unknown-none-elf/release/nano-esp32-c6-board

# 3. Capture output
stty -f /dev/tty.usbmodem112201 115200 raw -echo
cat /dev/tty.usbmodem112201 > test_output.log &
PID=$!

# 4. Wait for tests
sleep 10

# 5. Stop capture
kill $PID

# 6. Parse results
grep "initialization complete" test_output.log
grep "PASS" test_output.log
grep "FAIL" test_output.log
```

---

## Specification: Required Tooling

### Tooling Requirements

Based on the analysis, we need the following capabilities:

| Requirement | Priority | Solution |
|-------------|----------|----------|
| Flash binary to ESP32-C6 | HIGH | `espflash flash` (existing) |
| Reset board programmatically | HIGH | `espflash reset` (existing) |
| Capture serial output to file | HIGH | `stty` + `cat` (new script) |
| Timeout-based capture | HIGH | `sleep` + `kill` (new script) |
| Parse test results | MEDIUM | `grep` / `awk` (new script) |
| Automated test execution | MEDIUM | Wrapper script (new) |
| macOS compatibility | HIGH | Use built-in tools only |
| Non-interactive operation | HIGH | Background processes + cleanup |

### Architecture Decision

**Approach:** ✅ **Wrapper Scripts + Documentation**

**Rationale:**
1. `espflash` already handles flashing well - don't reinvent
2. Serial capture is simple with Unix tools - no need for Rust
3. Wrapper scripts are easier to maintain than library code
4. Documentation empowers @integrator to debug issues
5. Keeps tooling simple and transparent

**NOT Chosen:**
- ❌ Modify `espflash` - too complex, not our codebase
- ❌ Use `espflash` as library - overkill for simple tasks
- ❌ Write custom Rust tool - unnecessary complexity

---

## Recommended Tooling Suite

### 1. Flash Script: `flash_esp32c6.sh`

**Purpose:** Flash binary and reset board

```bash
#!/bin/bash
# flash_esp32c6.sh - Flash binary to ESP32-C6
#
# Usage: ./flash_esp32c6.sh <binary.elf>

set -e

BINARY="${1:?Usage: $0 <binary.elf>}"
PORT="${ESP32_PORT:-/dev/tty.usbmodem112201}"
CHIP="esp32c6"

echo "[FLASH] Flashing $BINARY to $CHIP on $PORT"

espflash flash \
  --chip "$CHIP" \
  --port "$PORT" \
  --after hard-reset \
  "$BINARY"

echo "[FLASH] Flash complete, board reset"
```

**Features:**
- ✅ Simple wrapper around `espflash flash`
- ✅ Configurable via `ESP32_PORT` environment variable
- ✅ Hard reset after flash
- ✅ Clear error messages

---

### 2. Serial Capture Script: `capture_serial.sh`

**Purpose:** Capture serial output with timeout

```bash
#!/bin/bash
# capture_serial.sh - Capture serial output from ESP32-C6
#
# Usage: ./capture_serial.sh <duration_seconds> <output_file>

set -e

DURATION="${1:?Usage: $0 <duration> <output_file>}"
OUTPUT="${2:?Usage: $0 <duration> <output_file>}"
PORT="${ESP32_PORT:-/dev/tty.usbmodem112201}"
BAUD="${ESP32_BAUD:-115200}"

echo "[CAPTURE] Capturing from $PORT at $BAUD baud for ${DURATION}s"
echo "[CAPTURE] Output: $OUTPUT"

# Configure serial port
stty -f "$PORT" "$BAUD" raw -echo

# Capture in background
cat "$PORT" > "$OUTPUT" 2>&1 &
PID=$!

echo "[CAPTURE] Started capture (PID: $PID)"

# Wait for duration
sleep "$DURATION"

# Stop capture
kill "$PID" 2>/dev/null || true
wait "$PID" 2>/dev/null || true

echo "[CAPTURE] Capture complete ($(wc -c < "$OUTPUT") bytes)"
```

**Features:**
- ✅ Configurable timeout
- ✅ Configurable baud rate
- ✅ Proper serial port configuration
- ✅ Clean background process management
- ✅ macOS compatible

---

### 3. Test Runner Script: `run_hardware_test.sh`

**Purpose:** Complete flash → capture → parse workflow

```bash
#!/bin/bash
# run_hardware_test.sh - Run hardware test on ESP32-C6
#
# Usage: ./run_hardware_test.sh <binary.elf> [timeout_seconds]

set -e

BINARY="${1:?Usage: $0 <binary.elf> [timeout]}"
TIMEOUT="${2:-10}"
OUTPUT="test_output.log"
PORT="${ESP32_PORT:-/dev/tty.usbmodem112201}"

echo "=== ESP32-C6 Hardware Test ==="
echo "Binary:  $BINARY"
echo "Port:    $PORT"
echo "Timeout: ${TIMEOUT}s"
echo ""

# Step 1: Flash
echo "[1/4] Flashing binary..."
./flash_esp32c6.sh "$BINARY"
echo ""

# Step 2: Wait for boot
echo "[2/4] Waiting for boot (2s)..."
sleep 2
echo ""

# Step 3: Capture output
echo "[3/4] Capturing serial output..."
./capture_serial.sh "$TIMEOUT" "$OUTPUT"
echo ""

# Step 4: Parse results
echo "[4/4] Parsing test results..."
echo ""

# Check for initialization
if grep -q "initialization complete" "$OUTPUT"; then
    echo "✅ BOOT: Kernel initialized"
else
    echo "❌ BOOT: No initialization message"
fi

# Check for test results
PASS_COUNT=$(grep -c "\[TEST\].*PASS" "$OUTPUT" || echo "0")
FAIL_COUNT=$(grep -c "\[TEST\].*FAIL" "$OUTPUT" || echo "0")

echo "✅ PASS: $PASS_COUNT tests"
echo "❌ FAIL: $FAIL_COUNT tests"

# Check for panics
if grep -q "panicked at" "$OUTPUT"; then
    echo "❌ PANIC detected:"
    grep "panicked at" "$OUTPUT"
fi

echo ""
echo "Full output saved to: $OUTPUT"

# Exit with error if any failures
if [ "$FAIL_COUNT" -gt 0 ] || grep -q "panicked at" "$OUTPUT"; then
    exit 1
fi
```

**Features:**
- ✅ Complete automated workflow
- ✅ Clear progress reporting
- ✅ Test result parsing
- ✅ Exit code indicates success/failure
- ✅ Saves full output for debugging

---

### 4. Reset Script: `reset_esp32c6.sh`

**Purpose:** Reset board without flashing

```bash
#!/bin/bash
# reset_esp32c6.sh - Reset ESP32-C6 board

set -e

PORT="${ESP32_PORT:-/dev/tty.usbmodem112201}"

echo "[RESET] Resetting ESP32-C6 on $PORT"

espflash reset --port "$PORT" --after hard-reset

echo "[RESET] Board reset complete"
```

**Features:**
- ✅ Simple reset operation
- ✅ Useful for re-running tests without reflashing

---

### 5. Board Info Script: `board_info.sh`

**Purpose:** Query board information

```bash
#!/bin/bash
# board_info.sh - Get ESP32-C6 board information

set -e

PORT="${ESP32_PORT:-/dev/tty.usbmodem112201}"

echo "[INFO] Querying board on $PORT"
echo ""

espflash board-info --port "$PORT"
```

**Features:**
- ✅ Quick board verification
- ✅ Useful for debugging connection issues

---

## Documentation Requirements

### 1. Hardware Setup Guide

**File:** `docs/hardware_testing_setup.md`

**Contents:**
- Hardware identification (which port to use)
- Port naming on different platforms (macOS vs Linux)
- Troubleshooting connection issues
- Serial port permissions
- Expected boot behavior

### 2. Automated Testing Guide

**File:** `docs/automated_hardware_testing.md`

**Contents:**
- Overview of test automation workflow
- Script descriptions and usage
- Environment variables (`ESP32_PORT`, `ESP32_BAUD`)
- Integration with CI/CD (future)
- Debugging failed tests

### 3. Tooling Reference

**File:** `docs/tooling_reference.md`

**Contents:**
- `espflash` command reference
- Serial port tools comparison
- macOS vs Linux differences
- Port configuration (`stty` settings)
- Common issues and solutions

---

## Workflow Specification for @integrator

### Standard Test Workflow

```bash
# 1. Set environment (optional, scripts have defaults)
export ESP32_PORT="/dev/tty.usbmodem112201"
export ESP32_BAUD="115200"

# 2. Build firmware (in tock/boards/nano-esp32-c6/)
cd tock/boards/nano-esp32-c6
cargo build --release

# 3. Run automated test
cd /path/to/scripts
./run_hardware_test.sh \
  ../../tock/target/riscv32imc-unknown-none-elf/release/nano-esp32-c6-board \
  10

# 4. Review results
# - Script outputs PASS/FAIL summary
# - Full log in test_output.log
# - Exit code 0 = success, 1 = failure
```

### Manual Testing Workflow

```bash
# 1. Flash binary
./flash_esp32c6.sh firmware.elf

# 2. Monitor output interactively
screen /dev/tty.usbmodem112201 115200
# Press Ctrl+A, then K to exit

# 3. Or capture to file
./capture_serial.sh 30 output.log
cat output.log
```

### Debugging Workflow

```bash
# 1. Check board is connected
./board_info.sh

# 2. Reset board
./reset_esp32c6.sh

# 3. Capture output
./capture_serial.sh 10 debug.log

# 4. Analyze output
cat debug.log
grep -i error debug.log
grep -i panic debug.log
```

### Test Result Parsing

**Expected Patterns:**

```bash
# Boot success
grep "initialization complete" test_output.log

# Test results
grep "\[TEST\].*PASS" test_output.log
grep "\[TEST\].*FAIL" test_output.log

# Errors
grep "\[ERROR\]" test_output.log
grep "panicked at" test_output.log

# Info messages
grep "\[INFO\]" test_output.log
```

**Example Output:**

```
ESP32-C6 initialization complete. Entering main loop
[TEST] boot_basic: PASS - kernel running
[TEST] uart_output: PASS - message visible
[INFO] All tests complete
```

---

## Risks Identified

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Serial port locked by another process | Medium | High | Check `lsof` before running, add to scripts |
| Timeout too short for tests | Medium | Medium | Make timeout configurable, document tuning |
| Port name changes on reconnect | Low | Medium | Document port identification, use `board_info.sh` |
| macOS vs Linux differences | Low | Low | Test on both platforms, document differences |
| Baud rate mismatch | Low | Medium | Ensure Tock UART and script use same baud (115200) |
| Background processes not cleaned up | Medium | Low | Use proper `kill` + `wait` in scripts |
| Binary too large for flash | Low | High | Check binary size before flashing (from SP001: 31.8KB is fine) |

---

## Questions for PO

### ✅ Answered by Context

1. **Q:** Should we modify `espflash` or create wrapper scripts?
   **A:** PO stated "UX of espflash might not be well suited for agentic interaction" → implies we should NOT modify espflash, but work around it

2. **Q:** What timeout is appropriate for tests?
   **A:** From SP001, basic boot should be ~2 seconds. Use 10 seconds default with configurability.

3. **Q:** Which serial port should we use?
   **A:** Analysis shows `/dev/tty.usbmodem112201` (CH343) is the correct port.

### ⚠️ Needs PO Confirmation

None - all requirements are clear from context and analysis.

---

## Recommendation

### Recommended Approach: ✅ **Wrapper Scripts + Documentation**

**Implementation Plan:**

1. **Create Scripts (High Priority)**
   - `flash_esp32c6.sh` - Flash wrapper
   - `capture_serial.sh` - Serial capture
   - `run_hardware_test.sh` - Automated test runner
   - `reset_esp32c6.sh` - Reset helper
   - `board_info.sh` - Board info helper

2. **Create Documentation (High Priority)**
   - `docs/hardware_testing_setup.md` - Setup guide
   - `docs/automated_hardware_testing.md` - Testing guide
   - `docs/tooling_reference.md` - Tool reference

3. **Testing (High Priority)**
   - Test all scripts on macOS with actual hardware
   - Verify serial capture works reliably
   - Test timeout handling
   - Document any issues found

4. **Integration (Medium Priority)**
   - Add scripts to repository
   - Update board README with testing instructions
   - Create example test cases

**Effort Estimate:**
- Scripts: 2-3 hours (5 simple bash scripts)
- Documentation: 2-3 hours (3 markdown files)
- Testing: 1-2 hours (verify on hardware)
- **Total: 5-8 hours** (less than 1 day)

**Benefits:**
- ✅ Simple, maintainable solution
- ✅ No modification to external tools
- ✅ Clear documentation for future developers
- ✅ Easy to debug and extend
- ✅ Works on macOS and Linux
- ✅ Enables automated testing immediately

**Alternatives Rejected:**
- ❌ Modify `espflash` - too complex, not our codebase, hard to maintain
- ❌ Use `espflash` library - overkill, API instability, requires Rust expertise
- ❌ Write custom Rust tool - unnecessary, shell scripts sufficient

---

## Handoff to Implementor

### Implementation Guidance

**File Structure:**
```
tools/esp32c6/
├── flash_esp32c6.sh          # Flash wrapper
├── capture_serial.sh         # Serial capture
├── run_hardware_test.sh      # Automated test runner
├── reset_esp32c6.sh          # Reset helper
├── board_info.sh             # Board info helper
└── README.md                 # Tool documentation

docs/
├── hardware_testing_setup.md      # Setup guide
├── automated_hardware_testing.md  # Testing guide
└── tooling_reference.md           # Tool reference
```

**Script Requirements:**
- Use `#!/bin/bash` shebang
- Include usage documentation in comments
- Use `set -e` for error handling
- Support environment variables for configuration
- Provide clear error messages
- Clean up background processes properly

**Testing Requirements:**
- Test all scripts on macOS with actual hardware
- Verify serial capture captures output correctly
- Test timeout handling (short and long)
- Test error cases (missing binary, wrong port, etc.)
- Document any platform-specific issues

**Documentation Requirements:**
- Clear, step-by-step instructions
- Examples for common workflows
- Troubleshooting section
- Platform differences (macOS vs Linux)
- Expected output examples

---

## Analyst Progress Report - PI001/SP002

### Session 1 - 2026-02-11
**Task:** Research and specify tooling requirements for ESP32-C6 hardware debugging

### Completed
- [x] Analyzed espflash capabilities and limitations
- [x] Identified hardware ports (CH343 vs direct USB)
- [x] Tested port connectivity with `espflash board-info`
- [x] Evaluated alternative serial capture tools
- [x] Designed wrapper script architecture
- [x] Specified 5 shell scripts for automation
- [x] Defined documentation requirements
- [x] Created workflow specifications for @integrator
- [x] Assessed risks and mitigations

### Gaps Identified
- None - all requirements are clear

### Handoff Notes

**For Implementor:**
- Create 5 shell scripts in `tools/esp32c6/`
- Create 3 documentation files in `docs/`
- Test on macOS with actual hardware
- Use `/dev/tty.usbmodem112201` as default port
- Follow script template provided in this report
- Ensure macOS compatibility (no GNU-specific tools)

**Key Decisions:**
- ✅ Use wrapper scripts, NOT modify espflash
- ✅ Use `stty` + `cat` for serial capture
- ✅ Use CH343 port (`/dev/tty.usbmodem112201`)
- ✅ Default timeout: 10 seconds (configurable)
- ✅ Default baud rate: 115200 (matches Tock UART)

**Technical Context:**
- Board: nanoESP32-C6, ESP32-C6 rev v0.1, 16MB flash
- Two USB ports: CH343 (use) and direct USB (ignore)
- espflash works well for flashing, poor for automation
- Standard Unix tools sufficient for serial capture
- macOS lacks `timeout` command, use `sleep` + `kill`

---

**Report Complete - Ready for Implementor**

---

## Addendum: Migration to uv (2026-02-11)

### Change Summary

**PO Requirement:** "for any python tooling, we should use uv"

**Changes Made:**
- Updated all documentation to use `uv pip install` instead of `pip3 install`
- Added uv installation instructions to all setup guides
- Updated requirements.txt comment to reference uv

**Rationale:**
- uv is a faster, more modern Python package manager
- Provides better dependency resolution
- Aligns with project standards for Python tooling

**Migration Path:**
```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install dependencies
uv pip install -r requirements.txt
```

**Impact:**
- ✅ No breaking changes - uv is compatible with requirements.txt format
- ✅ All existing workflows continue to work
- ✅ Documentation updated to reflect new standard

**Files Updated:**
- requirements.txt - Updated install comment
- All documentation files referencing pip3

**Status:** ✅ COMPLETE - All references migrated to uv
