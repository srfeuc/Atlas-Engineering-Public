---
Title: STD-0003 — Physical & Console/OOB Security Standard
Path: 00-Atlas-Foundation/Standards
Status: ✅ Adopted 2026-08-03 under `POL-0007` via `ADR-0017`/`ADR-0027`. In force; per-control conformance tracked in Verification.
Version: 2.1
---

# STD-0003 — Physical & Console/OOB Security

> **At a glance.** The estate's real physical-security surface is a home lab: the compensating controls are a reachable **serial-console break-glass**, a dedicated **out-of-band** path (target), an **air-gapped Root CA** with paper-passphrase custody, and **segmentation** around the un-patchable OT floor — each a real control, honestly marked built or not.

| Item | Value |
|---|---|
| Layer | **Standard** — the physical/console/OOB controls; binds real recovery paths, media custody, and zones |
| Governing policy | [`POL-0007`](../Policies/POL-0007-Hardening-Baseline.md) — Hardening Baseline (+ [`POL-0003`](../Policies/POL-0003-Change-Control.md) recovery-first) |
| Requirement, in one line | Reachable console break-glass · a dedicated OOB path · air-gapped CA + paper custody · OT segmentation |
| Owner | Security silo ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) silos) |
| Adopting decision | [`ADR-0017`](../Decisions/ADR-0017-Defer-CM-0012-CMOS-Battery.md) (OOB reality) + [`ADR-0027`](../Decisions/ADR-0027-AD-CS-Two-Tier-Microsoft-PKI.md) (offline root) + the `CIS-Hardening-*` break-glass → under [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) |
| Applies to | SW01/1941 (console) · PVE01 (iDRAC) · RCA01/the CA media + paper · the OT zone (VLAN 90) |
| Feeds / fed by | **fed by** the `CIS-Hardening-*` baselines + [`049`](../../Labs/Lab-01-Mikrotik-Core/Operations/049-Root-CA-and-Credential-Backup-Runbook.md) · **feeds** [`STD-0004`](./STD-0004-Encryption.md) R5 (CA key custody) + the recovery playbooks |
| Verified by | [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* read-backs below |
| Framework mapping | CIS v8 Ctl 3/12 · NIST 800-82 (OT) · Security+ (physical/operational security) |

---

## Scope & applicability

Binds the physical and out-of-band controls that keep the estate recoverable and the sensitive artifacts protected: console/OOB recovery, offline CA-key custody, and OT segmentation.

> **Home-lab honesty (`POL-0006`):** Atlas runs in a home environment — there is **no data-centre premises control** (locked cage, badge, camera). The physical-security *scope that matters here* is the irreplaceable artifacts (the CA keys/paper) and the recovery paths; those get real controls below. Premises access is an accepted, documented boundary, not a claimed control.

**Boundary with adjacent standards/policies:** *the crypto on the CA keys* is [`STD-0004`](./STD-0004-Encryption.md) R5; this standard owns their **physical custody**. *The device config* is [`POL-0007`](../Policies/POL-0007-Hardening-Baseline.md); this owns only the console/OOB clauses.

## Why a standard, not left in a guide

Recovery paths are invisible until you need them, and hardening deletes them: MKT01 once had **no safe recovery** mid-hardening (`CM-0021`), and PVE01's OOB is **absent** because a dead CMOS battery makes the BMC unable to hold config (`CM-0012`). A standard forces "the way back in is proven *before* you lock the door" to be auditable.

---

## The requirements

Each is citable as `STD-0003 R#`. Real recovery paths on named targets.

### R1 — A serial-console break-glass is present and reachable before any mgmt-plane change

Every network device keeps a **serial console — 9600 8N1, `line con 0 login local`** (local `ciscoadmin`), reachable **before** an SSH/mgmt change can lock you out (the recovery-first rule). **Applies to:** 1941, SW01, MKT01, FGT01. **Owner docs:** [`CIS-Hardening-1941`](../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-1941.md) / [`SW01`](../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-SW01.md). **Status:** ✅ **proven on the 1941** (the hardening pass was done on the console when SSH self-blocked, 2026-07-22); SW01 available, a console login-test 📋 to formally close the gate.

### R2 — A dedicated out-of-band path exists (target) — and its absence is documented, not hidden

PVE01's **iDRAC (`10.10.0.100`)** is the intended OOB path but is **not out-of-band today**: it rides the shared LOM (dies with SW01) and is **blocked by `CM-0012`** (dead CR2032 → the BMC can't hold settings). **Deferred, not faked** ([`ADR-0017`](../Decisions/ADR-0017-Defer-CM-0012-CMOS-Battery.md), Accepted — *"a tick you did not earn is a lie"*); [`050`](../../Labs/Lab-01-Mikrotik-Core/Operations/050-PVE01-iDRAC-Onboarding-Runbook.md) unblocks once the battery is replaced and the board proves it holds config. **Applies to:** PVE01. **Status: 📋 target — ⬜ blocked** on the hardware fix.

