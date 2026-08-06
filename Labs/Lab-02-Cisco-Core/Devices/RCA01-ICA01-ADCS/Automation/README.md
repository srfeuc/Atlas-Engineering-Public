---
Title: RCA01/ICA01 — Automation (scripts + how-tos)
Path: Labs/Lab-02-Cisco-Core/Devices/RCA01-ICA01-ADCS/Automation
Status: 📋 Designed stub (`ADR-0048`). Authored *after* the manual first pass. 🔴 The offline-root ceremony is deliberately NOT automated (air-gapped by design). 🟡 until each artifact runs idempotently.
Version: 0.1
Date: 2026-07-29
---

# RCA01 / ICA01 — Automation (`ADR-0048`)

> **The rule (`ADR-0048`).** This folder holds the PKI's automation **slice** — how-tos + scripts — authored **after** the manual first pass (you run the two-tier ceremony by hand to learn AD CS; *then* you make the repeatable parts repeatable). Runnable shared code = the estate capability (`Operations/Automation/` + self-hosted git, Backlog #7/#19). 🟡 until idempotent (`ADR-0041`).

> 🔴 **The hard "does-NOT-automate" boundary — the offline root.** The **RCA01 offline-root ceremony** (CAPolicy.inf → standalone root → sign ICA01 → export → power off + air-gap) is **manual and air-gapped by design** (`ADR-0027`/`ADR-0009`). It must **never** be scripted onto a networked box or folded into a pipeline — the whole point of an offline root is that its signing happens by hand, disconnected. Automation applies only to the *online, routine, issuance* side (ICA01).

## Planned automation (designed, phased — `ADR-0048` tooling ladder)

| Task | Tool | What it automates | What it does NOT automate |
|---|---|---|---|
| **Certificate templates as code** | PowerShell (`PSPKI`) / ADSI in git | Version + reproduce the ICA01 template set (EKUs, enrolment perms, SAN policy) so a rebuilt ICA01 restores identically | The **ESC1–ESC8 hardening review** (the security judgment — do it by hand, it's a PenTest+ learning target) |
| **Autoenrollment** | GPO (declarative) | Push autoenroll to DC/NPS/member computers via GPO | Deciding *which* templates autoenrol (policy) |
| **CRL publish / renewal checks** | scheduled PowerShell | Verify the CRL is fresh + reachable on SRV01 (`pki.atlas.lab`); alert before expiry | The **Part-4 revocation acceptance gate** (prove-a-revoked-cert-reads-revoked — run by hand, `ADR-0009`) |
| **Consumer cert enrolment** | per-host autoenroll / PowerShell | Enrol/renew LDAPS, RADIUS, TLS certs as hosts build | The first manual enrolment on each host (the learning) |
| **ICA01 rebuild-from-root** | documented runbook (semi-manual) | Speed a rebuild: reinstall role → generate request → (sign on RCA01 **by hand**) → install | The offline signing step — always manual |

## How this fits the estate
- **Phase alignment:** after the manual two-tier ceremony (Build-Guide Parts 1–4). Estate sequencing: Build-Order **Phase 10** (`ADR-0048`).
- **Secrets:** CA passphrases / KRA keys → **Vaultwarden** (`ADR-0009`), never in git; the offline-root key never leaves its air-gapped encrypted media.
- **Cert anchor:** templates/autoenroll-as-code (70-742 Ch8 · AZ-800/801), PSPKI/PowerShell (AZ-800/801), pipeline hygiene (AZ-400-adjacent).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Created as the designed `Automation/` stub for the PKI (`ADR-0048`) — templates-as-code, autoenroll GPO, CRL freshness checks, consumer enrolment, and a rebuild runbook, each with its learning boundary. 🔴 Foregrounds the **offline-root-stays-manual** rule (air-gapped by design). Filled after the manual ceremony (Build-Guide Parts 1–4). |
