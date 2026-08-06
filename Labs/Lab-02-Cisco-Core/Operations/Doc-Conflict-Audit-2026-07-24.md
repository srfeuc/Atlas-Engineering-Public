---
Title: Lab-02 Documentation Conflict Audit (Architecture + Windows-Infrastructure) — 2026-07-24
Path: Labs/Lab-02-Cisco-Core/Operations
Status: 🟢 Audit record (flag-only). **No source docs were changed by this audit.** HIGH/MED findings re-verified directly 2026-07-24 (see Verification status). Each fix is a separate, tracked change (`POL-0003`). Per `POL-0001` (audit policy).
Version: 1.1
Date: 2026-07-24
---

# Lab-02 — Documentation Conflict Audit (2026-07-24)

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** — a **documentation-consistency** audit (docs vs the current, device-verified design), run before populating **NetBox** as the source of truth (`POL-0004`) so stale role/service/PKI data does not get encoded into it. Scope: the **Architecture** and **Windows-Infrastructure** doc sets. **Devices** pages were treated as current (operator's call) and not audited. `00-Atlas-Foundation` is a separate follow-up pass.

## Method
- Three independent read-only passes (Microsoft/AD build · PKI/CA · networking/service), each comparing its docs against the **current authoritative design** as of 2026-07-24 (below), quoting real text, flagging only.
- **Authoritative baselines used** (these are current — audited *against*, not audited): `IP-Addressing-Plan-VLSM.md` (v1.2), `SW01-PVE01-Native-VLAN-Options.md` (v1.1), the device-verified Build-Guides (SW01 v0.7, MKT01 v0.7, DC01, AD CS guide), and ADRs `0023` (topology), `0027` (two-tier AD CS), `0028` (FGT LDAPS), `0004` (NPS/FreeRADIUS), `0003` (AD CS/OpenSSL coexistence), `0007` (atlas.lab), `0021` (tiered identity).

## The current design, in brief (the yardstick)
1. **AD**: domain `atlas.lab`; DC01 `10.20.0.2` promoted, DC02 `10.20.0.3` replica; Microsoft tier model; OUs **Devices/Employees** (not Computers/Users); PAW/tiered accounts/LAPS/PSO.
2. **Addressing**: `10.<vlan>.0.0/<mask>`, gateways on MKT01; VLAN10 Mgmt /27, 20 Servers /26 (Tier-0 carve `.2–.9` = DCs+CAs), 40 Mon /28, etc. Hosts: ICA01 `.20.0.4`, SRV01 `.20.0.10`, NetBox `.20.0.11`, MON01 `10.40.0.10`.
3. **Topology (ADR-0023)**: FGT01 (perimeter/NAT) → 1941 (routed core, no VLANs) → MKT01 (east-west FW + all VLAN gateways) → SW01 (pure L2) → hosts + PVE01.
4. **Trunks (2026-07-24)**: native VLAN **999** (parking) on all trunks; management **tagged VLAN 10** everywhere incl. the PVE01 host (`vmbr0.10`).
5. **PKI (ADR-0027)**: two-tier AD CS — RCA01 offline root + ICA01 issuing (`.20.0.4`) — for the **domain**; OpenSSL (Pi01→CA01) for **non-domain** only (ADR-0003). CRL/AIA at `http://pki.atlas.lab/pki/` on **SRV01 nginx**; revocation is a hard gate (ADR-0009).
6. **Auth**: FGT01 = **direct LDAPS** (ADR-0028); network devices = RADIUS via **NPS-on-DC + FreeRADIUS-on-SRV01** (ADR-0004).
7. **Services**: NetBox = source of truth (VLAN20 `.11`); SRV01 (Ubuntu, VLAN20 `.10`) = nginx CRL host + Kea DHCP + Oxidized + rsyslog; MON01 (VLAN40 `.10`); Pi01 (VLAN10) = Pi-hole DNS + chrony NTP.

## Severity legend
- **🔴 HIGH** — would drive a wrong build or feed wrong data into NetBox (source of truth).
- **🟠 MED** — stale/misleading; a decision or role that has since changed.
- **🟡 LOW** — cosmetic / stale-by-omission / Lab-01 leftover.

---

## 🔎 Verification status (re-verified directly 2026-07-24, no subagents)
**Quote-confirmed:** H1, H3, M1, M2, M3, M5, M6, M7, M8, M9, M10, M11, M13, M14, L1, L2, L3, and the meta-finding. **Tempered/corrected on re-read:** **H2** (304 is a "research/reference compilation, *not* a build guide" — it notes the FreeRADIUS/FGT arrangement as context and recommends *coexist*; it doesn't prescribe "build FGT with RADIUS" → severity HIGH→MED, and now moot since FreeRADIUS is dropped); **M4** (❌ **retracted** — the doc's "revocation is currently non-functional … moot *until that's fixed*" is **accurate**: no working CRL is served yet, legacy *or* AD CS, so it's a correct current statement, not stale); **M12** (heavily hedged Azure musing — "could plausibly serve … needs its own research pass" — not a current-design claim → LOW); **L4** (states a *true* current fact — FGT01 holds an old OpenSSL cert — historical, not a conflict). Net: the Lab-02 list held up better than the Foundation one (no invented attribution like Foundation's M5).

## 🔴 HIGH

| # | File | Where | Conflict |
|---|---|---|---|
| H1 | `Windows-Infrastructure/303-Windows-Design-Standards.md` | Part 3 OU tree — `├── Computers` / `├── Users` | OU skeleton uses **Computers/Users**; authoritative naming is **Devices/Employees** (the built-in-container collision, device-verified on DC01). As the design-standards doc it would mis-drive OU + GPO/tier targeting. |
| H2 → **MED (tempered)** | `Windows-Infrastructure/304-Microsoft-Architecture-Reference.md` | NPS section — "the FreeRADIUS instance already running on Pi01"; "MKT01/FGT01-equivalent NAS entries" | ✅ verified the text exists, but 304 is explicitly a **"research/reference compilation, not an Atlas Build Guide"** that notes the (then-current) FreeRADIUS/FGT arrangement and recommends *coexist* — it does **not** prescribe building FGT01 on RADIUS. Stale (FGT01 = LDAPS per ADR-0028) and now **moot** (FreeRADIUS dropped 2026-07-24 → Windows NPS). Downgraded from HIGH. |
| H3 | `Architecture/Master-Build-Order.md` | Phase 2 — "trunk to SW01 `Gi1/0/4` (native VLAN 10)" + the "a VM tagged VLAN 10 breaks" lesson | Pre-2026-07-24 design. Native is now **999** on all trunks; management is **tagged VLAN 10** (incl. `vmbr0.10`); the "VLAN-10 VMs break" lesson is **inverted** (they work now). Would rebuild the exact defect just fixed. |

## 🟠 MED — the PKI story predates the two-tier AD CS (ADR-0027/0028)

| # | File | Where | Conflict |
|---|---|---|---|
| M1 | `304-Microsoft-Architecture-Reference.md` | "Does AD CS Replace or Coexist…" | Presents PKI as an **open question**; two-tier CA "on Pi01". Decided: two-tier **AD CS** (RCA01+ICA01) for domain + OpenSSL (Pi01→CA01) for non-domain (ADR-0027/0003). |
| M2 | `303-Windows-Design-Standards.md` | Part 5 "AD CS (if built)"; Part 7 "resolve the coexist-vs-replace ADR first" | AD CS treated as conditional/undecided. It's committed (ADR-0027); the RADIUS split is decided (0004/0028). |
| M3 | `Architecture/CA-Migration-Handoff-Sanity-Check.md` | Section A/B | Frames **OpenSSL CA01 as *the* lab trust anchor**; never mentions AD CS/RCA01/ICA01; claims "both design docs put the CA in the VLAN-20 Tier-0 carve `.2–.9`" (that carve is *domain* Tier-0 = ICA01 `.4`, not the non-domain CA01). |
| ~~M4~~ **RETRACTED** | `Architecture/CA-PKI-Recovery-Objectives-RPO-RTO.md` | §2.2 — "revocation is currently non-functional … so the revocation half of RTO is moot *until that's fixed*" | ❌ **Not a conflict — the statement is accurate.** No working CRL is served yet (legacy CA had none per ADR-0009; the AD CS CRL host isn't built — the revocation gate is *pending*, not passed), and the doc explicitly caveats "until that's fixed." Correctly scoped current statement. The v1.0 draft was wrong to flag it. |
| M5 | `Architecture/Atlas-Service-Architecture.md` | Part 4 / Part 2 / Part 6 | Single Root→Intermediate model; identity as a throwaway single "DC01-LAB". Now two coexisting two-tier hierarchies + full DC01/DC02 on atlas.lab. |
| M6 | `Architecture/Lab-02-Device-Role-Assignments.md` | VM-estate — "CA01 \| AD CS issuing CA (domain) alongside the OpenSSL Intermediate" | Conflates **ICA01** (AD CS issuing `.4`) and **CA01** (OpenSSL non-domain intermediate) as one box. Distinct hosts. |

## 🟠 MED — RADIUS host / services / DC state

| # | File | Where | Conflict |
|---|---|---|---|
| M7 | `304-…Reference.md`; `Master-Build-Order.md` | "FreeRADIUS on Pi01" / "point FreeRADIUS (Pi01) at AD" | FreeRADIUS is **on SRV01** (ADR-0004); Pi01 is reduced to Pi-hole DNS + chrony NTP. Also self-contradicts the Pi01-reduction. |
| M8 | `Lab-02-Device-Role-Assignments.md` | VM-estate — "DC01/DC02 … **DHCP** …" | DHCP is **Kea on SRV01** (+ MKT01 relay); infra static. Not a DC service. |
| M9 | `Atlas-Service-Architecture.md`; `Lab-02-Device-Role-Assignments.md` | SRV01 role rows | SRV01 listed as TFTP/SFTP/NTP/Oxidized/rsyslog — **missing nginx CRL host `pki.atlas.lab` + Kea DHCP**; wrongly puts **NTP** on SRV01 (→ Pi01) and **NPS** on SRV01 (→ the DC). |
| M10 | `304-…Reference.md`; `303-…Standards.md` | "DC01 … currently on VLAN 10 untagged"; "promote it (still pending)"; "DC02 once VLAN/DHCP stable" | DC01 = `10.20.0.2` **VLAN 20**, **promoted**; DC02 = `.3` **replica**. "Not promoted / VLAN 10 untagged" is stale on both host placement and tagging. |
| M11 | `Atlas-Service-Architecture.md` | Part 5.2 — LibreNMS `10.40.0.20`, Grafana `.30`, Wazuh `.10` | MON01 is **one host at `10.40.0.10`**; the per-service `.20/.30` (from the deprecated `006`) misrepresents a single host and is internally inconsistent. |

## 🟠 MED — topology-edge / order / naming

| # | File | Where | Conflict |
|---|---|---|---|
| M12 → **LOW (tempered)** | `304-…Reference.md`; `302-…Roadmap.md` | Azure S2S — "**MKT01 could plausibly serve** as that device … needs its own research pass … before treating it as confirmed" | ✅ text verified, but it's a **heavily hedged forward-looking Azure musing**, not a current-design claim — 304 is a reference/planning doc. The point stands (the perimeter/public edge is **FGT01**, so a tunnel belongs there), but it's speculative, not a wrong current fact. Downgraded from MED. |
| M13 | `Architecture/Pre-Teardown-Backup-and-Verify-Checklist.md` | "Safe teardown sequence" step 3 | Encodes the **old** order (identity last, NetBox before the CA). Current Master-Build-Order sequences Identity to Phase 3 and pulls AD CS forward. |
| M14 | `303-…Standards.md` | Part 2 — "`atlas.lab` … **NOT `atlas.lab`**"; "`<device>.lab`" | A find/replace artifact that literally negates the correct value and implies single-label host naming (should be `<host>.atlas.lab`, cf. `pki.atlas.lab`). Confusing; clean up. |

## 🟡 LOW

| # | File | Where | Conflict |
|---|---|---|---|
| L1 | `304-…Reference.md` | Azure — "AZ-800/801 study value" | AZ-801 retires 2026-09-30 → AZ-802 (ADR-0008); `303` already updated, `304` not. Cosmetic. |
| L2 | `Architecture/Cabling-and-Port-Map.md` | Link #4 — "Carries: VLANs 10–90" | Stale-by-omission: no native-VLAN column; VLAN 999 (parking) not shown. Predates the 2026-07-24 native change. |
| L3 | `Architecture/Lab-02-Offline-Root-CA-Build-Design.md` | "air-gapped LUKS Root" vs authoritative "Pi01 root → CA01" | Reconcile the OpenSSL chain root: new greenfield air-gapped root (this doc) vs "Pi01 root" (current snapshot wording). |
| L4 | `CA-Migration-Handoff-Sanity-Check.md` | Section D — "FGT01's `fortigate.lab` cert … live" | FGT01's authoritative PKI relationship is now **AD CS (ICA01)** per ADR-0028, not the Pi01 OpenSSL CA. |

## ✅ Clean / current (audited, no material conflict)
- `Windows-Infrastructure/302-…Roadmap.md` (except M12) · `Windows-Infrastructure/README.md`
- `Architecture/CA-Migration-and-DR-Lab.md` (scoped throwaway DR drill on the retired Pi01) · `Architecture/Lab-02-Offline-Root-CA-Build-Design.md` (most current PKI doc; only L3) · `Architecture/Lab-02-Per-Device-Config-Design-Checklists.md` · `Architecture/Cabling-and-Port-Map.md` (except L2)
- **Reference/authoritative (not audited):** `IP-Addressing-Plan-VLSM.md`, `SW01-PVE01-Native-VLAN-Options.md`.

## 🔎 Meta-finding (most relevant to NetBox)
Across all four Windows-Infrastructure docs, **NetBox is never named as the source of truth** — `304` still points builders at the static `006-Network-Source-of-Truth.md`. Once NetBox is populated it will silently compete with these docs. `Atlas-Service-Architecture.md` and `Lab-02-Device-Role-Assignments.md` are the two most likely to feed **wrong data into NetBox** (stale SRV01/CA/DHCP/monitoring rows) and should be reconciled **before** population.

## Recommended reconciliation order (each a separate tracked change)
1. **Before NetBox population:** M6/M8/M9 (SRV01/CA/DHCP role rows in `Atlas-Service-Architecture` + `Lab-02-Device-Role-Assignments`) and M11 (MON01 address).
2. **Build-blocking:** H1 (OU names), H2 (FGT LDAPS), H3 (native-999 in Master-Build-Order).
3. **PKI narrative:** M1–M5, L3, L4 — add an "authoritative PKI = two-tier AD CS (domain) + OpenSSL (non-domain)" preamble; correct CA naming/placement.
4. **Cleanups:** M7, M10, M12, M13, M14, L1, L2.

## Change Log
| Version | Date | Change |
|---|---|---|
| 1.1 | 2026-07-24 | **Direct re-verification pass** (no subagents). Quote-confirmed H1/H3/M1/M2/M3/M5/M6/M7/M8/M9/M10/M11/M13/M14/L1/L2/L3 + meta. **Retracted M4** (the "revocation non-functional" statement is accurate, correctly caveated). **Tempered H2** (304 is a reference doc, not prescriptive; HIGH→MED; moot now FreeRADIUS is dropped) and **M12** (hedged Azure musing; MED→LOW). Added the verification-status block. Note: H3 fix means **`Master-Build-Order.md` still needs the native-VLAN-10→999 update** (SW01 Build-Guide + 204 were updated 2026-07-24, this one wasn't). FreeRADIUS-dropped (2026-07-24) makes M7/H2 moot. |
| 1.0 | 2026-07-24 | Created — documentation-consistency audit of the Lab-02 Architecture + Windows-Infrastructure doc sets against the 2026-07-24 authoritative design (three independent read-only passes). 3 HIGH, 11 MED, 4 LOW findings + the NetBox-not-named-as-SoT meta-finding; clean docs listed; reconciliation order recommended. Flag-only — no source docs changed. |
