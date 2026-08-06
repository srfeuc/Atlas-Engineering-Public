---
Title: SW01 Considerations and Risks
Path: Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch
---

# SW01 Considerations and Risks

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: SW01 - Role: Access Switch

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Draft |
| Version | 0.1 |
| Applies To | SW01 (10.10.0.2 — Cisco Catalyst 2960X, Layer-2 switch) |
| Last Reviewed | 2026-07-16 |

## Purpose

What could bite you on SW01 — design risks, weak spots, unverified assumptions — each with a way to check it. Read before you trust, rebuild, or harden this device. Complements `039` (Troubleshooting, reactive) and `045` (CIS, hardening posture).

## How to read this

- 🟩 **Recommendation** — best practice to adopt; makes it better/safer.
- 🟨 **Hole** — unverified assumption or weak spot; run the check to settle it.
- 🟥 **Device-gated** — confirmed issue whose fix needs a live device read/write (usually a change record). Not fixable by editing docs.

**Verify, don't assume.** Run the command in each row; don't trust the status column (Rule 13).

## Considerations & Risks

| # | Consideration / Risk | Type | How to verify | Current status | Ref |
|---|---|---|---|---|---|
| 1 | **The clock has NEVER synchronised.** `show ntp status` = stratum 16, `never updated`, reference time 1899. `ntp server 10.10.0.5` points at Pi01, which serves no NTP (`.INIT.`, reach 0). Every log line, port-security event and future SIEM record carries a meaningless timestamp — this is the foundation Book 5 is meant to build on. | 🟥 Device-gated | `show ntp status` (stratum 16) ; `show ntp associations` (`~10.10.0.5 .INIT. reach 0`) | **Confirmed open, re-verified 2026-07-16.** Design decision now recorded — **`ADR-0020`** (AD PDC-emulator target; external-pool interim for SW01, *not* chrony on Pi01). Remaining: configure the interim source and prove `Clock is synchronized`. | `CM-0030`, `ADR-0020`, `045` §2.3 |
| 2 | **SNMP is v2c with a cleartext RO community, to a trap host that may not exist.** The community is live in the tree (redact + rotate pending), and traps go to `10.40.0.52` — VLAN 40 is routed but empty (`027` §17), so every trap this switch has sent went nowhere. | 🟨 Hole | `show snmp host` — **paste version + host only, redact the community** | **Confirmed v2c 2026-07-16.** Move to SNMPv3; point traps at a real collector when Book 5 exists; redact+rotate the community. | `027` §17, `023`, `CM-0023` |
| 3 | **The SPAN session captures nothing.** `monitor session 1` has a **destination** (`Gi1/0/5`) but **no source** on the live device. `023`/`027` both record source `Gi1/0/1 both` — the source line is absent from the running config, so the monitor port is wired to a session that mirrors nothing. | 🟥 Device-gated | `show monitor session 1` → destination `Gi1/0/5`, **no source** | **Divergence confirmed 2026-07-16** (doc says source Gi1/0/1 both; device has none). Re-add the source or record the SPAN as intentionally idle. | `023` (SPAN), `027` §14 |
| 4 | **No remote syslog.** Only SNMP traps are configured (to the possibly-dead host in row 2); `show run` has no `logging host`. When Book 5 stands up a collector, SW01 emits nothing to it — and can't, until row 1's clock is fixed. | 🟨 Hole | `show run \| include logging` → no `logging host` | **Confirmed absent 2026-07-16.** Add a syslog target with Book 5; gated behind the clock fix. | `045` §2.2, `CM-0030` |
| 5 | **Local-only auth.** `no aaa new-model`; management is the local `cisco` user + `enable secret`, unlike FGT01 and MKT01 which both use RADIUS via Pi01. A deliberate choice is fine — but it should be a recorded decision, not a default. | 🟨 Hole | `show run \| include aaa new-model` → `no aaa new-model` | **Confirmed 2026-07-16.** Decide: extend RADIUS to SW01, or accept local-only (ADR). | `045` §1.1 |
| 6 | **DAI has no fallback on the server VLANs, and the hypervisor trunk isn't trusted.** VLANs 20–80 have DAI enabled but **no static ARP ACL**, and the DHCP-snooping binding table is **empty**; `Gi1/0/4` (PVE01) is neither DAI- nor snooping-trusted (only `Gi1/0/1` is). A static-IP VM in VLAN 20–80 arriving via `Gi1/0/4` will have its ARP **dropped** — no binding, no ACL, untrusted port. Latent only because `Gi1/0/4` is down today (row 8). | 🟥 Device-gated | `show ip dhcp snooping binding` (0) ; `show ip arp inspection` (VLANs 20–80: no ACL) ; `show ip dhcp snooping` (trust = Gi1/0/1 only) | **Confirmed 2026-07-16.** Before PVE01 goes live decide: trust `Gi1/0/4`, add per-VLAN static ACLs, or ensure VMs use DHCP so snooping builds bindings. | `023`, `027` §16, `ADR-0002` |
| 7 | **`Gi1/0/4` → PVE01 link is down.** `show ip interface brief` shows `Gi1/0/4` down/down; PVE01 is unreachable through SW01 right now. Directly relevant to the pending PVE01 reconcile (`060`/`061`, `024` D12). | 🟨 Hole | `show ip interface brief` → `Gi1/0/4 … down down` | **Confirmed down 2026-07-16.** Establish whether PVE01 is powered/cabled before reconciling PVE01. | `024`, `028`, `036` |
| 8 | **The SNMP location string is still on the device.** `snmp-server location Home-Lab-California` is live — a real-world location disclosure on a repo `ADR-0010` intends to publish. `027` §17 states this was **removed**; the guide was corrected, the **device was not**. | 🟨 Hole | `show run \| include snmp-server location` → `Home-Lab-California` | **Divergence confirmed 2026-07-16** (guide removed it; device retains it). Remove on the device, or drop the claim from `027`. | `027` §17, `ADR-0010` |
| 9 | **No login banner.** `027` §2 configures no banner and none is live — a minor CIS gap (`045` §1.3), matching Pi01's state (`053` row 5). | 🟨 Hole | `show run \| include banner` → none | **Confirmed absent 2026-07-16.** Low priority; add a legal banner to close. | `045` §1.3 |
| 10 | **Hostname drift — closed by this batch.** The device is `SW01` (`show version` / `show run \| include hostname`). Until 2026-07-16, `001`, `006`, `012`, `019` and `023` still asserted the live hostname was `CoreSwitch` with a rename "open"; the **CoreSwitch sweep in this batch corrected all five** (`016`/`027`/`051` were already corrective). | 🟩 Recommendation | `show version` → `SW01 uptime …` ; `grep -rn CoreSwitch` finds only historical changelog/lesson mentions, no live claims | ✅ **Resolved 2026-07-16** (sweep). A new doc must never reintroduce the old name as "current". | `CM-0022`, `027` |
| 11 | **The `STATIC-HOSTS` ARP ACL is correct — and it is the only thing keeping VLAN-10 hosts reachable.** All five entries incl Pi01 are live (`CM-0022` fix holds). The DAI filter on VLAN 10 is applied **without** the `static` keyword, so a non-matching ARP falls through to the empty snooping table and is dropped — effectively only these five pass. The gateway (`.1`) reaches VLAN 10 via the DAI-trusted MKT01 trunk, so it is unaffected. | 🟩 Recommendation | `show arp access-list` (5 entries) ; `show ip arp inspection` (VLAN 10 → `STATIC-HOSTS`) | 🟢 **Correct 2026-07-16.** Any new static-IP host on VLAN 10 must be **added here first** or it is silently dropped. Build from `006`, not memory. | `023`, `027` §16 |

