---
Title: 1941 Build Record — CCNA Lab Overlay (Router-on-a-Stick + ACLs)
Path: Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router
Status: 🟡 EVIDENCE SKELETON — the verified reality of the CCNA overlay, read back from the device. **Not yet run** — every row is 🟡/📋 until the operator pastes the real `show` output. A Record outranks its Guide; the device outranks the Record (Charter Rule 13).
Version: 0.1
Date: 2026-08-05
Scope: Lab-02
---

# 1941 — Build Record: CCNA Lab Overlay (Router-on-a-Stick + ACLs)

<!-- provenance -->
> **Lab-02 · Cisco-Core (🟢 ACTIVE)** — Host: **1941** — Role (overlay): temporary inter-VLAN (router-on-a-stick) + ACLs, `ADR-0023` Option A.

> **What this is.** The **verified state** of the CCNA overlay — read back from the device, not intended. This **outranks the [Build Guide](./Build-Guide-CCNA-Lab-Overlay.md)** ([source priority](../../../../00-Atlas-Foundation/Governance/Atlas-Workflow.md)). If the device disagrees with this page, **the device wins** (Rule 13) — reconcile this page to it. 🔴 **This overlay is temporary** — on lab teardown it is reverted to the production Option B build ([`Build-Guide.md`](./Build-Guide.md)); record the revert as the final session here.

