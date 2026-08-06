---
Title: Atlas Academy — Concepts Index ("why it works")
Path: Atlas-Academy/Concepts
Status: 🟢 LIVING index (D6 adopt-Academy / `ADR-0032` concept layer). Each entry is a concept taught through a real Atlas artifact. Fully-written modules are ✅; seeded targets are 🟡 stub (title + why + Atlas example + source — flesh out opportunistically). The **Lab-01 §3 recurring themes** (the estate's hard-won disciplines) become Concept modules here under the mentality/machine split (`ADR-0053`). (v1.4, 2026-08-04: +the two standards-flagged modules — **Encryption & PKI** (⭐ nailed as the golden reference Concept shape, #30-F) + **Out-of-Band Recovery** (#31); wired into the `STD-0004`/`STD-0003` Learn-it sections. v1.5, 2026-08-04: +three policy why-layer modules — **Secrets & Credential Custody** (POL-0002) · **A Backup Is Not a Backup Until a Restore Proves It** (POL-0005/0013) · **Risk as a Living Register** (POL-0012). v1.6, 2026-08-04: +**Hardening from a Tested Baseline** (POL-0007, fleshes the SCT/W3 stub) · **The Credential Layer — PSOs, LAPS & gMSA** (STD-0001) · **AGDLP — Granting Rights to Groups, Not People** (STD-0002).)
Version: 1.6
Date: 2026-08-04
---

# Atlas Academy — Concepts ("why it works")

<!-- provenance -->
> **Book 9 — Atlas Academy.** The third kind of doc (`Academy/README`): Build Guides answer *how do I build this*, Labs answer *can I demonstrate this*, **Concepts answer *why does this work and how does it fit*.** Every module references a **real Atlas artifact** by name — never a generic tutorial. Format per module (`Academy/README`): **The Concept · The Atlas Example · What Went Wrong · How to Explain This in an Interview.**

> **Status (D6):** Atlas Academy is **adopted** as the estate's "why it works" layer — ✅ **D6 ACCEPTED by the operator, 2026-07-28**. This page + `Tiered-Admin-Model.md` are the first concept modules; the deep verify commands live in `../Command-Library/`. Device `Diagnostics.md`/`Troubleshooting.md` pages link **up** into Academy; Academy doesn't duplicate their commands.

## Marker convention
✅ full module written · ⭐ golden reference module (the canonical Concept shape, `ADR-0053` 4-part format) · 🟡 seeded stub (title + why + Atlas example + source; flesh out opportunistically) · 📋 planned.

## Modules

### ✅ Tiered administration — `Tiered-Admin-Model.md`
The three-tier blast-radius model taught through Atlas's `t0/t1/t2-seth` accounts, AGDLP groups, Protected Users, the PAW, and the 7d deny-logon GPOs. The B2 one-pager. → `Concepts/Tiered-Admin-Model.md`.

### ✅ Windows logon scripts & drive mapping — `Windows-Logon-Scripts-and-Drive-Mapping.md`
How `net use` logon scripts map departmental + home drives, taught through the operator's real `BATlogin.txt` (N:/P:/S: shares + the `%username%` home drive) — plus the modern **GPP Drive Maps** replacement. Anchored to **FS01** + AGDLP. → `Concepts/Windows-Logon-Scripts-and-Drive-Mapping.md`.

### ✅ Identity-aware vs zone/subnet firewall policy (FSSO) — `Identity-Aware-vs-Zone-Firewall-Policy.md`
Why a firewall rule's source can be an **address** (zone/subnet) or a **user/group** (FSSO / User-ID), why real networks run **both** layered, and what you lose without the identity layer — taught through Atlas's zone-based flows matrix (MKT01/FGT01) + the **proposed** FGT01 FSSO lab (K3). The Network **N4** module; the build is a Backlog item. → `Concepts/Identity-Aware-vs-Zone-Firewall-Policy.md`.

### ✅ Proxmox VM migration & host bring-up (EQR6/PVE02) — `Proxmox-VM-Migration-and-Host-Bring-Up.md`
Standing up the second hypervisor (Beelink EQR6) and migrating the always-on tier off the R410, taught through the real `ADR-0036` v1.2 topology move — dependency order, backup-as-restore-test (PBS), and why a **DC** can't be moved like a file server (USN rollback, VM-GenerationID, the `CM-0012` clock reason). Virtualization **V1**; the migration is 📋 planned. → `Concepts/Proxmox-VM-Migration-and-Host-Bring-Up.md`.

### ✅ Provisioning a device from a config file (Ansible + IaC) — `Ansible-IaC-Device-Provisioning.md`
The smallest end-to-end version of the `ADR-0048` "build a device from a config file" vision — Terraform provisions a VM on Proxmox (or Hyper-V for AZ-802), Ansible configures the role, and **idempotency** (empty diff on re-run) is the gate. Anchored to CNT01 (#19 git/CI + GitOps) + the MKT01/SW01 policy-as-code sketches. Automation **A1**; the pipeline is 📋 planned. → `Concepts/Ansible-IaC-Device-Provisioning.md`.

### ✅ A completed command is not evidence (read the value back) — `A-Completed-Command-Is-Not-Evidence.md`
The estate's **most-repeated (7×+) and most expensive** discipline, taught through the real frozen Lab-01 incidents where a command *ran cleanly and was still wrong*: `MC-0001` (a silent `set admin-server-cert` found only by `get`, not `show`), `MC-0002` (a clean `openssl ca` sign log for a cert with an **empty SAN** — the golden-template incident), `CM-0030` (an `ntp server` config line while `show ntp status` said `stratum 16`). The exit code / success log / config line are all *claims*; the runtime read-back is the *evidence*. The first of the **Lab-01 §3 recurring themes** (Discipline **D1**) and the "why" the `Confirm-a-Config-Change-Actually-Took` + `Read-the-Cert-Not-the-Sign-Log` Playbooks link up to. → `Concepts/A-Completed-Command-Is-Not-Evidence.md`.

### ⭐ ✅ Encryption & PKI in Atlas — `Encryption-and-PKI-in-Atlas.md` — **golden reference**
Why the estate's crypto is what it is: the device-verified SSH hardening (CTR-only ciphers, the DH-2048 floor, the documented SHA1-MAC ceiling), the two-tier AD CS PKI (offline **RCA01** → issuing **ICA01**, and the deliberate `AlternateSignatureAlgorithm=0` choice so non-Windows relying parties can validate), and the frozen Lab-01 cert sagas (`MC-0001` get-not-show, `MC-0002` empty-SAN-after-clean-sign, the `ADR-0009`/`CM-0010` key-custody scars). The why-layer flagged by [`STD-0004`](../../00-Atlas-Foundation/Standards/STD-0004-Encryption.md). **⭐ This module is the canonical Concept shape (`ADR-0053` 4-part format) — cut new Concepts to it.** → `Concepts/Encryption-and-PKI-in-Atlas.md`.

### ✅ Out-of-Band Recovery — `Out-of-Band-Recovery.md`
Why the way back into a device is a control you build and prove on a *healthy* device before you need it: an out-of-band path doesn't depend on the thing that broke, an unneeded-looking fallback and a genuinely unneeded one are indistinguishable until the outage, and hardening deletes the way back in. Taught through the 1941 console break-glass (hardened over the console when SSH self-blocked), MKT01's Layer-2 MAC-WinBox path (`CM-0018`), the "retire it, it's inactive" near-miss (`ADR-0013`), and the honestly-deferred iDRAC (`CM-0012`/`ADR-0017`). The why-layer flagged by [`STD-0003`](../../00-Atlas-Foundation/Standards/STD-0003-Physical-Security.md). → `Concepts/Out-of-Band-Recovery.md`.

### ✅ Secrets & Credential Custody — `Secrets-and-Credential-Custody.md`
Why a secret in the wrong place is *burned, not hidden* — rotation (not deletion) is the only remedy that doesn't need anyone's cooperation; a rule with no mechanical control is a preference; a content scanner can't catch a shapeless passphrase (the filename was the signal). Taught through `CM-0014` (the passphrase committed in the same commit that shipped the runbook forbidding it), `CM-0010`/`ADR-0009` (rotate-before-backup + the missing destroy step), and the vault/paper/never-co-located custody rules. The why-layer behind [`POL-0002`](../../00-Atlas-Foundation/Policies/POL-0002-Secrets-and-Credentials.md). → `Concepts/Secrets-and-Credential-Custody.md`.

### ✅ A Backup Is Not a Backup Until a Restore Proves It — `A-Backup-Is-Not-a-Backup-Until-a-Restore-Proves-It.md`
Why a backup is a *claim* until a restore turns it into evidence; why the off-site copy is the one that matters (3-2-1); why RPO/RTO are measured in a drill and event-driven for a CA; and why the only drill worth running is one allowed to fail (rebuild-from-docs, `ADR-0011`). Taught through `049` (the one restore-tested backup — *"the moment the file becomes a backup"*), the `048` circular trap, `CM-0032`/`CM-0025`/`CM-0010`. The why-layer behind [`POL-0005`](../../00-Atlas-Foundation/Policies/POL-0005-Backup-and-Recovery.md) + [`POL-0013`](../../00-Atlas-Foundation/Policies/POL-0013-Business-Continuity.md). → `Concepts/A-Backup-Is-Not-a-Backup-Until-a-Restore-Proves-It.md`.

### ✅ Risk as a Living Register — `Risk-as-a-Living-Register.md`
Why an accepted risk is a *decision with a trigger*, not a shrug (*"an accepted risk with no review trigger is a forgotten one"*); why "no evidence" isn't "no problem"; why a gap isn't closed until the fix is *running*; and why a control you've never needed looks identical to one you don't need. Taught through `ADR-0009` (accept + triggers), `ADR-0013` (the invisible-fallback pattern), `ADR-0005`/`ADR-0017` (exception/deferral), and the Review-Flag-Register + gap-map. The why-layer behind [`POL-0012`](../../00-Atlas-Foundation/Policies/POL-0012-Risk-Management.md). → `Concepts/Risk-as-a-Living-Register.md`.

### ✅ Hardening from a Tested Baseline — `Hardening-from-a-Tested-Baseline.md`
Why you *import* a tested baseline (CIS · the Microsoft Security Baseline GPOs) and layer your own on top instead of hand-inventing settings; why "unused" is a decision you record (*"available is not a state"*); and why a hardening tick is a claim until a read-back proves it. Taught through the imported MS baseline GPOs (Stage 7a) + the `CIS-Hardening-*` device baselines and the frozen-Lab-01 scars `CM-0033` (five live undocumented ports on the *perimeter firewall*) / `CM-0015` / the five false ticks. The why-layer behind [`POL-0007`](../../00-Atlas-Foundation/Policies/POL-0007-Hardening-Baseline.md); folds in the seeded SCT-baselines (W3) target. → `Concepts/Hardening-from-a-Tested-Baseline.md`.

### ✅ The Credential Layer — PSOs, LAPS & gMSA — `The-Credential-Layer-PSOs-LAPS-and-gMSA.md`
Why the best password is one no human manages: length-first ASCII passphrases (the `£` that broke a recovery), a fine-grained policy (PSO) so one domain holds two standards, LAPS so every machine's local-admin (and the DC's DSRM) password is unique + escrowed, and gMSA so service accounts run on a password AD rotates and nobody knows. The credential-mechanics half of [`STD-0001`](../../00-Atlas-Foundation/Standards/STD-0001-Password-and-Authentication.md) (Tiered-Admin owns the blast-radius why). → `Concepts/The-Credential-Layer-PSOs-LAPS-and-gMSA.md`.

### ✅ AGDLP — Granting Rights to Groups, Not People — `AGDLP-Granting-Rights-to-Groups-Not-People.md`
Why authorization flows Accounts→Global→Domain-Local→Permission and never straight to a person (roles and resources change independently; a direct ACE leaves the directory and can't be audited); and why a tier boundary is *structured* when the groups exist but *enforced* only when the deny-logon GPOs are linked — the honest designed≠enforced gap. The authorization-model half of [`STD-0002`](../../00-Atlas-Foundation/Standards/STD-0002-Access-Control.md). → `Concepts/AGDLP-Granting-Rights-to-Groups-Not-People.md`.

## Seeded concept targets (register B3 / F29·F46 — the "uncovered concepts")

These are the concepts a reader hit without a "why" anchor. Each is seeded with its Atlas example + source; write the full module (using the 4-part format) as each topic comes up.

### Windows / identity

| # | Concept | Why it bites (the gap) | The Atlas example (real artifact) | Status |
|---|---|---|---|---|
| W1 | **FSMO roles** | "Which DC does what, and what breaks if one is down?" — five roles, single-holder, easily hand-waved. | DC01 holds all five (single-domain); the **PDC Emulator** is Atlas's authoritative **time source** (`ADR-0020`) and the target of `w32tm`. DC02 promotion is *replica*, not a second FSMO owner. | 🟡 stub |
| W2 | **DFSR / SYSVOL replication** | "How do GPOs actually reach the other DC?" — SYSVOL is replicated by DFSR; if it's broken, GPOs silently diverge. | The GPO baseline (Stage 7a, `Baseline-ADImport.ps1`) lives in SYSVOL; DC02 must replicate it. Verified via `dcdiag /test:sysvol` + `repadmin /replsummary` (see DC02 `Diagnostics.md`). | 🟡 stub |
| W3 | **Security Compliance Toolkit (SCT) baselines** | "Where do the 8 baseline GPOs come from and why import vs hand-set?" | The **MS Windows Server 2025 v2602 Security Baseline** imported as 8 GPOs (Stage 7a, device-verified) — baselines as a *tested starting point*, then Atlas layers Wave-A links + PSO on top. | ✅ **written** → [Hardening from a Tested Baseline](./Hardening-from-a-Tested-Baseline.md) |
| W4 | **VBS / Credential Guard** | "Virtualization-based security — what it protects and why it's gated." | GPO **Wave B** (VBS/CredGuard) is parked on a Proxmox `msinfo32` VBS check — VBS needs the hypervisor to expose the right CPU features; that's why it's a gate, not a checkbox. | 🟡 stub |
| W5 | **DSRM** | "Directory Services Restore Mode — the DC's break-glass, and why it's dangerous if static." | Atlas rotates the **DSRM password via Windows LAPS** (7c-DSRM, device-verified) so the DC recovery credential isn't a hand-recorded secret — retired the manual `POL-0002` DSRM record. | 🟡 stub |

### Network

| # | Concept | Why it bites (the gap) | The Atlas example (real artifact) | Status |
|---|---|---|---|---|
| N1 | **OSPF: learn vs originate (redistribute)** | "Why are MKT01's VLANs `O E2` on the 1941 instead of normal OSPF routes?" | MKT01 advertises its VLANs by **`redistribute=connected`** (they're *originated* as external LSAs), not by running OSPF on the user VLANs — because `passive` isn't a valid interface-template property in RouterOS 7.23.1 (see MKT01 `Troubleshooting`). OSPF stays on the transit /30 only. | 🟡 stub |
| N2 | **Dynamic ARP Inspection (DAI) + trust** | "Why does a VM on an isolated VLAN fail ARP until a static binding exists?" | SW01 DAI drops a host's gateway ARP on an untrusted access port unless there's an `ip source binding`; the **PVE01 trunk `Gi1/0/4` is a DAI-trusted port**. Bindings are generated from NetBox (Phase 4), not hand-typed. | 🟡 stub |
| N3 | **RouterOS v7 specifics** | "MikroTik v7 changed OSPF/bridge syntax vs v6 — copied v6 config fails." | MKT01 uses the **VLAN-sub-interface model on a plain `bridge-trunk` (`hw=no`)**, not a `vlan-filtering` bridge; OSPF via `redistribute=connected` on the instance. The real v6→v7 traps are in MKT01 `Troubleshooting` + `Build-Guide`. | 🟡 stub |
| N4 | **Identity-aware vs zone/subnet policy (FSSO / User-ID)** | "Do I match rules by subnet or by user — and is FSSO the enterprise standard?" | Zone base = the flows matrix (MKT01 E-W + FGT egress); the **proposed FGT01 FSSO layer** (K3) adds user/group-aware rules + usernames in logs, reusing the AGDLP groups. Run both, layered. | ✅ written |

### Virtualization & Automation

| # | Concept | Why it bites (the gap) | The Atlas example (real artifact) | Status |
|---|---|---|---|---|
| V1 | **VM migration & host bring-up (no cluster)** | "How do I move a VM — especially a DC — to a new host without a cluster, and without breaking AD?" | EQR6/PVE02 bring-up + the always-on tier moved off the R410 (`ADR-0036` v1.2); PBS restore = the Game Day; DC via clean-shutdown restore + VM-GenerationID, not snapshot-rollback. | ✅ written |
| A1 | **Infrastructure as code / idempotency** | "What actually makes a build 'infrastructure as code' vs just a script?" | The `ADR-0048` pipeline — Terraform provisions on Proxmox/Hyper-V, Ansible configures, run #2 = empty diff; GitOps from CNT01 (#19); Oxidized→git→PR for network configs. | ✅ written |
| A2 | **GitOps & config drift** | "How does a hand-edit on a device get caught?" | Oxidized backs up device configs → git → PR → deploy; MKT01 renders its E-W filter from the flows matrix (policy-as-code); SW01 DAI is rendered from NetBox. A hand-edit diffs against the committed file. | 🟡 stub |

## The command-library side (ADR-0032)
Academy is also the home of the **master command library** — see **`../Command-Library/`** (platform-first: PowerShell-Tier0 / Cisco-IOS / RouterOS / FortiOS full, Linux expanding; cross-indexed by service + failure-category). The per-device `Diagnostics.md` quick-refs link up into it; this Concepts index is the "why," the Command-Library is the "how do I check it."

## Related
- `Atlas-Academy/README.md` (Academy purpose + curriculum + the 4-part module format) · `Atlas-Teaching-Patterns-and-House-Style.md` (how Atlas writes to teach).
- `00-Atlas-Foundation/Decisions/ADR-0032` (diagnostics/verification architecture — Academy = the command library + concept layer).
- `Windows-Infrastructure/303` (Windows design) · `304-Microsoft-Architecture-Reference.md` (MS sources) — the build/target-state these concepts explain.
