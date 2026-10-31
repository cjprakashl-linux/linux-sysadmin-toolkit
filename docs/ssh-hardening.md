# Runbook: SSH Hardening

## Safety first
- Keep one SSH session open while you test changes.
- Back up the config: `sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak`
- Validate before reloading: `sudo sshd -t`
- Confirm key login works before disabling passwords.

## 1. Use key-based login
```
ssh-keygen -t ed25519
ssh-copy-id user@server
```

## 2. Recommended settings
```
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
X11Forwarding no
```

## 3. Apply and verify
```
sudo sshd -t
sudo systemctl reload sshd
ssh -v user@server
```
`sudo sshd -t` prints nothing when the config is valid. An invalid config prints the bad line and exits with a non-zero code (255), so don't reload.
The service may be named `ssh` on Debian/Ubuntu.

## 4. Extra protection
- Restrict users: `AllowUsers alice bob`
- Install fail2ban to block repeated failures
- Use a firewall: allow SSH only from trusted addresses
- Changing the port reduces noise but is not real security

## 5. Review
```
sudo journalctl -u ssh -n 50 --no-pager
last -n 10
```
Look for repeated failures from unknown addresses.
