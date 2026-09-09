# Firmware patch — app UART + extended button poll

The app needs two things the stock `bedge117/M1` app SDK does not expose:

1. **A header-UART primitive** so a `.m1app` can talk to a Meshtastic radio over
   USART1 (pin 12 = PA9 TX, pin 13 = PA10 RX).
2. **An extended button poll** that reports long-press (the stock
   `game_poll_button` only surfaces single clicks).

Both are small and reuse existing, tested infrastructure — no new peripheral
bring-up. This is still a **firmware change**: build it, then flash it to the
bank you run apps from. The M1 is dual-bank with CRC fallback, but treat any
flash as risky. Keep a known-good image and know your recovery path before you
start.

All line numbers below are against the `bedge117/M1` tree cloned on 2026-09-09
(revision C3.164 default branch). Re-check the anchors against your tree — they
move between revisions.

---

## 1. Add the new source files

Copy into `m1_csrc/`:

- `m1_uart_app.c`
- `m1_uart_app.h`

Then add the source to the build list in **`cmake/m1_01/CMakeLists.txt`** (the
explicit `../../m1_csrc/*.c` list, around line 425):

```cmake
    ../../m1_csrc/m1_uart_app.c
```

## 2. Register the symbols for apps — `m1_csrc/m1_app_api.c`

Add the include near the other `#include "m1_..."` lines at the top:

```c
#include "m1_uart_app.h"
```

Add these entries to the `api_name_entry_t entries[]` table (put them near the
1-Wire / GPIO block). The table holds up to `API_MAX_SYMBOLS` (256); it has ~235
entries, so there is room.

```c
        /* ===== Header UART for apps (Meshtastic, serial peripherals) ===== */
        { "m1_uart_app_init",      (void *)m1_uart_app_init },
        { "m1_uart_app_deinit",    (void *)m1_uart_app_deinit },
        { "m1_uart_app_read",      (void *)m1_uart_app_read },
        { "m1_uart_app_write",     (void *)m1_uart_app_write },
        { "m1_uart_app_available", (void *)m1_uart_app_available },
        { "m1_poll_button_ex",     (void *)m1_poll_button_ex },
        /* libc helpers the app links against but the table did not yet export */
        { "vsnprintf",             (void *)vsnprintf },
        { "strcpy",                (void *)strcpy },
```

`vsnprintf` and `strcpy` are firmware libc symbols; taking their address here is
the same pattern already used for `snprintf`, `strncpy`, etc.

## 3. Hold off the USB bridge while an app owns the UART — `m1_csrc/m1_usb_cdc_msc.c`

Add the include at the top:

```c
#include "m1_uart_app.h"
```

**3a. Stop draining RX to USB** so the bytes stay in `h_uart_rx_streambuf` for
the app. In `vSer2UsbTask`, at the very top of the `for(;;)` loop body
(before the `xStreamBufferReceive` on `h_uart_rx_streambuf`, ~line 272):

```c
  for(;;)
  {
    if (m1_uart_app_owned) { vTaskDelay(pdMS_TO_TICKS(10)); continue; }   /* <-- add */
    /* Read data from the USART RX Stream Buffer (blocking) */
    received_bytes = xStreamBufferReceive(h_uart_rx_streambuf, ...
```

**3b. Stop forwarding USB->USART1** so stray host bytes do not reach the radio.
In `vUsb2SerTask`, just before `bytes_remaining = received_bytes;` (~line 470,
right after the `#endif /* M1_APP_RPC_ENABLE */`):

```c
#endif /* M1_APP_RPC_ENABLE */

      if (m1_uart_app_owned) { continue; }   /* <-- add: app owns USART1 */

      bytes_remaining = received_bytes;
```

(RPC-over-USB still works: the `m1_rpc_feed` path runs above this point.)

## 4. (Recommended) Grow the UART RX buffer — `m1_csrc/m1_usb_cdc_msc.h`

The RX stream buffer is 256 bytes (line ~46). A Meshtastic `want_config` dump is
several KB in a burst; while the app polls, 256 bytes fill in ~22 ms at 115200.
Give it margin:

```c
#define RXSTREAMBUF_UART_SIZE   2048   /* was 256 */
```

## 5. (Optional) Declare the calls in the app SDK — `bedge117/m1-sdk/include/m1app.h`

The app in this repo vendors its own declarations, so this is only needed if you
want other apps to use these calls. See `firmware/m1app_additions.h`.

---

## Assumptions & caveats

- **VCP mode.** RX only reaches `h_uart_rx_streambuf` when the CDC is in
  `CDC_MODE_VCP` (the USART1 IDLE ISR path). That is the default runtime mode.
  If you build with `M1_DEBUG_CLI_ENABLE`, USART1 RX is routed to the CLI
  instead and the app will see no bytes — build without it, or extend the ISR.
- **Wiring is one pin off from a Flipper.** Node TX -> M1 pin 13 (RX), node RX
  -> M1 pin 12 (TX), share GND. Flipper UART hats are **not** drop-in.
- **TX uses blocking `HAL_UART_Transmit`** on `huart_logdb`. Safe because the
  bridge's DMA-TX path is gated off (3b) while the app owns the UART.
- Revision drift: this was written against C3.164; the device in the field notes
  ran C3.148. Anchors and struct layouts can shift — re-verify before flashing.
