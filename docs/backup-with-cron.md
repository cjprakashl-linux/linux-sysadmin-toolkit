# Automated Backups with Cron

## Alerting
```
*/30 * * * * /opt/scripts/disk-usage-alert.sh 80 90 >> /var/log/disk-alert.log 2>&1 || logger -p user.warning -t disk-alert "threshold exceeded"
```

## Run manually
```
./scripts/backup.sh /var/www /backup 7
```

## Schedule daily at 2 AM
```
crontab -e
0 2 * * * /opt/scripts/backup.sh /var/www /backup 7 >> /var/log/backup.log 2>&1
```

## Verify
```
ls -lh /backup
tar -tzf /backup/www-*.tar.gz | head
tail /var/log/backup.log
```

## Restore
```
tar -xzf /backup/www-DATE.tar.gz -C /restore/path
```

## Notes
- Test a restore regularly. An untested backup is not a backup.
- Keep copies off the server (another host or object storage).
- Use full paths in cron, because cron has a minimal PATH.
