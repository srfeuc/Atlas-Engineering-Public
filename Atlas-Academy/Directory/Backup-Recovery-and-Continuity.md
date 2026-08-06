---
Title: Backup, Recovery and Continuity — Full Directory
Path: Atlas-Academy/Directory
Status: 🟢 Living — the exhaustive twin of the Source-of-Truth router's §5. Backups, restores, and continuity — anchored in the real frozen-Lab-01 recovery record.
Version: 0.1
Date: 2026-08-03
---

# Backup, Recovery and Continuity — Full Directory

> **The deep version of [Source-of-Truth §5](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#5-backup-recovery-and-continuity).** The router gives you the one-glance answer; this page is the *encyclopedia* — the backup host, the recovery objectives, the continuity discipline, and the **real, device-verified recovery record** the estate learned its backup discipline from. Keep the router in a tab for speed; come here when you want the whole picture.
>
> Each device folder carries the standard page-set (`ADR-0037`): **README** (front door + Services map) · **Build-Guide** (target) · **Build-Record** (verified reality) · **Diagnostics / Troubleshooting** · **Considerations** · **Changes/** · **Automation/**.
>
> 🔒 **The real records here are frozen Lab-01 (`ADR-0022`) — history, not current guidance,** but they are the estate's *most load-bearing* seam: the one place a backup was actually taken, destroyed, rebuilt, and restore-verified at the machine. Read them for *how recovery really goes*; reconcile to the live design.

## On this page

1. [The backup host](#1-the-backup-host) — BKP01 (PBS + Vaultwarden)
2. [Recovery objectives and the design owners](#2-recovery-objectives-and-the-design-owners)
3. [The discipline — and the honest gap](#3-the-discipline--and-the-honest-gap)
4. [Real recovery records (frozen Lab-01)](#4-real-recovery-records-frozen-lab-01) — the goldmine
5. [Commands, playbooks and the Academy](#5-commands-playbooks-and-the-academy)
6. [The decisions (ADRs)](#6-the-decisions-adrs)

---

## 1. The backup host

| Host | Role | Status |
|---|---|---|
| [`BKP01-Backup`](../../Labs/Lab-02-Cisco-Core/Devices/BKP01-Backup/) | Two separate services on one VLAN-20 host — the estate's backup target + the secrets vault | 📋 Authored, not built — every row ⬜ |

BKP01 carries two roles (`Roles/`):

- [`PBS`](../../Labs/Lab-02-Cisco-Core/Devices/BKP01-Backup/Roles/PBS/Build-Checklist.md) — **Proxmox Backup Server**: the dedup/verify/prune backup datastore for the estate's VMs, on the EQR6 8 TB external (`ADR-0036` places BKP01 on the low-power always-on recovery tier).
- [`Vaultwarden`](../../Labs/Lab-02-Cisco-Core/Devices/BKP01-Backup/Roles/Vaultwarden/Build-Checklist.md) — the standalone **secrets vault** and CA-passphrase custody; it replaces the retired OpenSSL CA host as the estate's secret home (`ADR-0031`), and must stand up *before* any CA-passphrase handling (`POL-0002`).

> **The honest status is the point of this page (`POL-0001`/`POL-0006`).** BKP01's Build-Record is explicit: *"No device-verified rows yet — nothing is confirmed on the box."* Two items inside that ⬜ are the estate's **single biggest real risks** (Tier-1 backlog): the **restore Game Day has never been run** — *"the single most load-bearing open item here"* — and the **encrypted off-site copy does not yet exist** (both current archive copies sit in the same room). So this whole domain is heavily *designed* and thinly *proven*: the only backup ever restore-tested end-to-end in the estate is frozen Lab-01's `049` (§4), and even that has no off-site copy. Nothing here is marked ✅ on intent.

The crown jewels this protects — the offline Root CA, ICA01's issuance database, the RADIUS secrets, the vault — live under [Identity and Access](./Identity-and-Access.md); the VM backup targets are the hosts in [Servers and Compute](./Servers-and-Compute.md).

## 2. Recovery objectives and the design owners

The host *runs* backups; these own the *design and the targets*.

- **The recovery targets** — [`CA-PKI-Recovery-Objectives-RPO-RTO`](../../Labs/Lab-02-Cisco-Core/Architecture/CA-PKI-Recovery-Objectives-RPO-RTO.md): the estate's RPO/RTO home (and the concrete seed for `POL-0005`). RPO for the CA issuance DB is **zero un-backed-up mutating events**; RTO is **≤ 2 h** for a host loss with on-site backup intact (achievable) but **∞ for a site loss** until the off-site copy exists (the S2 target is 🔴 *unmet — currently infinite*). Includes a T0–T5 stopwatch worksheet so a drill is *measured*, not asserted.
- **The DR exercise** — [`CA-Migration-and-DR-Lab`](../../Labs/Lab-02-Cisco-Core/Architecture/CA-Migration-and-DR-Lab.md): migrate the CA onto a proper host, then restore it from backup as an `ADR-0011` Game Day on an isolated VLAN. The teaching core: *"a CA is just files"* — key, cert, `openssl.cnf`, `index.txt`, `serial`/`crlnumber`, `newcerts/` — and a restore proves the backup was real.
- **The pre-wipe gate** — [`Pre-Teardown-Backup-and-Verify-Checklist`](../../Labs/Lab-02-Cisco-Core/Architecture/Pre-Teardown-Backup-and-Verify-Checklist.md): the one rule before any device is wiped — *"Do not wipe a device until its irreplaceable data is (1) backed up, (2) restore-verified, and (3) copied to a second location. A backup you have not opened is not a backup."*
- **The per-device procedure** — [`Device-Backup-Runbook`](../../Labs/Lab-02-Cisco-Core/Operations/Device-Backup-Runbook.md): the reusable two-artifact (binary + text) backup with SHA-256 + open/list verify, `atlas-<device>-YYYY-MM-DD` naming, 3-2-1 placement (`POL-0005`).

## 3. The discipline — and the honest gap

- **The rules** — [`POL-0005` Backup & Recovery](../../00-Atlas-Foundation/Policies/POL-0005-Backup-and-Recovery.md) (3-2-1 · restore-tested) · [`POL-0013` Business Continuity](../../00-Atlas-Foundation/Policies/POL-0013-Business-Continuity.md) · the audit rule [`POL-0001`](../../00-Atlas-Foundation/Policies/POL-0001-Atlas-Audit-Policy.md).
- **The discipline** — [`ADR-0011` Game-Day unannounced failure drills](../../00-Atlas-Foundation/Decisions/ADR-0011-Game-Day-Unannounced-Failure-Drills.md): *a backup isn't real until a restore proves it.* No PBS job counts as done until a VM restores to an isolated VLAN and boots; the migrate/restore pass is framed explicitly as an `ADR-0011` Game Day (issue → revoke → CRL from the restored host, prove the same CA fingerprint, record the RTO).
- 🔴 **The honest gap (Tier-1 backlog).** The estate has **no off-site backup, and no backup has ever been restored** — the restore Game Day has *never run in Atlas* — and **rebuild is untested** (Lab-01's teardown runbook was never executed). Concretely: the S2 site-loss RTO is *infinite* until an off-site copy exists. The domain is rich in design (runbooks, checklists, RPO/RTO targets, 3-2-1) but thin in proof; the first moves are *one encrypted off-site copy + one real restore test* (backlog Tier-1 #1).

## 4. Real recovery records (frozen Lab-01)

**The goldmine — cite it heavily.** Lab-01 is where recovery stopped being theory: a backup was taken, an exposed copy destroyed, the archive rebuilt, and a restore *verified* — all at the machine, with the read-backs recorded. 🔒 Frozen (`ADR-0022`); reconcile to the live design where noted.

**The worst-day runbooks**

- [`048` — teardown and rebuild](../../Labs/Lab-01-Mikrotik-Core/Operations/048-Teardown-and-Rebuild-Runbook.md) — *"this is the test"*: tear the lab down and rebuild from documentation alone. Its central hard-won fact is the **circular trap** — every credential lives on the host you're about to wipe —
  > *"**Vaultwarden runs on Pi01.** Every device password in this lab is stored in Vaultwarden. **Wipe Pi01 and you have deleted your own credentials.**"*
  > 🔁 *Reconcile:* 048's own Phase-0 backup steps are **superseded** — [`CM-0025`](../../Labs/Lab-01-Mikrotik-Core/Change-Management/CM-0025-048-Phase-0-Rebuilds-the-Destroyed-Archive.md) repoints them at `049` (below). In Lab-02 the vault moves off the wiped host to BKP01, closing the circular trap.
- [`049` — Root-CA and credential backup](../../Labs/Lab-01-Mikrotik-Core/Operations/049-Root-CA-and-Credential-Backup-Runbook.md) — **the richest record in the estate**: a verified transcript, *"every command below was executed on the live device on 2026-07-13 and its real output recorded."* It is the one backup Atlas has actually restore-tested end-to-end. The restore proof —
  > `openssl rsa -in restore-test/…/root-ca.key -noout -check` → `RSA key ok` — *"This is the moment the file becomes a backup."*
  > and the pre-archive `ls` that *"found the most serious problem of the night"* — two `…key.bak-2026-07-12` copies wrapped in the **old, exposed** passphrase, never destroyed because the procedure had no destroy step. 🔴 Still-open scar: **Phase 5 off-site copy not done — both copies in the same room.**

**The lessons that became rules**

- [`015` — network validation](../../Labs/Lab-01-Mikrotik-Core/Operations/015-Network-Validation-Guide.md) — the read-back discipline every restore is measured against —
  > *"A command completing without an error is not a confirmed change … read the resulting state off the device. Not the exit code. Not the absence of an error. **The value.**"*
- [`CM-0010` — rotate before you back up](../../Labs/Lab-01-Mikrotik-Core/Change-Management/CM-0010-CA-Passphrase-Rotation-and-Exposed-Key-Destruction.md) — born from finding those exposed `.bak` keys; it set the ordering rule and the rollback discipline —
  > *"if a key's passphrase is exposed, rotate before any backup. Never the reverse."* — and *"Never destroy the rollback before the replacement verifies"* (the old tarball was `shred`'d only after the new backup proved out at `049` Phase 6).
- [`CM-0032` — the CA database is 40% blind](../../Labs/Lab-01-Mikrotik-Core/Change-Management/CM-0032-CA-Database-Has-No-Record-of-Two-Certificates.md) — `index.txt` held four rows while the CA had signed six certs devices trust (the missing two were issued with `openssl x509 -req -extfile`, which never writes the DB) — why the live RPO is **event-based** —
  > *"`index.txt` is `ADR-0009`'s only control, and it is 40% blind … A compromise-detection control whose baseline is wrong … fails LOUD and WRONG."*
- [`CM-0025` — a fix that reached every doc except the runbook](../../Labs/Lab-01-Mikrotik-Core/Change-Management/CM-0025-048-Phase-0-Rebuilds-the-Destroyed-Archive.md) — `CM-0010`'s correction updated everything that *describes* the CA backup but not the runbook that *takes* one, so 048 Phase 0 would have rebuilt the exact archive `CM-0010` destroyed —
  > *"`CM-0010`'s correction reached every document that DESCRIBES the CA backup — and not the RUNBOOK that TAKES one."*

> The estate-wide lesson (from [`016-Network-Lessons-Learned`](../../Labs/Lab-01-Mikrotik-Core/Operations/016-Network-Lessons-Learned.md)): a green prompt is not evidence; a backup you haven't opened is not a backup. The secret-commit companion is [`CM-0014`](../../Labs/Lab-01-Mikrotik-Core/Change-Management/CM-0014-Archive-Passphrase-Committed-to-Repository.md) (secrets, `POL-0002` — no value reproduced). The full ledger is [`Lab-01 Change-Management/`](../../Labs/Lab-01-Mikrotik-Core/Change-Management/).

## 5. Commands, playbooks and the Academy

- 🖥️ **Commands** — [Linux](../Command-Library/Linux.md) (`sha256sum`, `openssl … -check`, `restic`/`borg`, `tar`, `systemctl`, PBS `proxmox-backup-client`) · [PowerShell-Tier0](../Command-Library/PowerShell-Tier0.md) (Windows backup + AD restore)
- 🔧 **Playbooks** — [Recover-the-Lab-from-a-Bare-Metal-Teardown](../Playbooks/Recover-the-Lab-from-a-Bare-Metal-Teardown.md) · [Recover-from-a-DNS-Outage](../Playbooks/Recover-from-a-DNS-Outage.md) · [Rotate-a-Leaked-Key-Before-You-Back-It-Up](../Playbooks/Rotate-a-Leaked-Key-Before-You-Back-It-Up.md) · [Respond-to-a-Committed-Secret](../Playbooks/Respond-to-a-Committed-Secret.md)
- 📋 **Templates** — [Change-Record](../../00-Atlas-Foundation/Templates/Change-Record-Template.md) · [Build-Record](../../00-Atlas-Foundation/Templates/Build-Record-Template.md) · [Device-Verification-Procedure](../../00-Atlas-Foundation/Templates/Device-Verification-Procedure-Template.md) (the read-back a restore is proven with)
- 🎓 **Concepts + cert alignment** — [A Completed Command Is Not Evidence](../Concepts/A-Completed-Command-Is-Not-Evidence.md) *(why a backup isn't real until a restore proves it)* · the [Concepts index](../Concepts/) · the **[AZ-800/801](../Certification/AZ-800-801-Windows-Server-Hybrid-Lab-Map.md)** cert map (Windows backup/DR; resilience is cert-adjacent to CySA+/Security+)
- 🔩 **Per-device** — BKP01's own `Diagnostics.md` / `Troubleshooting.md`

## 6. The decisions (ADRs)

- [`ADR-0011`](../../00-Atlas-Foundation/Decisions/ADR-0011-Game-Day-Unannounced-Failure-Drills.md) — Game-Day unannounced failure drills (a backup isn't real until a restore proves it)
- [`ADR-0036`](../../00-Atlas-Foundation/Decisions/ADR-0036-Compute-Topology-and-VM-Placement.md) — compute topology / VM placement (BKP01 on the low-power always-on recovery tier + the 8 TB)
- [`ADR-0009`](../../00-Atlas-Foundation/Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md) — the IR + `index.txt` control lesson (backup integrity, not just existence)
- [`ADR-0031`](../../00-Atlas-Foundation/Decisions/ADR-0031-Retire-OpenSSL-Lab-CA.md) — retire the OpenSSL CA; Vaultwarden becomes the estate secret home
- [`ADR-0013`](../../00-Atlas-Foundation/Decisions/ADR-0013-Retire-bridgeLocal-Recovery-Network.md) — retire the bridgeLocal recovery network (recovery is console-based, not a routed rescue net — the design the frozen Lab-01 records above pre-date)

## Related

[Source-of-Truth router §5](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#5-backup-recovery-and-continuity) (the quick view) · [Identity and Access directory](./Identity-and-Access.md) (the crown jewels this protects) · [Servers and Compute directory](./Servers-and-Compute.md) (the backup targets) · [`POL-0005` Backup & Recovery](../../00-Atlas-Foundation/Policies/POL-0005-Backup-and-Recovery.md) · [`POL-0013` Business Continuity](../../00-Atlas-Foundation/Policies/POL-0013-Business-Continuity.md).

## Change Log

| Version | Changes |
|---|---|
| 0.1 | 2026-08-03. First cut — the exhaustive twin of Source-of-Truth §5: the backup host BKP01 (PBS + Vaultwarden) with honest build status (authored-not-built; the never-run restore Game Day + missing off-site copy flagged as the estate's Tier-1 risks); the recovery objectives + design owners (RPO/RTO, the DR lab, the pre-teardown gate, the device-backup runbook); the `POL-0005`/`POL-0013`/`ADR-0011` discipline + the honest designed-vs-proven gap; the **frozen Lab-01 recovery goldmine** cited heavily (048 teardown/rebuild, 049 the one restore-tested backup, 015 the read-back rule, CM-0010/CM-0025/CM-0032) with real read-backs; commands, playbooks + Academy; the recovery ADRs. Built per the `Session-29` brief. |
