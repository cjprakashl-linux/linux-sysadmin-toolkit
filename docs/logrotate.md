# Runbook: Logrotate Setup and Troubleshooting

## Where the configuration lives
- /etc/logrotate.conf (global defaults)
- /etc/logrotate.d/ (per-application files)
- State file: /var/lib/logrotate/status (last rotation times)

## A basic rule
```
/var/log/myapp/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 myapp myapp
}
```
Use `size 100M` instead of `daily` to rotate by size.

## Test safely
```
logrotate -d /etc/logrotate.d/myapp     # debug: shows what would happen, changes nothing
sudo logrotate -f /etc/logrotate.d/myapp  # force a rotation now
```

## Logs are not rotating
1. Check the schedule: `systemctl list-timers | grep logrotate` (or the cron entry).
2. Read the status file for the last rotation time.
3. Run `logrotate -d` and read the errors.

## Common errors
- "insecure permissions" or "bad file mode": fix ownership and mode (`chown root`, `chmod 644`).
- The app keeps writing to the old file: add `copytruncate`, or a `postrotate` script that reloads the service.
- "skipping, log does not exist": add `missingok`.
- Disk still fills: see the disk-full runbook.

## Verify
`ls -l /var/log/myapp/` shows rotated, compressed files, and the service writes to the new file.