## Open holes — summary (most consequential first)

1. **Clock never syncs (row 1)** — blocks Book 5 and corrupts every timestamp; needs the NTP design decision + a proven sync. `CM-0030`.
2. **SPAN mirrors nothing (row 3)** — the monitor port is wired to a session with no source; visibility you think you have, you don't.
3. **DAI drops PVE VMs when they arrive (row 6)** — a latent outage that fires the moment PVE01 comes up with static-IP VMs on VLANs 20–80.
4. **SNMP: v2c + cleartext community + dead trap host + live location string (rows 2, 8)** — a cluster to settle before publication (`ADR-0010`).
5. **No syslog / local-only auth / no banner (rows 4, 5, 9)** — hardening backlog, mostly gated on Book 5 and an AAA decision.

## For the next build (Device Role Plan / Service Architecture)

Do these right from the start so the holes never exist:

- **Prove the clock with `show ntp status`, never a config line.** Point every device at one real NTP server and read the status back — a switch is worthless to a SIEM without it.
- **Configure SPAN source *and* destination together, and verify with `show monitor session`** — a destination with no source is a silent dead end.
- **Decide the DAI strategy for trunk-attached hypervisors up front** — trust the hypervisor trunk, add per-VLAN static ACLs, or require DHCP so snooping builds bindings. Don't enable DAI on VLANs whose hosts can never pass it.
- **SNMPv3, a collector that exists, and no location string** before any config leaves the lab (`ADR-0010`).
- **Record auth posture as a decision** — local-only is a valid choice; an unrecorded default is not.
- **Every static-IP host goes into `STATIC-HOSTS` before it is plugged in** — with `DHCP Permits: 0` there is no snooping fallback on VLAN 10.

## Revision history

| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-16 | Created from the 2026-07-16 live SW01 verification run (`056`). Seeds the CM-0030 clock item; records three device-vs-doc divergences (SPAN has no source; SNMP location string still live; `Gi1/0/4`→PVE01 down); and the DAI-fallback, SNMP-v2c, syslog, AAA, banner and CoreSwitch-hostname holes. |

## Related pages

- **Verification Procedure: `056-SW01-Verification-Procedure.md`**
- Build Guide: `027` · Build Record: `023` · Troubleshooting: `039` · CIS: `045`
- Change records / decisions: `CM-0030` (clock), **`ADR-0020`** (time-source decision), `CM-0022` (rebuild + hostname), `CM-0001`, `CM-0003`, `ADR-0002`, `ADR-0010`
