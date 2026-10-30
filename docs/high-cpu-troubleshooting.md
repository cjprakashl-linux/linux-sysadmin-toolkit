# Runbook: High CPU on Linux

## Symptoms
- Slow server or sluggish SSH
- Load average much higher than CPU cores
- Services time out or fans spin up

## 1. Confirm the load
```
uptime
nproc
top -bn1 | head -15
```
A load average above the core count means the CPU is saturated.

## 2. Find the process
```
ps aux --sort=-%cpu | head -10
```

## 3. Identify the type of CPU use
In top, read the CPU line:
- us: user processes (apps)
- sy: kernel work
- wa: waiting on disk (check `iostat -x 1 5`)
- st: stolen by the hypervisor (VM host is overloaded)

## 4. Investigate the process
```
systemctl status <service>
journalctl -u <service> -n 50 --no-pager
ls -l /proc/<PID>/exe
lsof -p <PID> | head
```

## 5. Fix safely
```
systemctl restart <service>
renice +10 -p <PID>
kill -15 <PID>      # graceful
kill -9 <PID>       # last resort
```
Check `crontab -l` for overlapping jobs, such as backups.

## 6. Unknown process warning
An unfamiliar process using high CPU from /tmp or a hidden folder may be a compromise (for example a miner). Check `ss -tulpn`, `crontab -l` and `last`. Do not delete files. Isolate the host and escalate.

## 7. Prevention
- Monitoring alert above 80% CPU for 5 minutes
- systemd limits, for example `CPUQuota=50%`
- Keep packages updated
- Review cron schedules for overlaps

## Verify
Wait 5 minutes, then run `uptime` and `top`. Load should return to normal.
