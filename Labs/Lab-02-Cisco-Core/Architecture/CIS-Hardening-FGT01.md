---
Title: FGT01 Hardening Checklist (CIS-Informed)
Path: Labs/Lab-02-Cisco-Core/Architecture
---

# FGT01 Hardening Checklist (CIS-Informed)

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** - Host: FGT01 - Role: Perimeter Firewall (unchanged)

> **Note:** this is the **active** Lab-02 hardening baseline for FGT01. A first FGT01 CIS checklist exists in the frozen Lab-01 (`Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/CIS-Hardening.md`) and is left untouched as the historical record; this doc carries it forward with the strengthened evidence rule and the unused-interface items.

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Draft — curated priority checklist, not exhaustive |
| Version | 1.2 |
| Applies To | FGT01 (FortiGate-60E, FortiOS 7.4.5) |
| Reference | CIS Fortigate 7.0.x Benchmark v1.4.0 |
| Governing Policy | `POL-0007` (Hardening Baseline); evidence per `POL-0001` R-A1 |

## Important Version Note

**Real gap worth stating plainly, not glossing over:** the referenced benchmark is written for FortiOS **7.0.x**. FGT01 is confirmed live running **7.4.5** — a meaningfully newer release. The category structure and security concepts below transfer reasonably well, but **specific commands, menu paths, or defaults may have changed between 7.0 and 7.4** — treat every item as needing a live confirmation pass, not an assumption that 7.0.x guidance applies unchanged. A 7.4.x-specific CIS benchmark would be the correct primary source if/when available.

## How to Use This Checklist

Cited by CIS category and recommendation title only, in Atlas's own words. Cross-checked against everything already live-validated on FGT01 this session (`021-FGT01-Build-Record.md`, `MC-0001`).

> 🔴 **Governing policy: `POL-0007` (Hardening Baseline). Evidence rule: `POL-0001` R-A1 — a `[x]` requires a command and its output, not a config line.** `show run` shows intent; the runtime view (`get`, not `show`) shows truth. Five false ticks across three checklists (`POL-0001`) all came from ticking intent. **If you can't paste the output, the box stays `[ ]`.** Every `[x]` below names its live evidence; anything that can't is marked **Unverified**, which is a legitimate state, not a failure to hide.

---

## 1. Network Settings

### 1.1 DNS server configured
- [x] **Confirmed** — DNS-over-TLS configured (`set protocol dot`), found and documented during this session's validation.

### 1.3 Disable management services on WAN
- [x] **Confirmed correct** — `wan1`/`wan2` show `allowaccess ping` only, no HTTPS/SSH management exposed on the WAN side. Verified during live validation.

### 1.4 Unused interfaces disabled (🔴 strengthened — `POL-0007`, `CM-0033`)
- [ ] **`internal3`–`internal7` + the factory `dmz` L3 interface** — 🔴 **Confirmed gap (`CM-0033`): five live ports and a factory-default L3 interface, unassessed, on the perimeter firewall.** `POL-0007` requires every interface with no assigned purpose to be administratively down, *and the reason for any kept-enabled one recorded*. Assess each; disable the unused; document the exceptions (`internal3-7`/`192.168.1.99` is the break-glass path — that one is kept *by design*, `059`, and must be recorded as such, not silently left up).
- [ ] **The break-glass management path (`192.168.1.99`) is preserved** on whichever interface carries it — a hardening pass must never sever it (`Atlas-Firewall-Architecture.md` §3.8).

---

## 2. System Settings

### 2.2 Password Policy
- [ ] **Admin password complexity/expiration policy configured** — **Unverified.** Worth checking `config system password-policy` for actual enforcement, not just assuming the current admin password is strong.

### 2.3 SNMP
- [ ] **SNMP configuration reviewed** — **Unverified** whether SNMP is even enabled on FGT01; not covered in this session's validation.

### 2.4 Administrators and Admin Profiles
- [x] **Named admin trusted-host restrictions** — confirmed live: `admin` account has `trusthost1/2/3` scoped to specific subnets, not open management access.
- [ ] **Role-based admin profiles + AD-backed named admins (`ADR-0028` / `Build-Guide-2b`)** — **Gap, confirmed.** Only the single `admin`/`super_admin` account exists. 🔴 **Resolved direction (`ADR-0028`):** named admin auth is **direct LDAPS to the DC** — `G-Network-Admins` maps to a scoped admin profile via `Build-Guide-2b-AD-LDAPS-Admin.md` (least-priv `svc-fgt-ldap` bind), and the default `admin` is renamed to **`fortigateadmin` and kept as the sole *local* break-glass**. So this is no longer "consider a local named account" — it is *build the LDAPS admin path (Guide-2b) + keep one local break-glass*, gated on the DC LDAPS cert (AD CS `ADR-0027`). FGT01 uses **LDAPS, not RADIUS/RADSEC** (network-device RADIUS → NPS01, `ADR-0029`).

