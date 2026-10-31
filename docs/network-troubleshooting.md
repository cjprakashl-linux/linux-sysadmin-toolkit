# Runbook: Network Connectivity Problems

## Symptoms
- Server unreachable, or SSH/HTTP times out
- "Connection refused" or "No route to host"
- DNS names do not resolve

## 1. Check the local interface
```
ip -br addr
ip route
```
Confirm the interface is UP, has an address, and a default route exists.

## 2. Test layer by layer
```
ping -c 3 127.0.0.1        # local stack
ping -c 3 <gateway-ip>     # local network
ping -c 3 1.1.1.1          # internet by IP
```
- Fails at gateway: cable, VLAN, interface or IP config
- Works by IP but not by name: DNS problem

## 3. Check DNS
```
getent hosts example.com
cat /etc/resolv.conf
```

## 4. Check the service is listening
```
ss -tulpn | grep <port>
```
No listener means the service is down (see the service-down runbook).

## 5. Check the firewall
```
sudo ufw status            # Ubuntu
sudo firewall-cmd --list-all   # RHEL, Rocky
sudo iptables -S | head
```
Allow only what is needed. Do not disable the firewall as a "fix".

## 6. Trace the path
```
traceroute <host>
curl -vI https://<host>
```

## 7. Prevention
- Document IPs, VLANs and firewall rules
- Monitor the key ports
- Test changes with a second session open

## Verify
Reconnect, and confirm the service responds from another host.
