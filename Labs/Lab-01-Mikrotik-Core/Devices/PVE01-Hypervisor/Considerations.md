---
Title: PVE01 Considerations and Risks
Path: Labs/Lab-01-Mikrotik-Core/Devices/PVE01-Hypervisor
---

# PVE01 Considerations and Risks

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: PVE01 - Role: Hypervisor

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Draft |
| Version | 0.1 |
| Applies To | PVE01 (10.10.0.10 — Dell PowerEdge R410, Proxmox VE host) |
| Last Reviewed | 2026-07-16 |

## Purpose

What could bite you on PVE01 — design risks, weak spots, unverified assumptions — each with a way to check it. Read before you trust, rebuild, or harden this device. Complements `036` (Troubleshooting, reactive) and — (no CIS checklist yet).

## How to read this

- 🟩 **Recommendation** — best practice to adopt.
- 🟨 **Hole** — unverified assumption or weak spot; run the check to settle it.
- 🟥 **Device-gated** — confirmed issue whose fix needs a live device read/write (usually a change record). Not fixable by editing docs.

**Verify, don't assume.** Run the command in each row; don't trust the status column (Rule 13). **Run as `root` — no `sudo` on this host.**

## Considerations & Risks

| # | Consideration / Risk | Type | How to verify | Current status | Ref |
|---|---|---|---|---|---|
| 1 | **The CMOS/RTC does not hold across power loss — a new battery did NOT fix it.** RTC resets `2026`→`2018-05-30` on every power cycle (tested twice 2026-07-16, incl. after a holder reseat). While powered, NTP keeps the OS clock correct; the risk is every cold boot (wrong clock until NTP syncs) and any full power loss. **Blocks the iDRAC onboarding (`050`).** | 🟥 Device-gated | write RTC (`hwclock --systohc`), **full unplug**, boot, `dmesg \| grep -i 'RTC time'` → wants current year, reads `2018` | **FAIL, re-confirmed 2026-07-16.** Next: measure the cell (bare ≥ 3.0 V; ~3 V seated) to split weak/poorly-seated cell from a failed board RTC circuit. Then UPS-and-accept or retire. | `CM-0012`, `ADR-0017`, `036` |
| 2 | **`egrep -c '(vmx\|svm)'` mis-reports on kernel 6.8** — returns **32** on this 16-CPU host (a `vmx flags:` line per CPU), which reads as either the old false "32 vCPU" claim or as broken. VT-x is genuinely on. `ADR-0017`'s CMOS close-test uses exactly this command. | 🟨 Hole | `lsmod \| grep kvm` (kvm_intel loaded) ; `grep -c '^flags.*vmx' /proc/cpuinfo` (= 16) | **Confirmed 2026-07-16.** `024`/`028`/`036` corrected; `ADR-0017` close-test still says "returns the CPU count" — fix it there too. | `024`, `028`, `036`, `ADR-0017` |
| 3 | **The iDRAC is not onboarded, and onboarding is blocked.** Password changed at the console 2026-07-16 (no longer factory) but not remote-verifiable; no Lab CA cert; SNMP still `public`; IPMI-over-LAN disabled; still on the shared LOM. `050` is the build, blocked on `CM-0012` (row 1). | 🟥 Device-gated | `ipmitool lan print 1` (cipher `XXXa`, SNMP `public`) ; `ipmitool channel info 1` (disabled) | **Held across 2026-07-16 power cycles** (own NVRAM). Do **not** open a remote path until the board holds config. `CM-0011` is closed-as-false — not a work order. | `050`, `CM-0012`, `CM-0011` |
| 4 | **The iDRAC dies with SW01 — it is not out-of-band.** Shared LOM `…a4` rides `eno1`'s cable on SW01 `Gi1/0/4`. When SW01 is wiped (step one of any teardown), the iDRAC goes with it. The physical console is the real bootstrap path. | 🟥 Device-gated | `ipmitool lan print 1` MAC `…a4` = same card as `eno1 …a2` | **Confirmed.** Fix = move to the dedicated iDRAC port (`050` §1) during the same chassis visit as the battery — MAC changes, so update SW01 `STATIC-HOSTS`. | `050`, `003`, `048` |
| 5 | **Single power supply — no redundancy.** Only PSU bay 2 is powered (bay 1 is a filler or unseated). A single supply/outlet/breaker failure drops the host. Doubly important given row 1 — a power blip cold-boots it into a wrong clock. | 🟨 Hole | inspect bays; `ipmitool sdr list \| grep -i ps` | **Single-PSU 2026-07-16.** Put PVE01 on a **UPS** (the `ADR-0017` mitigation); add/seat a second PSU on a separate feed for real redundancy. | `ADR-0017` |
| 6 | **iDRAC MAC must be in SW01 `STATIC-HOSTS` or DAI silently drops it.** `…a4` rides the same `Gi1/0/4` as `eno1 …a2`; SW01 has `DHCP Permits: 0`, no snooping fallback. If the iDRAC moves to the dedicated port its MAC changes — update `STATIC-HOSTS` in the same session. | 🟩 Recommendation | on SW01: `show arp access-list` includes `10.10.0.100 → 0000.5e00.5314` | **Present today.** Re-check after any NIC move. | `028` §4, `023`, `050` |
| 7 | **VMs exist but are stopped — including `DC01`.** `qm list`: `DC01` (101), `WIN2025-BUILD-ARCHIVE` (100), template `TPL-WIN2025` (9000). `DC01` unpromoted matches `ADR-0004`; the old `024` said "none deployed". No inventory tracks their disk/role. | 🟨 Hole | `qm list` ; `qm config <id>` | **Confirmed 2026-07-16.** Track VM inventory (`VM-and-Services-Inventory.md`); `DC01` promotion is Book 3. | `024`, `ADR-0004` |
| 8 | **GUI shell (noVNC) is broken.** The Node → Shell button fails — VNC to `localhost:5900` refused. SSH is the working substitute. Not re-checked in the 2026-07-16 run. | 🟨 Hole | Proxmox GUI → Node → Shell ; SSH `root@10.10.0.10` works | **Open, not re-verified 2026-07-16.** Low priority while SSH works. | `024`, `028`, `036` |
| 9 | **The VLAN-aware bridge only carries VLAN 1 today.** `bridge vlan show` shows `eno1`/`vmbr0` at VLAN 1 PVID untagged only — expected with no tagged VMs running, but it means per-VM VLAN tagging is unproven live. | 🟨 Hole | start a VM tagged (e.g. VLAN 20), then `bridge vlan show` shows VID 20 added | **Unproven 2026-07-16** (all VMs stopped). Confirm when a tagged guest runs. | `028`, `036` |
| 10 | **`sudo` is not installed (root-only).** Every external Proxmox tutorial prefixes `sudo`; those commands fail as written here. | 🟩 Recommendation | `which sudo` → not found | By design on this host. Strip `sudo` from copied commands. | `036`, `CM-0012` |
| 11 | **The no-subscription GUI patch is overwritten by updates.** `proxmox-widget-toolkit` updates revert the nag patch; the shell button/nag returns until re-applied. | 🟩 Recommendation | after `apt upgrade`, check the GUI nag | Known; re-apply per `028` §8. | `028` |

