---
Title: NETBOX01 Networking Build Guide (Ubuntu clone bring-up — VLAN 20, 10.20.0.11)
Path: Labs/Lab-02-Cisco-Core/Devices/NETBOX01-Source-of-Truth
Status: 🟢 LIVING (v1.0) — **network bring-up device-verified 2026-07-24** (reachable at 10.20.0.11, SSH up). The network half of the NetBox build; the service install is `Build-Guide.md`. GUI-primary for the Proxmox clone; in-guest CLI for the fix.
Version: 1.0
Date: 2026-07-24
---

# NETBOX01 — Networking Build Guide

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** — brings an **Ubuntu Server** clone of `TPL-UBUNTU2604` (guide `220`) onto the wire as **NETBOX01**: VLAN 20, **`10.20.0.11/26`**, gw `10.20.0.1`, DNS `10.20.0.2`, domain `atlas.lab`. This is the **network bring-up only** — get the box reachable — before the NetBox service install (`Build-Guide.md`). Split out per the FGT01 pattern (`Build-Guide-1-Networking`): networking gets its own page.

## Identity (from `IP-Addressing-Plan-VLSM`)

| Item | Value |
|---|---|
| Hostname | `netbox01` (came up as `NETBOX` — cosmetic, see §5) |
| VLAN / bridge | 20 (Servers) on `vmbr0`, **VLAN Tag 20** |
| IPv4 | **`10.20.0.11/26`** |
| Gateway | `10.20.0.1` (MKT01 vlan20) |
| DNS server / search | `10.20.0.2` (DC01) / `atlas.lab` |
| Admin user | `nbadmin` (Cloud-Init) + SSH key; template seed user `seth` also present |
| In-guest NIC name | `eth0` (MAC `00:00:5e:00:53:02`) |

> **Why VLAN 20 (Servers), not VLAN 10 (Management)?** NetBox is a service *workload* (web app + DB + API), so it lives on the Servers VLAN with the DCs/SRV01; VLAN 10 is reserved for the device/hypervisor **management plane**. Full rationale in `Architecture/IP-Addressing-Plan-VLSM.md` → "Management vs Servers — what lives where."

> 🔴 **This box exposed two golden-image defects (both now fixed at source in guide `220`).** They will bite **every** Ubuntu clone until the template is rebuilt, so the per-clone workarounds are steps here, not footnotes: (1) the template ships **without a Cloud-Init drive** — add one (§2); (2) a baked-in netplan fallback **`00-atlas-dhcp.yaml` conflicts with Cloud-Init's static** and the clone comes up with **no IP** — disable the fallback (§4). See §Troubleshooting for the full trail.

---

## Part 1 — Clone the template + tag the NIC (Proxmox GUI)

- [x] **Full Clone** `TPL-UBUNTU2604` → name `netbox01`, storage `local-lvm` (right-click → Clone → Full).
- [x] **Hardware → Network Device (net0):** Bridge `vmbr0`, **VLAN Tag `20`**, Model VirtIO. 🔴 A blank VLAN tag = the box lands on the wrong network and is unreachable — set `20`.

## Part 2 — 🔴 Add a Cloud-Init drive (the template has none)

The golden image was built **without** a Cloud-Init drive, so the clone has none and the Cloud-Init tab shows *"No CloudInit Drive found."* Add one:

- [x] **Hardware → Add → CloudInit Drive** → Storage `local-lvm` → (Bus/Device default `IDE 2`) → **Add**.

*(This is a template defect — guide `220` now says the template must carry a Cloud-Init drive so clones inherit it. Until the template is rebuilt, add it per clone.)*

## Part 3 — Cloud-Init identity

- [x] **Cloud-Init tab**, set:
  - **User** `nbadmin`; **Password** (→ Vaultwarden, `POL-0002`; this is the console-login fallback).
  - **SSH public key** = the admin's Windows key (`ssh-keygen -t ed25519`; paste `C:\Users\<you>\.ssh\id_ed25519.pub`).
  - **IP Config (net0):** 🔴 **Static** (not DHCP — there is no DHCP server on VLAN 20 yet) → `10.20.0.11/26`, gateway `10.20.0.1`.
  - **DNS servers** `10.20.0.2`; **DNS domain** `atlas.lab`.
- [x] **Start** the VM.

## Part 4 — 🔴 Fix the netplan conflict, then verify reachable

On first boot the clone comes up with `eth0` **UP but no IPv4**, `ip route` empty, `ping` → *"Network is unreachable"*, and SSH times out. Cause: **two netplan files both claim `eth0`** so netplan applies neither (full detail in Troubleshooting). Fix it from the **Proxmox Console** (login `nbadmin` + the Cloud-Init password):

```bash
# see the two conflicting files (optional):
ls /etc/netplan/                 # 00-atlas-dhcp.yaml  +  50-cloud-init.yaml
# disable the golden-image DHCP fallback so Cloud-Init's static wins:
sudo mv /etc/netplan/00-atlas-dhcp.yaml /etc/netplan/00-atlas-dhcp.yaml.disabled
sudo netplan apply               # a "permissions too open" warning is harmless
```

Then verify (device-verified 2026-07-24):
```bash
ip -br a          # eth0  UP  10.20.0.11/26
ip route          # default via 10.20.0.1 dev eth0
ping -c3 10.20.0.1   # replies, 0% loss
```
- [x] From the admin PC: `ssh nbadmin@10.20.0.11` → logs in with the key. ✅ reachable 2026-07-24.

