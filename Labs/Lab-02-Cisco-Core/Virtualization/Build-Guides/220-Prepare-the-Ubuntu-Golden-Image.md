---
Title: Prepare the Ubuntu Server Golden Image (Linux template — reuse-existing-VM path)
Path: Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides
Status: 🟡 Target Design — authored, NOT executed. Runs per POL-0001 (verify on the device; evidence = command + output).
Version: 0.4
Date: 2026-07-22
---

# Prepare the Ubuntu Server Golden Image

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** — the **Linux** companion to the Windows golden-image series (`211`–`214`, record `216`). Produces the reusable Ubuntu template that every Linux box clones from: **SRV01** (the `pki.atlas.lab` CRL host — `ADR-0027`/`ADR-0028` critical path), **NetBox**, the rebuilt **Pi01** (DNS/NTP), and **CA01** (OpenSSL intermediate). One clean, generalized, hardened base → many single-purpose clones.

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | 🟡 **Target Design — not built.** Nothing here is device-verified. Every `[ ]` becomes `[x]` only with a command + its output (`POL-0001`). |
| Version | 0.4 |
| Applies To | PVE01 |
| Governs | The Ubuntu Server LTS golden image / Proxmox template. Mirrors the Windows chain (`211` prepare/sysprep → `212` template → `213` clone → `214` deploy) for Linux. |
| Reference | [CIS Ubuntu Linux Benchmark](https://www.cisecurity.org/benchmark/ubuntu_linux), [Proxmox VM templates & cloud-init](https://pve.proxmox.com/wiki/VM_Templates_and_Clones), [Ubuntu Server docs](https://ubuntu.com/server/docs), [cloud-init docs](https://cloudinit.readthedocs.io/) |
| Governing Policy | `POL-0007` (hardening), `POL-0001` (evidence), `POL-0002` (secrets → Vaultwarden) |

> 🔴 **The one rule this guide exists to get right — strip the machine's identity before templating.** A golden image cloned with a **static IP**, its **SSH host keys**, or its **machine-id** baked in produces clones that collide: duplicate IPs on the wire, identical SSH host keys (a host-key-collision *and* a security problem), and a shared machine-id that breaks systemd/DHCP-lease/logging identity. Generalization (Part 4) is not optional — it is the whole point.

> **⚙️ Automation companion — `220-prepare-ubuntu-golden-image.sh`** (this folder). Runs the in-guest work of this guide: `sudo ./220-…sh baseline` = Part 2 (patch + qemu-guest-agent + cloud-init + hardening; safe, re-runnable, no sshd restart, no reboot), `verify` = the read-back, `sudo ./220-…sh generalize --yes-shutdown-and-template` = Part 4 (🔴 destructive, strips identity + powers off; gated behind the flag + a typed `template` confirmation). The Proxmox-host steps (cloud-init drive, `qm template`) are **printed, not run** — do those on PVE (Part 5–6). The narrative below is the source of truth; the script is the executable path.

## 🔴 Known defects found in execution (2026-07-24 — fix before the next template rebuild)

The current `TPL-UBUNTU2604` shipped with two bugs that bit the **first real clone (NETBOX01)** and will bite **every** clone (SRV01, Pi01, CA01…) until the template is rebuilt. Per-clone workarounds are in each device's networking guide (e.g. `Devices/NETBOX01-Source-of-Truth/Networking-Build-Guide.md` §2/§4); the source fixes belong here.

1. 🔴 **The template has no Cloud-Init drive**, so clones show *"No CloudInit Drive found"* and get no identity. **Per-clone workaround:** Hardware → Add → CloudInit Drive → `local-lvm`. **Source fix:** attach the Cloud-Init drive to the **source VM before templating** (§2.4 — `qm set <SRC> --ide2 local-lvm:cloudinit`) so clones inherit it; verify `qm config <TPL>` shows an `ide2: …cloudinit` line **before** converting to template.
2. 🔴 **A baked-in netplan fallback `00-atlas-dhcp.yaml` conflicts with Cloud-Init's per-clone static**, so clones boot with **no IP** (`eth0` UP, no IPv4, empty `ip route`). The fallback matches **`name: "e*"`** (every NIC) with `dhcp4: true`; Cloud-Init writes `50-cloud-init.yaml` matching the NIC **by MAC** with the static — two definitions claim the same interface, `netplan generate` resolves neither. **Per-clone workaround:** `sudo mv /etc/netplan/00-atlas-dhcp.yaml{,.disabled} && sudo netplan apply`. **Source fix:** since every clone now gets a Cloud-Init drive (defect 1), the DHCP fallback is redundant *and* harmful — **remove `00-atlas-dhcp.yaml` from the golden image** (let Cloud-Init's `50-cloud-init.yaml` be the only netplan file). If a driveless-boot safety net is still wanted, it must **not** match a NIC Cloud-Init will configure (e.g. scope it narrowly or rely on `optional: true` with no address). 🔴 **The companion `220-prepare-ubuntu-golden-image.sh` writes this fallback in its generalize step — update the script to match this fix.**

