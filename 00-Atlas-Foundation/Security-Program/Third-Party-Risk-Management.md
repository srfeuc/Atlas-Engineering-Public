---
Title: Atlas Third-Party / Vendor Risk Management
Path: 00-Atlas-Foundation/Security-Program
Status: Draft — covers Security+ SY0-701 5.3, and the cyber-insurance attestation under 5.4. Grounded in 301/305 vendors + the MSP scenario.
Version: 1.0
Date: 2026-07-20
Framework: NIST CSF 2.0 GV.SC (Supply Chain) · CIS Controls v8 15 (Service Provider Management) · Security+ 5.3
---

# Atlas Third-Party / Vendor Risk Management

The domain the repo had least of — because a homelab has no vendors. But `301`/`305` invented several, and the MSP scenario is built on customer agreements, so this is all writable against material you already have. It also carries the **cyber-insurance attestation** `305` names but never worked out.

## 1. Why Atlas has third parties (the hooks already in the repo)

| Third party (from the scenario) | Relationship | Risk it carries |
|---|---|---|
| **Order-portal / e-commerce provider** (`305`, DMZ, PCI) | Processes card payments | PCI-DSS scope; the one backend call it may make is the flow attackers want |
| **AtlasERP / SQL vendor** | The business stops if it stops (`301`) | Availability, patch cadence, support SLA |
| **CAD software vendor** (Engineering) | Licensed, non-standard | Licensing, update trust |
| **SCADA / OT vendor** (`305`, the 2019 box) | *Vendor sign-off required to patch* | 🔴 The un-patchable box — vendor controls the only patch path |
| **Facilities: badge + HVAC vendor** | IP-connected building controls | The "we forgot Facilities was on the network" entry point |
| **MSP customers A & B** (roadmap MSP scenario) | *Atlas as the provider* | The other side of every agreement below (SLA/NDA/MSA to the tenant) |
| **Cyber-insurer** | Underwrites the risk | The attestation questionnaire (§4) — the real forcing function |
| **Hardware suppliers** | e.g. the console cable | 🔴 **Supply chain** — the counterfeit-Prolific cables are a real supply-chain integrity finding |

## 2. The vendor-risk lifecycle (Security+ 5.3)

### 2a. Assessment (before you trust them)
For each vendor, gather proportionate evidence:

- **Penetration testing** results / **evidence of internal audits** / **independent assessments** (SOC 2 Type II, ISO 27001, a PCI AoC for the payment provider).
- **Right-to-audit clause** in the contract — the ability to verify, not just take their word.
- **Supply-chain analysis** — where do *their* components come from (the counterfeit-chip lesson: trust the channel, not the label).
- A **security questionnaire** (§3) sized to the data class they touch (`305`): a payment processor gets the full PCI battery; the HVAC vendor gets a short one.

### 2b. Selection (choosing)
- **Due diligence** — financial stability, references, security posture, breach history.
- **Conflict of interest** — disclose and manage (the SQL consultant who also sells you the license).

### 2c. Agreement (contract) — pick the right instrument (see §3 cheat sheet).

### 2d. Monitoring (ongoing — trust decays)
- **Continuous, not one-time.** Re-assess on a cadence and on trigger (their breach, a scope change, contract renewal).
- Track SLA performance; re-collect attestations annually; watch for the vendor's own incidents.

## 3. Agreement-types cheat sheet (Security+ 5.3 — memorize these)

| Term | What it is | When Atlas uses it |
|---|---|---|
| **SLA** — Service-Level Agreement | Promises measurable service levels (uptime %, response time) + remedies | ERP support uptime; **Atlas → MSP customers** (99.x% uptime) |
| **MOU** — Memorandum of Understanding | Non-binding statement of intent; frames a relationship | Early talks with a new integrator |
| **MOA** — Memorandum of Agreement | More formal than an MOU; roles/responsibilities, can be binding | A cost-share arrangement between two parties |
| **MSA** — Master Service Agreement | The umbrella contract; terms that govern all future work | The **master** with the MSP customer or the ERP vendor |
| **SOW / WO** — Statement of Work / Work Order | The specific project under an MSA — scope, deliverables, timeline, price | "Migrate Customer A's AD" under the MSA |
| **NDA** — Non-Disclosure Agreement | Confidentiality of shared information | Any vendor touching `AtlasHR`/CAD/customer data |
| **BPA** — Business Partner(s) Agreement | Governs a partnership/joint venture; shared responsibilities & liability | A channel/reseller partnership |