## Open holes — summary (most consequential first)

1. **CMOS/RTC won't hold (row 1)** — a battery swap didn't fix it; measure the cell to decide battery-vs-board, then UPS-accept or retire. Blocks the iDRAC onboarding.
2. **iDRAC not out-of-band + not onboarded (rows 3, 4)** — the dedicated-NIC move + `050` are gated behind row 1.
3. **No power redundancy (row 5)** — single PSU; a UPS is the immediate mitigation and matters more because of row 1.
4. **VT-x count gotcha (row 2)** — cosmetic but it has already produced false "32 CPU" reads; fix `ADR-0017`'s close-test.

## For the next build (Device Role Plan / Service Architecture)

- **Prove RTC durability with a real power-pull before trusting the host for anything time-sensitive** — a battery swap is not proof; a boot RTC of the current year is.
- **Don't count CPUs with `egrep -c '(vmx|svm)'`** on modern kernels — use `grep -c '^flags.*vmx'` or the loaded `kvm_intel` module.
- **Onboard the BMC only onto a board proven to hold config** — cert, named account, deliberate path, dedicated NIC (`050`), never on a surface that resets.
- **Put the hypervisor on a UPS, and a second PSU on a separate feed** — a single supply plus a non-durable clock is two power faults waiting to compound.
- **Track the VM inventory** (disk, role, VLAN) as VMs land — `DC01` already exists and no doc listed it.

## Revision history

| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-16 | Created from the 2026-07-16 live PVE01 verification run (`060`). Seeds the CMOS/RTC durability failure (`CM-0012`), the VT-x kernel-6.8 gotcha, the iDRAC-onboarding block (`050`), single-PSU/UPS, the stopped VMs incl. `DC01`, and the sudo/GUI-shell/bridge-VLAN holes. |

## Related pages

- **Verification Procedure: `060-PVE01-Verification-Procedure.md`**
- Build Record: `024` · Build Guide: `028` · Troubleshooting: `036` · iDRAC onboarding: `050`
- Change records / decisions: `CM-0012` (CMOS/RTC), `CM-0011` (closed-false), `ADR-0017` (defer/freeze), `ADR-0004` (`DC01`/RADIUS)
