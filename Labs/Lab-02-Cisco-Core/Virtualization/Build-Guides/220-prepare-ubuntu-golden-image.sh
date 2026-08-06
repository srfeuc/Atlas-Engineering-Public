#!/usr/bin/env bash
#
# 220-prepare-ubuntu-golden-image.sh
# ----------------------------------
# Companion automation for: Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides/
#                           220-Prepare-the-Ubuntu-Golden-Image.md
#
# Runs IN-GUEST on the Ubuntu Server template SOURCE VM (Proxmox). It does the
# Part 2 baseline and the Part 4 generalize. The Proxmox-host steps (cloud-init
# drive, `qm template`) are printed at the end but CANNOT run from in here.
#
# POL-0001: this script echoes evidence as it goes; capture the output.
# It changes nothing destructive until you run `generalize` WITH the flag.
#
# Usage (run with sudo):
#   sudo ./220-prepare-ubuntu-golden-image.sh baseline
#       Patch fully, install qemu-guest-agent + cloud-init + unattended-upgrades,
#       stage the SSH keys-only hardening. Safe + re-runnable. Does NOT restart
#       sshd (so it can't lock you out) and does NOT reboot.
#
#   sudo ./220-prepare-ubuntu-golden-image.sh verify
#       Read back the state (patch level, services, cloud-init) for evidence.
#
#   sudo ./220-prepare-ubuntu-golden-image.sh generalize --yes-shutdown-and-template
#       DESTRUCTIVE + FINAL. Strips identity (machine-id, SSH host keys,
#       static IP) and powers off. Run this LAST, only when baseline is done.
#       Refuses to run without the exact flag. Do NOT boot the VM again after
#       this — convert it to a template while it is off.
#
# 🔴 Scars carried from the Windows golden image (216): patch fully first
#    (bit DC01), never bake a static IP (the 10.10.0.50 overlap), and prove the
#    clone's identity is UNIQUE on a throwaway clone afterward (guide Part 6).

set -euo pipefail

TPL_NETPLAN="/etc/netplan/00-atlas-dhcp.yaml"
SSHD_DROPIN="/etc/ssh/sshd_config.d/10-atlas.conf"

log()  { printf '\033[1;36m[golden]\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m[ ok ]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[FAIL]\033[0m %s\n' "$*" >&2; exit 1; }

require_root() {
  [ "${EUID:-$(id -u)}" -eq 0 ] || die "Run with sudo (need root to patch/generalize)."
}

preflight() {
  command -v apt-get >/dev/null || die "Not a Debian/Ubuntu system (no apt-get)."
  local virt="unknown"
  command -v systemd-detect-virt >/dev/null && virt="$(systemd-detect-virt || true)"
  log "Host: $(. /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-unknown}") | virt: ${virt} | hostname: $(hostname)"
  if [ "${virt}" = "none" ]; then
    warn "systemd-detect-virt says this is NOT a VM. This script is for the Proxmox template VM."
    read -r -p "Continue anyway? [y/N] " a; [ "${a,,}" = "y" ] || die "Aborted."
  fi
}

cmd_baseline() {
  require_root; preflight
  export DEBIAN_FRONTEND=noninteractive

  log "1/5 Patching fully (the DC01 under-patch scar) ..."
  apt-get update
  apt-get -y full-upgrade
  apt-get -y autoremove --purge
  ok "Patched. Newest kernel: $(ls -1 /boot/vmlinuz-* 2>/dev/null | sort -V | tail -1 || echo n/a); running: $(uname -r)"

  log "2/5 Proxmox integration + cloud-init ..."
  apt-get -y install qemu-guest-agent cloud-init unattended-upgrades
  systemctl enable --now qemu-guest-agent || warn "qemu-guest-agent enable deferred (starts at boot)."
  ok "qemu-guest-agent + cloud-init + unattended-upgrades present."

  log "3/5 Enabling automatic security updates ..."
  cat > /etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF
  ok "unattended-upgrades enabled."

  log "4/5 Staging SSH keys-only hardening (applies on NEXT boot — no restart, no lockout) ..."
  install -d -m 0755 /etc/ssh/sshd_config.d
  cat > "${SSHD_DROPIN}" <<'EOF'
# Atlas golden-image baseline — keys only. Role-specific rules go on the clone.
PasswordAuthentication no
PermitRootLogin prohibit-password
KbdInteractiveAuthentication no
EOF
  if sshd -t 2>/dev/null; then ok "sshd config valid (${SSHD_DROPIN})."; else warn "sshd -t reported an issue — review ${SSHD_DROPIN} before templating."; fi
  warn "Clones will be KEY-ONLY. Ensure cloud-init injects an SSH key per clone (Proxmox Cloud-Init tab) or you'll rely on the console."

  log "5/5 Baseline done. Nothing destructive was changed."
  echo
  cmd_verify
  echo
  ok "Next: run '$0 generalize --yes-shutdown-and-template' as the FINAL step (it powers off)."
}

