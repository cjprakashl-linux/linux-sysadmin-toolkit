# logrotate Runbook

## 1. Purpose and when to use it
logrotate rotates, compresses and removes old log files so they do not fill the disk. Use this runbook when:
- A log file keeps growing and is never rotated
- You need to add rotation for a new application
- A disk filled up because of logs (see `disk-full-troubleshooting.md`)
  
## 2. How logrotate runs
**Documentation only, not lab-tested.**
- On most distributions logrotate runs once a day, started by either a systemd timer (`logrotate.timer`) or a cron.daily script.
- Check which one your system uses: `systemctl list-timers | grep logrotate` and `ls /etc/cron.daily/`.

## 3. Key files
**Documentation only, not lab-tested.**
- `/etc/logrotate.conf`: main config and defaults
- `/etc/logrotate.d/`: one config file per application
- State file: remembers when each log was last rotated. Debian/Ubuntu commonly use `/var/lib/logrotate/status`; RHEL-family systems commonly use `/var/lib/logrotate/logrotate.status`. Verify on your system.

## 4. Key directives
| Directive | Meaning |
|---|---|
| `rotate N` | Keep N old copies, delete older ones |
| `size X` | Rotate only when the log is bigger than X |
| `daily` / `weekly` | Rotate on a time schedule |
| `compress` | Compress old logs with gzip |
| `delaycompress` | Leave the newest rotated log uncompressed until the next rotation |
| `missingok` | No error if the log file is missing |
| `notifempty` | Do not rotate an empty log |
| `create MODE` | Create a new empty log with this mode after rotating |
| `copytruncate` | Copy the log, then empty the original. Use when a program cannot reopen its log. Small risk of losing lines written during the copy |
| `postrotate` | Run a command after rotation, for example reload a service so it writes to the new file |

## 5. Example config (used in my lab)
```
/tmp/lrtest/app.log {
    size 1k
    rotate 3
    compress
    delaycompress
    missingok
    notifempty
    create 0640
}
```

## 6. Safe testing procedure
1. Use a test folder and a test state file. Never test on live logs first.
2. Debug mode changes nothing:
```
logrotate -d -s /tmp/lrtest/state /tmp/lrtest/app.conf
```
3. Then a real run with verbose output:
```
logrotate -v -s /tmp/lrtest/state /tmp/lrtest/app.conf
```

## 7. Lab results
Environment: GitHub Codespaces (Ubuntu), logrotate 3.21.0, run as a normal user. `results.txt` in the listings is my output capture file, so ignore it.

### Before rotation
```
total 16
-rw-r--r-- 1 codespace codespace  125 Nov 16 09:26 app.conf
-rw-r--rw- 1 codespace codespace 4292 Nov 16 09:26 app.log
-rw-r--rw- 1 codespace codespace   80 Nov 16 09:26 results.txt
```

### Round 1
```
total 20
-rw-r--r-- 1 codespace codespace  125 Nov 16 09:26 app.conf
-rw-r----- 1 codespace codespace    0 Nov 16 09:26 app.log
-rw-r--rw- 1 codespace codespace 4292 Nov 16 09:26 app.log.1
-rw-r--rw- 1 codespace codespace  282 Nov 16 09:26 results.txt
-rw-r----- 1 codespace codespace   70 Nov 16 09:26 state
```

### Round 2 (delaycompress)
```
total 20
-rw-r--r-- 1 codespace codespace  125 Nov 16 09:26 app.conf
-rw-r----- 1 codespace codespace    0 Nov 16 09:26 app.log
-rw-r----- 1 codespace codespace 3292 Nov 16 09:26 app.log.1
-rw-r--rw- 1 codespace codespace  484 Nov 16 09:26 app.log.2.gz
-rw-r--rw- 1 codespace codespace  602 Nov 16 09:26 results.txt
-rw-r----- 1 codespace codespace   70 Nov 16 09:26 state
```
What I observed: After round 1, `app.log.1` (4292 bytes) was plain and nothing was compressed yet. After round 2, `app.log.1` (3292 bytes) was plain and `app.log.2.gz` (484 bytes) was compressed, because `delaycompress` leaves the newest rotated log uncompressed until the next rotation.

### Failure path: missing log with missingok
I removed `app.log` and ran logrotate without `-v`. It printed nothing and exited with code 0:
```
exit=0
```

### Failure path: typo in config (`rotat 3`), debug mode
```
error: bad.conf:3 unknown option 'rotat' -- ignoring line
rotating pattern: /tmp/lrtest/app.log  1024 bytes (no old logs will be kept)
log /tmp/lrtest/app.log does not exist -- skipping
exit=0
```
Takeaway: a typo in a directive only produces a warning, the line is ignored, and the defaults apply. Here that meant no old logs would be kept. Always run `-d` after editing a config and read the output for the word "error".

## 8. Troubleshooting
**Documentation only, not lab-tested.**
- **Log not rotating:** check the size or schedule rules, the state file date, and that the config path is included from `/etc/logrotate.conf`. Run `logrotate -d` on the config.
- **Wrong permissions on new log:** check the `create` line (mode, owner, group).
- **Application still writes to the old file:** it keeps the old file open. Use `postrotate` to reload the service, or `copytruncate`.
- **Disk still full after rotation or deletion:** a process may hold a deleted file open. Find it with `lsof +L1`, then restart that service. See `disk-full-troubleshooting.md`.
-  **"Insecure permissions" style errors:** logrotate can refuse a config or log directory that other users can write to. This did not occur in my lab (`app.conf` was `rw-r--r--` and logrotate accepted it). If you see it, read the message, fix the permissions, or use the `su user group` directive. Not lab-tested.

## 9. Not tested
- Real services and `postrotate` reloads
- systemd timer and cron.daily behavior
- `/etc/logrotate.d/` includes
- RHEL-family paths
