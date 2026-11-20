#!/bin/sh
# Power off Bluetooth adapters at session start.
# Keeps the bluetoothd service running; only disables the adapter radio.
# BlueZ auto-powers adapters on at boot, so this overrides that.

command -v bluetoothctl >/dev/null 2>&1 || exit 0

# Wait for bluetoothd to be ready (retry ~15s), then power off every adapter.
i=0
while ! bluetoothctl show >/dev/null 2>&1; do
    i=$((i + 1))
    [ "$i" -ge 15 ] && exit 1
    sleep 1
done

bluetoothctl power off >/dev/null