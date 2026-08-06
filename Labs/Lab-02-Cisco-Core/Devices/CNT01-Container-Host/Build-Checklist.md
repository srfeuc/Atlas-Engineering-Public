---
Title: CNT01 — Build Checklist (container host)
Path: Labs/Lab-02-Cisco-Core/Devices/CNT01-Container-Host
Status: 📋 PROPOSED / gated — line-item target, all ⬜. Platform + purpose decided (2026-07-30); nothing starts before GATE-0 (the Backlog #19 ADR + placement). Mirrors `Roadmap.md` (`POL-0001`).
Version: 0.2
Date: 2026-07-30
---

# CNT01 — Build Checklist (container host)

<!-- provenance -->
> 🔴 **NOT STARTED — gated on the Backlog #19 estate-capability ADR + placement (#20).** CNT01's **platform (hybrid, Linux-primary) + primary purpose (estate git/CI, #19) are decided**, but **nothing is built.** Do not tick anything until GATE-0 clears. **Acceptance gate:** the **#19 ADR written** (self-host-vs-GitHub · GitOps model · runner placement) · placement/IP firmed (#20). Every `[ ]` → `[x]` only with a command + its output once built (`POL-0001`). Detail: `Build-Guide.md`.

## 🔴 GATE-0 — write the #19 estate-capability ADR + firm placement
- [x] ✅ **Platform decided (hybrid)** — Linux (Docker/Podman) primary + a Windows Server containers slice (operator 2026-07-30). *(decision only — build still ⬜.)*
- [x] ✅ **Primary purpose decided (estate git/CI, #19)** — self-hosted Gitea/GitLab + GitOps + Ansible/Terraform pipelines + CI runner (operator 2026-07-30). *(decision only — build still ⬜.)*
- [ ] ⬜ **Write the Backlog #19 estate-capability ADR** — self-host-vs-GitHub · the GitOps model · where the CI runner lives.
- [ ] ⬜ **Firm placement + IP (#20)** — Linux git/CI → EQR6 (always-on), VLAN 20 `10.20.0.19` *(proposed)*; Windows slice → R410; sizing firmed by Backlog #20 / the IP plan.

## Phase 1 — Provision the Linux host
- [ ] ⬜ Provision the Linux git/CI host on **PVE02/EQR6 (always-on)**; install Linux; **VLAN 20** `10.20.0.19` *(proposed)*; DNS/time from DC01.
- **🎯 Gate:** host up, addressed, DNS/time resolving.

## Phase 2 — Docker/Podman runtime
- [ ] ⬜ Install + configure Docker/Podman (the primary Linux runtime).
- **🎯 Gate:** runtime healthy; a hello-world container runs.

## Phase 3 — Gitea/GitLab + registry + ICA01 TLS
- [ ] ⬜ Stand up self-hosted Gitea/GitLab + registry; enrol a **TLS cert from ICA01** for the git/CI endpoints; trust the ICA chain.
- **🎯 Gate:** the git/CI endpoint serves over the ICA01 cert (no trust warning).

## Phase 4 — CI runner + GitOps pipeline
- [ ] ⬜ Register a CI runner; stand up the **GitOps pipeline for device configs** (Oxidized → git → PR → deploy), referencing NetBox as source-of-truth.
- **🎯 Gate:** a config change flows Oxidized → git → PR → deploy per the flows matrix; nothing else exposed.

## Phase 5 — Ansible/Terraform pipelines (Phase 10)
- [ ] ⬜ Stand up Ansible/Terraform pipelines on the CI runner (the estate-capability half of `ADR-0048`, Build-Order Phase 10).
- **🎯 Gate:** an idempotent pipeline run completes against a target.

## Phase 6 — Windows-container slice (R410)
- [ ] ⬜ Spin up the Windows Server containers slice on **PVE01/R410** for the AZ-800/801 objective (addr/placement → #20).
- **🎯 Gate:** a Windows container runs; the AZ-800/801 objective is exercised.

## Phase 7 — Automation onboarding (`ADR-0048`)
- [ ] ⬜ Capture the build as IaC (compose / Ansible / CI) → `Automation/` (idempotent, after the manual pass).

## Failure modes (pre-empt at GATE-0)
- 🔴 **Building before the #19 ADR** → an ungrounded git/CI capability (wrong self-host posture / GitOps model / runner placement). Write the #19 ADR first.
- 🔴 **Inventing an IP/placement** → drift from the IP plan (`POL-0008`). `10.20.0.19` is 📋 proposed; the IP plan owns it; final sizing → #20.
- 🔴 **Self-signed / wrong-SAN git/CI cert** → broken trust. Use an ICA01 cert with the correct SAN.

## Change Log
| Version | Changes |
|---|---|
| 0.2 | 2026-07-30. Decisions baked in (operator 2026-07-30): platform=hybrid; purpose=estate git/CI (#19). GATE-0 now marks platform + primary purpose as ✅-in-decision (build still ⬜); remaining GATE items = write the #19 ADR + firm placement/IP (#20). Phases reframed around the Linux git/CI stack (Docker/Podman → Gitea/GitLab + registry + ICA01 TLS → CI runner + GitOps → Ansible/Terraform pipelines) + the Windows-container slice (R410). All build steps kept ⬜. |
| 0.1 | 2026-07-30. Created to the standard — all ⬜, opening on the "not started — gated on `ADR-0045`" note + the GATE-0 acceptance gate. Phased (GATE-0 → provision → runtime → registry/ICA01 TLS → first tenant → automation) with the pre-GATE-0 failure modes. Placement/IP 📋 proposed. |
