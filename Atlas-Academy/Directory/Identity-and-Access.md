---
Title: Identity and Access — Full Directory
Path: Atlas-Academy/Directory
Status: 🟢 Living — the exhaustive twin of the Source-of-Truth router's §2. AD, PKI, and AAA — with the real frozen-Lab-01 certificate records.
Version: 0.1
Date: 2026-08-03
---

# Identity and Access — Full Directory

> **The deep version of [Source-of-Truth §2](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#2-identity-and-access).** The router gives you the one-glance answer; this page is the *encyclopedia* — Active Directory as the tiered-identity backbone, the two-tier Microsoft PKI, the AAA/RADIUS layer, the decisions that shaped them, and the **real, device-verified certificate records** the estate learned its PKI discipline from. Keep the router in a tab for speed; come here when you want the whole picture.
>
> Each device folder carries the standard page-set (`ADR-0037`): **README** (front door + Services map) · **Build-Guide** (target) · **Build-Record** (verified reality) · **Diagnostics / Troubleshooting** · **Considerations** · **Changes/** · **Automation/**.
>
> 🔒 **The real records here are frozen Lab-01 (`ADR-0022`) — history, not current guidance.** They reference the retired OpenSSL Lab CA (unified onto AD CS, `ADR-0031`); read them for *how the cert discipline was learned*, and reconcile to the live two-tier design.

## On this page

1. [The identity devices](#1-the-identity-devices) — AD · PKI · AAA · PAW
2. [The tiered-identity model](#2-the-tiered-identity-model) — Tier 0/1/2 · AGDLP · the PAW
3. [The two-tier PKI trust chain](#3-the-two-tier-pki-trust-chain)
4. [AAA / RADIUS](#4-aaa--radius)
5. [Real PKI and identity records (frozen Lab-01)](#5-real-pki-and-identity-records-frozen-lab-01) — the goldmine
6. [The decisions (ADRs)](#6-the-decisions-adrs)
7. [Commands, templates and the Academy](#7-commands-templates-and-the-academy)

---

## 1. The identity devices

Identity is the estate's Tier-0 core — the domain controllers, the PKI that issues every certificate, the RADIUS server that authenticates the network gear, and the hardened workstation you administer it all from.

| Host | Role | Status |
|---|---|---|
| [`DC-Domain-Controllers`](../../Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers/) | AD DS (DC01/DC02) — the Tier-0 backbone; AD-integrated DNS, DHCP, PDCe time authority (`ADR-0021`) | ✅ DC01 device-verified; 🟡 DC02 promoted, read-back pending (the one open 🔴) |
| [`RCA01-ICA01-ADCS`](../../Labs/Lab-02-Cisco-Core/Devices/RCA01-ICA01-ADCS/) | The two-tier Microsoft PKI — offline Root (RCA01) → issuing sub-CA (ICA01); the single source of trust (`ADR-0027`) | ⬜ Authored, not built — only ICA01 host reachability ✅; the root ceremony gates the whole PKI |
| [`NPS01-Network-Policy-Server`](../../Labs/Lab-02-Cisco-Core/Devices/NPS01-Network-Policy-Server/) | RADIUS admin AAA for the network devices that can't domain-join — MKT01, SW01, 1941 (`ADR-0029`) | 📋 Authored, not built |
| [`PAW01-Tier0-Admin`](../../Labs/Lab-02-Cisco-Core/Devices/PAW01-Tier0-Admin/) | The Tier-0 Privileged Access Workstation — the hardened box you administer Tier-0 from; also the Win11 golden image source (`ADR-0042`) | 📋 Authored, not built |

> **The markers are honest (`POL-0001`/`POL-0006`), and this domain is mostly *ahead in design, behind in build*.** **DC01 is the built core** (domain promoted to `atlas.lab`, FSMO ×5, the AGDLP tier groups + tier accounts, the GPO baseline — all read-back-verified 07-22). The rest is authored and gated: **the AD CS root ceremony is the tallest critical-path dependency** — no LDAPS, RADIUS, NPS-PEAP, or TLS cert works until RCA01 signs ICA01 (backlog Tier-1). Two enforcement pieces are explicitly **not yet applied**: the **AtlasHR SQL→AD pipeline** (⬜ — the 156 users aren't loaded) and the **7d cross-tier deny GPOs** (⬜ — so the flagship *Tier-2-can't-touch-Tier-0* proof can't pass yet). Nothing here is marked ✅ on intent.

The `AtlasHR` user source is [`SQL01-Database`](../../Labs/Lab-02-Cisco-Core/Devices/SQL01-Database/) (see [Servers and Compute](./Servers-and-Compute.md)); the PKI trust anchor is consumed by the perimeter and east-west firewalls in [§1 Security](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#1-security-and-perimeter).

## 2. The tiered-identity model

The devices *run* identity; these own the *design*.

- **The model** — [`ADR-0021` AD as the tiered-identity backbone](../../00-Atlas-Foundation/Decisions/ADR-0021-AD-as-Tiered-Identity-Backbone.md): Tier 0 (domain / PKI), Tier 1 (member servers), Tier 2 (clients), administered by separate per-tier accounts (`t0-seth` / `t1-seth` / `seth`) off the built-in Administrator, with Protected Users and a PAW as the Tier-0 surface (Microsoft's Enterprise Access Model).
- **Group design (AGDLP)** — the tier groups `G-Tier0/1/2-Admins` + `G-IT-Staff` exist on DC01; role globals (`G-Sales`/`G-Finance`/…) populate as the AtlasHR pipeline lands. Concept: [Tiered-Admin Model](../Concepts/Tiered-Admin-Model.md).
- **The enforcement gap** — the **7d cross-tier deny-logon-rights GPOs** are the missing piece; until they're applied, tiering is *structured but not enforced*. Tracked on the [DC Build-Checklist](../../Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers/Build-Checklist.md).
- **The rules** — [`STD-0001` Password & Authentication](../../00-Atlas-Foundation/Standards/STD-0001-Password-and-Authentication.md) · [`STD-0002` Access Control](../../00-Atlas-Foundation/Standards/STD-0002-Access-Control.md) · [`POL-0010` Acceptable Use](../../00-Atlas-Foundation/Policies/POL-0010-Acceptable-Use.md).

## 3. The two-tier PKI trust chain

- **The design** — [`RCA01-ICA01-ADCS`](../../Labs/Lab-02-Cisco-Core/Devices/RCA01-ICA01-ADCS/) + its [`AD-CS-Two-Tier-Build-Guide`](../../Labs/Lab-02-Cisco-Core/Devices/RCA01-ICA01-ADCS/AD-CS-Two-Tier-Build-Guide.md). **RCA01** is an offline, air-gapped standalone Root CA that signs ICA01 once and powers off; **ICA01** is the domain-joined Enterprise Issuing CA that mints every estate certificate (LDAPS, RADIUS/PEAP, TLS, and the non-domain device certs).
- **The decisions** — [`ADR-0027` two-tier Microsoft PKI](../../00-Atlas-Foundation/Decisions/ADR-0027-AD-CS-Two-Tier-Microsoft-PKI.md) · [`ADR-0031` retire the OpenSSL Lab CA](../../00-Atlas-Foundation/Decisions/ADR-0031-Retire-OpenSSL-Lab-CA.md) (unify on AD CS — the non-domain devices must trust the new root and be **reissued**) · [`ADR-0009` the intermediate-CA IR + destroy-step lesson](../../00-Atlas-Foundation/Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md).
- **The traps it must not repeat** — the retired OpenSSL CA issued certs with **no SAN** and had **no CRL distribution point**, so revocation reached no client. The live ICA01 templates must issue correct SANs and a working CDP — *verify a real issued cert, don't assume* (the §5 records are why). The reconciliation anchor is frozen Lab-01 [`CM-0027`](../../Labs/Lab-01-Mikrotik-Core/Change-Management/CM-0027-035-Issues-Certificates-With-No-SAN.md).

## 4. AAA / RADIUS

- **The RADIUS server** — [`NPS01-Network-Policy-Server`](../../Labs/Lab-02-Cisco-Core/Devices/NPS01-Network-Policy-Server/): Windows NPS authenticates the network devices that can't domain-join (MKT01, SW01, 1941) against AD, returning privilege by group membership. [`ADR-0029` drop FreeRADIUS → Windows NPS](../../00-Atlas-Foundation/Decisions/ADR-0029-Drop-FreeRADIUS-Windows-NPS.md) — a dedicated member server, deliberately **not** on the DC (blast-radius separation).
- **The deliberate exception** — [`ADR-0028`](../../00-Atlas-Foundation/Decisions/ADR-0028-FGT01-Admin-Auth-Direct-LDAPS.md): FGT01 admin auth is **direct LDAPS to the DC**, *not* NPS RADIUS — don't add it as an NPS client by reflex.
- **Hybrid identity** — [`ADR-0040` Entra Connect password-hash sync](../../00-Atlas-Foundation/Decisions/ADR-0040-Entra-Connect-Password-Hash-Sync.md) (the cloud-identity direction; lands with the hybrid/Intune phase).
- ⚠️ **Two-host auth chain** — every RADIUS client depends on *both* NPS01 and a DC, so each must keep a **local break-glass** account (a documented `POL-0001` risk, not a gap to paper over).

## 5. Real PKI and identity records (frozen Lab-01)

**The goldmine.** Atlas learned its certificate discipline the hard way, at the machine. Every record below is a real, dated incident with the read-back that proved it — and every one teaches the same lesson: *a successful-looking `set` command is not a confirmed change; read the live state back, don't trust the sign log.* 🔒 Frozen (`ADR-0022`); the OpenSSL Lab CA they reference is retired (`ADR-0031`).

**The cert sagas — "get, not show"**

- [`MC-0002` — MikroTik certificate reissuance + the CA-wide `copy_extensions` fix](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/MC-0002-MikroTik-Certificate-Reissuance-and-CA-Fix.md) — the record the Academy's golden Playbook template is cut from. A SAN correction uncovered that the Lab CA had been missing `copy_extensions` since it was built, so it had silently signed certs with **no SAN at all** —
  > *"Verified the resulting certificate directly (`openssl x509 … -text | grep SAN`) — **Empty — no SAN at all** … checking the actual file instead of trusting a clean-looking sign log caught a real defect immediately."*
- [`MC-0001` — FGT01 Lab CA certificate installation](../../Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/Changes/MC-0001-FGT01-Lab-CA-Certificate-Installation.md) — a "20-minute" FortiGate admin-cert install that became a four-layer diagnostic; `set admin-server-cert` silently never took effect and the GUI served the factory cert the whole time —
  > *"`show system global | grep admin-server-cert` → Empty output … `get system global | grep admin-server-cert` → `Fortinet_GUI_Server` — Root cause found."*
- [`CM-0007` — install the Lab CA cert on MikroTik](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/CM-0007-Install-Lab-CA-Certificate-on-MikroTik.md) → [`CM-0008` — reissue with the correct SAN](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/CM-0008-Reissue-MikroTik-Certificate-Correct-SAN.md) — a *perfect install of the wrong certificate*: the import succeeded, but the SAN was stale (`10.0.0.1`, pre-VLAN) so browsers rejected it —
  > *"The install was perfect. The certificate's own data was out of date. Those are different failures, and this record only covers the first."*

**Key and secret discipline**

- [`CM-0010` — emergency CA passphrase rotation + destruction of exposed key backups](../../Labs/Lab-01-Mikrotik-Core/Change-Management/CM-0010-CA-Passphrase-Rotation-and-Exposed-Key-Destruction.md) — a leaked Root CA passphrase surfaced two undocumented `.bak` key copies a runbook created with no destroy step. It set the ordering rule —
  > *"if a key's passphrase is exposed, rotate before any backup. Never the reverse."* — the `.bak` files were `shred -u`'d only after both live keys verified.
- [`CM-0014` — a backup-archive passphrase committed to the repo](../../Labs/Lab-01-Mikrotik-Core/Change-Management/CM-0014-Archive-Passphrase-Committed-to-Repository.md) — the estate's defining secrets scar: the one passphrase flagged *never store digitally* was committed **in the same commit that shipped the runbook forbidding it** (`POL-0002`). The lesson is why the estate never `git add .`'s and scans by **filename** —
  > *"A bare high-entropy passphrase has NO SHAPE … The FILENAME was the only signal." gitleaks default: "scanned ~25 bytes … no leaks found."*
  > *(No secret value is reproduced here — `POL-0002`. Remediation: rotate, `git filter-repo` history purge verified from a fresh clone, a name-based `.gitleaks.toml` rule.)*

> The estate-wide lesson these share (from [`016-Network-Lessons-Learned`](../../Labs/Lab-01-Mikrotik-Core/Operations/016-Network-Lessons-Learned.md)): a green prompt is not evidence. The full ledger is [`Lab-01 Change-Management/`](../../Labs/Lab-01-Mikrotik-Core/Change-Management/).

## 6. The decisions (ADRs)

- [`ADR-0021`](../../00-Atlas-Foundation/Decisions/ADR-0021-AD-as-Tiered-Identity-Backbone.md) — AD as the tiered-identity backbone (Tier 0/1/2, AGDLP, PAW)
- [`ADR-0027`](../../00-Atlas-Foundation/Decisions/ADR-0027-AD-CS-Two-Tier-Microsoft-PKI.md) — the two-tier Microsoft PKI (offline root → issuing sub-CA)
- [`ADR-0031`](../../00-Atlas-Foundation/Decisions/ADR-0031-Retire-OpenSSL-Lab-CA.md) — retire the OpenSSL Lab CA; unify on AD CS
- [`ADR-0029`](../../00-Atlas-Foundation/Decisions/ADR-0029-Drop-FreeRADIUS-Windows-NPS.md) — drop FreeRADIUS; RADIUS on Windows NPS
- [`ADR-0028`](../../00-Atlas-Foundation/Decisions/ADR-0028-FGT01-Admin-Auth-Direct-LDAPS.md) — FGT01 admin auth by direct LDAPS (the RADIUS exception)
- [`ADR-0040`](../../00-Atlas-Foundation/Decisions/ADR-0040-Entra-Connect-Password-Hash-Sync.md) — Entra Connect password-hash sync (hybrid identity)
- [`ADR-0009`](../../00-Atlas-Foundation/Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md) — the incident-response + destroy-step lesson (key custody)

## 7. Commands, templates and the Academy

- 🖥️ **Commands** — [PowerShell-Tier0](../Command-Library/PowerShell-Tier0.md) (`Get-ADUser`, `repadmin /replsummary`, `dcdiag`, `certutil`, `Get-ADReplicationFailure`) · the non-domain cert-trust reads live in [FortiOS](../Command-Library/FortiOS.md) · [RouterOS](../Command-Library/RouterOS.md)
- 📋 **Templates** — [Windows build-record template](../../00-Atlas-Foundation/Templates/Build-Record-Windows-Template.md) + 📘 [How-To-Make-a-Windows-Build-Record](../How-To-Make-a-Windows-Build-Record.md) · [Change-Record](../../00-Atlas-Foundation/Templates/Change-Record-Template.md) · [Major-Change-Record](../../00-Atlas-Foundation/Templates/Major-Change-Record-Template.md) (a cert/CA change is a major change)
- 🔧 **Playbooks** — [Domain-Join-Fails](../Playbooks/Domain-Join-Fails.md) · [Read-the-Cert-Not-the-Sign-Log](../Playbooks/Read-the-Cert-Not-the-Sign-Log.md) · [Rotate-a-Leaked-Key-Before-You-Back-It-Up](../Playbooks/Rotate-a-Leaked-Key-Before-You-Back-It-Up.md) · [Respond-to-a-Committed-Secret](../Playbooks/Respond-to-a-Committed-Secret.md) · [Recover-a-Locked-Out-Router-Out-of-Band](../Playbooks/Recover-a-Locked-Out-Router-Out-of-Band.md)
- 🎓 **Concepts + cert alignment** — [Tiered-Admin Model](../Concepts/Tiered-Admin-Model.md) · [Windows Logon Scripts & Drive Mapping](../Concepts/Windows-Logon-Scripts-and-Drive-Mapping.md) · the [Concepts index](../Concepts/) · the **[AZ-800/801](../Certification/AZ-800-801-Windows-Server-Hybrid-Lab-Map.md)** hybrid-lab cert map
- 🔩 **Per-device** — each host's own `Diagnostics.md` / `Troubleshooting.md`

## Related

[Source-of-Truth router §2](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#2-identity-and-access) (the quick view) · [Security and Perimeter directory](./Security-and-Perimeter.md) · [Servers and Compute directory](./Servers-and-Compute.md) · [`POL-0002` Secrets](../../00-Atlas-Foundation/Policies/POL-0002-Secrets-and-Credentials.md) · [`POL-0004`](../../00-Atlas-Foundation/Policies/POL-0004-Source-of-Truth.md).

## Change Log

| Version | Changes |
|---|---|
| 0.1 | 2026-08-03. First cut — the exhaustive twin of Source-of-Truth §2: the identity-device roster (DC · RCA01-ICA01 PKI · NPS01 · PAW01) with honest build status (DC01 ✅ built, DC02 read-back pending, the PKI ceremony the tallest unbuilt dependency, NPS01/PAW01 authored-not-built); the tiered-identity model + AGDLP + the 7d enforcement gap; the two-tier PKI trust chain + the retired-OpenSSL reconciliation; the AAA/RADIUS layer + the FGT-LDAPS exception; the **frozen Lab-01 PKI goldmine** (the get-not-show cert sagas `MC-0001`/`MC-0002`, the SAN reissue `CM-0007`/`CM-0008`, the key-rotation `CM-0010`, the secret-commit scar `CM-0014` — no secret reproduced); the identity ADRs; commands, templates + Academy. Built per the `Session-29` brief. |
