---
Title: DC01/DC02 Build Checklist (Domain Controllers — Tier 0)
Path: Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers
Status: 🔄 IN BUILD (07-22) — Promote/KDS/OU/PDCe-time ✅; AD-DNS ✅ (DHCP ⬜); **GPO 7a baseline+Wave-A · 7b PSO · 7c LAPS · 7c-DSRM ✅ device-verified** (see `Build-Guide/DC01/GPO-Design-and-Build.md` v0.7); `POL-0002` retired. **Stage 8 IN PROGRESS → `Build-Guide/DC01/Tiered-Admin-and-Groups-Build.md` v0.4 (GUI-first): ✅ Part 2 groups device-verified 07-22 (`G-Tier0/1/2-Admins`+`G-IT-Staff`); ✅ Part 3 accounts + off-built-in-Admin device-verified 07-22. DC02 promoted — 🟡 operator-reported 2026-07-28, `repadmin`/`dcdiag` read-back pending (`Build-Guide/DC02/DC02-Build-Guide.md` v0.1).** Remaining: GPO Wave B (VBS/CG) · 7d tier-deny (now unblocked). Verify with dcdiag/repadmin (POL-0001 R-A1).
Version: 1.6
---

# DC01 / DC02 — Build Checklist (Domain Controllers, Tier 0)

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

