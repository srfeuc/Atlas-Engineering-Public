---
Title: POL-0007 — Hardening Baseline Policy
Path: 00-Atlas-Foundation/Policies
Status: ✅ Adopted 2026-08-03 under `ADR-0026` (framework). In force.
Version: 2.0
---

# POL-0007 — Hardening Baseline

> **At a glance.** Every device meets a **named, CIS-informed baseline**. Every interface or service with no assigned purpose is disabled — and the reason for any kept-enabled one is *recorded*. A hardening tick needs the command output, not a config line; and hardening never removes the way back in without a proven recovery path. This policy folds the estate's hardening discipline into citable requirements (`POL-0007 R1`…) and doubles as a directory of the decisions that govern hardening (below).

| Item | Value |
|---|---|
| Layer | **Policy** — a standing requirement; governs the Standards, ADRs, and Changes beneath it |
| Requirement, in one line | A named baseline per device; unused interfaces/services disabled (kept ones justified); every tick evidence-backed; recovery preserved. |
| Owner | 🔴 Security silo ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md)) |
| Adopting decision | [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) — elevating the buried unused-interface rule (`010`) + the `045`–`047`/`CIS-Hardening-*` checklists |
| Governs the standards | [`STD-0004` Encryption](../Standards/STD-0004-Encryption.md) (the crypto values) · [`STD-0003` Physical/OOB](../Standards/STD-0003-Physical-Security.md) (console/OOB) |
| Builds on | [`POL-0006`](./POL-0006-Evidence-and-Verification.md) (every tick evidence-backed) · [`POL-0002`](./POL-0002-Secrets-and-Credentials.md) (no default/shared creds) |
| Verified by | [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* checklist below |
| Framework mapping | NIST CSF 2.0 `PR.PS` / `PR.AA` · CIS Controls v8 **4** (Secure Configuration) · Security+ 5.x |

---

## Scope & applicability

Governs the secure-configuration baseline of every device and service — the imported baseline, the interface/service surface, the management plane, and the recovery path a hardening change must not sever.

**Boundary with the standards it governs:** the *crypto values* (SSH ciphers, secret hashing) are [`STD-0004`](../Standards/STD-0004-Encryption.md); the *console/OOB path* is [`STD-0003`](../Standards/STD-0003-Physical-Security.md); POL-0007 owns *that* a named baseline is met and the surface is closed. Evidence for every tick is [`POL-0006`](./POL-0006-Evidence-and-Verification.md).

## Why this is a policy, not a note

The unused-interface rule already existed, **buried inside a Standards doc** (`010`), un-enumerable — and was violated repeatedly: `CM-0015` (MKT01 `ether2`, enabled and undocumented), `CM-0033` (FGT01 `internal3-7` + a factory `dmz` interface — **five live ports and an L3 interface, unassessed, on the perimeter firewall**), Pi01's `wlan0`. A rule you can't list is a rule you can't audit.

---

## The standing requirements

Each is citable as `POL-0007 R#`.

### R1 — A named baseline per device, imported not invented

Each device carries a named, version-matched baseline — CIS Cisco IOS, MikroTik "Securing your router", CIS/Fortinet Hardening, CIS Debian, **CIS Windows Server + the Microsoft Security Baseline** — as its `CIS-Hardening` doc, then layers the estate's own policies on top (a *tested starting point*, not a hand-built pile).

### R2 — Unused interfaces and services are disabled; kept ones are justified

Every interface/service with no assigned purpose is disabled; **any kept-enabled port's reason is recorded** (an uplink, a planned role, a break-glass path). *"Available" is not a state* — a silent enablement is a finding (`CM-0015`/`CM-0033`).

### R3 — Every hardening tick is evidence-backed

A tick needs the command output, not a config line ([`POL-0006`](./POL-0006-Evidence-and-Verification.md) R2) — *five false ticks* came from ignoring this. A control is either **enabled and verified working**, or **formally accepted out of scope by an ADR** (the FGT01 UTM case) — never a stale profile that *looks* protective.

### R4 — The management plane is locked down

SSH not Telnet; no HTTP admin; management scoped to the Management zone; MFA where supported; no default/shared credentials ([`POL-0002`](./POL-0002-Secrets-and-Credentials.md)); the strong-crypto values per [`STD-0004`](../Standards/STD-0004-Encryption.md).

### R5 — Hardening preserves the way back in

Any hardening change **preserves the break-glass recovery path** ([`STD-0003`](../Standards/STD-0003-Physical-Security.md)) — proven *before* the change (the 1941's SSH hardening was finished over the serial console after it self-blocked). *Hardening deletes the way back in* unless recovery is proven first.

---

## Decisions governed by this policy

> Which decisions serve this policy — **generated** from the ADRs' `Governing Policy:` lines (`tools/Build-Policy-Directories.ps1`). Do not hand-edit.

<!-- BEGIN AUTOGEN:decisions POL-0007 · generated by tools/Build-Policy-Directories.ps1 — do not hand-edit -->
| Decision | Status | Governing Policy |
|---|---|---|
| [ADR-0003 — AD CS vs. the Existing OpenSSL Lab CA: Coexist or Replace](../Decisions/ADR-0003-AD-CS-vs-OpenSSL-Lab-CA.md) | Accepted | POL-0007 |
| [ADR-0013 — Retirement of `bridgeLocal`, the Admin Recovery Network](../Decisions/ADR-0013-Retire-bridgeLocal-Recovery-Network.md) | Proposed — gated, deliberately NOT scheduled | POL-0007 |
| [ADR-0014 — MKT01 Layer-2 Management Posture: MAC-WinBox, MAC-Telnet,…](../Decisions/ADR-0014-MKT01-Layer2-Management-Posture.md) | ✅ ACCEPTED — operator, 2026-07-14. Option C: MAC-WinBox s… | POL-0007 (+POL-0009) |
| [ADR-0023 — Lab-02 Core & Segmentation Topology: 1941 as Core Router,…](../Decisions/ADR-0023-1941-Core-MKT01-East-West-Firewall-Topology.md) | Proposed | `POL-0007` (Hardening Baseline) · candidate *POL — Network Segmentation* (framework, not yet written) |
| [ADR-0027 — AD CS Two-Tier PKI, Built the Microsoft-Recommended Way](../Decisions/ADR-0027-AD-CS-Two-Tier-Microsoft-PKI.md) | Proposed — 2026-07-22 (operator accepts by moving to Acce… | POL-0007 |
| [ADR-0031 — Retire the OpenSSL Lab CA: One Unified PKI on AD CS](../Decisions/ADR-0031-Retire-OpenSSL-Lab-CA.md) | Accepted (operator, 2026-07-28). Reverses ADR-0003. | POL-0007 |
| [ADR-0038 — pfSense as a Transparent Inline IPS on the North-South Ed…](../Decisions/ADR-0038-pfSense-Inline-IPS-North-South.md) | Accepted (operator, 2026-07-29). Reshaped by ADR-0047 (20… | POL-0007 (+POL-0009) |
| [ADR-0042 — Client Workstation Fleet + Department Resource Access](../Decisions/ADR-0042-Client-Workstation-Fleet-and-Department-Resource-Access.md) | Accepted (operator, 2026-07-29). Scope addition; phased, … | POL-0007 (+POL-0010) |
| [ADR-0047 — FGT01 Runs FortiGuard UTM (Reverses ADR-0035; Reshapes AD…](../Decisions/ADR-0047-FGT01-FortiGuard-UTM.md) | Accepted in principle (operator, 2026-07-29) — the FortiG… | POL-0007 (+POL-0009) |
| [ADR-0050 — FGT01 TLS/SSL Deep-Inspection Scope + ICA01 Inspection-CA…](../Decisions/ADR-0050-FGT01-TLS-Deep-Inspection-Scope-and-ICA01-Inspection-CA.md) | Accepted (operator, 2026-07-30) — the K1 disposition reco… | POL-0011 (+POL-0007) |
| [ADR-0051 — DNS-Filtering Ownership: Pi-hole Owns It, FortiGuard DNS-…](../Decisions/ADR-0051-DNS-Filtering-Ownership-Pi-hole-Not-FortiGuard.md) | Accepted (operator, 2026-07-30) — recorded at the FGT01 #… | POL-0004 (+POL-0007) |
<!-- END AUTOGEN:decisions POL-0007 -->

## The amendment model — how these decisions relate to this policy

This policy holds the **current** rule; the decisions behind it are the **dated trail**. To change a rule, an ADR carries `Governing Policy: POL-0007`, states *"amends `POL-0007` R#"*, and a Change Log row is added ([`ADR-0054`](../Decisions/ADR-0054-Governance-Reconciliation-Promote-Policy-Shaped-ADRs.md)); preserved, never deleted (legacy snapshot).

## Verification (how compliance is proven)

- [ ] **R1** — each device has a current `CIS-Hardening` doc whose ticks cite command output.
- [ ] **R2** — `show interfaces status` / `/interface print` — unused ports **disabled**; kept-up exceptions documented with a reason.
- [ ] **R3** — no stale UTM/AV profile attached and pretending to protect; each control is verified-working or ADR-accepted-out-of-scope.
- [ ] **R4** — no cleartext management (Telnet/HTTP) enabled; management scoped; no default/shared credentials.
- [ ] **R5** — a proven console/OOB recovery path exists before any mgmt-plane hardening ([`STD-0003`](../Standards/STD-0003-Physical-Security.md)).
- [ ] **Meta** — every change to a rule here traces to an amending ADR + a Change Log row.

## What a violation looks like

An enabled, undocumented interface (`ether2`, `internal3-7`) · a hardening tick made from a config line · Telnet/HTTP left on · a default credential · a stale UTM/AV profile pretending to protect · a mgmt-plane change made with no proven recovery path.

## Related

[`Atlas-Governance-Framework`](../Governance/Atlas-Governance-Framework.md) · [`STD-0004`](../Standards/STD-0004-Encryption.md) / [`STD-0003`](../Standards/STD-0003-Physical-Security.md) (governed standards) · [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md) · [`POL-0006`](./POL-0006-Evidence-and-Verification.md) · the per-device `CIS-Hardening-*` docs · the [Security & Perimeter directory](../../Atlas-Academy/Directory/Security-and-Perimeter.md).

## Learn it — the Academy (the why + the read-backs)

- 🎓 **Concept (why it works):** [Hardening from a Tested Baseline](../../Atlas-Academy/Concepts/Hardening-from-a-Tested-Baseline.md) (import a tested baseline + layer on top · "available is not a state" · a tick is a claim until read back) · [Out-of-Band Recovery](../../Atlas-Academy/Concepts/Out-of-Band-Recovery.md) (hardening deletes the way back in) · [A Completed Command Is Not Evidence](../../Atlas-Academy/Concepts/A-Completed-Command-Is-Not-Evidence.md).
- 🔧 **Playbook:** [Enumerate-Every-Enabled-Interface-Before-Hardening](../../Atlas-Academy/Playbooks/Enumerate-Every-Enabled-Interface-Before-Hardening.md).
- 🏅 **Cert objective:** [Security+ Domain-5](../../Atlas-Academy/Certification/Atlas-Security-Plus-Domain5-Coverage-Map.md) (secure configuration) · [AZ-800/801](../../Atlas-Academy/Certification/AZ-800-801-Windows-Server-Hybrid-Lab-Map.md) (baselines/GPO).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-20. First hardening-baseline policy (named baseline · unused-interfaces-disabled · evidence-per-tick · management-plane · recovery-preserved). |
| 2.0 | 2026-08-04. **Reshaped to the golden `POL-0014` shape** (#42): at-a-glance + item table; the requirement-in-detail distilled into citable `R1–R5`; the boundary with `STD-0004`/`STD-0003`; the amendment model; per-`R#` Verification; a **Learn it (Academy)** section pointing at the now-built [`Hardening from a Tested Baseline`](../../Atlas-Academy/Concepts/Hardening-from-a-Tested-Baseline.md) + [`Out-of-Band Recovery`](../../Atlas-Academy/Concepts/Out-of-Band-Recovery.md) concepts; status flipped to ✅ Adopted. AUTOGEN directory unchanged. No normative change. |
