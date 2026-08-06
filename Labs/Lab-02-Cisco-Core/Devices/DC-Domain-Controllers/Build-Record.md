---
Title: DC01/DC02 — Build Record (verified as-built state)
Path: Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers
Status: 🟡 LIVING — the verified as-built state of the identity core. **DC01 device-verified; DC02 operator-reported, read-back pending.** Records outrank guides (`POL-0001`). Evidence lives in the `Build-Checklist.md` ✅ items + `Diagnostics-*.md`; this page is the at-a-glance "what is actually true right now."
Version: 1.0
Date: 2026-07-29
---

# DC01 / DC02 — Build Record (verified as-built state)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build).** The single "what is actually true right now" snapshot for the Tier-0 identity core — the `POL-0001` evidence home. It **outranks the Build-Guides** (guides = target state; this = reality). Each row cites *where the evidence lives* rather than re-pasting it (`POL-0008`). Markers: ✅ device-verified · 🟡 operator-reported, read-back pending · ⬜ not built.

## DC01 — `atlas.lab` forest root  (PVE01 · `10.20.0.2` · VLAN 20 T0)

| Attribute | As-built | Status | Evidence |
|---|---|---|---|
| Forest / domain | `atlas.lab` — single forest / domain / site | ✅ | `Get-ADDomain` (Build-Checklist §1) |
| FSMO roles | all five held by DC01 | ✅ | `netdom query fsmo` (Checklist) |
| KDS root key | present (gMSA-ready) | ✅ | `Get-KdsRootKey` (§2) |
| OU structure | per `Build-Guide/DC01/OU-Design-and-Build.md` (`Devices`/`Employees` rename; `redircmp`→Staging) | ✅ | `Build-Guide/DC01/OU-Design-and-Build.md` |
| AD-integrated DNS | up; forwarder `1.1.1.1` (interim) | ✅ | `Diagnostics-DC01.md` |
| PDCe time authority | external → `time.nist.gov` (not CMOS) | ✅ | `w32tm /query /source` (§5) |
| GPO 7a — baseline + Wave-A | MS Server 2025 v2602 baseline (8 purpose-scoped GPOs) + Wave-A links | ✅ | `Build-Guide/DC01/GPO-Design-and-Build.md` §7a; `gpresult` DC01 |
| GPO 7b — PSO | `PSO-FinanceHR` (min 15, lockout 3) | ✅ | `Build-Guide/DC01/GPO-Design-and-Build.md` §7b |
| GPO 7c — LAPS + DSRM-via-LAPS | schema + `LAPS`→Devices; DSRM LAPS-managed (`POL-0002` retired) | ✅ | `Build-Guide/DC01/GPO-Design-and-Build.md` §7c / §7c-DSRM |
| AGDLP tier groups | `G-Tier0/1/2-Admins` + `G-IT-Staff` | ✅ | `Build-Guide/DC01/Tiered-Admin-and-Groups-Build.md` §2 (07-22) |
| DHCP (on DC01, `ADR-0030`) | not built | ⬜ | — |
| GPO 7d — tier-deny logon | not applied — the 7d GPOs aren't built/linked yet (accounts + groups exist) | ⬜ | — |
| Tier accounts `t0/t1/t2-seth` · off built-in Admin · Protected Users | created + secured (Stage-8 Part 3) | ✅ (07-22) | `Build-Guide/DC01/Tiered-Admin-and-Groups-Build.md` Part 3 · re-verify `Diagnostics-DC01.md` |

## DC02 — replica DC  (PVE02 · `10.20.0.3` · VLAN 20 T0)

| Attribute | As-built | Status | Evidence |
|---|---|---|---|
| Promotion (replica, add-to-existing-domain) | operator-reported 2026-07-28 | 🟡 read-back pending | `Build-Guide/DC02/DC02-Build-Guide.md` |
| Replication health | pending | 🟡 | `repadmin /replsummary` = 0 failures (to run) |
| GC / replica DNS / DOMHIER time | pending | 🟡 | `Diagnostics-DC02.md` |

> 🔴 **DC02 read-back is the one outstanding item** — run `repadmin /replsummary` (0 failures) · `dcdiag` · `Get-ADDomainController DC02`; capture the output and the DC02 rows flip ✅ (`POL-0001`).

## Related
- `Build-Checklist.md` (the action list + the ✅ evidence these rows summarize) · `Diagnostics-DC01.md` / `Diagnostics-DC02.md` (the verify commands) · `Roadmap.md` (build path) · `Considerations.md` (open risks).

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-29. Created — consolidated DC01's **device-verified** as-built state (promotion `atlas.lab`, FSMO, KDS, OU tree, AD-DNS, PDCe external time, GPO 7a/7b/7c/7c-DSRM, AGDLP tier groups) from the Build-Checklist ✅ items into the single as-built record; DC02 rows **🟡 pending read-back**. Records outrank guides (`POL-0001`). |
