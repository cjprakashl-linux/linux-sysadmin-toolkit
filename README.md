# Linux Sysadmin Toolkit

Practical scripts and runbooks for common Linux server problems.

## Scripts
| Script | Purpose |
|---|---|
| scripts/server-health-check.sh | Snapshot of disk, memory, CPU, failed services and open ports |
| scripts/backup.sh | Timestamped tar.gz backup with retention cleanup |
| scripts/log-cleanup.sh | Safe log compression and cleanup (dry-run by default) |
| scripts/kvm-health-check.sh | Read-only KVM/libvirt host health report |
| scripts/disk-usage-alert.sh | Threshold-based disk alert with exit codes for cron |
| scripts/log-summary.sh | Summarise errors and warnings in a log file |
| scripts/user-audit.sh | Read-only audit of users, sudo access and logins |
| scripts/ssl-expiry-check.sh | Check TLS certificate expiry, with exit codes for cron |

## How I test
Every script is syntax-checked (`bash -n`), run against sample data, and tested on failure paths
(missing files, bad arguments). Scripts that change anything default to dry-run.

## Runbooks
| Runbook | Purpose |
|---|---|
| docs/disk-full-troubleshooting.md | Diagnose and fix "disk full" issues |
| docs/backup-with-cron.md | Schedule and verify automated backups |
| docs/high-cpu-troubleshooting.md | Diagnose and fix high CPU usage |
| docs/service-down-troubleshooting.md | Diagnose and fix a failed or unreachable service |
| docs/ssh-hardening.md | Secure SSH access with keys and safe config changes |
| docs/network-troubleshooting.md | Diagnose network and DNS connectivity issues |
| docs/lvm-extend-resize.md | Extend an LVM volume safely 

## Usage
```
chmod +x scripts/server-health-check.sh
./scripts/server-health-check.sh
./scripts/backup.sh /path/to/source /path/to/backups 7
./scripts/log-cleanup.sh /var/log/myapp 7 30          # dry run
./scripts/log-cleanup.sh /var/log/myapp 7 30 --apply  # make changes
sudo ./scripts/kvm-health-check.sh
./scripts/disk-usage-alert.sh 80 90
./scripts/log-summary.sh docs/sample.log
sudo ./scripts/user-audit.sh
./scripts/ssl-expiry-check.sh example.com 443 30
```

## Tested on
Ubuntu (GitHub Codespaces container, no systemd). The KVM script was tested on its no-libvirt path only.

## Roadmap
The LVM runbook is documentation. It was not lab-tested in Codespaces, because containers don’t support LVM.

Author: Jyothi Prakash
