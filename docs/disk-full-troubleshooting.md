# Runbook: Disk Full on Linux

## Symptoms
- "No space left on device" errors
- Services crash or fail to start
- Logs stop writing, apps hang

## 1. Check space and inodes
```
df -h
df -i
```
Full inodes with free space means millions of tiny files.

## 2. Find the biggest directories
```
du -xh / --max-depth=1 2>/dev/null | sort -h | tail
```
Repeat inside the biggest one, e.g. `/var`.

## 3. Check deleted files still held open
```
lsof +L1
```
Space is not freed until the process closes the file. Restart that service.

## 4. Safe cleanup
```
journalctl --disk-usage
journalctl --vacuum-size=200M
apt clean        # Ubuntu/Debian
dnf clean all    # RHEL/Rocky/Alma
```
Rotate or compress old logs in /var/log. Never delete files blindly.

## 5. Prevention
- Configure logrotate for app logs
- Add a cron alert at 80% disk usage
- Keep /var and /home on separate LVM volumes
- Extend LVM when needed: `lvextend -r -L +5G /dev/vg/lv`

## Verification
Run `df -h` and confirm usage is below 80% and services are running.