---

## 3. Policy and Objects

### 3.2 Policies should not use "ALL" as Service unnecessarily
- [ ] **Firewall policy scope** — **Known, deliberate gap, already tracked.** Policy 1 (`LAB-to-Internet`) uses `srcaddr all` and broad service scope — this is `ADR-0005`, a deliberate deferral pending network redundancy, not an oversight. This checklist item is already formally tracked, not new information.

### 3.4 Logging enabled on all firewall policies
- [ ] **Unverified** whether `logtraffic` is actually set on the existing policy — should be, given the Build Record documents `logtraffic all`, but worth a live re-check given how much else turned out to need direct verification tonight rather than assumption.

---

## 4. Security Profiles

### 4.1-4.3 IPS, Antivirus, DNS Filter
- [ ] **UTM security profiles applied to policies** — **Confirmed gap.** Earlier validation found AV/IPS/App-Control signature databases years stale (2015-2018) — consistent with these profiles not being actively maintained or possibly not applied to the traffic policy at all. Worth a real decision: enable and maintain these, or consciously accept they're not in active use given lab-scale traffic.

---

## 5. Security Fabric

- [ ] **Not applicable currently** — no FortiAnalyzer/FortiManager/additional Fortinet fabric devices in the current inventory.

---

## 6. VPN

### 6.1 SSL VPN
- [ ] **Not currently configured** — ties directly to the Azure site-to-site VPN idea raised earlier in the Windows Environment Roadmap and the CCNP lab list (`08-Labs/README.md`). Worth building when that work actually starts, not before.

---

## 7. Logs and Reports

### 7.1 Enable Logging
- [x] **Local logging confirmed working** — used extensively throughout tonight's validation work (policy logs, admin activity).

### 7.3 Centralized Logging and Reporting
- [ ] **Not yet configured** — same Book 5 (Monitoring) dependency as SW01 and Pi01's equivalent gaps.

---

## Real Priorities, Ranked

1. **Confirm admin password policy is actually enforced**, not just assumed strong.
2. **Build AD-backed named admin auth over LDAPS (`ADR-0028` / `Build-Guide-2b`)** — `G-Network-Admins` → scoped profile, `fortigateadmin` the sole local break-glass; gated on the DC LDAPS cert (AD CS). *(Supersedes the earlier "consider a local named account" framing.)*
3. **Decide the UTM profile question** — actively maintain signature-based protection, or formally accept it's not in scope for a lab-traffic firewall.
4. **Confirm `logtraffic` is genuinely applied**, not just documented.

## Related Pages

- `Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/Build-Record.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/Troubleshooting.md`
- `00-Atlas-Foundation/Decisions/ADR-0005-FGT01-Firewall-Policy-Scope-Deferred.md` · `ADR-0028` (FGT01 admin auth = direct LDAPS)
- `Devices/FGT01-Perimeter-Firewall/Build-Guide-2b-AD-LDAPS-Admin.md` (the admin-auth build) · `Build-Guide-Index.md`
- `00-Atlas-Foundation/Policies/POL-0007-...` (Hardening Baseline) · `POL-0001` (Audit — R-A1 evidence rule)
- Sibling Lab-02 baselines: `CIS-Hardening-MKT01.md`, `CIS-Hardening-PVE01.md` (same folder)

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Initial CIS-informed priority checklist for FGT01 (FortiOS 7.4.5 vs the 7.0.x benchmark), cross-checked against live validation (`021`, `MC-0001`). |
| 1.1 | 2026-07-17. **Strengthened:** added the `POL-0001` R-A1 evidence rule (a tick needs a command + output, not a config line) as the governing discipline; added §1.4 **unused-interface hardening** (`internal3-7` + factory `dmz`, the `CM-0033` gap, per `POL-0007`) with the `192.168.1.99` break-glass exception recorded as kept-by-design; named `POL-0007` as governing policy. Now the template for the MKT01 and PVE01 baselines. |
| 1.2 | 2026-07-28. **C5 — routed admin auth to `ADR-0028`/Guide-2b.** §2.4 + Real-Priorities #2 reframed from "consider a local named scoped admin" to **AD-backed named admins over direct LDAPS** (`G-Network-Admins`→scoped profile via `Build-Guide-2b`, `fortigateadmin` the local break-glass), gated on the DC LDAPS cert; noted FGT01 is LDAPS-not-RADIUS. Added `ADR-0028` + Guide-2b to Related. No device changes. |
