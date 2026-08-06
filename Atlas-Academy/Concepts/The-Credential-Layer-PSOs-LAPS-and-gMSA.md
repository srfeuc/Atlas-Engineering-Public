---
Title: The Credential Layer — PSOs, LAPS & gMSA — why the best password is one no human manages, taught through Atlas's real identity build
Path: Atlas-Academy/Concepts
Status: 🟢 Academy concept module (D6 / `ADR-0032` concept layer). The "why it works" companion to `STD-0001` (Password & Authentication).
Version: 1.0
Date: 2026-08-04
---

# The Credential Layer — PSOs, LAPS & gMSA (one module)

<!-- provenance -->
> **Atlas Academy — Concepts.** A "why it works" module (`Academy/README` 4-part format), in the ⭐ [golden Concept shape](./Encryption-and-PKI-in-Atlas.md). Every claim points at a **real Atlas artifact** — a real PSO, a real LAPS deployment, a real passphrase that broke a recovery. The *settings* live in [`STD-0001` Password & Authentication](../../00-Atlas-Foundation/Standards/STD-0001-Password-and-Authentication.md); the *blast-radius model* those accounts sit in is [`Tiered-Admin-Model`](./Tiered-Admin-Model.md). This page is the credential-*mechanics* why-layer. One home per fact (`POL-0004`).

> **The gap this closes ([`STD-0001`](../../00-Atlas-Foundation/Standards/STD-0001-Password-and-Authentication.md)):** the standard links `Tiered-Admin-Model` for *why a Tier-0 credential must never touch a lower tier* — but that concept is about blast radius, not about the credentials themselves. This module is the missing half: why fine-grained password policies, why machine-managed local-admin secrets, and why the best service password is one no human ever knows.

## The Concept

Authentication has two halves: **proving who you are** (this module) and **what you may then reach** ([AGDLP & least privilege](./AGDLP-Granting-Rights-to-Groups-Not-People.md)). The credential layer's whole job is to make every secret **strong, unique, and — wherever possible — not human-managed at all**, because the passwords humans choose and reuse are the softest thing in any estate. Four moves get you there.

**Length beats complexity, in ASCII.** A passphrase's strength comes from **length**, not from exotic characters — and the exotic characters actively hurt, because a `£` or `&` is a different byte sequence to a rescue console or a shell and will fail during the recovery the secret exists for. "24 ASCII characters" beats "19 with a symbol in it" on both entropy *and* survivability.

**A fine-grained policy (PSO) lets one domain hold two standards.** Sensitive populations (finance, HR, admins) need a stricter password rule than everyone else — but you don't build a second domain for it. A **Password Settings Object** applies a tighter policy (longer minimum, lower lockout threshold) to a *group*, overriding the domain default by precedence. One directory, graduated strictness.

**LAPS makes every machine's local admin password unique and disposable.** The classic breach path is one local-admin password shared across every machine — steal it once, own the fleet. **LAPS** gives each machine a random local-admin password that AD rotates and escrows, so a hash stolen from one box unlocks only that box. The same idea rescues the most dangerous hand-recorded secret in the domain — the DC's DSRM recovery password — by putting it under LAPS instead of in a document.

**gMSA removes the human from service accounts entirely.** A service running as a user account with a password someone chose and never rotates is a permanent, over-privileged foothold. A **group Managed Service Account** has a long password *Active Directory* generates and rotates on a schedule, that **no human ever knows or types**. The best-managed password is the one nobody manages.

Above all of it sits the honest gap: a password — even a great one — is one factor. Atlas strengthens privileged auth today with tiering + Protected Users + the PAW, and marks **MFA as a stated target, not a claim.**

## The Atlas Example (real artifacts)

Every one of these is on a named target in [`STD-0001`](../../00-Atlas-Foundation/Standards/STD-0001-Password-and-Authentication.md), read-back-verified where built:

