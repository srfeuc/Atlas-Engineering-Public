# ADR-0029 — Drop FreeRADIUS: Network-Device Auth Consolidates on Windows NPS

| Item | Value |
|---|---|
| Status | **Accepted** — **amended 2026-07-27 (D7):** the NPS host is a **dedicated member server (`NPS01`)**, not the DC. See Change Log v1.1. |
| Governing Policy | POL-0010 |
| Scope | **Lab-02-Cisco-Core** |
| Date | 2026-07-24 (amended 2026-07-27) |
| Supersedes | The **FreeRADIUS half** of `ADR-0004` (the coexist decision). `ADR-0004`'s NPS half stands and expands. |
| Related | `ADR-0004` (NPS vs FreeRADIUS — coexist), `ADR-0028` (FGT01 direct LDAPS), `ADR-0021` (tiered identity / service-estate LDAPS), `ADR-0027` (AD CS — the "Windows PKI") |
| Evidence Status | **Decision** (operator, 2026-07-24; host amended 2026-07-27). The `NPS01` member server is **`Target`** until it is designated/renamed/domain-joined and the NPS role is installed. Decommission of any live FreeRADIUS instance is **`Target`** until confirmed on the device (see the Device-Confirmation handout). |

## Context

`ADR-0004` chose **coexistence**: FreeRADIUS on Pi01 for non-domain network devices (MKT01/SW01/1941) + NPS for domain machines — and it explicitly flagged that a **full consolidation onto NPS** would be "a deliberate migration project with its own change record," not a side effect. Since then the design moved on:

- **Pi01 is reduced to DNS + NTP only** (`Master-Build-Order` Phase 5) — FreeRADIUS was slated to leave it.
- **FGT01 already moved to direct LDAPS** (`ADR-0028`), off the RADIUS boundary entirely.
- The **FreeRADIUS host became unreconciled** across docs (ADR-0004 said Pi01; the SRV01 checklist said SRV01; the tracker's SRV01 line omitted it) — a `POL-0008` drift with no decision record behind it.

The operator has now made the call: **stop running FreeRADIUS; put all authentication on the Windows side** (NPS for RADIUS, LDAPS for the FortiGate, AD CS for certificates).

## Decision

**FreeRADIUS is retired. Network-device authentication consolidates on Windows NPS + AD CS.**

- **No FreeRADIUS** on Pi01, SRV01, or anywhere. Pi01 stays **DNS/NTP only**.
- **NPS runs on a dedicated domain member server, `NPS01`** (amended 2026-07-27, D7) — **not on a domain controller.** `NPS01` is a Windows member server in `OU=Servers,OU=Devices`, on **VLAN 20 (Servers)**, administered only from **PAW01**; its address is registered authoritatively in `IP-Addressing-Plan-VLSM` (`POL-0008` — proposed `10.20.0.12`, in the server range, *not* the `.2–.9` Tier-0 carve). It **reuses one of the existing spare Windows VMs** (designate → rename → domain-join → add the NPS role) — a role assignment, not a build-from-scratch.
- **Network devices that cannot domain-join (MKT01, SW01, 1941)** become **RADIUS clients of `NPS01`**. NPS validates their admin logins against **AD accounts** and returns the admin profile by AD group. *(The device is a RADIUS client / NAS — it does **not** join the domain; ADR-0004's "can't domain-join the device" concern does not block this.)*
- **FGT01 = direct LDAPS** to the DC (`ADR-0028`).
- **Certificates** — including the **NPS server cert** (**PEAP/EAP-TLS**, now a **build-time** item on `NPS01`, no longer deferred) and the DC LDAPS cert — come from **AD CS** (`ADR-0027`).

One boundary, one stack: identity and its RADIUS/LDAPS/PKI all on the Windows/AD side.

## Alternatives Considered

- **Keep coexistence (`ADR-0004` as-is).** Rejected — leaves two RADIUS stacks, an unreconciled host, and a service Pi01 was meant to shed. The operator wants a single auth stack.
- **FreeRADIUS + `ntlm_auth` (domain-join a Linux host).** Rejected — `ADR-0004`'s blast-radius argument still holds, and there's no longer a Linux box that should carry it (Pi01 is DNS/NTP-only; SRV01's role is nginx-CRL/Kea/Oxidized/rsyslog).
- **NPS on a domain controller.** Rejected (D7, 2026-07-27). Microsoft's [NPS best-practices guidance](https://learn.microsoft.com/en-us/windows-server/networking/technologies/nps/nps-best-practices) actually *recommends* the DC — *"to optimize NPS authentication and authorization response times and minimize network traffic, install NPS on a domain controller."* But that is a **performance** optimization whose benefit is negligible at lab scale, and it runs against Microsoft's own **role-separation / DC-hardening** posture — the same rule this estate already applies to the CAs (`ADR-0027`: *"Neither CA goes on DC01/DC02 … keep DC and CA blast radii apart"*). `NPS01` authorizes admin access to the core routing/switching/firewall and holds their RADIUS shared secrets; co-locating that on a DC widens the DC's attack surface for no real gain. A dedicated member server keeps the blast radii apart and doubles as the host for the deferred member-server LAPS tests. **Security posture over a lab-irrelevant performance note.**

## Consequences

- **`ADR-0004` gets a backward note:** its FreeRADIUS half is superseded here; its NPS half stands and now covers network devices too.
- **A new host enters the estate: `NPS01`** — a dedicated Windows member server (VLAN 20 Servers, `OU=Servers,OU=Devices`, PAW01-administered). Its **address is assigned in `IP-Addressing-Plan-VLSM`** (`POL-0008`: one home for addresses — add the `NPS01` row there, proposed `10.20.0.12`; the Tier-0 `.2–.9` carve stays **CAs+DCs only**, so NPS sits in the server range). `NPS01` is the subject of the previously **deferred member-server LAPS tests** (D7). A new **east-west flow** is implied — MKT01/SW01/1941 → `NPS01` **UDP 1812/1813 (RADIUS)** — and keeping NPS *out* of the `.2–.9` Identity micro-zone is deliberate, so that zone stays LDAPS/Kerberos/DNS-only (`Atlas-East-West-Allowed-Flows-Matrix`, flow #9).
- **Docs to reconcile (each its own tracked change, `POL-0003`):** `SRV01/Build-Guide.md` (remove FreeRADIUS from the role list), `SRV01/Build-Checklist.md` (drop the FreeRADIUS section + its `033` `testing123` warning becomes moot), `POL-0013` (identity fallback → "NPS/the DC," not "RADIUS/Pi01"), **CIS-Hardening `1941`/`SW01`/`MKT01`** (Pass-2 "RADIUS/TACACS+ → SRV01/NPS" → **NPS on `NPS01`**; MKT01's "AD-LDAPS admin" and SW01's "Pi01 = RADIUS host" are stale), `Master-Build-Order` Pass-2 (✅ done 2026-07-24), `Atlas-Service-Architecture` / `Lab-02-Device-Role-Assignments` (SRV01 + NPS role rows), `304` (FreeRADIUS reference), `IP-Addressing-Plan-VLSM` (add the `NPS01` row), `Atlas-East-West-Allowed-Flows-Matrix` (RADIUS → `NPS01`), and the **AD-CS build guide** (its "NPS server cert … later" line → build-time).
- **Availability tradeoff:** network-device *admin* auth now depends on **`NPS01` (the RADIUS service) and the DC (AD) both being reachable** — a two-host chain. Mitigate with the **local break-glass admin** already required on every device (Pass-1 standard) and, later, a **second NPS + DC** (Microsoft recommends **at least two NPS servers** for fault tolerance). This is the tradeoff `ADR-0004` named; it is accepted deliberately here, now spanning the member server as well as the DC.
- **Sequencing:** NPS for network devices is **Pass-2**, gated on AD CS (the **`NPS01` server cert**) — unchanged in order. Password-based RADIUS (PAP/MS-CHAPv2) works without the cert; **cert-based PEAP/EAP-TLS waits on the `NPS01` cert from AD CS, which is now a *build-time* item** — it was "deferred" in the AD-CS guide under the old `ADR-0004`; that guide's "NPS server cert … when NPS is stood up" line is promoted to build-time (its own tracked change).
- 🔴 **Decommission:** any **live FreeRADIUS instance** must be stopped/removed and its **RADIUS shared secrets rotated out** of every network device that pointed at it. **Confirm where FreeRADIUS actually runs before decommissioning** (Device-Confirmation handout) — do not assume.

## Review Trigger

- If single-DC NPS availability proves painful, revisit adding a **second NPS/DC**.
- If a genuine **non-Windows RADIUS** need reappears (a device NPS can't serve), re-open — but that is a new decision, not a silent reversal.

## Change Log

| Version | Changes |
|---|---|
| 1.1 | **Amended 2026-07-27 (D7).** NPS host moved **from the DC to a dedicated member server, `NPS01`** (VLAN 20 Servers, `OU=Servers,OU=Devices`, PAW01-administered), reusing a spare Windows VM. Rationale: role separation / DC blast-radius (mirrors `ADR-0027`'s CA-off-the-DC rule); Microsoft's NPS-on-a-DC **performance** recommendation logged as the rejected alternative. **NPS PEAP/EAP-TLS server cert reclassified deferred → build-time.** Availability caveat + break-glass retained (the chain now spans `NPS01` **and** the DC; noted Microsoft's ≥2-NPS fault-tolerance guidance). Added the `NPS01` estate/addressing + east-west-flow (RADIUS UDP 1812/1813) consequences, and added the CIS-Hardening docs, the IP plan, the east-west matrix, and the AD-CS guide to the reconcile list. The v1.0 decision (drop FreeRADIUS; consolidate on NPS + AD CS) is unchanged. |
| 1.0 | Accepted 2026-07-24. **Drop FreeRADIUS; consolidate network-device auth on Windows NPS** (the consolidation `ADR-0004` anticipated as "its own change record"). MKT01/SW01/1941 → NPS (RADIUS clients, AD-validated); FGT01 → direct LDAPS (`ADR-0028`); certs from AD CS (`ADR-0027`); Pi01 stays DNS/NTP-only. Supersedes `ADR-0004`'s FreeRADIUS half; lists the docs to reconcile and the decommission/secret-rotation step (gated on device confirmation). |
