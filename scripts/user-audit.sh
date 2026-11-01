#!/usr/bin/env bash
# user-audit.sh: read-only audit of local users, sudo access and logins.
# Makes no changes. Run as root to include the /etc/shadow check.
set -uo pipefail

echo "== Users with login shells (UID >= 1000) =="
awk -F: '$3>=1000 && $7 !~ /(nologin|false)$/ {printf "%-20s uid=%-6s shell=%s\n",$1,$3,$7}' /etc/passwd

echo "== UID 0 accounts (should be only root) =="
awk -F: '$3==0 {print $1}' /etc/passwd

echo "== Members of sudo/wheel/admin groups =="
for g in sudo wheel admin; do
  if getent group "$g" >/dev/null; then
    echo "$g: $(getent group "$g" | cut -d: -f4)"
  fi
done

echo "== Sudoers rules (root only) =="
if [[ $EUID -eq 0 ]]; then
  grep -hvE '^[[:space:]]*(#|$|Defaults)' /etc/sudoers /etc/sudoers.d/* 2>/dev/null
else
  echo "(run as root to read sudoers)"
fi

echo "== Accounts with empty passwords =="
if [[ $EUID -eq 0 ]]; then
  awk -F: '($2=="") {print $1}' /etc/shadow
else
  echo "(run as root to check /etc/shadow)"
fi

echo "== Recent logins =="
if command -v last >/dev/null 2>&1; then
  last -n 5 2>/dev/null
else
  echo "last not available"
fi

echo "== SSH authorized keys per user =="
while IFS=: read -r user _ uid _ _ home _; do
  [[ $uid -ge 1000 || $uid -eq 0 ]] || continue
  f="$home/.ssh/authorized_keys"
  [[ -r "$f" ]] && echo "$user: $(grep -cE '^(ssh|ecdsa)' "$f") key(s)"
done < /etc/passwd
