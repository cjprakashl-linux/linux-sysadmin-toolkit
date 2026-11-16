# logrotate Runbook

## 1. Purpose and when to use it
logrotate rotates, compresses and removes old log files so they do not fill the disk. Use this runbook when:
- A log file keeps growing and is never rotated
- You need to add rotation for a new application
- A disk filled up because of logs (see `disk-full.md`)

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
Environment: GitHub Codespaces, run as a normal user.

### Sample log before rotation
```
PASTE REAL OUTPUT: ls -l app.log
```

### Round 1
```
PASTE REAL OUTPUT: ls -l after the first real run
```

### Round 2 (delaycompress)
```
PASTE REAL OUTPUT: ls -l after the second real run
```
What I observed: PASTE YOUR OWN SENTENCE about which file was plain and which was .gz, and why.

### Failure path: missing log with missingok
```
PASTE REAL OUTPUT
```

### Failure path: typo in config (`rotat 3`)
```
PASTE REAL OUTPUT: the exact error text
```

## 8. Troubleshooting
**Documentation only, not lab-tested.**
- **Log not rotating:** check the size or schedule rules, the state file date, and that the config path is included from `/etc/logrotate.conf`. Run `logrotate -d` on the config.
- **Wrong permissions on new log:** check the `create` line (mode, owner, group).
- **Application still writes to the old file:** it keeps the old file open. Use `postrotate` to reload the service, or `copytruncate`.
- **Disk still full after rotation or deletion:** a process may hold a deleted file open. Find it with `lsof +L1`, then restart that service. See `disk-full.md`.
- **"Insecure permissions" style errors:** read the message. It usually points to a directory that is writable by others. Fix the permissions, or use the `su user group` directive. Record what you saw in section 7 if it happens in your lab.

## 9. Not tested
- Real services and `postrotate` reloads
- systemd timer and cron.daily behavior
- `/etc/logrotate.d/` includes
- RHEL-family paths
