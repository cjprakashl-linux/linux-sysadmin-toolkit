# Linux Sysadmin Toolkit
| scripts/backup.sh | Timestamped tar.gz backup with retention cleanup |

Practical scripts and runbooks for common Linux server problems.

## Scripts
| Script | Purpose |
|---|---|
| scripts/server-health-check.sh | Snapshot of disk, memory, CPU, failed services and open ports |

## Runbooks
| Runbook | Purpose |
|---|---|
| docs/disk-full-troubleshooting.md | Diagnose and fix "disk full" issues |

## Usage
```
chmod +x scripts/server-health-check.sh
./scripts/server-health-check.sh
```

## Tested on
Ubuntu (GitHub Codespaces container, no systemd)

## Roadmap
- Backup script with cron
- Log cleanup script
- Runbooks: high CPU, service down

Author: Jyothi Prakash
