---
Title: CNT01 — Roadmap (gated build path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/CNT01-Container-Host
Status: 📋 PROPOSED / gated — the build path is a designed stub. Platform + purpose decided (2026-07-30); nothing builds before GATE-0 (the Backlog #19 estate-capability ADR + placement). Mirrors `Build-Checklist.md` (`POL-0001`).
Version: 0.2
Date: 2026-07-30
---

# CNT01 — Roadmap (gated build path + connections)

> **How to read this.** Each row is 📋 proposed and behind a 🔴 gate. **Needs** = healthy-first; **Unblocks** = what proceeds. The platform (hybrid, Linux-primary) + primary purpose (estate git/CI) are **decided**; what remains before build is the **Backlog #19 estate-capability ADR** + placement/sizing (#20). Detail: `Build-Guide.md`.

## The build path (in order)

### 🔴 GATE-0 — write the #19 estate-capability ADR (before ANYTHING)
- [ ] 🔴 **Write the Backlog #19 estate-capability ADR** — **self-host-vs-GitHub · the GitOps model · where the CI runner lives** — plus **firm placement/sizing (#20)**. *Platform ✅ decided (hybrid, Linux-primary + Windows slice); primary purpose ✅ decided (estate self-hosted git/CI).* *Why:* the git/CI capability is committed but its estate-capability shape (self-host posture, GitOps model, runner placement) and firm placement/IP are still owed — nothing builds until the #19 ADR is written. → `00-Atlas-Foundation/Decisions/ADR-Index.md`.

### Phase 1 — Provision the Linux host (📋 proposed)
- [ ] 📋 **Provision the Linux git/CI host** on **PVE02/EQR6 (always-on)** — the estate's internal source-of-truth + CI must stay up. Install Linux; **VLAN 20 (Servers)**, `10.20.0.19` *(proposed — IP plan owns)*; DNS/time from **DC01**. *Needs:* GATE-0. *Unblocks:* the runtime. → `../../Architecture/IP-Addressing-Plan-VLSM.md`. *Cert:* AZ-400 / CCNA Dom-6 (host + automation base).

### Phase 2 — Docker/Podman runtime (📋 proposed)
- [ ] 📋 **Install + configure Docker/Podman** (the primary Linux runtime). *Needs:* Phase 1. *Unblocks:* hosting the git/CI stack. *Cert:* AZ-400 · general container/Docker skills.

### Phase 3 — Gitea/GitLab + registry + ICA01 TLS (📋 proposed)
- [ ] 📋 **Stand up self-hosted Gitea/GitLab + registry**; enrol a **TLS cert from ICA01** (SAN = the git/CI FQDN) and trust the ICA chain. *Needs:* Phase 2 + ICA01 issuing. *Unblocks:* the estate source-of-truth. *Cert:* PKI-issued service cert (Security+ PKI · AZ-400).

### Phase 4 — CI runner + GitOps pipeline (📋 proposed)
- [ ] 📋 **Register a CI runner** and stand up the **GitOps pipeline for device configs** (**Oxidized → git → review/PR → deploy**), referencing **NetBox** as source-of-truth. *Needs:* Phase 3. *Unblocks:* the estate git/CI + GitOps capability. *Cert:* AZ-400 (CI/CD) · CCNA Dom-6 (automation).

### Phase 5 — Ansible/Terraform pipelines (Phase 10 Automation/IaC) (📋 proposed)
- [ ] 📋 **Stand up Ansible/Terraform pipelines** on the CI runner (the estate-capability half of `ADR-0048`, Build-Order **Phase 10**). *Needs:* Phase 4. *Unblocks:* estate-wide IaC. *Cert:* AZ-400 · CCNA Dom-6.

### Phase 6 — Windows-container slice (R410) (📋 proposed)
- [ ] 📋 **Spin up the Windows Server containers slice** on **PVE01/R410** for the **AZ-800/801 "containers" objective** (addr/placement → #20). *Needs:* GATE-0 (#20 sizing). *Unblocks:* the AZ-800/801 objective. *Cert:* AZ-800/801 (→AZ-802 2026-09-30).

### Phase 7 — Automation capture (`ADR-0048`)
- [ ] 📋 **Capture the build as IaC** — compose / Ansible / the CI runner config → `Automation/` (idempotent, after the manual first pass). *Needs:* Phase 5. → `Automation/README.md`.

## Connections at a glance
| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | a PVE host → SW01 → MKT01 (VLAN-20 gw) | placement/transit (proposed) |
| ⬆ Depends on | DC01 | DNS/53 · NTP/123 (domain-join for the Windows slice) |
| ⬆ Depends on | ICA01 | TLS certs for the git/CI endpoints |
| ⬆ Depends on | NetBox | source-of-truth the rendered configs reference |
| ⬆ Depends on | Oxidized / SRV01 | device-config feed into git |
| ⬇ Depended on by | git/CI capability + GitOps consumers | git/SSH+HTTPS · CI → PR → deploy · HTTPS/443 |

## Certification alignment (learning lens)
| CNT01 stage | Exercises (exam objective) | Cert |
|---|---|---|
| Linux host provision | server build / OS install / automation base | AZ-400 · CCNA Dom-6 |
| Docker/Podman runtime | container runtime / Docker | AZ-400 · general container skills |
| Gitea/GitLab + ICA01 TLS | self-hosted git, PKI-issued service cert | AZ-400 · Security+ (PKI) |
| CI runner + GitOps (Oxidized → git → PR → deploy) | CI/CD, GitOps, network automation | AZ-400 · CCNA Dom-6 |
| Ansible/Terraform pipelines | IaC pipelines (Phase 10) | AZ-400 · CCNA Dom-6 |
| Windows-container slice | Windows Server containers objective | AZ-800/801 (→AZ-802 2026-09-30) |

> Sequences at Build-Order **Phase 10** (Automation/IaC — the estate-capability half of `ADR-0048`).

## Related
- `Build-Checklist.md` · `Build-Guide.md` · `Considerations.md` · `README.md`. Estate index: `../../Service-Server-Build-Plan.md`. Build order: `../../Operations/Build-Order-and-Dependencies.md`. `ADR-0045` (this host) · `ADR-0036` (placement) · `ADR-0048` (automation/CI — the estate-capability half, Backlog #19) · `ADR-0044` (enterprise-first).

## Change Log
| Version | Changes |
|---|---|
| 0.2 | 2026-07-30. Decisions baked in (operator 2026-07-30): platform=hybrid; purpose=estate git/CI (#19). GATE-0 reframed to writing the Backlog #19 estate-capability ADR (self-host-vs-GitHub · GitOps model · runner placement) + placement/sizing (#20), not the platform. Build path reframed around the Linux git/CI stack (EQR6 always-on → Docker/Podman → Gitea/GitLab + registry + ICA01 TLS → CI runner + GitOps Oxidized→git→PR→deploy → Ansible/Terraform pipelines → Windows-container slice on R410 → automation capture). Cert alignment → AZ-400 + CCNA Dom-6 primary (+ AZ-800/801 for the Win slice). Sequences at Build-Order Phase 10. |
| 0.1 | 2026-07-30. Created — gated build path for the proposed CNT01 container host (from `ADR-0045`): 🔴 GATE-0 (platform Win/Linux + placement/IP + tenant scope) → provision → runtime → registry/ICA01 TLS → first tenant (git/CI candidate, Backlog #19) → automation onboarding. All 📋 proposed / gated. Cert alignment AZ-800/801. |