- **PSO** — `PSO-FinanceHR` (precedence **10**, min length **15**, lockout threshold **3**) applied to `G-FinanceHR-Users`; everyone else on the domain baseline. ✅ built (DC Stage 7b); `Get-ADFineGrainedPasswordPolicy` confirms it.
- **LAPS** — Windows LAPS self-permissioned on the `Devices` OU, so every member's local admin password is rotated and escrowed, **and the DCs' DSRM password is LAPS-managed** — which retired the manual DSRM secret from the `POL-0002` vault. ✅ built (Stage 7c).
- **Per-tier accounts + Protected Users** — `t0-seth` / `t1-seth` / `seth`, with `t0-seth` in **Protected Users** (no NTLM, so a Tier-0 credential can't be replayed down a tier). ✅ device-verified 2026-07-22 (the [Tiered-Admin-Model](./Tiered-Admin-Model.md) is *why*).
- **gMSA-first** — service accounts are `svc-gmsa-<purpose>`; the **KDS root key exists** (the prerequisite), so gMSAs can be created as services land.
- **scrypt device secrets** — IOS secrets are **Type 9** (never 7/5), the credential-storage crossover with [`STD-0004` R2](../../00-Atlas-Foundation/Standards/STD-0004-Encryption.md); the working value lives in the vault ([Secrets & Credential Custody](./Secrets-and-Credential-Custody.md)).

## What Went Wrong (real troubleshooting history — the best teacher)

- **A `£` in a passphrase broke bare-metal recovery ([`049`](../../Labs/Lab-01-Mikrotik-Core/Operations/049-Root-CA-and-Credential-Backup-Runbook.md) / [`CM-0014`](../../Labs/Lab-01-Mikrotik-Core/Change-Management/CM-0014-Archive-Passphrase-Committed-to-Repository.md)).** OpenSSL reads a passphrase as **bytes**, and a non-ASCII glyph is a different byte sequence on a rescue console — the passphrase that was supposed to unlock the CA key wouldn't, at the exact moment it mattered. The rule that came out of it (`STD-0001` R1) is *length-first, ASCII-only* — entropy from length, not from characters that break the tools you need in an emergency.
- **The DC recovery password that lived in a document.** DSRM — the domain controller's break-glass — was a hand-recorded secret, a Tier-0 credential sitting in a file. Moving it under **LAPS** (device-verified) turned it into a rotated, escrowed value that no longer exists in any doc: the credential layer erasing a standing exposure.
- **You can't prove a boundary you only have one side of.** The member-server LAPS test — *"a Tier-2 account cannot read a Tier-1 machine's LAPS password"* — was **deferred because there was no Tier-1 member server yet to prove it on** (`Tiered-Admin-Model`'s troubleshooting note). A control isn't verified until you've actually stood on the wrong side of it and been refused — designed ≠ enforced (`POL-0001`).

## How to Explain This in an Interview

*"The credential layer is about making every secret strong, unique, and ideally not human-managed. Four things I actually do: passphrases get their strength from length in plain ASCII — I learned that when a pound sign in a CA passphrase wouldn't decrypt on a rescue console, because OpenSSL reads it as bytes and the recovery is the one moment it has to work. For sensitive groups like finance I use a fine-grained password policy — a PSO — so one domain can enforce a stricter rule on some people without standing up a second domain. For local admin passwords I use LAPS, so every machine has its own random password AD rotates and escrows, which kills the 'one local-admin password owns the whole fleet' attack — and I put the domain controller's DSRM recovery password under LAPS too, so it's not sitting in a document anymore. And for service accounts I use group Managed Service Accounts, where AD generates and rotates a password no human ever knows. The best-managed password is the one nobody manages. I'm also honest that a password is still one factor — MFA is a stated gap on my roadmap, not something I pretend I've already got."*

## Related

- **The standard + the model:** [`STD-0001` Password & Authentication](../../00-Atlas-Foundation/Standards/STD-0001-Password-and-Authentication.md) (the values) · governing [`POL-0002` Secrets](../../00-Atlas-Foundation/Policies/POL-0002-Secrets-and-Credentials.md) · [`ADR-0021`](../../00-Atlas-Foundation/Decisions/ADR-0021-AD-as-Tiered-Identity-Backbone.md) (tiered identity) · [`ADR-0040`](../../00-Atlas-Foundation/Decisions/ADR-0040-Entra-Connect-Password-Hash-Sync.md) (the planned MFA home) · [`ADR-0028`](../../00-Atlas-Foundation/Decisions/ADR-0028-FGT01-Admin-Auth-Direct-LDAPS.md) (the no-MFA reality on FGT01).
- **The owner doc:** the DC [`Build-Checklist`](../../Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers/Build-Checklist.md) (PSO §6 · LAPS §1/§6 · tier accounts §8 · gMSA §7).
- **The real records:** [`049`](../../Labs/Lab-01-Mikrotik-Core/Operations/049-Root-CA-and-Credential-Backup-Runbook.md) (the ASCII-passphrase standard) · [`CM-0014`](../../Labs/Lab-01-Mikrotik-Core/Change-Management/CM-0014-Archive-Passphrase-Committed-to-Repository.md).
- **The neighbouring concepts:** [`Tiered-Admin-Model`](./Tiered-Admin-Model.md) (why the tier accounts) · [`AGDLP — Granting Rights to Groups, Not People`](./AGDLP-Granting-Rights-to-Groups-Not-People.md) (what these accounts may do) · [`Secrets-and-Credential-Custody`](./Secrets-and-Credential-Custody.md) (where the secrets live) · [`Encryption-and-PKI-in-Atlas`](./Encryption-and-PKI-in-Atlas.md) (how they're hashed) · the [Concepts index](./README.md).
- **Run the read-backs:** [PowerShell-Tier0](../Command-Library/PowerShell-Tier0.md) (`Get-ADFineGrainedPasswordPolicy`, `Get-LapsADPassword`, `Test-ADServiceAccount`, `Get-ADGroupMember "Protected Users"`).
- **Cert alignment:** [AZ-800/801](../Certification/AZ-800-801-Windows-Server-Hybrid-Lab-Map.md) (identity: PSO / LAPS / gMSA) · [Security+ Domain-5](../Certification/Atlas-Security-Plus-Domain5-Coverage-Map.md) (5.1 authentication).