> 🔴 **Root cause is fixed in guide `220`**, so a rebuilt template won't need this step. On the *current* template every clone (SRV01, Pi01, CA01…) hits it — do §4 on each until the template is rebuilt.

## Part 5 — Tidy-ups (optional, cosmetic)

- [ ] **Hostname** came up as `NETBOX` (Proxmox sets it from the VM *Name*). To match the register's `netbox01`:
  ```bash
  sudo hostnamectl set-hostname netbox01
  ```
  (and rename the VM in Proxmox to `netbox01` for consistency). Cosmetic — does not affect reachability.
- [ ] **Template seed user `seth`** is present alongside `nbadmin`. Leave it or remove it later per the identity decision in `220` §2.3 (`POL-0002`); not blocking.

## Verification — read the state back (`POL-0001`)

- [x] `ip -br a` → `eth0` = `10.20.0.11/26`. ✅ 2026-07-24
- [x] `ip route` → default via `10.20.0.1`. ✅ 2026-07-24
- [x] `ping -c3 10.20.0.1` → 0% loss. ✅ 2026-07-24
- [x] `ssh nbadmin@10.20.0.11` from the admin PC → key login. ✅ 2026-07-24
- [ ] DNS record `netbox.atlas.lab` → `10.20.0.11` added on DC01 (needed for the NetBox web step — `Build-Guide.md` Part 0/3).

---

## Troubleshooting (the full trail from the 2026-07-24 bring-up)

**Symptom chain:** `ssh nbadmin@10.20.0.11` → *Connection timed out*; at the console `ip -br a` showed `eth0` UP with only an IPv6 link-local (no IPv4), `ip route` empty, `ping 10.20.0.1` → *Network is unreachable*.

1. **"No CloudInit Drive found."** The template was built without one. → **Add a CloudInit Drive** to the clone (Hardware → Add → CloudInit Drive → local-lvm). §2.
2. **Cloud-Init created the user but not the network.** `nbadmin` existed (login worked) yet `eth0` had no IPv4 — so Cloud-Init's *user* module ran but the *network* didn't apply. First reflex was to force a re-run (`sudo cloud-init clean --logs && sudo reboot`) — it re-wrote the config but the address still didn't land, which pointed at a **netplan conflict**, not a Cloud-Init miss.
3. **The real cause — two netplan files both match `eth0`:**
   - `50-cloud-init.yaml` (correct): matches the NIC **by MAC** (`00:00:5e:00:53:02`), sets `10.20.0.11/26` + gateway + DNS + `set-name: eth0`.
   - `00-atlas-dhcp.yaml` (golden-image fallback): matches **`name: "e*"`** (every ethernet, so also `eth0`) with `dhcp4: true`, `optional: true`.
   Two definitions matching the same physical interface → `netplan generate` can't resolve it and applies **neither**, so `eth0` gets no address.
4. **Fix:** move the fallback out of the way so only the correct static remains, then apply:
   ```bash
   sudo mv /etc/netplan/00-atlas-dhcp.yaml /etc/netplan/00-atlas-dhcp.yaml.disabled
   sudo netplan apply
   ```
   → `eth0` immediately took `10.20.0.11/26`, default route appeared, gateway ping succeeded, SSH worked.

**Windows-side gotchas (accessing the box):**
- Reading the public key: **PowerShell** uses `type $env:USERPROFILE\.ssh\id_ed25519.pub`; **cmd** uses `type %USERPROFILE%\.ssh\id_ed25519.pub`. Mixing them gives *"The filename, directory name, or volume label syntax is incorrect."*
- **SSH "Connection timed out" ≠ a key problem.** A timeout means the host isn't reachable on the network (no IP / wrong VLAN) — it never even gets to authentication. Diagnose reachability (console, `ip -br a`) before touching keys.

**Why this is safe/expected:** the clone's break-glass is the **Proxmox console** (network-independent), so a no-IP clone is never "lost" — you fix it at the console. Nothing here risks other hosts.

## Related

- `Build-Guide.md` (the NetBox **service** install — assumes this guide left the box reachable at `10.20.0.11`) · `Build-Checklist.md`
- `Virtualization/Build-Guides/220-Prepare-the-Ubuntu-Golden-Image.md` (the template + the **root-cause fixes** for the two defects above) · `Reference/218-VM-Snapshot-and-Naming-Convention.md`
- `Architecture/IP-Addressing-Plan-VLSM.md` (`10.20.0.11`, VLAN 20) · `Architecture/SW01-PVE01-Native-VLAN-Options.md` (how VM VLAN tags reach the wire) · `Operations/Device-Hardening-Standard.md` (break-glass = Proxmox console)

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-07-24 | Created — NETBOX01 network bring-up, **device-verified** (`eth0` = `10.20.0.11/26`, default via `10.20.0.1`, gateway ping 0% loss, SSH key login). Documents the clone + **VLAN-20 NIC tag**, the 🔴 **add-a-CloudInit-drive** step (template ships without one), the Cloud-Init identity, and the 🔴 **netplan `00-atlas-dhcp.yaml` vs `50-cloud-init.yaml` conflict** with the `mv …disabled` + `netplan apply` fix — captured in full in Troubleshooting along with the Cloud-Init-clean red herring and the Windows cmd-vs-PowerShell / timeout-≠-key gotchas. Both golden-image defects are fixed at source in guide `220`; per-clone workarounds remain here until the template is rebuilt. Split out per the FGT01 networking-guide pattern. |
