#!/usr/bin/env bash

# keeps balance when changing volume with pipewire/wpaudioctl
# change the LBAL and RBAL variables to adjust the balance ratio
# by J Avalos
set -euo pipefail

SINK='@DEFAULT_AUDIO_SINK@'
STEP=0.05          # 5%
LIMIT=1.0          # cap at 100%
LBAL=0.99
RBAL=0.95

dir="${1:-}"
case "$dir" in
  up)   delta="$STEP" ;;
  down) delta="-$STEP" ;;
  *) echo "Usage: $0 {up|down}" >&2; exit 2 ;;
esac

cur="$(wpctl get-volume "$SINK" | awk '{print $2}')"

new="$(awk -v c="$cur" -v d="$delta" -v lim="$LIMIT" '
  BEGIN {
    n = c + d
    if (n < 0) n = 0
    if (n > lim) n = lim
    printf "%.4f", n
  }')"

ratio="$(awk -v l="$LBAL" -v r="$RBAL" 'BEGIN{printf "%.8f", r/l}')"
L="$new"
R="$(awk -v n="$new" -v k="$ratio" 'BEGIN{printf "%.4f", n*k}')"

wpctl set-volume -l "$LIMIT" "$SINK" "$L" "$R"
