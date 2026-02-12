# USER_QUESTIONS.md - PI001/SP003

## Open Questions

### Q1: Boot Mode and Serial Output Investigation
**Asked by:** @supervisor
**Date:** 2026-02-12
**Context:** We implemented USB-JTAG serial driver but get 0 bytes output (not even ROM bootloader messages)

**Situation:**
- Flash succeeds (30KB binary written)
- Reset succeeds
- Port opens successfully
- But 0 bytes received on USB-JTAG serial

**Questions:**
1. When you manually run `espflash monitor`, do you see ROM bootloader output? (You mentioned seeing "boot:0x4" and bootloader assertion earlier)
2. If yes, does the ROM output appear IMMEDIATELY after reset, or do you need to press a button?
3. Can you try this command and share the full output?
   ```bash
   cd /Users/az02096/dev/perso/esp/esp_tock
   espflash reset --chip esp32c6 --port /dev/tty.usbmodem112201
   # Then immediately press CTRL+R in espflash monitor to capture boot
   espflash monitor --chip esp32c6 --port /dev/tty.usbmodem112201
   ```

**Why this matters:**
- If ROM bootloader DOES output to USB-JTAG, our driver should work
- If ROM bootloader does NOT output, we need to understand the boot sequence
- The bootloader assertion you saw suggests the device IS booting, we're just not capturing it

**PO Response:**
[PO fills this in]

0 %    espflash reset --chip esp32c6 --port /dev/tty.usbmodem112201

[2026-02-12T09:22:17Z INFO ] Serial port: '/dev/tty.usbmodem112201'
[2026-02-12T09:22:17Z INFO ] Connecting...
[2026-02-12T09:22:17Z INFO ] Resetting target device
0
az02096@RSLMAC034   ~
0 %    espflash monitor --chip esp32c6 --port /dev/tty.usbmodem112201

[2026-02-12T09:22:27Z INFO ] Serial port: '/dev/tty.usbmodem112201'
[2026-02-12T09:22:27Z INFO ] Connecting...
[2026-02-12T09:22:27Z INFO ] Using flash stub
Commands:
    CTRL+R    Reset chip
    CTRL+C    Exit

ESP-ROM:esp32c6-20220919
Build:Sep 19 2022
rst:0x15 (USB_UART_HPSYS),boot:0x4 (DOWNLOAD(USB/UART0/SDIO_FEI_FEO))
Saved PC:0x40800548
waiting for download

---

### Q2: Embassy Reference Test
**Asked by:** @supervisor
**Date:** 2026-02-12
**Context:** We have a working embassy-rs project in `embassy-on-esp/` directory

**Question:**
Can you test the embassy project to confirm it still works and shows serial output?
```bash
cd /Users/az02096/dev/perso/esp/esp_tock/embassy-on-esp
cargo run --release
```

**Why this matters:**
- Confirms hardware is working
- Confirms USB-JTAG serial works
- Gives us a known-good baseline to compare against

**PO Response:**
[PO fills this in]

Indeed cargo run was not working anymore!
I had to do a full power cycle to get a working hw again.

No I get the embassy demo working again
---

### Q3: Manual Flash Test with --monitor Flag
**Asked by:** @supervisor
**Date:** 2026-02-12
**Context:** We fixed the boot mode issue (boot:0xc now), but automated tests still capture 0 bytes

**Question:**
Can you manually run the flash script and observe the output?
```bash
cd /Users/az02096/dev/perso/esp/esp_tock
./scripts/flash_esp32c6.sh tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board
```

**What to look for:**
1. Does it show `boot:0xc (SPI_FAST_FLASH_BOOT)`? ✅ (we expect YES)
2. Do you see ESP-IDF bootloader messages? (like "I (23) boot: ESP-IDF...")
3. Do you see the bootloader assertion error? ("Assert failed in unpack_load_app, bootloader_utility.c:769")
4. Do you see ANY output after the bootloader assertion?
5. If you see "Hello World from Tock!" we succeeded! 🎉

**Why this matters:**
- Automated test may have timing issues
- Manual observation will show us the actual boot sequence
- We need to know if Tock kernel starts after bootloader

**PO Response:**
[PO fills this in]

The script exit itself after a while

./scripts/flash_esp32c6.sh tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board
(output showing boot:0xc and bootloader assertion)

---

