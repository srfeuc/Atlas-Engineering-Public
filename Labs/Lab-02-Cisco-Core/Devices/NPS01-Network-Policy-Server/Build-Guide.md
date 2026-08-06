---
Title: NPS01 — Network Policy Server (RADIUS) Build Guide
Path: Labs/Lab-02-Cisco-Core/Devices/NPS01-Network-Policy-Server
Status: 📋 Target design — the phased, gated rebuild contract (`ADR-0043`); phases mirror `Roadmap.md` 1:1. NOT executed. Author live values + 📸 + gotchas at the bench (`POL-0001` — evidence = command + output).
Version: 0.2
Date: 2026-07-29
---

# NPS01 — Network Policy Server (RADIUS) Build Guide

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built)** — Host: **NPS01** — Role: Windows **NPS (RADIUS)** for network-device admin auth (`ADR-0029`). **This is RADIUS, not PKI** — the CAs (RCA01 + ICA01) are `Devices/RCA01-ICA01-ADCS/`; NPS01 only *consumes* a server cert from ICA01. Work **phase by phase, each behind its 🔴 GATE**; secrets → Vaultwarden (`POL-0002`), never here.

> 🔵 **Why a member server, not the DC (`ADR-0029` D7):** role separation + smaller DC blast radius (NPS holds device RADIUS secrets + gates core admin). 🔴 **Break-glass:** auth = NPS01 **and** DC; keep a local admin on every client.

## Phase 0 — Gate 🔴
**GATE — do not start until:** DC01 healthy (AD + DNS) · VLAN-20 reachability · clock synced. NPS validates against AD and the host domain-joins — none of this works without the DC.

## Phase 1 — Host stand-up 🔴
**GATE:** Phase 0 ✅. Placement PVE02/EQR6 (always-on).
- **Service-setup:** rename a spare Win Server 2025 (Desktop Experience) → **NPS01** → reboot → **domain-join `atlas.lab`** → move the computer object to `OU=Servers,OU=Devices` → `gpupdate /force` (server baseline applies).
- **LAPS** on the local admin (the deferred member-server LAPS test, D7).
- 📸 `Get-ComputerInfo` (domain + OU); the LAPS password retrieval from AD (do **not** capture the value).

## Phase 2 — NPS role + AD registration 🔴
**GATE:** Phase 1 ✅ (domain-joined).
- **Service-setup:** `Install-WindowsFeature NPAS -IncludeManagementTools` → NPS console → **Register server in Active Directory** (adds NPS01 to **RAS and IAS Servers**).
- 📸 `Get-WindowsFeature NPAS` = Installed; the "registered in AD" confirmation.

## Phase 3 — RADIUS clients + policies 🔴
**GATE:** Phase 2 ✅.
- **Service-setup:** add RADIUS clients **MKT01 · SW01 · 1941** (strong unique shared secrets → **Vaultwarden**); create **network policies** mapping **AD group → device admin privilege level**, **deny-by-default** last.
- 📸 the client list (names only), the policy order (deny-last).

## Phase 4 — Certificate application (from ICA01) 🔴
**GATE:** AD CS ceremony complete + CRL published (SRV01) + revocation gate passed.
- **Certificate-application:** enrol NPS01 for a **RAS-and-IAS-Server** cert from **ICA01** (the AD-CS guide's previously-deferred "NPS server cert"). Needed for **PEAP/EAP-TLS**; password RADIUS (PAP/MS-CHAPv2) works without it.
- 📸 the cert in the machine store (Enhanced Key Usage = Server Auth).

## Phase 5 — Hardening + acceptance 🔴
**GATE:** Phases 1–3 ✅ (cert optional per client).
- Hardening pass (`POL-0007`).
- 🔴 **Prove break-glass** — stop NPS; confirm local admin still logs into MKT01/SW01/1941; restart NPS.
- 🎯 **Acceptance (closes F14):** a **real device → NPS login accepted** with the correct privilege level (event logged in NPS) **and** an **unknown user rejected**. 📸 the accept + the reject events.

## Phase 6 — Automation-onboarding (`ADR-0048`) 🔴
**GATE:** the manual build proven.
- Capture DSC (NPS install/config) + **policy-as-code** in `Automation/` (idempotent). Secrets from the vault at run time, never committed.

## Deferred / later
- **2nd NPS** for fault tolerance (`ADR-0029` review trigger; Microsoft ≥2-NPS).
- **802.1X** wired/wireless + **FortiAP WPA2-Enterprise** (register K6); **RDS01 Gateway CAP/RAP** (Batch A).

## Related
- `Roadmap.md` (phases) · `Build-Checklist.md` (line-item + gates) · `Diagnostics.md` (verify) · `Build-Record.md` (as-built) · `ADR-0029` · `../RCA01-ICA01-ADCS/` (the CA that issues the cert) · `../../Architecture/IP-Addressing-Plan-VLSM.md` · `../../Architecture/Atlas-East-West-Allowed-Flows-Matrix.md` (flow #14) · `../../Operations/Device-Hardening-Standard.md` (break-glass) · `Atlas-Academy/Command-Library/PowerShell-Tier0.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.2 | 2026-07-29. **Rebuilt to the phased, gated Build-Guide doc-type** (`ADR-0043`) as part of the DC-template replication: phases mirror `Roadmap.md` with a 🔴 GATE header + standard **Service-setup / Certificate-application / Automation-onboarding** sections + 📸 capture points; added the `ADR-0048` Phase-6 automation-onboarding. Preserves the v0.1 role/identity/dependency facts. |
| 0.1 | 2026-07-27. Created as a placeholder per `ADR-0029` (D7) — role (RADIUS for MKT01/SW01/1941), the NPS-vs-CA distinction, host identity, the AD-CS server-cert dependency, the deferred member-server LAPS test, and a build/verify outline. |
