# PI001/SP003 - Implementation Report: Serial Port Timing Fix

## TDD Summary
- Tests written: 8
- Tests passing: 8
- Cycles: 2 / target <15

## Problem Statement
After `espflash reset`, the serial monitor failed with "Errno 6 Device not configured" error. This occurred because the ESP32-C6 USB-JTAG port needs time to re-enumerate after reset, and the monitor script attempted to open the port before it was ready.

## Solution Approach
Implemented a two-layer solution:
1. **Shell script delay**: Increased sleep from 2 to 5 seconds after reset
2. **Monitor retry logic**: Added port availability checking with retry in Python script

## Files Modified

### 1. `scripts/monitor_serial.py`
**Purpose**: Added retry logic for port availability

**Changes**:
- Added `wait_for_port()`: Waits for port device to exist in filesystem
- Added `is_port_ready()`: Tests if port can be opened (handles Errno 6)
- Added `monitor_serial_with_retry()`: Wrapper with retry logic
- Updated `main()`: Uses retry logic with 10-second timeout

**Key Features**:
- Checks port existence before attempting to open
- Handles OSError errno 6 (Device not configured) gracefully
- Configurable timeout and check interval
- Clear user feedback during wait

### 2. `scripts/test_esp32c6.sh`
**Purpose**: Increased delay after reset

**Changes**:
- Increased sleep from 2 to 5 seconds after reset
- Added explanatory comment about USB-JTAG re-enumeration
- Added user-visible log message during wait

### 3. `scripts/test_monitor_serial.py` (NEW)
**Purpose**: Unit tests for monitor script

**Test Coverage**:
- `test_wait_for_port_exists_immediately`: Port available immediately
- `test_wait_for_port_exists_after_delay`: Port appears after delay
- `test_wait_for_port_timeout`: Port never appears (timeout)
- `test_is_port_ready_success`: Port can be opened
- `test_is_port_ready_not_configured`: Errno 6 handling
- `test_is_port_ready_other_error`: Other error handling
- `test_monitor_serial_with_retry_success_first_try`: Full retry flow success
- `test_monitor_serial_with_retry_port_not_ready`: Full retry flow timeout

## Quality Status
- ✅ Python syntax: PASS
- ✅ Bash syntax: PASS
- ✅ Unit tests: PASS (8/8 tests)
- ✅ No external dependencies added

## Test Coverage

| Test | Purpose | Status |
|------|---------|--------|
| test_wait_for_port_exists_immediately | Port exists check - immediate | PASS |
| test_wait_for_port_exists_after_delay | Port exists check - delayed | PASS |
| test_wait_for_port_timeout | Port exists check - timeout | PASS |
| test_is_port_ready_success | Port open check - success | PASS |
| test_is_port_ready_not_configured | Port open check - errno 6 | PASS |
| test_is_port_ready_other_error | Port open check - other error | PASS |
| test_monitor_serial_with_retry_success_first_try | Full flow - success | PASS |
| test_monitor_serial_with_retry_port_not_ready | Full flow - timeout | PASS |

## Implementation Details

### Port Availability Logic
```python
def wait_for_port(port, timeout=10, check_interval=0.5):
    """Wait for port device to exist in filesystem"""
    start_time = time.time()
    while time.time() - start_time < timeout:
        if os.path.exists(port):
            return True
        time.sleep(check_interval)
    return False
```

### Port Ready Check
```python
def is_port_ready(port, baudrate, timeout=1):
    """Check if port can be opened (handles errno 6)"""
    try:
        ser = serial.Serial(port=port, baudrate=baudrate, timeout=timeout)
        ser.close()
        return True
    except OSError as e:
        if e.errno == 6:  # Device not configured
            return False
        return False
    except Exception:
        return False
```

### Retry Flow
1. Wait for port to exist in filesystem (up to 10 seconds)
2. Wait for port to be ready to open (up to 10 seconds)
3. Proceed with normal monitoring
4. Return None if port never becomes ready

## User Experience Improvements
- Clear feedback: "Waiting for port to be ready..."
- Clear feedback: "Port exists, checking if ready to open..."
- Clear feedback: "Port ready!"
- Error messages indicate timeout duration
- No confusing stack traces for expected timing issues

## Verification
- ✅ Unit tests pass (8/8)
- ✅ Python syntax valid
- ✅ Bash syntax valid
- ✅ Handles errno 6 gracefully
- ✅ Configurable timeouts
- ✅ User-friendly messages

## Handoff Notes

### For Integrator
This fix addresses the serial port timing issue after board reset. The solution is defensive and should work across different USB enumeration speeds.

**Testing recommendations**:
1. Run full hardware test with actual ESP32-C6 board
2. Verify monitor connects successfully after reset
3. Check that 5-second delay is sufficient (may need tuning)
4. Verify error messages are clear if port never appears

**Configuration**:
- Shell script delay: 5 seconds (line 148 in test_esp32c6.sh)
- Monitor timeout: 10 seconds (configurable in monitor_serial_with_retry)
- Check interval: 0.5 seconds (configurable)

**Potential improvements**:
- Could make delays configurable via environment variables
- Could add exponential backoff for check interval
- Could detect port type and adjust delays accordingly

### Known Limitations
- Fixed 5-second delay may be too long for fast systems or too short for slow systems
- No detection of permanent port failure vs. temporary enumeration delay
- Assumes port will eventually appear (no alternative port fallback)

### Future Enhancements
- Auto-detect optimal delay based on port type
- Support for multiple port candidates
- More sophisticated USB enumeration detection
- Integration with system USB event monitoring

## TDD Cycles

### Cycle 1: Port Availability Functions
- **RED**: Wrote tests for `wait_for_port()` and `is_port_ready()`
- **GREEN**: Implemented functions to pass tests
- **REFACTOR**: N/A (simple implementation)

### Cycle 2: Integration
- **RED**: Wrote test for `monitor_serial_with_retry()`
- **GREEN**: Implemented retry wrapper and updated main()
- **REFACTOR**: Updated shell script delay and added comments

## Metrics
- Lines of code added: ~100 (Python)
- Lines of test code: ~100
- Test coverage: 100% of new functions
- Time to implement: 2 TDD cycles
- No regressions introduced
