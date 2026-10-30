#!/usr/bin/env bash
# kvm-health-check.sh: read-only health snapshot of a KVM/libvirt host.
# Makes no changes. Run with sudo or as a member of the libvirt group.
# No "set -e" on purpose: one failed check should not stop the report.
set -uo pipefail

ok()   { echo "[OK]   $*"; }
warn() { echo "[WARN] $*"; }
info() { echo "[INFO] $*"; }

echo "== CPU virtualization =="
if grep -Eq '(vmx|svm)' /proc/cpuinfo; then
  ok "CPU reports hardware virtualization (vmx/svm)"
else
  warn "No vmx/svm flag (unsupported, or disabled in BIOS/hypervisor)"
fi

echo "== KVM device and modules =="
if [[ -e /dev/kvm ]]; then ok "/dev/kvm present"; else warn "/dev/kvm missing"; fi
if command -v lsmod >/dev/null 2>&1; then
  if lsmod | grep -Eq '^kvm'; then ok "kvm modules loaded"; else warn "kvm modules not loaded"; fi
else
  info "lsmod not available"
fi

echo "== libvirt =="
if ! command -v virsh >/dev/null 2>&1; then
  warn "virsh not installed (install libvirt client tools)"
  exit 0
fi
if [[ -d /run/systemd/system ]]; then
  if systemctl is-active --quiet libvirtd || systemctl is-active --quiet virtqemud; then
    ok "libvirt daemon active"
  else
    warn "libvirt daemon not active"
  fi
else
  info "systemd not running; skipping daemon check"
fi

echo "== VMs =="
virsh list --all 2>&1 | head -30
echo "== Storage pools =="
virsh pool-list --all 2>&1 | head -15
echo "== Networks =="
virsh net-list --all 2>&1 | head -15
echo "== Host resources =="
free -h | head -2
df -h / 2>/dev/null
