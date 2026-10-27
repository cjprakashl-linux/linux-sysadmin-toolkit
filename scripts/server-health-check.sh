#!/usr/bin/env bash
# server-health-check.sh
# Quick health snapshot of a Linux server.

echo "== Host =="; hostname; uptime
echo "== Disk =="; df -h | grep -v tmpfs
echo "== Memory =="; free -h
echo "== Top CPU =="; ps aux --sort=-%cpu | head -6
echo "== Failed services =="
if [ -d /run/systemd/system ]; then
  systemctl --failed --no-pager
else
  echo "systemd not running (container or non-systemd host)"
fi
echo "== Listening ports =="; ss -tulpn 2>/dev/null | head -15
