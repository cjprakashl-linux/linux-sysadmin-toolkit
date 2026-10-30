# Runbook: Service Down on Linux

## Symptoms
- Website or app not loading
- "Connection refused" or timeout
- Service shows failed or inactive

## 1. Confirm what is failing
```
systemctl status <service>
systemctl is-active <service>
systemctl --failed
```

## 2. Read the logs
```
journalctl -u <service> -n 100 --no-pager
journalctl -xe
ls /var/log/<app>/
```
The first error line is usually the real cause.

## 3. Check the listener and port
```
ss -tulpn | grep <port>
curl -I http://localhost:<port>
```
No listener means the service is not running. A different process on the port means a conflict.

## 4. Common causes
- Config syntax error: `nginx -t`, `apachectl configtest`, `sshd -t`
- Port already in use: see step 3
- Disk full: `df -h` (see the disk-full runbook)
- Out of memory: `dmesg | grep -i oom`
- Permissions or SELinux: `ls -l`, `getenforce`, `ausearch -m avc -ts recent`
- Missing file or dependency: check the log message

Do not disable SELinux as a fix. Correct the labels or policy instead.

## 5. Fix and restart
```
<fix the config or file>
systemctl restart <service>
systemctl enable <service>
```

## 6. If it still fails
```
systemctl cat <service>
```
Run the ExecStart command manually as the service user to see the error directly.

## 7. Prevention
- Add `Restart=on-failure` in the unit file
- Test the config before every reload
- Monitor the port and the process
- Take a backup or snapshot before changes

## Verify
`systemctl status <service>` shows active (running), and `curl` returns the expected response.
