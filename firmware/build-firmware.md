# Building the patched firmware (reproducible)

The delivered `.bin` images were built like this, so anyone can reproduce them.

## Toolchain
- `arm-none-eabi-gcc` (built with 13.2; the project pins 14.2 — either works),
  `cmake` (3.22+), `ninja`, `python3`.

## Steps
```sh
git clone --depth 1 https://github.com/bedge117/M1.git
cd M1
# Apply the patch documented in m1-meshtastic/firmware/PATCH.md:
#   - add m1_csrc/m1_uart_app.c and m1_csrc/m1_uart_app.h
#   - m1_app_api.c: #include "m1_uart_app.h" + 8 export-table entries
#   - m1_usb_cdc_msc.c: #include + 2 bridge gates (m1_uart_app_owned)
#   - m1_usb_cdc_msc.h: RXSTREAMBUF_UART_SIZE 256 -> 2048
#   - cmake/m1_01/CMakeLists.txt: add ../../m1_csrc/m1_uart_app.c
cmake -G Ninja -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
# Output (CRC already injected by the build's post-step):
#   build/M1_v0800_C3.164_wCRC.bin   <- flash this
```

Building the tree **without** the patch yields the stock image
(`M1_C3.164_STOCK_wCRC.bin`).

## Verification done on the delivered build
- Patched firmware defines all 6 new symbols (`m1_uart_app_*`,
  `m1_poll_button_ex`) in flash.
- Cross-check: **every** symbol the `m1-meshtastic.m1app` imports (47 of them) is
  defined in the patched firmware ELF — the app and firmware are a complete pair.
- Not run on hardware. See FLASHING.md.
