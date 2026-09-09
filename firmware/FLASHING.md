# M1 Meshtastic — firmware flashing guide (plain language)

You asked for a ready-to-flash firmware so you don't have to patch it yourself.
Here it is, with the safe way to install it and how to undo it if anything goes
wrong. **Read the "Before you start" box first.**

## What you got

| File | What it is |
|---|---|
| `M1_C3.164_MESHTASTIC_wCRC.bin` | **The candidate.** Stock M1 firmware C3.164 **plus** the small change that lets the Meshtastic app talk to a radio over the header UART. This is the one you flash. |
| `M1_C3.164_STOCK_wCRC.bin` | The **same firmware without** my change — a fallback you can flash to get back to plain C3.164. |
| `m1-meshtastic.m1app` | The Meshtastic app. Goes on the SD card **after** the firmware is flashed. |

Both `.bin` files already have the CRC/metadata the M1 needs — they're ready to
flash as-is.

> ### ⚠️ Before you start — please read
> - **I built this firmware but I could not run it.** It compiles cleanly and I
>   verified the app and firmware fit together perfectly, but no one has powered
>   an M1 on with it yet. Treat it as a test build.
> - **It replaces your current firmware (C3.148) with C3.164 + my change.** I
>   could not get the exact C3.148 source (it was never published), so this is
>   built from the newest public source, C3.164. That's a version bump, not just
>   my patch.
> - **It was built with a slightly different compiler** than the project pins
>   (GCC 13.2 vs 14.2). Binaries should behave the same, but it's a difference.
> - **Recovery exists and does not need special hardware** (see below), but if
>   you're not comfortable doing the recovery steps, it's worth having someone
>   technical on hand the first time.

## What you need
- The M1, a USB cable, and your computer.
- **qMonstatek** — the M1 companion app that does the flashing:
  https://github.com/bedge117/qMonstatek
- **Your original/official firmware image kept somewhere safe** as the primary
  recovery (whatever you'd normally reflash). My `_STOCK_` file is a secondary
  fallback, but an official image is the one to trust most.

## Step 1 — prove the tool works first (no flashing yet)
1. Plug the M1 in, open qMonstatek, let it connect.
2. Confirm it reads the device (battery, firmware version, etc.).

If qMonstatek can't see the device, **stop** — sort that out before flashing.
This step also confirms you can reach the M1 if you later need to recover it.

## Step 2 — flash the candidate
1. In qMonstatek, open the **Firmware Update** page.
2. Choose `M1_C3.164_MESHTASTIC_wCRC.bin`.
3. Flash it and let it finish **without unplugging**.
4. The M1 should reboot into C3.164.

## Step 3 — install and run the app
1. The M1's SD card shows up as a USB drive. Copy
   `m1-meshtastic.m1app` into the **`apps`** folder on it (`0:/apps/`).
2. On the M1, open **Apps** and launch **Meshtastic**.
3. Wire a radio to the header (node **TX → M1 pin 13**, node **RX → M1 pin 12**,
   **GND → GND**), set the radio's serial to **PROTO**, **115200**.
4. Tell me what the screen shows and I'll help from there.

## If something goes wrong — recovery
The part of the firmware that does recovery (the bootloader) is **not** touched
by my change, so this path stays available even if the new firmware misbehaves:

1. **DFU mode:** with the M1 off/unresponsive, hold **Up + OK for ~5 seconds**.
   The screen stays dark — that's normal, it means it's in DFU.
2. Open qMonstatek's **DFU Flash** page.
3. Flash your **official/original firmware** (primary), or
   `M1_C3.164_STOCK_wCRC.bin` (fallback).
4. To leave DFU without flashing, hold **Right + Back** to reboot.

If the screen is dark or frozen after a flash, that's what DFU mode is for — it
is very likely recoverable. Take your time; don't unplug mid-flash.

## Honest bottom line
The app and firmware are proven to fit together, the firmware builds cleanly,
and there's a hardware-free recovery path. What's **not** yet proven is the
firmware running on a real M1. If you'd rather not flash an unverified build to
your only M1, the alternative is to have someone confirm the build on a spare/
bench unit first — tell me and we'll plan that instead.
