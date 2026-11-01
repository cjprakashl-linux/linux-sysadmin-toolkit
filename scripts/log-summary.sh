#!/usr/bin/env bash
# log-summary.sh: summarise errors and warnings in a log file.
# Read-only. Usage: ./log-summary.sh <logfile> [top_n=10]
set -uo pipefail

LOG="${1:-}"; TOP="${2:-10}"
if [[ -z "$LOG" || ! -f "$LOG" || ! -r "$LOG" ]]; then
  echo "Usage: $0 <readable_logfile> [top_n]" >&2
  exit 1
fi
if ! [[ "$TOP" =~ ^[0-9]+$ ]]; then
  echo "ERROR: top_n must be a number" >&2
  exit 1
fi

echo "== File: $LOG =="
echo "Total lines: $(wc -l < "$LOG")"
echo "Errors:      $(grep -ciE 'error|fail|fatal|critical' "$LOG")"
echo "Warnings:    $(grep -ciE 'warn' "$LOG")"

echo "== Top $TOP repeated error messages =="
grep -iE 'error|fail|fatal|critical' "$LOG" \
  | sed -E 's/^[A-Z][a-z]{2} +[0-9]+ [0-9:]+ //; s/[0-9]{1,3}(\.[0-9]{1,3}){3}/<ip>/g; s/[0-9]+/<n>/g' \
  | sort | uniq -c | sort -rn | head -n "$TOP"
