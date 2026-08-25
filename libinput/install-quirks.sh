#!/bin/bash
# Copy the Asahi SPI trackpad quirks into the path libinput actually reads.
# Usage: pkexec ~/dotfiles/libinput/install-quirks.sh
set -euo pipefail

src="$(cd "$(dirname "$0")" && pwd)/local-overrides.quirks"
install -m 0644 "$src" /etc/libinput/local-overrides.quirks

# Rebind the SPI trackpad so Hyprland/libinput re-read quirks without a logout.
hid=001C:05AC:0343.0002
if [[ -e /sys/bus/hid/drivers/magicmouse/$hid ]]; then
  printf '%s' "$hid" > /sys/bus/hid/drivers/magicmouse/unbind
  sleep 0.3
  printf '%s' "$hid" > /sys/bus/hid/drivers/magicmouse/bind
fi
