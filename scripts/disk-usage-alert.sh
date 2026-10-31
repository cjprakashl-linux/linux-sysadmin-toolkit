#!/usr/bin/env bash
# disk-usage-alert.sh: warn when filesystems exceed a usage threshold.
# Usage: ./disk-usage-alert.sh [warn_pct=80] [crit_pct=90]
# Exit codes: 0 OK, 1 WARN, 2 CRIT, 3 usage error
set -uo pipefail

WARN="${1:-80}"; CRIT="${2:-90}"
if ! [[ "$WARN" =~ ^[0-9]+$ && "$CRIT" =~ ^[0-9]+$ ]] \
   || (( WARN >= CRIT )) || (( CRIT > 100 )); then
  echo "Usage: $0 [warn_pct] [crit_pct]  (numbers, warn < crit <= 100)" >&2
  exit 3
fi

status=0
while read -r fs size used avail pct mount; do
  usage="${pct%\%}"
  if (( usage >= CRIT )); then
    echo "[CRIT] $mount at ${usage}% ($fs, $avail free)"; status=2
  elif (( usage >= WARN )); then
    echo "[WARN] $mount at ${usage}% ($fs, $avail free)"
    (( status < 1 )) && status=1
  else
    echo "[OK]   $mount at ${usage}%"
  fi
done < <(df -hP -x tmpfs -x devtmpfs -x squashfs 2>/dev/null | tail -n +2)

exit "$status"
