---
Title: WAC01 — Considerations (open risks & decisions)
Path: Labs/Lab-02-Cisco-Core/Devices/WAC01-Windows-Admin-Center
Status: 🟠 LIVING — open risks + unsettled decisions for the WAC gateway.
Version: 1.1
Date: 2026-07-30
---

# WAC01 — Considerations (open risks & decisions)

## Decided (operator 2026-07-30)
- ✅ **Placement → PVE02 / EQR6 (always-on).** A management surface must be reachable when you need to administer the estate → the always-on tier (`ADR-0036` v1.2). **Supersedes `ADR-0045`'s PVE01 note.** 🟡 Residual (→ #20): RAM on the always-on stack (light, but count it).
- ✅ **VLAN → 10 (Management).** WAC is a **Tier-0 admin/management surface**, so it belongs on the **management plane** with the other admin surfaces (operator: *"those belong on VLAN 10"*; the IP plan's own VLAN-10 examples include "the PAW/admin"). This **exercises `ADR-0045`'s VLAN review trigger** and **overrides its VLAN-20 default.** Can carve a dedicated OOB/mgmt network later if wanted.
- ✅ **Azure Arc → gated stub now** (`ADR-0043`) — the hybrid on-ramp is designed (gate + outline) but not built until Phase 11.
- ✅ **Services map added to `README.md`** *(#22 audit, Standard v1.7 / Backlog #27)* — WAC gateway console · estate WinRM management · Arc on-ramp, all ⬜. Edges already labelled (v1.6) — Services-map-only. **No separate `Networking-Build-Guide.md`** (VLAN-10 mgmt VM; the VLAN-10-vs-20 rule-text tension below is a **#20 IP-plan residual**, not a bring-up procedure — routed, not absorbed into this docs pass).

## Open gates
- 🔴 **Tier-0 exposure is the whole risk.** WAC can reach every DC + member server. Access must be **PAW01-only** (WAC roles keyed to a Tier-0 group **and** a network ACL: 443 → WAC01 only from PAW01, deny+log). The **negative test** (a non-PAW host is refused) is a required acceptance gate.
- 🔴 **Delegation model.** Managing nodes over WinRM can pull Tier-0 creds onto/through WAC. Prefer **Kerberos**; avoid **unconstrained CredSSP**; scope any delegation. Settle before onboarding the DCs.

## Standing risks / open decisions
- 🟡 **VLAN-10-vs-20 rule tension (flag for #20/#22 reconciliation).** The IP plan states two things that pull opposite ways for WAC: (a) its VLAN-10 examples list "the PAW/admin" (→ VLAN 10, WAC is a Tier-0 admin surface — **the chosen basis**); (b) its "VLAN 10 vs 20" rationale says *service VMs / apps an admin uses* (like NetBox) go on **VLAN 20**, and WAC is a web-app service VM. We chose **VLAN 10** on the admin-surface basis (operator). **Reconcile the rule text with this Tier-0-admin-surface exception in the #20/#22 pass.**
- 🔴 **PAW-VLAN drift (relevant + should reconcile together).** The IP plan **text** puts "the PAW/admin" on **VLAN 10**, but the estate index (`Service-Server-Build-Plan`) places **PAW01 on VLAN 20 tagged (T0)**. WAC's VLAN should be **settled together with PAW's** (operator leans VLAN 10 for both admin surfaces). Flagged for the #20 placement reconciliation (`POL-0008`).
- 🟡 **Gateway vs desktop mode** — settled to **gateway mode** (`ADR-0045`); a desktop install on PAW01 was rejected (co-locating muddies the tier boundary). Recorded, not re-open.
- 🟡 **Address `10.10.0.5`** is proposed — added to the IP-plan register as 📋 proposed; **deconflict against the other VLAN-10 hosts** (Pi01, SW01/PVE01 mgmt) when the register is firmed. Authoritative in `IP-Addressing-Plan-VLSM` → NetBox (`POL-0008`).

## Related
- `Roadmap.md` · `Build-Checklist.md` · `ADR-0045` (this host) · `ADR-0027` (ICA01 cert) · `ADR-0021` (tiering) · `ADR-0036` (placement) · Backlog #20 (placement/sizing) / #22 (audit) · `../../Operations/Device-Hardening-Standard.md`.

## Change Log
| Version | Changes |
|---|---|
| 1.1 | 2026-07-30. **#22 audit:** Services map backfilled into `README.md` (Standard v1.7 / Backlog #27, all ⬜); recorded no `Networking-Build-Guide.md` (VLAN-10 mgmt VM). The VLAN-10-vs-20 rule-text tension + PAW-VLAN drift are left as **#20 IP-plan residuals** (routed, not absorbed into this docs pass). |
| 1.0 | 2026-07-30. Created — decided (placement → PVE02/EQR6; **VLAN 10** as a Tier-0 admin surface, overriding `ADR-0045`'s VLAN-20 default; Arc gated stub), open gates (Tier-0 exposure → PAW-only + negative test; delegation model), and the flagged tensions (the IP-plan VLAN-10-vs-20 rule vs the admin-surface exception; the **PAW-VLAN drift** to reconcile together in #20/#22; proposed address deconfliction). |