## 🔴 Confirm before executing (assumptions in this draft)

These shape the guide; correct any that are wrong and I'll adjust:

- **OS = Ubuntu Server (headless), LTS.** ✅ **Confirmed 2026-07-23: Ubuntu Server 26.04 LTS** (kernel `7.0.0-generic`), built fresh from ISO — a Desktop VM was rejected as too heavy / NetworkManager-managed for headless clones. Nothing structural changes vs the earlier 24.04 assumption.
- **Reuse your existing working Ubuntu VM as the seed** (you said you only changed IP + maybe firewall — minimal cruft, ideal).
- **Proposed names/IDs (convention, not fact — you confirm):** template **`TPL-UBUNTU2604`** (26.04 LTS), **VMID 9001** (Windows template is 9000); pre-generalization **archive** keeps the next free VMID; per-clone identity injected via **cloud-init**.
- **cloud-init = yes (recommended).** It injects per-clone hostname / IP / SSH key / user automatically and regenerates host keys — it's the clean answer to the identity problem. If you'd rather configure each clone by hand, say so and I'll swap Part 6 for a manual path.

## Prerequisites

- [ ] The existing Ubuntu VM boots and you can log in (SSH or console).
- [ ] Proxmox admin access to PVE01 (web UI + a root shell for `qm`).
- [ ] Confirmed free space on `local-lvm` (verified 2026-07-22: **~597 GB free**, 24.76% used — ample; the `302`/older "disk-tight" note is stale per POL-0001).

---

## Part 0 — Record the source VM (evidence before you change anything)

Capture what the seed actually is, so the record is real (`216` lesson: a checklist tick is not evidence).

```bash
# In the guest:
hostnamectl                          # OS version, machine-id, hostname
lsb_release -a                       # Ubuntu release (confirm Server/LTS)
ip -br a ; cat /etc/netplan/*.yaml   # what IP/netplan is currently set (this must NOT survive to the template)
sudo ufw status verbose 2>/dev/null ; sudo nft list ruleset 2>/dev/null   # any firewall rules you added
systemctl is-enabled ssh qemu-guest-agent 2>/dev/null
cat /etc/machine-id
ls -l /etc/ssh/ssh_host_*            # the host keys that must be removed before templating
```

```bash
# From the PVE host:
qm config <SOURCE-VMID>
```

- [ ] Read-back captured: release, current IP/netplan, firewall rules, machine-id, host-key list, `qm config`.

## Part 1 — 🔴 Retain a pre-generalization archive (rollback first)

Mirror the Windows `WIN2025-BUILD-ARCHIVE` (VMID 100) pattern — keep a bootable rollback of your working VM **before** you strip it.

- [ ] **PVE UI:** right-click the source VM → **Clone** → **Full Clone** → name it e.g. `UBUNTU-BUILD-ARCHIVE` (next free VMID). *(CLI: `qm clone <SOURCE-VMID> <ARCHIVE-VMID> --name UBUNTU-BUILD-ARCHIVE --full 1`.)*
- [ ] 🔴 **Do not boot the archive** to "check" it later — inspect offline if needed (`216` rule). It is the untouched rollback.
- [ ] You'll generalize the **original/source** VM into the template; the archive is your safety net.

