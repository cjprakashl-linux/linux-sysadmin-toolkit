# Linux Sysadmin Toolkit

Practical scripts and runbooks for common Linux server problems.

## Scripts
| Script | Purpose |
|---|---|
| scripts/server-health-check.sh | Snapshot of disk, memory, CPU, failed services and open ports |
| scripts/backup.sh | Timestamped tar.gz backup with retention cleanup |
| scripts/log-cleanup.sh | Safe log compression and cleanup (dry-run by default) |

## Runbooks
| Runbook | Purpose |
|---|---|
| docs/disk-full-troubleshooting.md | Diagnose and fix "disk full" issues |
| docs/backup-with-cron.md | Schedule and verify automated backups |
| docs/high-cpu-troubleshooting.md | Diagnose and fix high CPU usage |

## Usage
```
chmod +x scripts/server-health-check.sh
./scripts/server-health-check.sh
./scripts/backup.sh /path/to/source /path/to/backups 7
./scripts/log-cleanup.sh /var/log/myapp 7 30          # dry run
./scripts/log-cleanup.sh /var/log/myapp 7 30 --apply  # make changes
```

## Tested on
Ubuntu (GitHub Codespaces container, no systemd)

## Roadmap
- Runbooks: high CPU, service down

Author: Jyothi Prakash