### R3 — The Root CA is air-gapped; its passphrases live on paper, off-site, never with the media

The **Root CA key is on air-gapped, encrypted removable media, powered off** — it signs only the issuing CA, then goes back "in a drawer"; the passphrases are on **paper (two copies, one off-site)**, **never in the same container as the media**, and **separate for Root vs Issuing**. **Applies to:** the CA media + paper (Lab-01 Pi01 CA; the Lab-02 [`RCA01`](../Decisions/ADR-0027-AD-CS-Two-Tier-Microsoft-PKI.md) design). **Owner docs:** [`049` Phase 1](../../Labs/Lab-01-Mikrotik-Core/Operations/049-Root-CA-and-Credential-Backup-Runbook.md) · [`Lab-02-Offline-Root-CA-Build-Design`](../../Labs/Lab-02-Cisco-Core/Architecture/Lab-02-Offline-Root-CA-Build-Design.md). **Status:** paper custody ✅ **proven (Lab-01, 2 copies/1 off-site)**; 🔴 **the encrypted media has no off-site copy — both in the same room** (the estate's Tier-1 backup gap); the Lab-02 RCA01 offline root is 📋 design-only.

### R4 — The OT floor is segmented; segmentation is its compensating control

**VLAN 90 (OT Isolation, `10.90.0.0/26`, statically addressed)** is **default-deny both directions**; the plant floor **never initiates** into corporate IT, the internet, or identity (east-west **flow #12**) — segmentation is the compensating control for un-patchable PLCs/HMIs (*availability outranks confidentiality*, NIST 800-82). **Applies to:** VLAN 90. **Owner docs:** [`IP-Addressing-Plan-VLSM`](../../Labs/Lab-02-Cisco-Core/Architecture/IP-Addressing-Plan-VLSM.md) · [flows matrix #12](../../Labs/Lab-02-Cisco-Core/Architecture/Atlas-East-West-Allowed-Flows-Matrix.md). **Status: ⬜ designed, not enforced** (segmentation lands Phase 7 on MKT01).

---

## Adopting & amending decisions

The dated trail (kept, never deleted; originals in the legacy snapshot).

| Decision | Status | What it did |
|---|---|---|
| [`ADR-0017`](../Decisions/ADR-0017-Defer-CM-0012-CMOS-Battery.md) | Accepted | deferred `CM-0012` (documented, not closed) — the honest-OOB reality (R2) |
| [`ADR-0027`](../Decisions/ADR-0027-AD-CS-Two-Tier-Microsoft-PKI.md) | Accepted | the offline-root air-gap (R3) |
| [`ADR-0023`](../Decisions/ADR-0023-1941-Core-MKT01-East-West-Firewall-Topology.md) | Accepted | the segmentation topology that isolates OT (R4) |
| the `CIS-Hardening-*` baselines | in force (`POL-0007`) | the serial-console break-glass, device-verified (R1) |

## Verification (how conformance is proven)

Real read-backs — the [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) audit runs these; the device wins over the doc.

- [x] **R1** — a console login on 9600 8N1 reaches `ciscoadmin` (✅ 1941; SW01 test 📋); recovery-first checked before each mgmt-plane change.
- [ ] **R2** — 📋 once unblocked: `ipmitool -I lanplus -H 10.10.0.100 -C 3 … chassis status` → `System Power: on`, and a **cipher-0 session must fail**; until then, `ADR-0017` deferral recorded.
- [x] **R3** — the paper passphrase opens the live key: `openssl rsa -in root-ca.key -noout` → `RSA key ok` (`049`); paper copies counted (2, one off-site). 🔴 media off-site copy: **not done**.
- [ ] **R4** — ⬜ from an OT host, an outbound session to any corporate zone is **dropped + logged** on MKT01 (gated on Phase-7 enforcement).
- [ ] **Meta** — any change to a value here traces to an amending ADR + a Change Log row.

> Markers are honest (`POL-0006`): R1/R3-paper are ✅ proven; R2 (iDRAC), R3-media-offsite, and R4 (OT) are 📋/⬜/🔴 — real gaps, named not hidden.

## Learn it — the Academy (the source of truth for the *why* + the commands)

- 🎓 **Concept (why it works):** ✅ [Out-of-Band Recovery](../../Atlas-Academy/Concepts/Out-of-Band-Recovery.md) — the *"the way back in is a control you build before you need it / hardening deletes it"* why-layer (the `CM-0021`/`CM-0012` lessons); also the [Concepts index](../../Atlas-Academy/Concepts/) and the recovery playbooks below.
- 🖥️ **Commands (run the read-backs):** [Recover-a-Locked-Out-Router-Out-of-Band](../../Atlas-Academy/Playbooks/Recover-a-Locked-Out-Router-Out-of-Band.md) · [Recover-the-Lab-from-a-Bare-Metal-Teardown](../../Atlas-Academy/Playbooks/Recover-the-Lab-from-a-Bare-Metal-Teardown.md) · [Cisco-IOS](../../Atlas-Academy/Command-Library/Cisco-IOS.md) (console/line config)
- 🏅 **Cert objective:** Security+ (physical & operational security) · [AZ-800/801](../../Atlas-Academy/Certification/AZ-800-801-Windows-Server-Hybrid-Lab-Map.md) (OOB/recovery) *(a dedicated physical-domain map is a known Academy gap)*
- 📋 **Security program:** [Compliance Program](../Security-Program/Atlas-Compliance-Program.md) (physical/OT control mapping) · [Incident Response](../Security-Program/Incident-Response-Playbook.md) (a locked-out/failed-device response)

## What a violation looks like

A mgmt-plane change made with **no proven console path** · an iDRAC ticked ✅ while `CM-0012` is open (a claim you can't hold) · a CA passphrase in the **same container** as the media, or **no** off-site paper copy · an OT host that can reach the internet or a corporate zone · a `cipher-0` IPMI session that **succeeds**.

## Related

[`POL-0007`](../Policies/POL-0007-Hardening-Baseline.md) (governing) · [`STD-0004`](./STD-0004-Encryption.md) R5 (CA key crypto) · [`049`](../../Labs/Lab-01-Mikrotik-Core/Operations/049-Root-CA-and-Credential-Backup-Runbook.md) · [`050`](../../Labs/Lab-01-Mikrotik-Core/Operations/050-PVE01-iDRAC-Onboarding-Runbook.md) · [`ADR-0017`](../Decisions/ADR-0017-Defer-CM-0012-CMOS-Battery.md) · the [Standards register](./README.md) · [the framework](../Governance/Atlas-Governance-Framework.md).

## Change Log

| Version | Changes |
|---|---|
| 2.1 | 2026-08-04. **Learn-it:** the flagged *out-of-band recovery* why-layer Concept is now **built** ([`Out-of-Band-Recovery`](../../Atlas-Academy/Concepts/Out-of-Band-Recovery.md), #31) — the 📋 "warranted" flag flips to the ✅ live link. No normative change to any requirement. |
| 2.0 | 2026-08-03. **Rewrote the thin v1.0 into an estate-grounded, testable standard** (#39/#42): the serial-console break-glass (✅ proven on the 1941), the iDRAC OOB target + its honest `CM-0012`/`ADR-0017` block, the air-gapped Root CA + paper-passphrase custody (✅ Lab-01, with the 🔴 media-off-site gap named), and OT VLAN-90 segmentation (⬜ Phase 7) — each with a read-back + honest markers, the home-lab scope note, the **Learn it (Academy)** section, and feeds/fed-by links. Cut from `STD-Template`. |
| 1.0 | 2026-07-22. Thin Standard — named the requirement; added no new control. (Superseded by v2.0.) |