## On this page
1. [Document control](#1-document-control) — status + verification dates
2. [Platform](#2-platform) — identity
3. [Verified state](#3-verified-state) — subinterfaces + ACLs, device-verified
4. [Known deviations](#4-known-deviations) — the overlay *is* a deviation from production
5. [Change log](#5-change-log)

---

## 1. Document control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | 🟡 **Not yet applied** — authored 2026-08-05; no device read-backs captured |
| Version | 0.1 |
| Applies To | Atlas 2.0 · the physical 1941 (IOS 15.5(3)M4) |
| Last Live Verification | — (pending first run) |
| Last Reconciled | 2026-08-05 (authored against the [overlay Build-Guide](./Build-Guide-CCNA-Lab-Overlay.md)) |

> **"Verified" is a claim about a date** (Charter Rule 14). Until *Last Live Verification* is set, treat every row below as **target, not reality**.

---

## 2. Platform

| Item | Value |
|---|---|
| Hardware | Cisco 1941 (ISR G2) |
| OS / firmware | IOS 15.5(3)M4 universalk9 — verify live: `show version` |
| Live hostname | `1941` — 🟡 confirm `show version` |
| Overlay interface | `Gi0/0` re-purposed from the MKT01 transit /30 to the **SW01 trunk** (lab-session-only) |
| Base config | inherited from the production [`Build-Guide.md`](./Build-Guide.md) Stage 1/1b (SSH, named admin, vty) — unchanged by this overlay |

---

## 3. Verified state

> **One table per subsystem the overlay actually adds.** Every row: the **observed value** + the **read-back command** + the **date**. Nothing is ✅ until its output is pasted. **Never invent output.** The **`SS-##` screenshot slots** in the [overlay Build-Guide](./Build-Guide-CCNA-Lab-Overlay.md) §6 land here — attach each capture beside the row it proves (SS-01 trunk · SS-02/03/04 subinterfaces+routing · SS-05–07 standard ACL · SS-08/09 extended ACL · SS-10/11 revert).

### Subinterfaces — router-on-a-stick gateways (`show ip interface brief | include 0/0`)

| Subinterface | VLAN | Gateway / mask (target) | Observed state | Read-back | Verified |
|---|---|---|---|---|---|
| `Gi0/0.999` | 999 (native) | no IP | 🟡 | `show run interface Gi0/0.999` | 📋 |
| `Gi0/0.10` | 10 | `10.10.0.1 /27` | 🟡 | `show ip int brief` | 📋 |
| `Gi0/0.20` | 20 | `10.20.0.1 /26` | 🟡 | `show ip int brief` | 📋 |
| `Gi0/0.30` | 30 | `10.30.0.1 /28` | 🟡 | `show ip int brief` | 📋 |
| `Gi0/0.40` | 40 | `10.40.0.1 /28` | 🟡 | `show ip int brief` | 📋 |
| `Gi0/0.50` | 50 | `10.50.0.1 /25` | 🟡 | `show ip int brief` | 📋 |
| `Gi0/0.60` | 60 | `10.60.0.1 /27` | 🟡 | `show ip int brief` | 📋 |
| `Gi0/0.70` | 70 | `10.70.0.1 /28` | 🟡 | `show ip int brief` | 📋 |
| `Gi0/0.80` | 80 | `10.80.0.1 /28` | 🟡 | `show ip int brief` | 📋 |
| `Gi0/0.90` | 90 | `10.90.0.1 /26` | 🟡 | `show ip int brief` | 📋 |

> Intent home for the addresses: [`IP-Addressing-Plan-VLSM`](../../Architecture/IP-Addressing-Plan-VLSM.md) (`POL-0008`). Paste the real `up/up` + address read-back to flip each 📋→✅.

### Inter-VLAN routing (`show ip route connected`)

| Check | Expected | Observed | Verified |
|---|---|---|---|
| Connected route per VLAN subnet | 10.10–10.90 subnets directly connected | 🟡 | 📋 |
| VLAN 50 → VLAN 20 gateway ping (pre-ACL) | reply | 🟡 | 📋 |

### ACLs (`show access-lists`)

| ACL | Applied | Intended behaviour | Observed (+ match counts) | Verified |
|---|---|---|---|---|
| `10` (standard, numbered) | `Gi0/0.20` out | deny VLAN 70 → VLAN 20; permit rest | 🟡 | 📋 |
| `CLIENTS-TO-SERVERS` (extended, named) | `Gi0/0.50` in | VLAN 50 → VLAN 20 on 443 only; deny other; permit rest | 🟡 | 📋 |

> Capture `show access-lists` **before and after** the test pings so the **match-count delta** is the evidence (`POL-0001`).

---

## 4. Known deviations

The overlay **is** a deliberate, sanctioned deviation from the production build — recorded so it isn't "corrected" away.

| Item | Target (production, Option B) | Current (overlay, Option A) | Action |
|---|---|---|---|
| Inter-VLAN routing | MKT01 owns the VLAN `.1` gateways | 🟡 1941 holds each `10.<vlan>.0.1` on a subinterface | **Temporary** — revert on lab teardown (Guide §7); recorded on [`Considerations`](./Considerations.md) |
| `Gi0/0` role | MKT01 transit `/30` (`10.255.255.5`) | 🟡 SW01 trunk (all VLANs) | Revert re-cables + re-addresses `Gi0/0` |
| OSPF adjacency w/ MKT01 | FULL | 🟡 down while `Gi0/0` is the SW01 trunk | Restored on revert (`show ip ospf neighbor` FULL) |
| East-west filtering | MKT01 firewall (flows matrix) | 🟡 practiced via IOS ACLs on the 1941 | Teaching only — production policy stays on MKT01 |

---

## 5. Change log

> Newest session on top. Each = a dated block: a **Notes** line, then the changes tagged 🔴 MAJOR / 🟢 Normal / 🟡 Unverified. Always state what you did **not** change and why.

### Session 1 — ‹YYYY-MM-DD› (operator) — 🟡 PENDING FIRST RUN
**Notes:** ‹Apply the overlay Build-Guide on the 1941 — trunk from SW01, subinterface gateways, the two ACL exercises. Paste the `show` read-backs here and flip §3 rows 📋→✅.›

- 🟡 **Unverified** — Router-on-a-stick subinterfaces `Gi0/0.10–.90` + native `.999` (target: §3). Read back with `show ip interface brief` + `show ip route connected`.
- 🟡 **Unverified** — Standard ACL `10` (VLAN70⇏VLAN20) and extended `CLIENTS-TO-SERVERS` (VLAN50→VLAN20:443). Read back with `show access-lists` (+ match-count delta).
- **Not changed (by design):** the production routes-only config is **not** removed while overlaying — `Gi0/0` is simply re-purposed for the session; the base hardening (SSH/vty/admin) is untouched.

*(On teardown, add a final session recording the §7 revert: subinterfaces + ACLs removed, `Gi0/0` back to the MKT01 `/30`, OSPF FULL — then this Record closes.)*

## Related

[Overlay Build Guide (target)](./Build-Guide-CCNA-Lab-Overlay.md) · teaching ⭐ [`Set-Up-the-1941-for-the-CCNA-Lab`](../../../../Atlas-Academy/Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md) · production [`Build-Guide.md`](./Build-Guide.md) · [`Considerations.md`](./Considerations.md) · [`Diagnostics.md`](./Diagnostics.md) · [`Atlas-Workflow` §1 source priority](../../../../00-Atlas-Foundation/Governance/Atlas-Workflow.md) · [`POL-0004`](../../../../00-Atlas-Foundation/Policies/POL-0004-Source-of-Truth.md) · [`POL-0006`](../../../../00-Atlas-Foundation/Policies/POL-0006-Evidence-and-Verification.md).
