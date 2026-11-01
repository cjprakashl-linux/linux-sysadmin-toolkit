#!/usr/bin/env bash
# ssl-expiry-check.sh: days until a host's TLS certificate expires.
# Usage: ./ssl-expiry-check.sh <host> [port=443] [warn_days=30]
# Exit codes: 0 OK, 1 expires soon, 2 expired/unreachable, 3 usage error
set -uo pipefail

HOST="${1:-}"; PORT="${2:-443}"; WARN="${3:-30}"
if [[ -z "$HOST" || ! "$PORT" =~ ^[0-9]+$ || ! "$WARN" =~ ^[0-9]+$ ]]; then
  echo "Usage: $0 <host> [port] [warn_days]" >&2
  exit 3
fi
for cmd in openssl date timeout; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "ERROR: $cmd is required" >&2; exit 3; }
done

end="$(echo | timeout 10 openssl s_client -servername "$HOST" -connect "$HOST:$PORT" 2>/dev/null \
  | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)"
if [[ -z "$end" ]]; then
  echo "[CRIT] could not read a certificate from $HOST:$PORT"
  exit 2
fi

days=$(( ( $(date -d "$end" +%s) - $(date +%s) ) / 86400 ))
if (( days < 0 )); then
  echo "[CRIT] $HOST certificate EXPIRED ${days#-} days ago ($end)"; exit 2
elif (( days <= WARN )); then
  echo "[WARN] $HOST certificate expires in $days days ($end)"; exit 1
else
  echo "[OK]   $HOST certificate valid for $days more days ($end)"; exit 0
fi
