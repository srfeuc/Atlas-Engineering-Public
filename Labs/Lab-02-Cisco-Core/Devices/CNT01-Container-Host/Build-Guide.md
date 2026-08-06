---
Title: CNT01 — Container Host Build Guide (designed gated stub)
Path: Labs/Lab-02-Cisco-Core/Devices/CNT01-Container-Host
Status: 📋 PROPOSED / gated — a designed stub (`ADR-0043`). NOT executed. Platform + purpose decided (2026-07-30); gate + phase outline + section hooks now; click-by-click detail authored once the #19 ADR is written + the manual first build. Mirrors `Roadmap.md`.
Version: 0.2
Date: 2026-07-30
---

# CNT01 — Container Host Build Guide

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 proposed, ⬜ not built).** This is a **designed gated stub** (`ADR-0043`), **not** a placeholder: it gives the **gate**, a **phase outline**, and the standard **section hooks** now. The **platform (hybrid, Linux-primary) + primary purpose (estate git/CI, #19) are decided**, but because the **`ADR-0048` / Backlog #19 estate-capability ADR** (self-host-vs-GitHub · GitOps model · runner placement) is not yet written and placement is not firmed (#20), there are **no invented click-steps** — each section notes where the detail lands. Work **phase by phase, each behind its 🔴 gate**.

## 🔴 GATE-0 — the #19 estate-capability ADR + placement
**GATE — do not start until:** the **Backlog #19 estate-capability ADR** is written (**self-host-vs-GitHub · the GitOps model · where the CI runner lives**) · placement + IP firmed (**Backlog #20** / IP plan). *Platform ✅ decided (hybrid, Linux-primary + Windows slice); primary purpose ✅ decided (estate self-hosted git/CI).* *(See `Considerations.md`.)*

## Phase 1 — Provision the Linux host (outline)
- **Service-setup:** provision the Linux git/CI host on **PVE02/EQR6 (always-on)**; install Linux; set **VLAN 20** `10.20.0.19` *(proposed)*, DNS/time from **DC01**.
- *Detail authored once the #19 ADR + #20 placement are settled.*

## Phase 2 — Docker/Podman runtime (outline)
- **Service-setup:** install + configure **Docker/Podman** (the primary Linux runtime); verify with a hello-world container.
- *Detail authored at the manual first build.*

## Phase 3 — Certificate-application (hook)
- Enrol a **TLS cert from ICA01** (SAN = the git/CI service FQDN, e.g. Gitea/GitLab) and trust the ICA chain; bind it to the published git/CI endpoints.
- *Detail authored when the git/CI service FQDN + bind mechanism are pinned.*

## Phase 4 — Service-setup (git/CI + runner) (hook)
- Stand up self-hosted **Gitea/GitLab + registry**; register a **CI runner**; build the **GitOps pipeline for device configs** (Oxidized → git → PR → deploy) referencing **NetBox** as source-of-truth; add **Ansible/Terraform pipelines** (Phase 10).
- *Detail authored per the #19 ADR (self-host posture, GitOps model, runner placement).*

## Phase 5 — Automation-onboarding (`ADR-0048`) (hook)
- Capture the build as IaC (compose / Ansible / the CI runner config) → `../Automation/` (idempotent, after the manual pass).
- *Detail authored once there is a manual build to capture.* See `Automation/README.md`.

## Phase 6 — Windows-container slice (hook)
- Spin up the **Windows Server containers slice** on **PVE01/R410** for the **AZ-800/801 "containers" objective** (addr/placement → #20).
- *Detail authored when the Windows-slice scope/placement is firmed (#20).*

## Related
- `Roadmap.md` · `Build-Checklist.md` · `Considerations.md` · `README.md`. `ADR-0045` (this host) · `ADR-0043` (gated-stub discipline) · `ADR-0048` (automation — estate-capability half, Backlog #19) · ICA01 (TLS). Cert map: `Atlas-Academy/AZ-800-801-Windows-Server-Hybrid-Lab-Map.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.2 | 2026-07-30. Decisions baked in (operator 2026-07-30): platform=hybrid; purpose=estate git/CI (#19). GATE-0 reframed to the #19 estate-capability ADR (self-host-vs-GitHub · GitOps model · runner placement) + placement (#20), not the platform. Phase outline reflects the hybrid/git-CI design (Linux host → Docker/Podman → Gitea/GitLab + ICA01 TLS → git/CI + runner + GitOps → automation → Windows-container slice). Kept a designed gated stub — detail still deferred until the #19 ADR + the manual first build. |
| 0.1 | 2026-07-30. Created — designed gated stub (`ADR-0043`): 🔴 GATE-0 (platform + placement/IP + tenant) → provision → runtime → Certificate-application / Service-setup (first tenant) / Automation-onboarding section hooks, each marked "detail authored when the platform/scope is decided." No invented click-steps (`ADR-0045` open). |