## Part 2 — Bring the source to baseline (patch + agent + hardening)

### 2.1 🔴 Patch fully (the DC01 scar — carried forward from `216`)

The Windows golden image shipped under-patched and *"that bit us on DC01."* Same rule here: bring it fully current now, while it's still a normal box.

```bash
sudo apt update && sudo apt full-upgrade -y
sudo apt autoremove --purge -y
sudo reboot        # if a new kernel landed
```

- [ ] Read-back: `apt list --upgradable` returns nothing held back; `uname -r` = the newest installed kernel.

### 2.2 Proxmox integration

```bash
sudo apt install -y qemu-guest-agent
sudo systemctl enable --now qemu-guest-agent
```

- [ ] In `qm config` / PVE UI → VM **Options → QEMU Guest Agent = Enabled** (`agent: 1`).
  - 🔴 **Gotcha (seen 2026-07-23):** installing the package alone throws `A dependency job for qemu-guest-agent.service failed` on boot — the service needs the **virtio-serial channel**, which only appears once the Proxmox agent option is on **and the VM is fully power-cycled** (a soft `reboot` *inside* the guest is not enough — it's a hardware change; stop → start from Proxmox). Confirm the channel: `ls /dev/virtio-ports/` must show `org.qemu.guest_agent.0`; then `systemctl is-active qemu-guest-agent` → `active` and the PVE **Summary** shows the guest IP. (The `baseline` script tolerates this and warns — it's expected, not a failure.)
