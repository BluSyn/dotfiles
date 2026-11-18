#!/usr/bin/env bash
# Prefix-free pane movement, matching tmux is_vim + bind-key -n C-h/j/k/l.
#
# Vim/Neovim: forward the chord so editor splits keep C-h/j/k/l; the nvim
# maps call herdr pane focus at a split edge.
# Agents and shells: move the herdr pane (same as tmux when is_vim is false).
# prefix+h/j/k/l still always moves herdr panes, even from inside nvim.

set -euo pipefail

dir="${1:?usage: navigate.sh <left|down|up|right>}"
herdr="${HERDR_BIN_PATH:-herdr}"
pane="${HERDR_ACTIVE_PANE_ID:-${HERDR_PANE_ID:-}}"

case "$dir" in
  left)  key="ctrl+h" ;;
  down)  key="ctrl+j" ;;
  up)    key="ctrl+k" ;;
  right) key="ctrl+l" ;;
  *)
    echo "navigate.sh: unknown direction: $dir" >&2
    exit 2
    ;;
esac

# Same idea as tmux.conf is_vim: vi, vim, nvim, view, gvim, lvim, *-wrapped, *diff.
vim_re='^g?\.?((l|n)?vim?x?|view)(-wrapped)?(diff)?$'

forward=0
if [ -n "$pane" ] && command -v jq >/dev/null 2>&1; then
  if "$herdr" pane process-info --pane "$pane" 2>/dev/null \
    | jq -e --arg vim "$vim_re" '
        .result.process_info.foreground_processes[]?
        | [
            ((.name // "") | ascii_downcase),
            ((.argv0 // "") | split("/") | last | ascii_downcase)
          ][]
        | select(test($vim))
      ' >/dev/null 2>&1; then
    forward=1
  fi
fi

if [ "$forward" -eq 1 ]; then
  exec "$herdr" pane send-keys "$pane" "$key"
elif [ -n "$pane" ]; then
  exec "$herdr" pane focus --direction "$dir" --pane "$pane"
else
  exec "$herdr" pane focus --direction "$dir" --current
fi
