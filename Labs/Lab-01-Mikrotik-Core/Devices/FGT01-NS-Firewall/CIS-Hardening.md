---
Title: FGT01 Hardening Checklist (CIS-Informed)
Path: Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall
---

# FGT01 Hardening Checklist (CIS-Informed)

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: FGT01 - Role: Perimeter Firewall

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Draft — curated priority checklist, not exhaustive |
| Version | 1.0 |
| Applies To | FGT01 (FortiGate-60E, FortiOS 7.4.5) |
| Reference | CIS Fortigate 7.0.x Benchmark v1.4.0 |

## Important Version Note

**Real gap worth stating plainly, not glossing over:** the referenced benchmark is written for FortiOS **7.0.x**. FGT01 is confirmed live running **7.4.5** — a meaningfully newer release. The category structure and security concepts below transfer reasonably well, but **specific commands, menu paths, or defaults may have changed between 7.0 and 7.4** — treat every item as needing a live confirmation pass, not an assumption that 7.0.x guidance applies unchanged. A 7.4.x-specific CIS benchmark would be the correct primary source if/when available.

## How to Use This Checklist

Cited by CIS category and recommendation title only, in Atlas's own words. Cross-checked against everything already live-validated on FGT01 this session (`021-FGT01-Build-Record.md`, `MC-0001`).

---

## 1. Network Settings

### 1.1 DNS server configured
- [x] **Confirmed** — DNS-over-TLS configured (`set protocol dot`), found and documented during this session's validation.

### 1.3 Disable management services on WAN
- [x] **Confirmed correct** — `wan1`/`wan2` show `allowaccess ping` only, no HTTPS/SSH management exposed on the WAN side. Verified during live validation.

---

## 2. System Settings

### 2.2 Password Policy
- [ ] **Admin password complexity/expiration policy configured** — **Unverified.** Worth checking `config system password-policy` for actual enforcement, not just assuming the current admin password is strong.

### 2.3 SNMP
- [ ] **SNMP configuration reviewed** — **Unverified** whether SNMP is even enabled on FGT01; not covered in this session's validation.

### 2.4 Administrators and Admin Profiles
- [x] **Named admin trusted-host restrictions** — confirmed live: `admin` account has `trusthost1/2/3` scoped to specific subnets, not open management access.
- [ ] **Role-based admin profiles beyond default `super_admin`** — **Gap, confirmed.** Only one admin account (`admin`, `super_admin` profile) exists — no named, scoped administrator account exists on FGT01, unlike Proxmox's `seth-admin@pve` pattern. Worth considering, matching the least-privilege pattern already used elsewhere in Atlas.

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
2. **Consider a named, scoped admin account** — same least-privilege pattern already used on Proxmox.
3. **Decide the UTM profile question** — actively maintain signature-based protection, or formally accept it's not in scope for a lab-traffic firewall.
4. **Confirm `logtraffic` is genuinely applied**, not just documented.

## Related Pages

- `Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/Build-Record.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/Troubleshooting.md`
- `00-Atlas-Foundation/Decisions/ADR-0005-FGT01-Firewall-Policy-Scope-Deferred.md`
