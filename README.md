# m1-meshtastic

A Meshtastic client for the **Monstatek M1**, ported from
[ZeroMesh](https://github.com/SAMS0N1TE/ZeroMesh) (the Flipper Zero Meshtastic
app). It connects to a Meshtastic radio over the M1's header UART and shows the
mesh on the 128×64 display: live messages, a node roster, signal stats,
telemetry, debug logs, and on-device node configuration.

This is a **v1 (lean)** port. It runs as an `.m1app` (a file on the SD card — no
firmware flash to install the app), but it depends on a small **firmware patch**
that exposes a header-UART primitive to apps (see below).

## Status

- **Builds clean** with `arm-none-eabi-gcc` → `m1-meshtastic.m1app` (~34 KB).
- The hard part — the Meshtastic protobuf stack (nanopb + the generated defs)
  and ZeroMesh's stream framing / decode — is carried over and links against the
  M1 app target needing only `memcpy`/`memset` plus soft-float builtins (bundled
  from libgcc).
- **Not yet run on hardware.** The firmware UART primitive and the on-device
  behaviour (display polarity, keyboard, timing, RAM fit) want validation on a
  real M1. Treat this as a reviewable, buildable first cut.

## What's here vs. deferred

Included (7 pages): **Messages, Roster, Stats, Signal, Logs, Settings, Node
Config**. Broadcast + per-node DMs, delivery ACKs, roster with SNR/RSSI/battery/
GPS, node config (region, preset, role, GPS, channel public/private, reboot),
selectable alert tones + LED.

Deferred from v1:
- **Offline vector map** (ZeroMesh's `carto`/`pmtiles`) — the heavy RAM
  consumer; left out to keep the first build within the app heap.
- **Bluetooth transport** — ZeroMesh's BLE needs a custom Meshtastic build and a
  GATT server the M1 ESP32 API doesn't expose.
- **Custom SD `.rtttl` ringtones** — the 18 built-in tones are kept.

## Architecture of the port

| Layer | Origin | What changed |
|---|---|---|
| Protobuf + Meshtastic defs (`lib/nanopb`, `lib/meshtastic_api`) | ZeroMesh, verbatim | none |
| Protocol / framing (`src/protocol.c`) | ZeroMesh | ~6 furi calls swapped; RX thread → `protocol_poll` |
| Transport (`src/transport.c`) | new | binds to the firmware `m1_uart_app_*` primitive |
| App shell (`src/main.c`) | rewritten | single cooperative task (no RX thread/mutex), u8g2 paged draw, `m1_vkb_get_filename` for text |
| GUI + roster + nodecfg | ZeroMesh | drawn through `src/compat.h`, a furi-`Canvas`→u8g2 shim |
| Notify (`src/notify.c`) | reimplemented | M1 buzzer + LP5814 LED |
| Settings (`src/settings.c`) | reimplemented | M1 FatFS instead of Flipper Storage |

`src/compat.h` is the key piece: it maps furi's `Canvas`/`InputEvent`/tick/mutex
/RNG surface onto the M1 SDK so the GUI and protocol code port with mechanical
edits instead of a rewrite.

## Build

Requires `arm-none-eabi-gcc` (10+).

```
make
```

Produces `m1-meshtastic.m1app`.

## Install

1. **Flash the firmware patch** (once) — see [`firmware/PATCH.md`](firmware/PATCH.md).
   Without it, the loader rejects the app with a missing-symbol error, because
   the app SDK has no UART primitive.
2. Copy `m1-meshtastic.m1app` to `0:/apps/` on the M1 SD card.
3. Launch it from the **Apps** menu.

## Wiring

USART1 on the expansion header. **It is one pin off from a Flipper Zero**, so
Flipper UART hats are not drop-in.

| Node | M1 header |
|---|---|
| TX | pin 13 (PA10, RX) |
| RX | pin 12 (PA9, TX) |
| GND | GND |

Set the node's serial module to **PROTO**, baud **115200**.

## Controls

| Page | Key | Action |
|---|---|---|
| any | Left / Right | change page |
| Messages | OK | compose a broadcast |
| Messages | OK (long) | cycle channel |
| Roster | Up / Down | select node |
| Roster | OK | private chat |
| Roster | OK (long) | node details |
| Chat | OK | send · Back | back to roster |
| Logs | OK | pause / resume |
| Settings | OK | edit · Left/Right change value |
| Node Config | OK | edit · Left/Right change · OK long on Reboot |
| any | Back | exit the app |

## Known caveats (v1)

- **Text entry** uses the M1's built-in multi-page keyboard
  (`m1_vkb_get_filename`); message length is bounded by it. A richer on-screen
  keyboard would be a firmware addition.
- **Channel PSK** randomness comes from `m1_crypto_generate_iv` + `rand()`;
  audit before relying on a generated private key.
- **Fixed position** (Node Config) needs the map crosshair, so setting it is a
  no-op in v1; clearing it works.
- Display polarity, font choices, and loop timing are best-guess until validated
  on hardware — see `src/compat.h` (`ColorBlack`→u8g2 draw color 1, `FontPrimary`
  →`helvB08`, `FontSecondary`→`5x8`).

## Licensing

GPL-3.0, inherited from ZeroMesh and the Meshtastic protocol assets; nanopb is
zlib-licensed. See [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) and
[`LICENSE`](LICENSE).