- [ ] **Hardware (Linux gets what the Windows template couldn't):** disk on **VirtIO SCSI** (`scsi0`, controller *VirtIO SCSI single*) and a **VirtIO** NIC — Linux has native virtio drivers, so unlike the Windows template (which fell back to IDE + E1000 because virtio drivers were never installed, per `216`) you get the fast paths for free. If the seed is on IDE/SATA/E1000, note it; converting the disk bus is a separate, careful step — flag me and we'll do it deliberately.

### 2.3 Minimal, universal hardening baseline (CIS-lite)

> 🔴 Keep the golden baseline **generic**. Bake in only what *every* Linux box wants; **role-specific firewall + services belong on the clone**, not the template (SRV01 opens 80 for CRLs; Pi01 opens 53/123 — those live in their own build guides).

- [ ] **SSH:** keys only — in `/etc/ssh/sshd_config.d/10-atlas.conf`: `PasswordAuthentication no`, `PermitRootLogin prohibit-password`, `KbdInteractiveAuthentication no`. (Don't `restart ssh` yet if you're on an SSH session without a key in place — use console, or keep a key ready.)
- [ ] **Automatic security updates:** `sudo apt install -y unattended-upgrades && sudo dpkg-reconfigure -plow unattended-upgrades`.
- [ ] **Template admin identity (decide + document):** the seed already has your user. Either (a) keep it as a documented break-glass admin with an authorized **public** key, or (b) let **cloud-init** create the per-clone user (cleaner — no shared identity). 🔴 **Never bake a private key or any secret into the image** (`POL-0002`); a shared *authorized public key* across clones is a documented, accepted lab risk at most — prefer cloud-init injection.
- [ ] Time: clones will get NTP per role (`ADR-0020`); no special config needed in the base beyond default `systemd-timesyncd`/chrony (Pi01's build swaps in chrony deliberately).

### 2.4 cloud-init (recommended — the per-clone identity mechanism)

```bash
sudo apt install -y cloud-init
```

Then on the PVE host, give the VM a cloud-init drive so Proxmox can inject per-clone config:

```bash
qm set <SOURCE-VMID> --ide2 local-lvm:cloudinit
qm set <SOURCE-VMID> --ciupgrade 0          # we already patched; avoid double-upgrade on first boot
# serial console helps cloud images/console + some cloud-init paths:
qm set <SOURCE-VMID> --serial0 socket --vga serial0   # optional but recommended for headless
```

- [ ] Per-clone values (hostname, IP/CIDR/gw, DNS, SSH key, user) are then set on each clone in **PVE UI → VM → Cloud-Init** (or `qm set … --ipconfig0 ip=10.20.0.x/26,gw=10.20.0.1 --nameserver 10.20.0.2 --sshkey <file> --ciuser <name>`). Nothing per-clone is baked into the template.
  - 🔴 **Verify the flag against your Proxmox version:** the Proxmox Cloud-Init wiki example uses **`--sshkey`** (singular); some versions/the `qm` config key use `--sshkeys`. Run `qm set --help` and use what your box accepts — don't trust the spelling blind.

## Part 3 — Record final source state (evidence)

```bash
hostnamectl ; ip -br a ; systemctl is-enabled ssh qemu-guest-agent unattended-upgrades
cloud-init --version ; dpkg -l | grep -E 'qemu-guest-agent|cloud-init|unattended-upgrades'
```

- [ ] Fully patched, agent enabled, cloud-init present, baseline SSH hardening in place — captured.

## Part 4 — 🔴 Generalize (strip identity) — the critical block

Run these **last**, then shut down and **do not boot again** before templating (a boot re-specializes: regenerates identity you're about to see it create on *clones*, and dirties the template).

```bash
# 1) Clear cloud-init state so every clone runs first-boot fresh
sudo cloud-init clean --logs --seed

# 2) Reset machine-id (systemd regenerates a unique one on next boot)
sudo truncate -s 0 /etc/machine-id
sudo rm -f /var/lib/dbus/machine-id
sudo ln -s /etc/machine-id /var/lib/dbus/machine-id

# 3) 🔴 Remove SSH host keys (unique keys regenerate on first boot — cloud-init or ssh.service does this)
sudo rm -f /etc/ssh/ssh_host_*

# 4) 🔴 Revert networking to DHCP — NO baked static IP (the 10.10.0.50 overlap lesson, 216)
#    Edit /etc/netplan/*.yaml so the interface is: dhcp4: true  (remove addresses/gateway4/nameservers)
#    cloud-init will write per-clone netplan from the Cloud-Init drive.
sudo sed -n '1,50p' /etc/netplan/*.yaml   # review before/after

# 5) Clean logs, caches, history, leases, temp
sudo apt clean
sudo rm -rf /var/lib/apt/lists/*
sudo journalctl --rotate ; sudo journalctl --vacuum-time=1s
sudo find /var/log -type f -exec truncate -s 0 {} \;
sudo rm -f /var/lib/dhcp/* 2>/dev/null
sudo rm -f /root/.bash_history /home/*/.bash_history
history -c

# 6) Shut down — do NOT power back on before templating
sudo shutdown -h now
```

- [ ] 🔴 After shutdown, **do not start the VM again.** (If you do, re-run Part 4 before templating.)

## Part 5 — Convert to a Proxmox template

- [ ] **PVE UI:** right-click the (now stopped, generalized) source VM → **Convert to template**. *(CLI: `qm template <SOURCE-VMID>`.)* Optionally rename to `TPL-UBUNTU2604` / VMID `9001` first (templates can't be edited the same way after — set the name/ID beforehand).
- [ ] Read-back: `qm config <TPL-VMID>` shows `template: 1`; the VM shows a template icon in the UI and can no longer be started directly (only cloned).

## Part 6 — Prove it (POL-0001) — a throwaway test clone

The template is only "good" once a clone comes up with a **unique identity**. Clone one, boot it, verify, destroy it.

- [ ] **Clone:** PVE UI → template → **Clone** → **Full Clone**, temp name `ubuntu-tpl-test`. Set Cloud-Init (hostname `tpltest`, a test IP, your SSH key).
- [ ] Boot it, then check the identity actually regenerated uniquely:

```bash
cat /etc/machine-id                      # non-empty, and DIFFERENT from the source's captured value
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub   # a fresh fingerprint (unique per clone)
hostnamectl                              # hostname = tpltest (cloud-init applied)
ip -br a                                 # the per-clone IP you set, not a baked one
cloud-init status                        # done
systemctl is-active qemu-guest-agent     # active (PVE shows the guest IP)
```

- [ ] All unique/correct → **destroy the test clone** (`qm destroy <TEST-VMID>`). The template is verified.

---

## Validation — read the state back

- [ ] Template exists: `qm config <TPL-VMID>` → `template: 1`.
- [ ] Pre-generalization archive retained and **unbooted**.
- [ ] Test clone had a **unique** machine-id + **unique** SSH host keys + per-clone hostname/IP (Part 6).
- [ ] Fully patched at generalization; qemu-guest-agent + cloud-init present; SSH keys-only baseline.

## Common mistakes

- 🔴 **Templating with a static IP still set** — every clone fights for the same address (the `10.10.0.50` overlap family). Revert to DHCP/cloud-init first.
- 🔴 **Cloned SSH host keys** — remove `/etc/ssh/ssh_host_*` before templating; each clone must generate its own. Duplicate host keys = collision + security issue.
- 🔴 **Booting the generalized source before templating** — re-specializes and dirties the image (`211`'s "don't boot a Sysprepped image" rule, Linux edition).
- 🔴 **Under-patching the base** — the DC01 scar. Patch fully before Part 4.
- 🔴 **Baking secrets/private keys or role-specific firewall into the template** — keep it generic; secrets → Vaultwarden; role config → the clone's build guide.
- 🔴 **Template with no Cloud-Init drive** (found 2026-07-24) — clones can't get an identity. Attach the Cloud-Init drive to the source **before** templating; see Known defects §1.
- 🔴 **A broad-match DHCP netplan fallback (`00-atlas-dhcp.yaml`, `name: "e*"`) alongside Cloud-Init's static** (found 2026-07-24) — both claim the NIC, netplan applies neither, the clone boots with no IP. Remove the fallback from the image; see Known defects §2.

## Scars carried forward (from the Windows image, `216`)

- **Under-patched golden image bit DC01** → Part 2.1 patches fully first.
- **IP overlap open item (`10.10.0.50`)** → Part 4 forces DHCP/cloud-init; no baked IP survives.
- **"Capture real evidence, not a checklist tick"** → Parts 0/3/6 capture command output, not just `[x]`.
- **Windows analog note:** where Windows needed Sysprep to clear the SID, Linux clears **machine-id + SSH host keys + cloud-init state** — same goal (no shared identity across clones), different mechanism.

## Rollback

- The pre-generalization **archive VM** (Part 1) is the rollback to a known-good working Ubuntu box. Inspect offline; don't boot it casually.

## Related

- `211`–`214` + record `216` (the Windows golden-image chain this mirrors) · `SRV01` build guide (first consumer — the CRL host) · `Pi01-DNS-NTP/Build-Checklist.md` (a consumer; the reduced DNS+NTP box) · `Devices/CA01-VAULT01-PKI/` (OpenSSL side, a consumer) · `ADR-0027`/`ADR-0028` (why SRV01/the CRL host is on the critical path) · `ADR-0020` (NTP per-role) · VM Snapshot & Naming Convention · `IP-Addressing-Plan-VLSM`.

## Next guide

- **SRV01 build guide** — clone this template → assign identity via cloud-init → stand up nginx serving `http://pki.atlas.lab/pki/` (+ Oxidized/syslog roles). SRV01 is the AD CS Part-2.7 prerequisite.

## Sources (official — verified 2026-07-22, POL-0001)

Each load-bearing step is grounded in vendor/project documentation; the *sequence* is Atlas's synthesis of these into one reuse-existing-VM runbook (verify, don't assume — the flag caveat in §2.4 is exactly why).

- **Generalize before templating** ("Remove all user data, passwords and keys" → "Convert to template"; full vs linked clone): Proxmox VE — [VM Templates and Clones](https://pve.proxmox.com/wiki/VM_Templates_and_Clones).
- **Cloud-init drive, per-clone `ipconfig0`/`sshkey`/`ciuser`, `qm template`** (and the "prepare the image yourself" recommendation): Proxmox VE — [Cloud-Init Support](https://pve.proxmox.com/wiki/Cloud-Init_Support).
- **Empty `/etc/machine-id` on images → unique id generated at boot**: systemd — [machine-id(5)](https://man7.org/linux/man-pages/man5/machine-id.5.html) ("For operating system images which are created once and used on multiple machines… /etc/machine-id should be either missing or an empty file… An ID will be generated during boot").
- **`cloud-init clean` (`--logs`, `--seed`) → next boot re-runs as first boot**: cloud-init — [CLI reference](https://docs.cloud-init.io/en/latest/reference/cli.html).
- **SSH host-key regeneration on first boot** (why removing `/etc/ssh/ssh_host_*` is safe here): cloud-init's ssh module regenerates them on first boot — but **proven empirically in Part 6** (unique fingerprint on a test clone), not taken on trust.
- **Netplan DHCP / CIS Ubuntu hardening**: standard Canonical [netplan](https://netplan.io/) config + [CIS Ubuntu Benchmark](https://www.cisecurity.org/benchmark/ubuntu_linux).

## Change Log

| Version | Date | Change |
|---|---|---|
| 0.5 | 2026-07-24 | **🔴 Two golden-image defects found on the first real clone (NETBOX01) — documented with source fixes.** (1) The template shipped **without a Cloud-Init drive** → clones get no identity; fix = attach the drive to the source before templating (§2.4). (2) A baked-in **`00-atlas-dhcp.yaml`** netplan fallback (`name: "e*"`, dhcp4) **conflicts** with Cloud-Init's MAC-matched static `50-cloud-init.yaml`, so clones boot with **no IP**; fix = remove the fallback from the image (Cloud-Init is now the only netplan source) and **update the companion `.sh` generalize step**. Added a "Known defects" block up top, two Common-mistakes bullets, and per-clone workarounds referenced from `NETBOX01/Networking-Build-Guide.md`. 🔴 The `.sh` still needs the corresponding edit (tracked). |
| 0.4 | 2026-07-23 | **Executed — golden image built.** Confirmed **Ubuntu Server 26.04 LTS** (was assumed 24.04); template proposal → `TPL-UBUNTU2604`. Added the **qemu-guest-agent Proxmox-enable + power-cycle gotcha** to §2.2 (the "dependency job failed" seen on build). Companion script's `verify` count fix noted. |
| 0.3 | 2026-07-23 | Added the **⚙️ Automation companion** pointer to `220-prepare-ubuntu-golden-image.sh` (baseline / verify / gated generalize; Proxmox-host steps printed, not run). Narrative stays the source of truth. |
| 0.2 | 2026-07-22 | Added a **Sources** section (POL-0001) tracing each step to Proxmox / systemd `machine-id(5)` / cloud-init official docs, verified live. Flagged the `--sshkey` vs `--sshkeys` version discrepancy in §2.4 (verify via `qm set --help`). No procedural change — provenance + one caveat. |
| 0.1 | 2026-07-22 | Authored (not executed). Ubuntu Server LTS golden-image guide, **reuse-existing-VM path**: record source → retain pre-generalization archive (the `216` VMID-100 pattern) → baseline (full patch [DC01 scar], qemu-guest-agent, VirtIO SCSI/net, CIS-lite SSH-keys-only, unattended-upgrades, cloud-init) → **generalize (machine-id + SSH host keys + netplan→DHCP + cloud-init clean + logs)** → convert to template (`TPL-UBUNTU2404`/9001, proposed) → verify via a throwaway clone (unique machine-id + host keys). Carries forward the Windows scars (under-patch→DC01, the `10.10.0.50` no-baked-IP lesson, evidence-not-ticks). GUI-primary (PVE UI) + `qm`/bash alongside. 🔴 confirms pending: Server-not-Desktop, 24.04 LTS, names/VMIDs, cloud-init yes. |
