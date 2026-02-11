---
name: tdd
description: Test-Driven Development methodology for embedded Rust - Red-Green-Refactor cycle with host testing focus
license: MIT
compatibility: opencode
metadata:
  category: methodology
  for_agent: implementor
  focus: quality, testability
---

# TDD Methodology for Tock ESP32-C6

## The TDD Cycle

```
+-------------------------------------------+
|  1. RED: Write a failing test             |
|     - Test must compile                   |
|     - Test must fail initially            |
|     - Test should run on HOST             |
+-------------------------------------------+
|  2. GREEN: Make the test pass             |
|     - Write minimal code                  |
|     - Don't optimize yet                  |
|     - Focus on correctness                |
+-------------------------------------------+
|  3. REFACTOR: Improve the code            |
|     - Clean up while tests pass           |
|     - Run clippy and fmt                  |
|     - Improve naming and structure        |
+-------------------------------------------+
```

## Host Testing Strategy

Tock kernel code is `#![no_std]`, but tests should run on host where possible:

```rust
// In lib.rs or module
#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_parse_register_value() {
        let value = parse_register(0x12345678);
        assert_eq!(value.field1, 0x12);
        assert_eq!(value.field2, 0x34);
    }
}
```

### What Can Run on Host
- Pure logic (parsing, calculations)
- State machine transitions
- Data structure operations
- Error handling paths

### What Needs Hardware
- Actual register reads/writes
- Interrupt handling
- Peripheral interactions
- Timing-dependent behavior

## Cycle Counting

**One cycle** = one edit/compile/test iteration

| Cycles | Status | Action |
|--------|--------|--------|
| < 15 | Normal | Continue |
| 15-20 | Warning | Document struggle |
| 20-25 | Concern | Consider asking for help |
| > 25 | Critical | Pause, escalate |

## Quality Commands

Run after every GREEN phase:

```bash
cargo fmt
cargo clippy --all-targets -- -D warnings
cargo test
```

## Test Organization

```
src/
  lib.rs
  module/
    mod.rs
    submodule.rs
    #[cfg(test)]
    tests.rs      # Unit tests for module
tests/
  integration/    # Integration tests (if applicable)
```

## Anti-Patterns

- Writing implementation before tests
- Writing multiple tests before any pass
- Skipping refactor phase
- Not tracking cycles
- Tests that only run on target (when host is possible)

## Example TDD Session

```markdown
## Cycle 1 (RED)
- Wrote test_gpio_config_default()
- Test fails: GpioConfig not implemented
- Status: RED

## Cycle 2 (GREEN)
- Implemented GpioConfig struct with Default
- cargo test: PASS
- Status: GREEN

## Cycle 3 (REFACTOR)
- Added documentation
- cargo clippy: PASS
- cargo fmt: PASS
- Status: REFACTOR complete

Total cycles: 3 (target <15)
```
