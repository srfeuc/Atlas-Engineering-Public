---
Title: RDS01 — Considerations (open risks & decisions)
Path: Labs/Lab-02-Cisco-Core/Devices/RDS01-Remote-Desktop
Status: 🟠 LIVING — open risks + unsettled decisions for the RD Session Host.
Version: 1.2
Date: 2026-07-30
---

# RDS01 — Considerations (open risks & decisions)

## Open gates
- 🔴 **CALs before the 120-day grace.** RD Session Host runs ungraced for 120 days, then refuses connections until a **license server + CALs** are in place. Procure CALs and activate licensing in Phase 2 — don't let the grace clock run out mid-lab.
- 🔴 **Tier-0 must not be reachable via RDS.** RDS is the *standard-user* path; the Tier-0 admin path is **PAW01** (`ADR-0021`). Exclude Tier-0 accounts from the collection + the CAP, and **prove the denial** (the negative test in acceptance) — a remote-access host that can reach T0 collapses the tier model.

## Standing risks (design)
- 🟡 **Remote-access attack surface (the Security silo).** RD Gateway is an authenticated entry point. Keep it TLS-only (ICA01 cert), deny-by-default via NPS CAP/RAP, session-locked-down by GPO, and **internal-only this era** — external-facing publishing is a separate, later gate (FGT01 + a hardened published gateway).
- 🟡 **Authorization belongs on NPS01, not the host.** RD Gateway CAP/RAP live on **NPS01** (`ADR-0029`) so the estate has one policy home. Building policies locally on RDS01 drifts from that model — resist it.
- 🟡 **Single session host = no HA.** One session host this era; if it's down, published desktops are unavailable (acceptable for the lab). A **Connection Broker + second host** (farm) is a future phase if load/HA warrants.

## Decided (operator 2026-07-30)
- ✅ **Host placement → PVE02 / EQR6 (always-on).** RDS is user-facing — availability wins over the R410 spin-up model. Lands in `ADR-0036` v1.2's always-on tier; estate index updated. 🟡 **Residual (→ #20):** the session host's RAM adds to the always-on stack (the 64 GB EQR6 prereq) — size it in the capacity pass.
- ✅ **RD Gateway + RD Web Access → included this build** (not deferred). Adds the TLS front-door + browser launch + the CAP/RAP-on-NPS remote-access learning now. CAP/RAP stays on **NPS01** (`ADR-0029`); TLS from **ICA01** (`ADR-0027`).
- ✅ **VLAN → 20 (Servers).** RDS is a **service workload consumed by clients** — the IP-plan's own rationale ("a service reached by clients belongs in the Servers zone", the NetBox pattern), not a client endpoint. Clients reach it via **flows-matrix flow #3** (Clients→Servers:443+app) + the new **RD-Gateway flow**. VLAN 50 is for client *workstations* (the `ADR-0042` fleet), not the session host.
- ✅ **Services map added to `README.md`** *(#22 audit, Standard v1.7 / Backlog #27)* — session-host+collection · RD Gateway/Web · Licensing · TLS listener, all ⬜ (not built). Edges already labelled (RDS01 was the v1.6 exemplar) — Services-map-only.
- ✅ **No separate `Networking-Build-Guide.md`** *(#22 — appliances point, hosts get new)* — standard tagged-VLAN-20 VM.

## Open decisions (need a call / ADR when reached)
- 🟡 **Per-user vs per-device CALs** — pick the CAL model to match how the lab's standard users connect (roaming users → per-user).
- 🟡 **Address `10.20.0.17`** is proposed — added to the IP-plan register as 📋 proposed; authoritative in `IP-Addressing-Plan-VLSM` → NetBox (`POL-0008`).

## Related
- `Roadmap.md` · `Build-Checklist.md` · `ADR-0029` (NPS CAP/RAP) · `ADR-0027` (ICA01 TLS cert) · `ADR-0021` (tiering — RDS ≠ Tier-0) · Backlog #20 (sizing/placement) · `../../Operations/Device-Hardening-Standard.md`.

## Change Log
| Version | Changes |
|---|---|
| 1.2 | 2026-07-30. **#22 audit:** Services map backfilled into `README.md` (Standard v1.7 / Backlog #27, all ⬜); recorded no separate `Networking-Build-Guide.md` (VLAN-20 VM). Edges were already labelled (v1.6 exemplar). |
| 1.1 | 2026-07-30. **Three open decisions resolved (operator):** placement → **PVE02/EQR6 always-on** (residual RAM sizing → #20); **RD Gateway/Web included** this build; **VLAN → 20 (Servers)** (client-reached service workload, the NetBox pattern; flow #3 + a new RD-Gateway flow). Remaining open: CAL model, proposed address. |
| 1.0 | 2026-07-30. Created — open gates (CALs-before-grace, Tier-0 separation), standing risks (remote-access surface, NPS-owned authorization, single-host no-HA), and open decisions (VLAN-20-vs-client-facing placement, Gateway/Web include-vs-defer, CAL model, proposed IP). |
