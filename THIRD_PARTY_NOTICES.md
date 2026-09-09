# Third-Party Notices

This project is a port of ZeroMesh and includes third-party open-source
software. Notices are provided for attribution and license compliance.

## ZeroMesh (upstream)
Project: ZeroMesh — a Meshtastic client for the Flipper Zero
Source: https://github.com/SAMS0N1TE/ZeroMesh
License: GNU General Public License v3.0 (GPL-3.0)
Notice: This repository ports ZeroMesh's protocol, framing and UI to the
Monstatek M1. The offline map (libcarto/pmtiles) and the BLE transport are not
included in this port.

## Meshtastic firmware / protocol assets
Project: Meshtastic
Source: https://github.com/meshtastic/firmware
License: GNU General Public License v3.0 (GPL-3.0)
Notice: lib/meshtastic_api contains the generated Meshtastic message
definitions.

## Nanopb
Project: nanopb
Source: https://github.com/nanopb/nanopb
License: zlib license
Notice: The zlib license text must be retained with distributions. Vendored
verbatim under lib/nanopb.

## Flipper Zero firmware / SDK
Project: flipperzero-firmware
Source: https://github.com/flipperdevices/flipperzero-firmware
License: GNU General Public License v3.0 (GPL-3.0)
Notice: ZeroMesh targeted the Flipper SDK; API shapes referenced by the port
originate there.

## Monstatek M1 firmware / app SDK
Project: bedge117/M1, bedge117/m1-sdk
Source: https://github.com/bedge117/M1 , https://github.com/bedge117/m1-sdk
License: see upstream (M1 firmware ships under its own COPYING.txt).
Notice: firmware/ contains a patch (m1_uart_app.*) intended to be added to the
bedge117/M1 firmware tree.
