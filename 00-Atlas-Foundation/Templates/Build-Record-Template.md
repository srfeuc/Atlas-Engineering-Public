<!--
  ATLAS BUILD-RECORD TEMPLATE  ·  copy to  Devices/<DEVICE>/Build-Record[-<Area>].md
  ────────────────────────────────────────────────────────────────────
  A Build RECORD is VERIFIED REALITY — what is actually running on this device, read back from it,
  including every deviation. It is NOT the Build Guide (that's the target/intent). Source priority
  (Atlas-Workflow §1): a Record OUTRANKS a Guide; the DEVICE outranks the Record (Charter Rule 13).

  Modelled on the real Lab-01 records (SW01/MKT01/FGT01/PI01/PVE01), which were made at the machine.
  HOW TO USE
  1. Fill every ‹placeholder›. §3 is device-specific — one table per subsystem the device actually has
     (a switch: VLANs/ports/STP/L2-security; a Linux host: services/auth/storage; etc.). Delete the rest.
  2. Every fact = an observed value + how it was read back + the date. Unverified → 🟡. Never invent output.
  3. Don't restate a fact whose home is elsewhere (addressing plan / NetBox) — record the OBSERVED value
     and link its intent home (POL-0004: one home per fact).
  Delete this comment block in the finished record.
-->
---
Title: ‹DEVICE› Build Record
Path: Labs/‹Lab›/Devices/‹DEVICE›
---

# ‹DEVICE› Build Record

<!-- provenance -->
> **‹Lab, e.g. Lab-02-Cisco-Core› (‹🟢 ACTIVE / 🔒 FROZEN ‹date››)** — Host: ‹DEVICE› — Role: ‹role›

> **What this is.** The verified state of ‹DEVICE› — read back from the device, not intended. This **outranks the Build Guide** ([source priority](../../../../00-Atlas-Foundation/Governance/Atlas-Workflow.md#1-source-priority--read-this-first)). If the device disagrees with this page, **the device wins** (Rule 13) — reconcile this page to it.

## On this page

1. [Document control](#1-document-control) — status + verification dates
2. [Platform](#2-platform) — identity
3. [Verified state](#3-verified-state) — one table per subsystem, device-verified
4. [Known deviations](#4-known-deviations) — target vs reality
5. [Change log](#5-change-log)

---

## 1. Document control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | ‹Verified — reconciled to live ‹YYYY-MM-DD›; residual items raised: ‹CM-####…›› |
| Version | ‹n.n› |
| Applies To | ‹Atlas 2.0› |
| Last Live Verification | ‹YYYY-MM-DD› |
| Last Reconciled | ‹YYYY-MM-DD› |

> **"Verified" is a claim about a date** (Charter Rule 14). If this page hasn't been re-read against the device since *Last Live Verification*, treat it as **Historical** until re-verified.

---

## 2. Platform

| Item | Value |
|---|---|
| Hardware | ‹Cisco WS-C2960X-48FPS-L / Dell R410 / …› |
| OS / firmware | ‹IOS 15.2(2)E6 / PVE 8.x / …› |
| Live hostname | ‹SW01› — device-verified ‹YYYY-MM-DD› (`‹show version›`) |
| Target hostname | ‹SW01› |
| Management IP | ‹10.10.0.2› — intent home: [`IP-Addressing-Plan-VLSM`](../../Architecture/IP-Addressing-Plan-VLSM.md) → NetBox |
| Default gateway | ‹10.10.0.1› |
| Domain | ‹atlas.lab› |
| Console | ‹9600 8N1, no flow control› |

---

## 3. Verified state

> **One table per subsystem the device actually has.** Every row: the **observed value** + how it was **read back** + the **date**. Anything not read back is 🔴/🟡. Mark device-verified facts explicitly, as the real records do (*"device-verified 2026-07-16 (`show version`)"*).

### ‹Subsystem 1 — e.g. Port assignments (verified)›

| ‹Port› | ‹Description› | ‹Mode / VLAN / value› | State / verified |
|---|---|---|---|
| ‹Gi1/0/1› | ‹Trunk-to-MKT01› | ‹Trunk · native 999 · tagged 10–80,999› | ‹Connected · ✅ 2026-07-16› |

### ‹Subsystem 2 — e.g. Layer-2 security / Services / Authentication / Storage›

| ‹Feature / service› | ‹Observed state› | Read-back | Verified |
|---|---|---|---|
| ‹DHCP snooping› | ‹Enabled, VLANs 10–80, trusted Gi1/0/1› | `‹show ...›` | ‹✅ date / 🟡› |

> 🔴 **Call out any correction the way the real records do** — a one-fact-wrong table caused the Pi01 "mystery" that survived three handoffs. If you fix a value here, note *what was wrong, what the device actually says, and the read-back that proves it* (Rule 13).

---

## 4. Known deviations

Where reality differs from the [Build Guide](./Build-Guide.md) (target). A **recorded + justified** deviation is fine; a guide still teaching the old way is a **defect** — reconcile it (Rule 15).

| Item | Target | Current (reality) | Action |
|---|---|---|---|
| ‹NTP› | ‹AD PDC-emulator hierarchy› | 🔴 ‹points at Pi01, never synced — stratum 16› | ‹decision `ADR-0020`; fix tracked `CM-0030`› |
| ‹…› | ‹…› | ‹…› | ‹`CM-####` / `ADR-####`› |

---

## 5. Change log

> **How this log works.** Newest session on top. Each session is a dated block: a **Notes** line (what you did and why, plainly), then the changes — each tagged so they're easy to tell apart at a glance:
>
> - 🔴 **MAJOR** — a structural or security-posture change (a new VLAN, a trust, a firewall stance). Also gets a **Major Change record** ([`MC-####`](./Changes/)).
> - 🟢 **Normal** — a description, a routine setting, a scoped tweak. A standard **Change record** ([`CM-####`](./Changes/)).
> - 🟡 **Unverified** — done, but not yet read back.
>
> Always **state what you did NOT change and why** (gated on a rotation, an operator call, an unreachable device) — the real records do this, and it's what keeps them honest.

<!-- ▼▼▼ EXAMPLE — delete this block and record this device's real sessions ▼▼▼ -->
### Session 2 — 2026-07-16 (operator)
**Notes:** Reconciled to the live device after the segmentation redesign; enabled L2 security.

- 🔴 **MAJOR** — Enabled **DHCP snooping + Dynamic ARP Inspection** on VLANs 10–80 (`MC-0007`). Verified: `show ip arp inspection` (2026-07-16).
- 🟢 Normal — Corrected the `Gi1/0/1` description to `Trunk-to-MKT01` (`CM-0001`). Verified live.
- **Not changed (gated):** the cleartext SNMP community — redact *after* rotation (`CM-0023`).

### Session 1 — 2026-07-12 (operator)
**Notes:** Initial build from the guide; VLAN database + trunking.

- 🔴 **MAJOR** — Built the VLAN database + the MKT01 trunk (native 999) (`MC-0006`).
- 🟢 Normal — Set console `9600 8N1` and `exec-timeout 10`.
<!-- ▲▲▲ END EXAMPLE ▲▲▲ -->

### Session ‹n› — ‹YYYY-MM-DD› (‹who›)
**Notes:** ‹what you did this session, plainly›

- 🔴 **MAJOR** — ‹…› (`MC-####`) — verified `‹command›` (‹date›)
- 🟢 Normal — ‹…› (`CM-####`) — verified (‹date›)

## Related

[Build Guide (target state)](./Build-Guide.md) · [device README](./README.md) · [`Considerations`](./Considerations.md) · [`Changes/`](./Changes/) · [`Atlas-Workflow` §1 source priority](../../../../00-Atlas-Foundation/Governance/Atlas-Workflow.md#1-source-priority--read-this-first) · the rules: [`POL-0004`](../../../../00-Atlas-Foundation/Policies/POL-0004-Source-of-Truth.md) · [`POL-0006`](../../../../00-Atlas-Foundation/Policies/POL-0006-Evidence-and-Verification.md) · [`POL-0014`](../../../../00-Atlas-Foundation/Policies/POL-0014-Documentation-and-Knowledge-Management.md) · [Source-of-Truth router](../../../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md).