cmd_verify() {
  log "State read-back (POL-0001 evidence):"
  . /etc/os-release 2>/dev/null || true
  echo "  OS            : ${PRETTY_NAME:-unknown}"
  echo "  Upgradable    : $(apt-get -s upgrade 2>/dev/null | grep -c '^Inst' || true) package(s) pending"
  echo "  qemu-guest-agent: $(systemctl is-enabled qemu-guest-agent 2>/dev/null || echo n/a) / $(systemctl is-active qemu-guest-agent 2>/dev/null || echo n/a)"
  echo "  cloud-init    : $(command -v cloud-init >/dev/null && cloud-init --version 2>&1 || echo 'not installed')"
  echo "  ssh drop-in   : $([ -f "${SSHD_DROPIN}" ] && echo present || echo MISSING)"
  echo "  machine-id    : $(cat /etc/machine-id 2>/dev/null || echo none)  (will be blanked at generalize)"
  echo "  host keys     : $(ls /etc/ssh/ssh_host_*_key.pub 2>/dev/null | wc -l) present (removed at generalize)"
  echo "  netplan files : $(ls /etc/netplan/*.yaml 2>/dev/null | tr '\n' ' ')"
}

cmd_generalize() {
  require_root
  [ "${1:-}" = "--yes-shutdown-and-template" ] || die "Refusing: generalize is destructive + powers off. Re-run with: $0 generalize --yes-shutdown-and-template"

  warn "GENERALIZING — this strips machine identity and SHUTS DOWN. Do not boot again before templating."
  read -r -p "Type EXACTLY 'template' to proceed: " confirm
  [ "${confirm}" = "template" ] || die "Aborted."

  log "1/6 cloud-init clean (each clone re-runs first boot) ..."
  command -v cloud-init >/dev/null && cloud-init clean --logs --seed || warn "cloud-init not present; skipping."

  log "2/6 Blank machine-id (systemd regenerates a unique one on boot) ..."
  : > /etc/machine-id
  rm -f /var/lib/dbus/machine-id
  ln -s /etc/machine-id /var/lib/dbus/machine-id

  log "3/6 Remove SSH host keys (unique keys regenerate on first boot) ..."
  rm -f /etc/ssh/ssh_host_*

  log "4/6 Networking -> DHCP fallback, NO baked static IP (the 216 overlap lesson) ..."
  install -d -m 0755 /etc/netplan/pre-template-backup
  mv /etc/netplan/*.yaml /etc/netplan/pre-template-backup/ 2>/dev/null || true
  cat > "${TPL_NETPLAN}" <<'EOF'
# Golden-image fallback. cloud-init writes 50-cloud-init.yaml per clone (its
# static IP wins for the configured NIC); this keeps boot from hanging if a
# clone has no cloud-init drive. NO static address is baked here on purpose.
network:
  version: 2
  renderer: networkd
  ethernets:
    alleth:
      match:
        name: "e*"
      dhcp4: true
      dhcp6: false
      optional: true
EOF
  chmod 600 "${TPL_NETPLAN}"

  log "5/6 Clearing logs, caches, leases, shell history ..."
  apt-get clean || true
  rm -rf /var/lib/apt/lists/* 2>/dev/null || true
  journalctl --rotate || true
  journalctl --vacuum-time=1s || true
  find /var/log -type f -exec truncate -s 0 {} \; 2>/dev/null || true
  rm -f /var/lib/dhcp/* 2>/dev/null || true
  rm -f /root/.bash_history /home/*/.bash_history 2>/dev/null || true

  log "6/6 Done. On the PROXMOX HOST (not here), finish the template:"
  cat <<'EOF'

  # Attach a cloud-init drive + convert to template (run on the PVE host):
  qm set   <SOURCE-VMID> --ide2 local-lvm:cloudinit
  qm set   <SOURCE-VMID> --ciupgrade 0
  qm set   <SOURCE-VMID> --serial0 socket --vga serial0     # recommended for headless
  qm template <SOURCE-VMID>                                  # renames/ID beforehand if wanted

  # Per clone (verify the flag with 'qm set --help' — --sshkey vs --sshkeys varies by version):
  qm clone <TPL-VMID> <NEW-VMID> --name SRV01 --full 1
  qm set   <NEW-VMID> --ipconfig0 ip=10.20.0.10/26,gw=10.20.0.1 --nameserver 10.20.0.2 --sshkey <pubkey> --ciuser <user>

  # Then verify UNIQUE identity on the clone (guide Part 6): cat /etc/machine-id ;
  # ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub ; cloud-init status
EOF

  warn "Powering off in 5s. Do NOT boot this VM again before 'qm template'."
  sleep 5
  shutdown -h now
}

main() {
  case "${1:-}" in
    baseline)   shift; cmd_baseline "$@" ;;
    verify)     shift; require_root; preflight; cmd_verify ;;
    generalize) shift; cmd_generalize "$@" ;;
    *) cat <<EOF
220-prepare-ubuntu-golden-image.sh — Ubuntu Server golden-image prep (guide 220)

  sudo $0 baseline     patch + agent + cloud-init + hardening (safe, re-runnable)
  sudo $0 verify       read back state (POL-0001 evidence)
  sudo $0 generalize --yes-shutdown-and-template   DESTRUCTIVE + powers off (do LAST)

Run 'baseline' first, reconnect/verify, then 'generalize' as the final step.
EOF
       exit 1 ;;
  esac
}

main "$@"
