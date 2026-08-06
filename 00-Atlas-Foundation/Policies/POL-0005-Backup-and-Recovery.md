---
Title: POL-0005 — Backup & Recovery Policy
Path: 00-Atlas-Foundation/Policies
Status: ✅ Adopted 2026-08-03 under `ADR-0026` (framework). In force.
Version: 2.0
---

# POL-0005 — Backup & Recovery

> **At a glance.** Every irreplaceable asset is backed up on the 3-2-1 rule; **a backup is not a backup until a restore has succeeded**; and the recovery objective (RPO/RTO) for each asset is written down and *tested*, not assumed. This policy folds the estate's recovery discipline into citable requirements (`POL-0005 R1`…) and doubles as a directory of the decisions that govern backup (below).

| Item | Value |
|---|---|
| Layer | **Policy** — a standing requirement; governs the Standards, ADRs, Runbooks, and Changes beneath it |
| Requirement, in one line | 3-2-1 on every irreplaceable asset; restore-tested before it counts; a written, tested RPO/RTO per asset; secret-bearing backups obey `POL-0002`. |
| Owner | 🔴 Platform / Operations silo ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md)) — secret-bearing backups defer to Security / [`POL-0002`](./POL-0002-Secrets-and-Credentials.md) |
| Adopting decision | [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) → the rule promoted from [`ADR-0011`](../Decisions/ADR-0011-Game-Day-Unannounced-Failure-Drills.md) (Game Days: a backup isn't real until a restore proves it) |
| Builds on | [`POL-0006`](./POL-0006-Evidence-and-Verification.md) (the restore is the read-back) · [`POL-0002`](./POL-0002-Secrets-and-Credentials.md) (secret-bearing backups) · [`POL-0013`](./POL-0013-Business-Continuity.md) (continuity leans on this) |
| Verified by | [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* checklist below |
| Framework mapping | NIST CSF 2.0 **RC.RP** / **PR.DS-11** · CIS Controls v8 **11** (Data Recovery) · Security+ 5.x (resilience) |

---

## Scope & applicability

Governs the protection and recoverability of every irreplaceable asset in the estate — the CA keys and issuance database, the vault, device and hypervisor configurations, AD/identity state, and service/VM data — and every backup, restore test, and pre-teardown gate.

**Boundary with [`POL-0013`](./POL-0013-Business-Continuity.md):** POL-0005 owns *backup/restore mechanics + 3-2-1* (getting it back after it's gone); POL-0013 owns *continuity strategy + graceful degradation* (keeping running through the failure). RTO/RPO numbers and the BIA are owned by [`POL-0012`](./POL-0012-Risk-Management.md) Part F + the CA/PKI RPO-RTO doc; this policy *requires* them and links there.

## Why this is a policy, not a note

The rule was scattered and, where it existed, unmet. `049` proved the *CA archive* restores — but its off-site copy still doesn't exist, so a single room-loss event takes the entire PKI; and **no device configuration has ever been restored on any device, ever** ([`ADR-0013`](../Decisions/ADR-0013-Retire-bridgeLocal-Recovery-Network.md)), nor has the rebuild-from-documentation premise ([`ADR-0011`](../Decisions/ADR-0011-Game-Day-Unannounced-Failure-Drills.md)) been run. A recovery capability that is not enumerable is not auditable, and the gap is not hypothetical — it is the difference between *"we have backups"* and *"we can recover."*

---

## The standing requirements

Each is citable as `POL-0005 R#`.

### R1 — Tiered protection: everything irreplaceable is backed up

*Tier 0 (unrebuildable)* — the Root & Intermediate CA keys, the issuance DB (`index.txt`/`serial`/`crlnumber`/`newcerts`), the passphrases; *Tier 1 (expensive)* — the vault, device/hypervisor configs, AD state; *Tier 2 (rebuildable but costly)* — service configs, VM data. **When unsure of a tier, protect at the higher one.**

### R2 — 3-2-1, and the off-site copy is the point

At least **three** copies, on **two** media, with **one off-site**. `E:` plus a copy on the same host is *redundancy* — the event this survives (fire, theft, flood) takes both. The off-site copy is the one that survives losing the room. 🔴 **Open estate gap:** no off-site copy exists yet (the Tier-1 risk).

### R3 — A backup is not a backup until a restore has succeeded

Every backup class carries a **restore test** on a cadence ([`ADR-0011`](../Decisions/ADR-0011-Game-Day-Unannounced-Failure-Drills.md)): the CA decrypt-and-open (`049` Phase 4), a device-config restore, and the ultimate one — the **documentation-only rebuild**. > *"A backup you have never opened is a hope."* A `gpg`/job exit-0 is a claim; the restore is the evidence ([`POL-0006`](./POL-0006-Evidence-and-Verification.md)).

### R4 — Recovery objectives are written, and event-driven where the asset is

Each protected asset has a stated **RPO** and **RTO**, *measured* in Game Days, not guessed (owner: [`POL-0012`](./POL-0012-Risk-Management.md) + the CA/PKI RPO-RTO doc). For a CA the RPO is **event-based — zero un-backed-up issuances** (back up immediately after any issue/revoke/rotate, because a post-backup issuance restores as an unrevocable orphan — `CM-0032`); a staleness backstop covers static periods.

### R5 — Secret-bearing backups obey `POL-0002`, including the destroy step

A backup capturing key material or a vault names, in the same procedure, **who removes any decrypted/intermediate copy and when** ([`ADR-0009`](../Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md)). Decrypt/verify crown-jewel archives **only on a local, ideally air-gapped machine**; the passphrase lives on **paper**, off-site (the `049` circular-dependency fix — the vault is on the host that dies).

### R6 — Backups live off the device, and pre-teardown is a hard gate

A config backed up only to the device, or logs kept only on the box that generates them, are lost with it — pull them **off-device** to the 3-2-1 set. **Before any wipe:** irreplaceable data is (1) backed up, (2) restore-**verified**, (3) off-site — the pre-teardown gate. SW01/FGT01 have **no backup** until their running config is exported; that export is one-shot.

---

## Decisions governed by this policy

> Which decisions serve this policy — **generated** from the ADRs' `Governing Policy:` lines (`tools/Build-Policy-Directories.ps1`). Do not hand-edit.

<!-- BEGIN AUTOGEN:decisions POL-0005 · generated by tools/Build-Policy-Directories.ps1 — do not hand-edit -->
| Decision | Status | Governing Policy |
|---|---|---|
| [ADR-0011 — Game Days: Unannounced Failure Drills That Test the Docum…](../Decisions/ADR-0011-Game-Day-Unannounced-Failure-Drills.md) | Proposed — captured 2026-07-13, deliberately NOT scheduled | POL-0005 (+POL-0013, +POL-0016) |
| [ADR-0046 — Two-Node Failover Cluster + Storage Spaces Direct: HA Wor…](../Decisions/ADR-0046-Two-Node-Failover-Cluster-and-S2D.md) | Accepted in principle (operator, 2026-07-29). ✅ PVE02-gat… | POL-0013 (+POL-0005) |
<!-- END AUTOGEN:decisions POL-0005 -->

## The amendment model — how these decisions relate to this policy

This policy holds the **current** rule; the decisions behind it are the **dated trail**.

- **To change a rule, an ADR amends it** — `Governing Policy: POL-0005`, *"amends `POL-0005` R#"*, a Change Log row ([`ADR-0054`](../Decisions/ADR-0054-Governance-Reconciliation-Promote-Policy-Shaped-ADRs.md)).
- **(C) promotion:** the Game-Day rule of [`ADR-0011`](../Decisions/ADR-0011-Game-Day-Unannounced-Failure-Drills.md) is promoted here; the ADR is kept as the adopting decision (originals in the legacy snapshot).

## Verification (how compliance is proven)

- [ ] **R1** — every Tier-0/Tier-1 asset has a current backup.
- [ ] **R2** — a named off-site copy exists (today: close `049` Phase 5).
- [ ] **R3** — each backup class has a **dated, passed restore test** on record.
- [ ] **R4** — each asset has a written RPO/RTO; the CA backup fires on every issuance (event-driven), not only the clock; restore tests capture an RTO number.
- [ ] **R5** — secret-bearing backups show the destroy step + the local-only decrypt; the passphrase has an off-site paper copy.
- [ ] **R6** — pre-teardown gate met before any wipe (backed up · restore-verified · off-site); no config exists only on its device.
- [ ] **Meta** — every change to a rule here traces to an amending ADR + a Change Log row.

## What a violation looks like

Both copies in one room (no off-site) · a `.gpg` wiped-toward with no proven decrypt · a CA issuance never followed by a backup · a device config that exists only on the device · a crown-jewel archive decrypted on a networked box · an RTO/RPO asserted but never measured · a "backup" trusted as one that has never been restored.

## Related

[`POL-0013` Business Continuity](./POL-0013-Business-Continuity.md) · [`POL-0012` Risk (BIA/RTO/RPO)](./POL-0012-Risk-Management.md) · [`POL-0002` Secrets](./POL-0002-Secrets-and-Credentials.md) · [`ADR-0011` Game Days](../Decisions/ADR-0011-Game-Day-Unannounced-Failure-Drills.md) · [`ADR-0009`](../Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md) · the [Backup, Recovery & Continuity directory](../../Atlas-Academy/Directory/Backup-Recovery-and-Continuity.md) · the legacy snapshot.

## Learn it — the Academy (the why + the read-backs)

- 🎓 **Concept (why it works):** [A Backup Is Not a Backup Until a Restore Proves It](../../Atlas-Academy/Concepts/A-Backup-Is-Not-a-Backup-Until-a-Restore-Proves-It.md) (restore-testing · 3-2-1 · event-driven RPO · the rebuild-from-docs Game Day — grounded in `049`/`048`/`ADR-0011`) · [A Completed Command Is Not Evidence](../../Atlas-Academy/Concepts/A-Completed-Command-Is-Not-Evidence.md) (a green backup job is not proof).
- 🖥️ **Commands:** [Linux](../../Atlas-Academy/Command-Library/Linux.md) (`sha256sum`, `openssl … -check`, `proxmox-backup-client`) · [PowerShell-Tier0](../../Atlas-Academy/Command-Library/PowerShell-Tier0.md).
- 🔧 **Playbooks:** [Recover-the-Lab-from-a-Bare-Metal-Teardown](../../Atlas-Academy/Playbooks/Recover-the-Lab-from-a-Bare-Metal-Teardown.md) · [Recover-from-a-DNS-Outage](../../Atlas-Academy/Playbooks/Recover-from-a-DNS-Outage.md).
- 🏅 **Cert objective:** [AZ-800/801](../../Atlas-Academy/Certification/AZ-800-801-Windows-Server-Hybrid-Lab-Map.md) (backup/DR) · [Security+ Domain-5](../../Atlas-Academy/Certification/Atlas-Security-Plus-Domain5-Coverage-Map.md).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-20. First written form of the referenced-but-missing `POL-0005` (3-2-1 · restore-testing as the definition · tiered assets · event-driven RPO · destroy-step · pre-teardown gate). |
| 2.0 | 2026-08-04. **Reshaped to the golden `POL-0014` shape** (#42): at-a-glance + item table; the requirement-in-detail distilled into citable `R1–R6`; the boundary with `POL-0013`/`POL-0012`; the amendment model (Game-Day rule promoted from `ADR-0011`); per-`R#` Verification; a **Learn it (Academy)** section pointing at the now-built [`A Backup Is Not a Backup…`](../../Atlas-Academy/Concepts/A-Backup-Is-Not-a-Backup-Until-a-Restore-Proves-It.md) concept; status flipped to ✅ Adopted. AUTOGEN directory unchanged. No normative change. |
