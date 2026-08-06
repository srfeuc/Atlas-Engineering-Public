---
Title: STD-0002 — Access Control Standard
Path: 00-Atlas-Foundation/Standards
Status: ✅ Adopted 2026-08-03 under `POL-0010` via `ADR-0021`. In force; most enforcement 📋 pending the tier-deny GPOs + the PAW (tracked in Verification).
Version: 2.1
---

# STD-0002 — Access Control

> **At a glance.** Authorization runs on AGDLP with per-tier admin groups; a higher-tier credential is *denied logon* to a lower tier; Tier-0 is administered only from the PAW, and only auth protocols reach the identity micro-zone — each pinned to a real group/flow and provable with a read-back.

| Item | Value |
|---|---|
| Layer | **Standard** — the concrete authorization model; binds real AD groups, GPOs, and east-west flows |
| Governing policy | [`POL-0010`](../Policies/POL-0010-Acceptable-Use.md) — Acceptable Use / access |
| Requirement, in one line | AGDLP grouping · per-tier admin groups · cross-tier deny-logon · Tier-0 only via the PAW · least privilege |
| Owner | Security silo ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) silos) |
| Adopting decision | [`ADR-0021`](../Decisions/ADR-0021-AD-as-Tiered-Identity-Backbone.md) (tiered identity/AGDLP) + [`ADR-0042`](../Decisions/ADR-0042-Client-Workstation-Fleet-and-Department-Resource-Access.md) (dept resource access) → under [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) |
| Applies to | the DC (groups/GPOs) · [`PAW01`](../../Labs/Lab-02-Cisco-Core/Devices/PAW01-Tier0-Admin/) · the identity micro-zone `10.20.0.2–.9` · every authorized resource |
| Feeds / fed by | **fed by** [`STD-0001`](./STD-0001-Password-and-Authentication.md) (the accounts it authorizes) · **feeds** the [`Atlas-East-West-Allowed-Flows-Matrix`](../../Labs/Lab-02-Cisco-Core/Architecture/Atlas-East-West-Allowed-Flows-Matrix.md) (flows #9/#23 render this model) |
| Verified by | [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* read-backs below |
| Framework mapping | CIS v8 Ctl 5/6 · NIST 800-53 AC · Microsoft Enterprise Access Model · Security+ 5.x · AZ-800/801 |

---

## Scope & applicability

Binds *what an authenticated identity may do*: the grouping model, the admin-tier boundaries, and the paths into Tier-0.

**Boundary with adjacent standards/policies:** *who you are* (accounts, passwords, MFA) is [`STD-0001`](./STD-0001-Password-and-Authentication.md); this standard begins once you're authenticated. *Hardening the PAW itself* is [`POL-0007`](../Policies/POL-0007-Hardening-Baseline.md). *The firewall enforcement* of these flows is [`STD-0004`](./STD-0004-Encryption.md)-adjacent segmentation, owned by the flows matrix.

## Why a standard, not left in a guide

Without a uniform model, "who can log on where" becomes per-server folklore — the exact path lateral movement takes. Atlas's answer is tiering: a Tier-0 credential must be **structurally unable** to authenticate to a lower tier, and Tier-0 must be reachable only from a known, hardened surface. A standard makes that testable (the flagship *"Tier-2 can't touch Tier-0"* proof) instead of assumed.

---

## The requirements

Each is citable as `STD-0002 R#`. Real groups/flows on named targets.

### R1 — Authorization uses AGDLP

Accounts → **Global** role groups → **Domain-Local** resource groups → permission. No user or admin is granted a permission directly. **Applies to:** every resource grant. **Owner doc:** [`ADR-0021`](../Decisions/ADR-0021-AD-as-Tiered-Identity-Backbone.md) + the DC [`Build-Checklist` §7](../../Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers/Build-Checklist.md).

### R2 — Admin rights flow only through the per-tier groups

The tier admin globals **`G-Tier0-Admins` / `G-Tier1-Admins` / `G-Tier2-Admins`** (+ **`G-IT-Staff`**) are the *only* source of admin rights, each scoped to its tier; department role globals (**`G-Sales` / `G-Finance` / …**) grant resource (not admin) access. **Applies to:** the DC. **Owner doc:** [DC `Build-Checklist` §7](../../Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers/Build-Checklist.md). **Status:** tier globals + `G-IT-Staff` ✅ **device-verified 2026-07-22**; dept globals/DLs 📋 designed (arrive with the user population).

### R3 — A higher-tier credential is denied logon to a lower tier (the "7d" GPOs)

**Five cross-tier deny-logon-rights GPOs** enforce the tier boundary — a Tier-0 identity is **denied interactive/RDP/network logon** on Tier-1/2 hosts (and vice-versa), **never linked at the domain root**. This is the control behind the flagship **"Tier-2 can't touch Tier-0"** proof. **Applies to:** the tier OUs. **Owner docs:** [DC `Build-Checklist` §6 (7d)](../../Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers/Build-Checklist.md); the itemized five deny-rights + the denial test live in [`Validation-and-Adversarial-Testing`](../../Labs/Lab-02-Cisco-Core/Operations/Validation-and-Adversarial-Testing.md). **Status: 🔴 ⬜ not built** — **unblocked** now the tier groups exist; the single most important open access control.

### R4 — Tier-0 is administered only from the PAW; only auth reaches it

Interactive Tier-0 administration comes **only from [`PAW01`](../../Labs/Lab-02-Cisco-Core/Devices/PAW01-Tier0-Admin/)** (east-west **flow #23** — RDP/WinRM/RSAT into `10.20.0.2–.9`; *deny admin logon to Tier-0 from any non-PAW source*); everything else reaching the identity micro-zone is **auth-only** — LDAPS/Kerberos/DNS (**flow #9**, *"the only thing that reaches Tier 0"*). PAW01 sits on **VLAN 10 mgmt `10.10.0.8`** (per the IP plan v1.10 — its README's VLAN-20 line is stale). **Owner docs:** [`PAW01`](../../Labs/Lab-02-Cisco-Core/Devices/PAW01-Tier0-Admin/) · [flows matrix #9/#23](../../Labs/Lab-02-Cisco-Core/Architecture/Atlas-East-West-Allowed-Flows-Matrix.md) · [`IP-Addressing-Plan-VLSM`](../../Labs/Lab-02-Cisco-Core/Architecture/IP-Addressing-Plan-VLSM.md). **Status: 📋 PAW01 not built;** until the 7d GPOs (R3) are linked, the boundary is *structural only* (OU/GPO placement), **not enforced**.

### R5 — Least privilege + Protected Users

Daily work uses the standard account; admin uses the tier account (`STD-0001 R4`); **`t0-seth` is in Protected Users** (no NTLM), which is *why* Tier-0 must come through the PAW. Standard users receive resource access only via the AGDLP DL groups (R1), never direct. **Read-back:** `Get-ADGroupMember "Protected Users"`.

---

## Adopting & amending decisions

The dated trail (kept, never deleted; originals in the legacy snapshot).

| Decision | Status | What it did |
|---|---|---|
| [`ADR-0021`](../Decisions/ADR-0021-AD-as-Tiered-Identity-Backbone.md) | Accepted | the tiered model, AGDLP, the tier groups + Protected Users (R1/R2/R3/R5) |
| [`ADR-0042`](../Decisions/ADR-0042-Client-Workstation-Fleet-and-Department-Resource-Access.md) | Accepted | the department resource-access model (R2 dept globals) |

## Verification (how conformance is proven)

Real read-backs — the [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) audit runs these; the device wins over the doc.

- [x] **R1/R2** — `Get-ADGroupMember G-Tier0-Admins` (+ Tier1/2, G-IT-Staff) returns the expected members; no direct-ACE grants (✅ groups verified 2026-07-22).
- [ ] **R3** — 🔴 `gpresult /r` on a Tier-1/2 host shows the deny-logon GPO; the denial test: a Tier-2 account is **refused** interactive/RDP logon to a DC (gated on the 7d build).
- [ ] **R4** — from a non-PAW host, admin RDP to `10.20.0.x` is **denied**; from PAW01 it succeeds (gated on PAW01 + 7d).
- [x] **R5** — `Get-ADGroupMember "Protected Users"` includes `t0-seth`; `whoami /groups` shows tier-only membership.
- [ ] **Meta** — any change to a value here traces to an amending ADR + a Change Log row.

> Markers are honest (`POL-0006`): the **groups/accounts are ✅ built**, but the **enforcement (R3 tier-deny, R4 PAW) is ⬜/📋** — this standard is *structured but not yet enforced*, and says so.

## Learn it — the Academy (the source of truth for the *why* + the commands)

- 🎓 **Concept (why it works):** [AGDLP — Granting Rights to Groups, Not People](../../Atlas-Academy/Concepts/AGDLP-Granting-Rights-to-Groups-Not-People.md) (the authorization model this standard runs on) · [Tiered-Admin Model](../../Atlas-Academy/Concepts/Tiered-Admin-Model.md) (the Enterprise Access Model + why cross-tier logon is denied) · [Concepts index](../../Atlas-Academy/Concepts/)
- 🖥️ **Commands (run the read-backs):** [PowerShell-Tier0](../../Atlas-Academy/Command-Library/PowerShell-Tier0.md) (`Get-ADGroupMember`, `gpresult /r`, `whoami /groups`)
- 🏅 **Cert objective:** [AZ-800/801](../../Atlas-Academy/Certification/AZ-800-801-Windows-Server-Hybrid-Lab-Map.md) (GPO/tiering/AGDLP) · [Security+ Domain-5](../../Atlas-Academy/Certification/Atlas-Security-Plus-Domain5-Coverage-Map.md)
- 📋 **Security program:** [Compliance Program](../Security-Program/Atlas-Compliance-Program.md) (the access-control mapping) · [Incident Response](../Security-Program/Incident-Response-Playbook.md) (lateral-movement containment)

## What a violation looks like

A permission granted to a user directly (no AGDLP DL group) · a Tier-2 account that **can** RDP a DC (R3 not enforced) · admining Tier-0 from a non-PAW host · a deny-logon GPO **linked at the domain root** · `t0-seth` outside Protected Users · a dept user in a Tier-admin global.

## Related

[`POL-0010`](../Policies/POL-0010-Acceptable-Use.md) (governing) · [`STD-0001`](./STD-0001-Password-and-Authentication.md) (who you are) · [`ADR-0021`](../Decisions/ADR-0021-AD-as-Tiered-Identity-Backbone.md) · [`PAW01`](../../Labs/Lab-02-Cisco-Core/Devices/PAW01-Tier0-Admin/) · the [flows matrix](../../Labs/Lab-02-Cisco-Core/Architecture/Atlas-East-West-Allowed-Flows-Matrix.md) · the [Standards register](./README.md) · [the framework](../Governance/Atlas-Governance-Framework.md).

## Change Log

| Version | Changes |
|---|---|
| 2.1 | 2026-08-04. **Learn-it:** added the new dedicated why-layer Concept [`AGDLP — Granting Rights to Groups, Not People`](../../Atlas-Academy/Concepts/AGDLP-Granting-Rights-to-Groups-Not-People.md) (the authorization model + the structured-vs-enforced gap). No normative change to any requirement. |
| 2.0 | 2026-08-03. **Rewrote the thin v1.0 into an estate-grounded, testable standard** (#39/#42): the AGDLP model, the real `G-Tier0/1/2-Admins`/`G-IT-Staff` groups (✅ verified) + dept globals (📋), the five-GPO cross-tier deny-logon control (⬜ unblocked — the flagship *Tier-2-can't-touch-Tier-0* proof), the PAW-only Tier-0 path (flows #9/#23; PAW01 on VLAN 10 per IP plan v1.10), and Protected Users — each with a read-back + honest ✅/⬜/📋 markers, the **Learn it (Academy)** section, and feeds/fed-by links. Cut from `STD-Template`. |
| 1.0 | 2026-07-22. Thin Standard — named the requirement; added no new control. (Superseded by v2.0.) |
