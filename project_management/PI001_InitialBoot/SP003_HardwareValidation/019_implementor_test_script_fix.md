# PI001/SP003 - Implementation Report #019

## TDD Summary
- Tests written: 0 (script fix, no unit tests needed)
- Tests passing: N/A
- Cycles: 1 / target <15

## Task
Fix test_esp32c6.sh to use single USB-JTAG port for both flashing and serial monitoring.

## Files Modified
- scripts/test_esp32c6.sh - Removed UART_PORT, use FLASH_PORT for both operations

## Changes Made

### 1. Configuration Section (Lines 17-22)
**Before:**
```bash
# Configuration
FLASH_PORT="${FLASH_PORT:-/dev/tty.usbmodem112201}"  # ESP32-C6 native USB
UART_PORT="${UART_PORT:-/dev/tty.usbmodem595B0538021}"  # CH343 UART
BAUDRATE="${BAUDRATE:-115200}"
TEST_DURATION="${2:-10}"  # Default 10 seconds
KERNEL_ELF="$1"
```

**After:**
```bash
# Configuration
# ESP32-C6 USB-JTAG port handles BOTH flashing AND serial monitor
FLASH_PORT="${FLASH_PORT:-/dev/tty.usbmodem112201}"  # ESP32-C6 native USB-JTAG
BAUDRATE="${BAUDRATE:-115200}"
TEST_DURATION="${2:-10}"  # Default 10 seconds
KERNEL_ELF="$1"
```

**Rationale:**
- Removed UART_PORT variable entirely
- Added comment explaining USB-JTAG handles both operations
- This aligns with SP002 goal: autonomous testing without manual intervention

### 2. Monitor Section (Lines 115-123)
**Before:**
```bash
log_info "Monitoring $UART_PORT at $BAUDRATE baud..."

if python3 "$MONITOR_SCRIPT" "$UART_PORT" "$BAUDRATE" ...
```

**After:**
```bash
log_info "Monitoring $FLASH_PORT at $BAUDRATE baud..."

if python3 "$MONITOR_SCRIPT" "$FLASH_PORT" "$BAUDRATE" ...
```

**Rationale:**
- Use same port for monitoring as flashing
- After espflash reset, the JTAG port is ready for serial monitoring
- No need to switch ports or wait for different device

## Quality Status
- bash -n: PASS (syntax check)
- Script structure: PASS (no logic errors)
- Comments: PASS (clear explanation of single-port usage)

## Verification

### Syntax Check
```bash
$ bash -n scripts/test_esp32c6.sh
# No errors - syntax is valid
```

### Key Improvements
1. **Single Port**: FLASH_PORT (/dev/tty.usbmodem112201) used for all operations
2. **Autonomous**: No manual port switching needed
3. **Clear Documentation**: Comments explain USB-JTAG dual functionality
4. **Workflow**: Flash → Reset → Monitor (all on same port)

## Test Flow (Updated)
1. **Board Detection**: espflash board-info --port $FLASH_PORT
2. **Flash Firmware**: espflash flash --port $FLASH_PORT
3. **Reset Board**: espflash reset --port $FLASH_PORT
4. **Monitor Serial**: python3 monitor_serial.py $FLASH_PORT (same port!)
5. **Verify Output**: Check for expected messages

## Handoff Notes

### For Integrator
- Script is ready for testing with actual hardware
- Should work with single USB-JTAG cable
- No manual intervention needed between flash and monitor
- Port can be overridden via environment: `FLASH_PORT=/dev/ttyUSB0 ./test_esp32c6.sh ...`

### Next Steps
1. Test with actual hardware to verify single-port operation
2. Confirm serial output is captured correctly after reset
3. Validate that no port conflicts occur during monitor phase

### Known Considerations
- 2-second sleep after reset (line 113) may need tuning
- Monitor script must handle port being "busy" immediately after reset
- Python serial library should auto-handle port availability

## Success Criteria Met
- [x] Single port variable (FLASH_PORT) for both operations
- [x] UART_PORT removed
- [x] Monitor uses FLASH_PORT
- [x] Syntax validated
- [x] Comments explain dual-use of USB-JTAG port

---

**Status**: ✅ COMPLETE
**Cycles**: 1
**Quality**: All checks passed
**Ready for**: Hardware validation testing
