#!/bin/bash
# Asahi/brcmfmac on Apple Silicon: the first iwd associate after boot fails
# (NetworkManager surfaces it as "wrong password" / no-secrets). Toggling
# Wi-Fi off and on, as in the Omarchy menu, makes the next associate work.
# Run from the post-boot hook so login does that bounce automatically.

set -euo pipefail

log() {
  printf 'asahi-wifi-bounce: %s\n' "$*" | systemd-cat -t asahi-wifi-bounce -p info
}

if ! command -v nmcli >/dev/null; then
  exit 0
fi

wifi_state() {
  nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null | awk -F: '$2=="wifi" {print $1,$3; exit}'
}

wait_for_wlan() {
  local i
  for i in $(seq 1 30); do
    if [[ -n $(wifi_state) ]]; then
      return 0
    fi
    sleep 0.5
  done
  return 1
}

already_connected() {
  nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null | awk -F: '$2=="wifi" && $3=="connected" {found=1} END {exit !found}'
}

if already_connected; then
  log 'wlan already connected, skipping bounce'
  exit 0
fi

if ! wait_for_wlan; then
  log 'no wifi device, skipping'
  exit 0
fi

log 'bouncing wifi radio (brcmfmac/iwd first-associate workaround)'
nmcli radio wifi off || true
sleep 1
nmcli radio wifi on || true

for i in $(seq 1 25); do
  if already_connected; then
    log 'connected after bounce'
    exit 0
  fi
  sleep 0.4
done

# Autoconnect did not fire; try saved wifi profiles in name order.
while IFS=: read -r name type autoconnect; do
  [[ $type == 802-11-wireless && $autoconnect == yes ]] || continue
  log "activating $name"
  if nmcli -w 20 connection up "$name"; then
    log "connected via $name"
    exit 0
  fi
done < <(nmcli -t -f NAME,TYPE,AUTOCONNECT connection show)

log 'bounce finished; still not connected (will need the menu)'
exit 0
