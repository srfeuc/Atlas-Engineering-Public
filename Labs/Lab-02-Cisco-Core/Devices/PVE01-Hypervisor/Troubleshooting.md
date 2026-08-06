---
Title: PVE01 — Troubleshooting (symptom → cause → fix)
Path: Labs/Lab-02-Cisco-Core/Devices/PVE01-Hypervisor
Status: 🟠 LIVING — real R410/Proxmox failure modes + fixes. Deep verify commands → the Virtualization Diagnostics battery.
Version: 0.1
Date: 2026-07-30
---

# PVE01 — Troubleshooting (symptom → cause → fix)

> Symptom-first fixes for the R410 hypervisor. Verify commands live in `../../Virtualization/Build-Records/PVE01-Diagnostics.md`; deep networking state in `../../Virtualization/Build-Records/PVE01-Networking.md` (`ADR-0034`).

| Symptom | Likely cause | Fix |
|---|---|---|
| **Host unreachable after a network apply** | Applied the switch **or** PVE side alone — mgmt is tagged `vmbr0.10`; a native/tagged mismatch strands it | Recover at the **physical console** (iDRAC rides the same cable, so it's also gone). Apply **both ends in one window** (`204` recovery-first order). |
| **A VM has no network on its VLAN** | VLAN tagged on the vNIC but **not in `vmbr0`'s `bridge-vids`** — the VLAN-aware bridge tags internally and drops at the uplink | `bridge vlan show` → confirm `eno1` lists the VLAN; add it to `bridge-vids 10–90,999`, `ifreload -a`, re-check (`204` §3). |
| **Return traffic to a VLAN-10 VM lost** | Legacy native-VLAN-10 coupling (pre-07-24 design) | Confirm SW01 `Gi1/0/4` native = **999** and mgmt is tagged `vmbr0.10`; the fix is already applied (see `PVE01-Networking` History). |
| **Clock wrong after a power cycle; VMs' time skewed** | 🔴 `CM-0012` — dead CMOS/RTC resets `2026`→`2018` | Keep the host on **continuous power/UPS**; chrony re-syncs on boot but won't survive a full power loss. Physical battery replacement outstanding (`ADR-0017`). Never boot a DC here with a wrong host clock. |
| **iDRAC unreachable during a teardown** | 🔴 `CM-0011` — iDRAC is **shared-LOM** on `eno1`/`Gi1/0/4`, dies when SW01 is wiped | Expected — it's **not** out-of-band. Use the **physical console**. (Future: cable the R410's unused dedicated iDRAC port.) |
| **GUI shell / noVNC "connection refused"** | Known noVNC/`localhost:5900` issue | **SSH is a full substitute** — administer over SSH; re-verify the noVNC issue before carrying it forward. |
| **Per-VM firewall rules not taking effect** | Proxmox global firewall is `disabled/running` → per-VM `firewall=1` is **inert** | Enable the datacenter/node firewall deliberately if firewalling is intended; otherwise document that `firewall=1` is currently a no-op (`217-Verified-Facts`). |
| **No-subscription patch reverted; nag returns** | `apt upgrade` overwrote `proxmox-widget-toolkit` | Re-apply the no-sub widget patch after updates (add a post-update hook). |
| **RAM reads slower / less than expected** | RAM relocated off faulty DIMM slot **B1** to B3 | Verify against Dell's supported population order for full triple-channel interleaving (`217-Verified-Facts`). |

## Escalation
- Networking specifics → `../../Virtualization/Build-Records/PVE01-Networking.md` + `../../Virtualization/Build-Guides/204-Proxmox-Networking.md` (recovery-first order).
- VM migration / DC USN-rollback trap → `../../Virtualization/Build-Guides/221-PVE02-EQR6-Bring-Up-and-VM-Migration.md`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created (#21) — symptom→cause→fix for the R410 hypervisor: host-unreachable-after-apply (both-ends-one-window), VM-VLAN-drop (`bridge-vids`), native-10 return-traffic (fixed), `CM-0012` clock, `CM-0011` iDRAC shared-LOM, noVNC/SSH, inert global firewall, no-sub patch revert, DIMM population. Links to the Virtualization Diagnostics/Networking records + the `221` migration trap. |
