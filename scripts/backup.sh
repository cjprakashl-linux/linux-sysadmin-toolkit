#!/usr/bin/env bash
# backup.sh: compress a directory into a timestamped tar.gz
# and delete backups older than N days.
# Usage: ./backup.sh <source_dir> <backup_dir> [retention_days]
set -euo pipefail
umask 077   # backups readable only by the owner

SRC="${1:-}"; DEST="${2:-}"; DAYS="${3:-7}"

if [[ -z "$SRC" || -z "$DEST" ]]; then
  echo "Usage: $0 <source_dir> <backup_dir> [retention_days]" >&2
  exit 1
fi
if [[ ! -d "$SRC" ]]; then
  echo "ERROR: source '$SRC' not found" >&2
  exit 1
fi

mkdir -p "$DEST"
BASE="$(basename "$SRC")"
NAME="${BASE}-$(date +%F_%H%M%S).tar.gz"

tar -czf "$DEST/$NAME" -C "$(dirname "$SRC")" "$BASE"
chmod 600 "$DEST/$NAME"
echo "$(date '+%F %T') Backup created: $DEST/$NAME ($(du -h "$DEST/$NAME" | cut -f1))"

find "$DEST" -name "${BASE}-*.tar.gz" -mtime +"$DAYS" -print -delete
echo "Retention: removed backups older than $DAYS days"