> **Role:** the tiered identity backbone (`ADR-0021`, `ADR-0025` — permanent, not a throwaway). Windows Server 2025 VMs on PVE01, **VLAN 20 Tier‑0 block** (`DC01 = 10.20.0.2`, `DC02 = 10.20.0.3`, gw `10.20.0.1`, `IP-Addressing-Plan-VLSM`). Design source: **`303`** (corrected) + **`301`** (the company it serves). Hardening: [CIS Microsoft Windows Server Benchmark](https://www.cisecurity.org/benchmark/microsoft_windows_server) + [Microsoft Security Baselines / SCT](https://learn.microsoft.com/windows/security/operating-system-security/device-management/windows-security-configuration-framework/security-compliance-toolkit-10).
>
> 🔴 **Four traps specific to this build — read them first:** `atlas.lab` **not** `atlas.corp`; the **KDS root key 10‑hour delay**; **tiered from day one** (not retrofitted); and the **VM time‑sync fight** on the PDC‑emulator.

## Gate
- [x] Network up (Phase 2) ✅ + working time source (`ADR-0020`) ✅. ⚠ **NetBox not yet built** — DC proceeded ahead per the tracker's Rule-13 divergence (DC-early / in-tandem).
- [x] ✅ DC01 VM existed unpromoted → **promoted `atlas.lab` 07-21**.

## Build order (303 Part 7 / Master‑Build‑Order Phase 5)

### 1. Promote DC01 — the forest/domain
- [x] Static IP `10.20.0.2`; DNS pointing at itself (AD-DNS up + forwarder `1.1.1.1` interim).
- [x] **Promoted to a new forest, domain `atlas.lab`** (`ADR-0007`) — `Get-ADDomain` confirmed. 🔴 *(First attempt landed on `atlas.local` → demoted & re-promoted; wrong domain = rebuild, not rename.)*
- [x] Single forest/domain/site. DSRM password set at promotion — ✅ now **LAPS-managed & rotating** (§7c-DSRM), so `POL-0002` manual-record is **retired** (retrieve via `Get-LapsADPassword -Identity DC01 -AsPlainText`).
- **Verify:** ✅ `Get-ADDomain` = `atlas.lab`; AD-integrated DNS answers. *(Run `dcdiag /v` for a full health pass.)*

### 2. KDS root key — immediately
- [x] ✅ **KDS root key created** (effective-time backdated for immediate lab use — noted). Skipping this makes gMSA creation fail mysteriously days later.
- **Verify:** ✅ `Get-KdsRootKey` returns a key.

- [x] ✅ **Built device-verified 07-21 — see `Build-Guide/DC01/OU-Design-and-Build.md` (authoritative).** 🔺 Reserved-name fix: root `Computers`/`Users` collide with the built-in containers (`8305`) → renamed **`Devices`**/**`Employees`**; `_Admin`→`Admin`; per-tier **Service Accounts** + **PAW** OUs added; `redircmp`→`OU=Staging,OU=Devices`. `Contractors` OU deferred. Built via PowerShell (Marketing by GUI as a learning exercise).
- [x] ✅ Role-based, not departmental — department = group membership, not OU placement.
- [x] ✅ DCs left in the built-in `Domain Controllers` OU (never moved).

### 4. DNS + DHCP
- [x] ✅ **AD-integrated DNS** up on DC01; forwarder `1.1.1.1` interim (→ Pi-hole conditional-forward `atlas.lab`→DCs later, `ADR-0003`/`ADR-0007`). DC02 DNS 🟡 operator-reported up (verify at read-back).
- [ ] **DHCP** — not yet (authorize on a DC or Kea on SRV01 per `ADR-0004`); scopes per `IP-Addressing-Plan-VLSM`. OT gets **no** DHCP.

### 5. Time — PDC‑emulator authority (`ADR-0020`)
- [ ] 🔴 **Confirm the Proxmox/QEMU guest time-sync is disabled** on the PDCe — only bites if the source reverts to CMOS; watch for it. (Left as a standing check.)
- [x] ✅ **PDCe → `time.nist.gov`** (`w32tm /config /manualpeerlist … /syncfromflags:manual /reliable:yes /update`); `/query /source` = external, not CMOS.
- **Verify:** ✅ `w32tm /query /source` on the PDCe = real source; members sync from a DC (verify once members exist).

### 6. Base GPOs (before populating objects)
- [x] ✅ **MS Security Baseline (Server 2025 v2602) imported + Wave-A linked & device-verified** — see `Build-Guide/DC01/GPO-Design-and-Build.md` §7a (8 GPOs, separate purpose-scoped, never one mega Default Domain Policy). ⬜ **Wave B** (DC VBS + Member Server Credential Guard) gated on a Proxmox VBS check. ⬜ **CIS overlay** (separate higher-precedence GPO) not yet.
- [x] ✅ Domain password/lockout set via the baseline **Domain Security** GPO at the root (link order 1). ✅ **Finance/HR PSO** (7b) built & verified — `PSO-FinanceHR` (prec 10, min 15, lockout 3) → `G-FinanceHR-Users`; resultant-policy proof deferred to Stage 8 (no users). See `Build-Guide/DC01/GPO-Design-and-Build.md` §7b.
- [x] ✅ **Windows LAPS** (7c) — schema extended, self-perm on Devices, `LAPS` GPO → Devices. ⏭ Member live-password test + Tier-1-reads/Tier-2-can't test deferred to Stage 8. **Bonus:** DSRM password now LAPS-managed on the DCs (§7c-DSRM, fully verified) → **`POL-0002` retired**.
- [ ] 🔴 ⬜ **Tier enforcement GPOs** (7d) — the five deny-logon rights cross-tier; a higher-tier credential must be *unable* to authenticate to a lower tier (`303` Part 5, `ADR-0021`). **Never at the domain root.**

### 7. Groups (AGDLP) then users
> 📋 Stage 8 build guide → `Build-Guide/DC01/Tiered-Admin-and-Groups-Build.md` (v0.4, GUI-first). **Part 2 (groups) ✅ device-verified 07-22**; Part 3 (accounts) ✅ device-verified 07-22.
- [x] ✅ **AGDLP tier admin groups** (`G-Tier0/1/2-Admins`) — the **7d prerequisite**; all Global/Security in each `Admin\Tier X\Groups` OU, **device-verified 07-22** (`Get-ADGroup` readout in the doc §2 Verify). Plus `G-IT-Staff` (✅ created; 🔎 sits in `OU=Groups` root — recommended Move to `Security-Roles`). *(Dept role globals `G-Sales`/`G-Finance`… + DL resource groups come with the user population — pattern §2c.)*
- [ ] **Service accounts gMSA‑first** (`svc-gmsa-<purpose>`); fall back to sMSA/user only when unsupported, and document why. *(Per-service, later — out of Stage 8 scope.)*
- [ ] **Populate from `AtlasHR` (SQL), not a CSV** (`301`) — the SQL→AD pipeline with write‑back of `sAMAccountName`; handle the deliberate name mess (O'Brien apostrophe, the 20‑char `sAMAccountName` cap, collisions, diacritics).

### 8. DC02 + the tier model, for real
> 🟡 **DC02 promotion operator-reported done 2026-07-28** (`Build-Guide/DC02/DC02-Build-Guide.md`; `repadmin`/`dcdiag` read-back pending). Tiered accounts (`Build-Guide/DC01/Tiered-Admin-and-Groups-Build.md` Part 3) ✅ device-verified 07-22 (re-verify `Diagnostics-DC01.md`, `POL-0001`).
- [ ] 🟡 Promote **DC02** (`10.20.0.3`) — **operator-reported COMPLETE 2026-07-28; read-back PENDING** (`repadmin /replsummary` = 0 failures, `dcdiag`, `Get-ADDomainController DC02`) — flips to ✅ when run at the lab. Replica-DC build (add-to-existing-domain, **not** a new forest) + `DOMHIER` time. Full guide **`Build-Guide/DC02/DC02-Build-Guide.md`** v0.1. *(A 150‑person company with one DC is not a credible design — `301`/VM Inventory.)*
- [x] ✅ **2026-07-22 — Created the tiered admin accounts** — `t0-seth` (DC/PKI only), `t1-seth` (member servers), standard `seth` (daily) (`303` Part 5, `ADR-0024`); **off the built-in Administrator** (secured as break-glass) + Protected Users — `Build-Guide/DC01/Tiered-Admin-and-Groups-Build.md` Part 3. Re-verify: `Diagnostics-DC01.md`.

## Validation — read the state back
- [ ] 🟡 `dcdiag /v` and `repadmin /replsummary` + `repadmin /showrepl` — healthy, replicating. **This is the outstanding DC02 read-back** — operator reports DC02 promoted 2026-07-28; run these at the lab to confirm (→ ✅).
- [x] ✅ `Get-ADDomain` → **`atlas.lab`**; `Get-KdsRootKey` → present.
- [x] ✅ OU tree matches `Build-Guide/DC01/OU-Design-and-Build.md`; DCs still in the `Domain Controllers` OU.
- [x] ✅ `w32tm /query /source` — PDCe on the real source (`time.nist.gov`). Members-on-a-DC verify pending members.
- [~] `gpresult` on **DC01** ✅ baseline applied (Wave A, 07-21); **member** gpresult + **LAPS live-password** pending (no members joined yet). PSO ✅ built; LAPS GPO ✅ linked; DSRM-via-LAPS ✅ verified.
- [ ] `Test-ADServiceAccount` for a gMSA → True (pending gMSAs).
- [ ] 🔴 **The flagship test (`301`/`305`):** prove a **Tier‑2 / helpdesk account cannot touch a Tier‑0 object** — capture the **AD failure message**. The paired *network* denial comes once segmentation is live (Phase 7). ➡ These adversarial tests now have a home: **`Operations/Validation-and-Adversarial-Testing.md`** (control→attack→evidence matrix; most rows gate on Stage-8 tier accounts/groups).

## Failure modes
- 🔴 **`atlas.corp`** — the `303` defect. Verify `Get-ADDomain`; a wrong domain name is a rebuild, not an edit.
- 🔴 **KDS key forgotten / delay not accounted for** — gMSAs fail days later with opaque errors.
- 🔴 **Built flat, "we'll tier later"** — it never happens. Tier from day one; the deny‑cross‑tier GPOs are the enforcement.
- 🔴 **Hypervisor time sync vs w32time on the PDCe** — domain time drifts, Kerberos/replication break. Disable guest time sync on the PDCe.
- 🔴 **Departmental OUs** — GPO targeting hell (`303`); one policy linked to two OUs, one OU split by two policies.
- 🔴 **DCs moved out of the `Domain Controllers` OU** — default DC policy stops applying.
- **Single DC** — no redundancy. DC02 now built (🟡 operator-reported 2026-07-28; verify read-back).
- **Domain Admins sprawl** — the Reeves "3 temp DAs nobody remembers" lesson (`301`); audit membership, keep it near‑empty.
- **gMSA on a failover cluster** — not supported (`303` Part 4).

## Change Log
| Version | Changes |
|---|---|
| 1.5 | 2026-07-22. **Stage 8 Part 2 (groups) device-verified.** `G-Tier0/1/2-Admins` + `G-IT-Staff` all Global/Security, tier groups in the right OUs (§7 AGDLP item → ✅). Noted the `G-IT-Staff` placement nit (Groups-root → recommend Move to Security-Roles). Status/version bumped; Tiered-Admin doc → v0.4. |
| 1.6 | 2026-07-28. **DC02 status reconciled (07-24 audit M10; operator report).** DC02 promotion marked **🟡 operator-reported done 2026-07-28** (not ✅) across §8, the AD-DNS line, the status header, and failure modes; the **read-back (`repadmin /replsummary` = 0 failures, `dcdiag`, `Get-ADDomainController DC02`) is flagged PENDING** — flips to ✅ only when run at the lab (POL-0001). DC01 stays device-verified promoted. No `[ ]` was ticked to `[x]` on unverified state. |
| 1.4 | 2026-07-22. **DC02 split into its own `Build-Guide/DC02/DC02-Build-Guide.md` v0.1** (replica-DC build — add-to-existing-domain, DOMHIER time, replication verify). §8 now points at it + `Build-Guide/DC01/Tiered-Admin-and-Groups-Build.md` (v0.2) as the two Stage-8 sources (POL-0008). Status/version bumped. |
| 1.3 | 2026-07-22. **Stage 8 authored (not executed).** Pointed §7 (AGDLP tier admin groups `G-Tier0/1/2-Admins` + `G-IT-Staff`) and §8 (DC02 promotion + `t0-seth`/`t1-seth`/`seth` + getting off the built-in Administrator + Protected Users) at the new `Build-Guide/DC01/Tiered-Admin-and-Groups-Build.md` v0.1, marked 📋 authored-awaiting-execution (POL-0001 — not ✅). Status line notes 7d is now unblocked (its group references are concrete). |
| 1.2 | 2026-07-22. **Stage 7 progress:** checked off **7b PSO** (`PSO-FinanceHR`→`G-FinanceHR-Users`, lockout 3) and **7c LAPS** (schema + self-perm + `LAPS` GPO→Devices; member/tiered-read tests deferred). **DSRM password now LAPS-managed** (§7c-DSRM) → `POL-0002` manual-record **retired** (updated §1 + verify-on-resume). Pointed the flagship Tier-2-can't-touch-Tier-0 test at the new `Operations/Validation-and-Adversarial-Testing.md`. Remaining: Wave B (VBS/CG), 7d tier-deny (gated on Stage-8 tier groups), DHCP, AGDLP/users, DC02. |
| 1.1 | 2026-07-21. **Progress pass — checked off what's device-verified:** promote `atlas.lab` (KDS, AD-DNS, PDCe external time), OU skeleton (with the `Devices`/`Employees` reserved-name rename + `redircmp`→Staging), and **GPO 7a — MS Server 2025 v2602 baseline imported + Wave-A links applied & verified** (`gpresult` on DC01). Pointed the OU + GPO items at the authoritative living docs (`Build-Guide/DC01/OU-Design-and-Build.md`, `Build-Guide/DC01/GPO-Design-and-Build.md`) per POL-0008. Still open: GPO Wave B (VBS/CG — Proxmox VBS check), PSO, LAPS, tier-deny, DHCP, AGDLP/users, DC02. Status/Gate/Validation updated. |
| 1.0 | 2026-07-17. Build checklist for DC01/DC02 as the Lab-02 Tier-0 identity backbone (`ADR-0021`/`0025`), following the `303` build order: promote `atlas.lab` (not `.corp`), KDS root key immediately, role-based OU skeleton, AD-integrated DNS + DHCP, PDC-emulator NTP (`ADR-0020`, with the VM time-sync fix), Microsoft/CIS baseline GPOs + LAPS + cross-tier deny, AGDLP groups, SQL→AD population from `301`, DC02 + the t0/t1/t2 accounts. Grounded in CIS Windows Server + Microsoft Security Baselines. Foregrounds the four build-specific traps and the flagship Tier-2-can't-touch-Tier-0 test. |
