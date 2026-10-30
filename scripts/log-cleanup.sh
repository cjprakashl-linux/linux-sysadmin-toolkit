#!/usr/bin/env bash
# log-cleanup.sh: compress old logs, delete very old archives.
# Dry-run by default. Add --apply to make changes.
# Usage: ./log-cleanup.sh <log_dir> [compress_days=7] [delete_days=30] [--apply]
set -euo pipefail
umask 077

APPLY=0; ARGS=()
for a in "$@"; do
  if [[ "$a" == "--apply" ]]; then APPLY=1; else ARGS+=("$a"); fi
done
DIR="${ARGS[0]:-}"; COMPRESS="${ARGS[1]:-7}"; DELETE="${ARGS[2]:-30}"

if [[ -z "$DIR" || ! -d "$DIR" ]]; then
  echo "Usage: $0 <log_dir> [compress_days] [delete_days] [--apply]" >&2
  exit 1
fi
if ! [[ "$COMPRESS" =~ ^[0-9]+$ && "$DELETE" =~ ^[0-9]+$ ]]; then
  echo "ERROR: days must be numbers" >&2; exit 1
fi
if (( DELETE <= COMPRESS )); then
  echo "ERROR: delete_days must be greater than compress_days" >&2; exit 1
fi
case "$(realpath "$DIR")" in
  /|/etc|/bin|/usr|/home|/root) echo "ERROR: refusing to run on $DIR" >&2; exit 1;;
esac

echo "Mode: $([[ $APPLY -eq 1 ]] && echo APPLY || echo DRY-RUN)"
echo "== To compress (*.log older than $COMPRESS days) =="
find "$DIR" -type f -name "*.log" -mtime +"$COMPRESS" -print
echo "== To delete (*.gz older than $DELETE days) =="
find "$DIR" -type f -name "*.gz" -mtime +"$DELETE" -print

if [[ $APPLY -eq 1 ]]; then
  find "$DIR" -type f -name "*.log" -mtime +"$COMPRESS" -exec gzip -f {} \;
  find "$DIR" -type f -name "*.gz" -mtime +"$DELETE" -delete
  echo "Done."
else
  echo "Dry run only. Re-run with --apply to make changes."
fi
