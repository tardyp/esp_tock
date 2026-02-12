# Analyst Progress Report - PI001/SP003

## Session 026 - 2026-02-12
**Task:** Analyze why ESP32-C6 boots in DOWNLOAD mode instead of NORMAL mode

### Completed
- [x] Loaded ESP32-C6 skill for hardware reference
- [x] Analyzed PO feedback showing `boot:0x4` DOWNLOAD mode
- [x] Researched ESP32-C6 boot mode selection (GPIO strapping)
- [x] Compared our flash script vs embassy's approach
- [x] Tested espflash with/without --monitor flag
- [x] Analyzed espflash source code for reset behavior
- [x] Identified root cause: missing --monitor flag
- [x] Documented boot mode codes (0x4 vs 0xc)
- [x] Explained why power cycle was needed
- [x] Created comprehensive 570-line analysis report
- [x] Provided exact fix (one-line change)

### Key Findings

#### Root Cause
`espflash flash` without `--monitor` flag leaves device in DOWNLOAD mode (boot:0x4) because:
1. espflash enters bootloader mode to flash (GPIO9=LOW)
2. Flash completes successfully
3. Without --monitor, no final reset to normal mode
4. Device stays in "waiting for download" state
5. Power cycle forces hardware reset with GPIO9=HIGH → normal boot

#### Evidence
- Embassy uses `runner = "espflash flash --monitor"` (works ✓)
- Our script uses `espflash flash` without --monitor (fails ✗)
- PO confirmed: power cycle was needed, embassy now works

#### Solution
Add `--monitor` flag to `scripts/flash_esp32c6.sh` (line 126):
```bash
espflash flash --monitor "$KERNEL_ELF"
```

### Boot Mode Analysis

| Code | GPIO9 | GPIO8 | Mode | Description |
|------|-------|-------|------|-------------|
| 0x4  | 0 | 1 | DOWNLOAD | Bootloader waiting for flash |
| 0xc  | 1 | 1 | SPI_FAST_FLASH_BOOT | Normal application boot |

**Current state:** boot:0x4 (DOWNLOAD)  
**Target state:** boot:0xc (NORMAL)

### Risks Identified

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Device stuck in DOWNLOAD mode | HIGH | Add --monitor flag |
| User must power cycle | HIGH | Fix flash script |
| Inconsistent boot behavior | MEDIUM | Document procedure |

### Gaps Identified
None - analysis is complete with high confidence.

### Handoff Notes

**For Implementor:**
1. **File to modify:** `scripts/flash_esp32c6.sh`
2. **Change:** Add `--monitor` flag to espflash command (line 126)
3. **Testing:** Flash kernel, verify `boot:0xc` in output
4. **Success criteria:** No power cycle needed between flashes

**Implementation details:**
- One-line change (add --monitor flag)
- Matches embassy's proven approach
- Provides immediate boot feedback
- No code changes needed (USB-JTAG driver is correct)

**Alternative if --monitor causes issues:**
- Use `--after hard-reset` flag instead
- Add 2-second sleep after flash
- Document reason in commit

### References
1. ESP32-C6 datasheet - Strapping pins section
2. esptool boot mode documentation
3. espflash source code (reset.rs, cli/mod.rs)
4. Embassy .cargo/config.toml

### Confidence Level
**HIGH** - Root cause confirmed through:
- PO feedback (boot:0x4 observed)
- espflash source code analysis
- Embassy comparison (uses --monitor)
- Boot mode documentation (GPIO strapping)

---

**Status:** ✅ Analysis complete, ready for implementation  
**Next Agent:** @implementor  
**Estimated Implementation:** 1 iteration (simple script change)