### Q4: Test Updated Linker Script (3 segments instead of 4)
**Asked by:** @supervisor
**Date:** 2026-02-12
**Context:** We reduced segments from 4 to 3 (target was 2, but couldn't achieve it)

**Question:**
Can you rebuild and test with the updated linker script?
```bash
cd /Users/az02096/dev/perso/esp/esp_tock/tock/boards/nano-esp32-c6
make
cd /Users/az02096/dev/perso/esp/esp_tock
./scripts/flash_esp32c6.sh tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board
```

**What to look for:**
1. Does bootloader still show assertion error? (maybe 3 segments is OK?)
2. If assertion gone, do you see "Jumping to entry point 0x42000020"?
3. Do you see "Hello World from Tock!"?

**Why this matters:**
- The bootloader assertion might accept 3 segments (not strictly ==2)
- We made progress (4→3 segments)
- Need to know if we must reach exactly 2 or if 3 is enough

**PO Response:**
[PO fills this in]

[INFO] Using espflash: /Users/az02096/.cargo/bin/espflash
[INFO] Version: espflash 3.3.0
[INFO] Using port: /dev/tty.usbmodem112201
[INFO] ================================================
[INFO] ESP32-C6 Direct Boot Flash (Embassy-style)
[INFO] ================================================
[INFO] Kernel ELF: tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board
[INFO] Port: /dev/tty.usbmodem112201
[INFO] Chip: esp32c6
[INFO]
[INFO] Flashing kernel with espflash (direct boot mode)...
[INFO] This will:
[INFO]   1. Convert ELF to ESP32 image format
[INFO]   2. Add 32-byte espflash header
[INFO]   3. Flash to offset 0x0
[INFO]   4. ROM bootloader will jump to 0x42000020
[INFO]
[2026-02-12T09:44:13Z INFO ] Serial port: '/dev/tty.usbmodem112201'
[2026-02-12T09:44:13Z INFO ] Connecting...
[2026-02-12T09:44:14Z INFO ] Using flash stub
Chip type:         esp32c6 (revision v0.1)
Crystal frequency: 40 MHz
Flash size:        16MB
Features:          WiFi 6, BT 5
MAC address:       40:4c:ca:5e:ae:b8
App/part. size:    30,288/4,128,768 bytes, 0.73%
[2026-02-12T09:44:14Z INFO ] Segment at address '0x0' has not changed, skipping write
[2026-02-12T09:44:14Z INFO ] Segment at address '0x8000' has not changed, skipping write
[2026-02-12T09:44:14Z INFO ] Segment at address '0x10000' has not changed, skipping write
[2026-02-12T09:44:14Z INFO ] Flashing has completed!
Commands:
    CTRL+R    Reset chip
    CTRL+C    Exit

ESP-ROM:esp32c6-20220919
Build:Sep 19 2022
rst:0x15 (USB_UART_HPSYS),boot:0xc (SPI_FAST_FLASH_BOOT)
Saved PC:0x4080054c
0x4080054c - STACK_MEMORY
    at ??:??
SPIWP:0xee
mode:DIO, clock div:1
load:0x4086c410,len:0xd48
load:0x4086e610,len:0x2d68
load:0x40875720,len:0x1800
entry 0x4086c410
I (23) boot: ESP-IDF v5.1-beta1-378-gea5e0ff298-dirt 2nd stage bootloader
I (23) boot: compile time Jun  7 2023 08:02:08
I (24) boot: chip revision: v0.1
I (28) boot.esp32c6: SPI Speed      : 80MHz
I (33) boot.esp32c6: SPI Mode       : DIO
I (37) boot.esp32c6: SPI Flash Size : 4MB
I (42) boot: Enabling RNG early entropy source...
I (48) boot: Partition Table:
I (51) boot: ## Label            Usage          Type ST Offset   Length
I (58) boot:  0 nvs              WiFi data        01 02 00009000 00006000
I (66) boot:  1 phy_init         RF data          01 01 0000f000 00001000
I (73) boot:  2 factory          factory app      00 00 00010000 003f0000
I (81) boot: End of partition table
I (85) esp_image: segment 0: paddr=00010020 vaddr=42000020 size=0760ch ( 30220) map
I (100) boot: Loaded app from partition at offset 0x10000
I (100) boot: Disabling RNG early entropy source...
Assert failed in unpack_load_app, bootloader_utility.c:769 (rom_index == 2)
Error:   × Broken pipe

---

### Q5: Test .text_gap Fix - Bootloader Assertion Should Be Gone
**Asked by:** @supervisor
**Date:** 2026-02-12
**Context:** Analyst found root cause - espflash was merging segments into 1, bootloader expects 2

**Question:**
Can you rebuild and test with the .text_gap fix?
```bash
cd /Users/az02096/dev/perso/esp/esp_tock/tock/boards/nano-esp32-c6
make
cd /Users/az02096/dev/perso/esp/esp_tock
./scripts/flash_esp32c6.sh tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board
```

**What to look for:**
1. Does the bootloader assertion "Assert failed in unpack_load_app, bootloader_utility.c:769 (rom_index == 2)" DISAPPEAR? ✅
2. Do you see "Jumping to entry point 0x42000020"?
3. What happens after that? Any new errors or output?
4. Do you see "Hello World from Tock!"?

**Why this matters:**
- Analyst proved espflash was merging segments (1 instead of 2)
- .text_gap creates a gap to prevent merging
- This should fix the bootloader assertion
- We may have new issues after bootloader, but this is progress!

**PO Response:**
[PO fills this in]

---
