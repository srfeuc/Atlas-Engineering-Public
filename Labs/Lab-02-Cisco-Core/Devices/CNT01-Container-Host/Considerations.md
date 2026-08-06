---
Title: CNT01 — Considerations (decided + open decisions & gates)
Path: Labs/Lab-02-Cisco-Core/Devices/CNT01-Container-Host
Status: 📋 PROPOSED / gated — platform + purpose decided (2026-07-30); the Backlog #19 estate-capability ADR + placement remain the gate. Nothing is built.
Version: 0.3
Date: 2026-07-30
---

# CNT01 — Considerations (decided + open decisions & gates)

> CNT01 is an **`ADR-0045` proposal** whose **platform + primary purpose are now decided (operator 2026-07-30)**. This doc records what's decided and keeps the **open-questions register** — the remaining items *are* GATE-0. Nothing is `✅`-able as built yet (`POL-0001`).

## Decided (operator 2026-07-30)
- ✅ **Platform = HYBRID.** **Linux (Docker/Podman) is the PRIMARY runtime** — it hosts the estate's self-hosted git + CI/CD stack — **plus a Windows Server containers slice** to exercise the AZ-800/801 "containers" objective. (Was "Windows vs Linux — undecided"; now both, Linux-primary.)
- ✅ **Primary purpose = the estate's self-hosted Git + CI/CD capability** — the estate-capability half of `ADR-0048` (**Backlog #19**): self-hosted **Gitea/GitLab** as the internal source-of-truth + CI/CD host; **GitOps for device configs** (Oxidized → git → review/PR → deploy); **Ansible/Terraform pipelines** (Phase 10 Automation/IaC); a **CI runner**. Enterprise-real: internal git ≠ public GitHub. (Was "tenant TBD; git/CI a candidate"; now the committed purpose.)
- 📋 **Placement (proposed → Backlog #20).** The **Linux git/CI runtime → PVE02/EQR6 (always-on)** (the estate's source-of-truth + CI must stay up); the **Windows-container AZ slice → PVE01/R410 (spin-up)**. Final sizing → #20. Address 📋 **VLAN 20 (Servers)** `10.20.0.19` (the Linux git/CI runtime's proposed addr; the Windows-slice addr/placement → #20) — the IP plan owns it → `../../Architecture/IP-Addressing-Plan-VLSM.md` (`POL-0008`).
- ✅ **Dedicated host = JUSTIFIED (resolved).** CNT01 hosts the estate git/CI — a real always-on capability — so its own host/folder is warranted. (Was open.)
- ✅ **Services map added to `README.md`** *(#22 audit, Standard v1.7 / Backlog #27)* — self-hosted Git · CI runner/pipelines · GitOps delivery · Windows-container slice, all 📋 (proposed; GATE-0 = the #19 ADR). Edges already labelled (v1.6) — Services-map-only. **No separate `Networking-Build-Guide.md`** (proposed VLAN-20 VM; addressing is a #20/IP-plan residual, not a bring-up procedure).

## Open gates (block the build)
- 🔴 **GATE-0 — the Backlog #19 estate-capability ADR + placement.** Platform + primary purpose are **decided**; what remains is writing the **#19 ADR** (self-host-vs-GitHub · the GitOps model · where the CI runner lives) and firming **placement/sizing (#20)**. These must be settled before Phase 1 → `00-Atlas-Foundation/Decisions/ADR-Index.md`.

## Open decisions
- 🔴 **The Backlog #19 estate-capability ADR — the real remaining gate.** **self-host-vs-GitHub · the GitOps model · where the CI runner lives.** This is the estate-capability half of `ADR-0048`; it must be written before build.
- 📋 **Placement / sizing → Backlog #20.** Linux git/CI → EQR6 (always-on); Windows slice → R410 (spin-up). Firm sizing + the Windows-slice addr → #20. The IP plan owns the firm values.
- 📋 **Windows-container-slice scope / placement.** The extent of the AZ-800/801 Windows-container slice (what it runs, its addr, R410 sizing) → #20.

## Notes
- Silo: ⚪ **Platform** (proposed). Build order: sequences at Build-Order **Phase 10** (Automation/IaC — the estate-capability half of `ADR-0048`) → `../../Operations/Build-Order-and-Dependencies.md`.
- Cert alignment: **AZ-400 (DevOps) + CCNA Dom-6 (automation)** primary, **plus AZ-800/801** for the Windows-container slice (→AZ-802 2026-09-30).

## Related
- `README.md` · `Roadmap.md` · `Build-Checklist.md` · `Build-Guide.md`. `ADR-0045` (this host) · `ADR-0036` (placement) · `ADR-0048` (automation/CI, Backlog #19) · `ADR-0044` (enterprise-first). Backlog #19 (git/CI estate-capability ADR) / #20 (placement/sizing). Decisions: `00-Atlas-Foundation/Decisions/ADR-Index.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.3 | 2026-07-30. **#22 audit:** Services map backfilled into `README.md` (Standard v1.7 / Backlog #27, all 📋); recorded no `Networking-Build-Guide.md` (proposed VLAN-20 VM). |
| 0.2 | 2026-07-30. Decisions baked in (operator 2026-07-30): platform=hybrid; purpose=estate git/CI (#19). Added a "Decided" section (platform hybrid Linux-primary + Windows slice; purpose estate self-hosted git/CI #19; placement proposed EQR6/R410 → #20; dedicated-host justified). Shrank Open decisions to the #19 estate-capability ADR (self-host-vs-GitHub · GitOps model · runner placement), placement/sizing #20, and the Windows-slice scope. GATE-0 reframed (platform + purpose no longer open). |
| 0.1 | 2026-07-30. Created — the `ADR-0045` open decisions front-and-centre: GATE-0 (machine unscoped); platform Win-vs-Linux (headline); placement/IP/OS proposed → #20; tenant scope open (candidate: Backlog #19 git/CI); dedicated-host-vs-fold-onto-existing. Grouped Open gates / Open decisions. All 📋 / 🔴. |