> Mnemonic for the exam: **MOU = intent (soft)** → **MOA = agreement (firmer)** → **MSA = the master contract** → **SOW/WO = the actual job under it**. **SLA = the numbers you promise**; **NDA = keep it secret**; **BPA = we're partners**.

## 4. The cyber-insurance questionnaire — a worked attestation (bridges 5.3 → 5.4)

`305` names this as *"the renewal questionnaire every real company now signs… you attest you have them, and a claim can be denied if you didn't."* Here it is, worked against Atlas's real state — which doubles as a compliance self-assessment and a gap list.

| Insurer asks | Control | Atlas honest answer today | Gap → backlog |
|---|---|---|---|
| **MFA on remote access & privileged accounts?** | MFA | ⚠️ Partial — RADIUS/802.1X exists; MFA not deployed | Add MFA (VPN, admin) |
| **Network segmentation between environments?** | Segmentation | ✅ Designed — east-west matrix + Book 11 (MKT01) | Build & verify (the per-rule plan) |
| **EDR / anti-malware on endpoints?** | Endpoint | ⚠️ Planned — Wazuh (Book 5) not built | Stand up Wazuh |
| **Tested backups, off-site, restore-proven?** | Backup/DR | ⚠️ CA restore-tested; off-site copy **missing** (`049` Phase 5) | 🔴 Close Phase 5 (`POL-0005`) |
| **Documented incident response plan?** | IR | ✅ *Now* — `POL-0009 (Incident Response)` + playbook | Adopt via ADR |
| **Security awareness training + phishing testing?** | Awareness | ✅ *Now* — the Awareness Program | Run the first campaign |
| **Privileged access management / tiering?** | PAM | ⚠️ Designed — `ADR-0021` Tier 0/1/2 | Enforce; find the Reeves DAs |
| **Timely patching / vulnerability management?** | Patch | ⚠️ WSUS planned; the OT 2019 box is un-patchable | Compensating control (segmentation) |
| **Logging/monitoring with retention?** | Logging | 🔴 Weak — no off-box SIEM; SW01 clock unsynced (`CM-0030`) | Book 5 + fix the clock |
| **Offboarding removes access promptly?** | Offboarding | 🔴 The five ghosts say no | Offboarding SOP + HR-vs-AD gap report |

> 🔴 **The point of the exercise:** attesting "yes" to a control you don't have is how a claim gets denied *after* the incident. The honest column above is a **risk register and a remediation backlog in one** — and every "⚠️/🔴" ties to work already on your roadmap. This is compliance monitoring (5.4: attestation, due care, consequences) done for real.

## 5. Rules of engagement (for any assessment you commission or perform)

Whether you hire a pentester or run your own SPAN/IDS test: a written **RoE** — scope (which IPs/zones), timing, what's off-limits (the OT line — a test that stops production *is* the incident), data handling, and a point of contact. Same discipline as the phishing-campaign RoE.

## Related

`305` (compliance obligations, the vendors, cyber-insurance) · `301` (the ERP/CAD/OT vendors, MSP customers) · `Atlas-Roadmap-Advanced-Scenarios` (MSP scenario = the agreement hooks) · `POL-0001` (audit/attestation) · `POL-0005` (the backup answer on the questionnaire) · the IR playbook (vendor-breach response) · the CompTIA Domain-5 coverage map.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-20. First third-party risk artifact. Vendor inventory from 301/305 (order portal, ERP, CAD, SCADA, Facilities, MSP customers, insurer, hardware supply chain); the 5.3 lifecycle (assessment/selection/agreement/monitoring); an agreement-types cheat sheet (SLA/MOU/MOA/MSA/SOW/NDA/BPA) with a memory aid; the cyber-insurance questionnaire worked against Atlas's honest state as a combined attestation + gap backlog (bridging 5.4); and rules-of-engagement. |
