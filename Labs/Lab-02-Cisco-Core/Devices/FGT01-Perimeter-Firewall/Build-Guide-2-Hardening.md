---
Title: FGT01 Build Guide 2 — Hardening — LIVING guide
Path: Labs/Lab-02-Cisco-Core/Devices/FGT01-Perimeter-Firewall
Status: 🟡 LIVING DRAFT (v0.1). GUI-primary + CLI. FortiOS 7.4.5. Executes CIS-Hardening-FGT01 + Build-Checklist §3–10. Read back with `get` (`MC-0001`). No FortiGuard needed.
Version: 0.1
Date: 2026-07-20
---

# FGT01 — Build Guide 2: Hardening

Executes `CIS-Hardening-FGT01.md` and `Build-Checklist.md` §3–10 — this guide is the **how**; those docs are the **why + control mapping** (don't restate them, follow them). GUI + CLI each step; `get` read-back; 📷 capture. ⚠️ Version-gated items marked **[7.6.1+]** don't apply to 7.4.5 — confirm each.

## 🔴 The rule that governs this whole guide
**Every step must preserve the break-glass** — console + `192.168.1.99` / `internal3-7` (`CM-0033`, `ADR-0016`). The local-in mgmt-deny (§3) is the #1 self-inflicted lockout: **exempt the break-glass and test it before you trust it.**

## §1 — Administrator access (Checklist §3)
- **Rename `admin` + non-standard admin ports**
  - GUI: System ▸ Administrators (create a named super_admin, then remove `admin`) · System ▸ Settings ▸ HTTPS/SSH admin ports → non-standard
  - CLI: `config system admin edit "…" …` ; `config system global set admin-sport <port> set admin-ssh-port <port>`
  - ✅ `get system global | grep admin-sport`; `get system admin`
- **Interface `allowaccess`** — mgmt iface = `ping https ssh`; 🔴 **`wan1` = none** (CIS 1.3)
  - CLI: `config system interface edit "wan1" set allowaccess ping next end` *(no https/ssh/http/telnet)*
  - ✅ `get system interface wan1` → `allowaccess: ping` (or none)
- **`trusthost` per admin + local-in mgmt-deny (exempt break-glass)**
  - GUI: System ▸ Administrators ▸ (admin) ▸ Restrict login to trusted hosts = Management subnet · Policy & Objects ▸ Local-In Policy
  - CLI: `config system admin edit "…" set trusthost1 10.10.0.0 255.255.255.224 next end`
  - 🔴 Local-in policy: allow mgmt from the Management zone + **the `192.168.1.99` break-glass and console**, deny elsewhere.
  - ✅ `get system admin`; **then reach `192.168.1.99`/console — break-glass STILL works** (Checklist validation).
  - 📷 captures/fgt01-adminaccess.png
- **MFA on every admin** (FortiToken/Duo) — System ▸ Administrators ▸ Enable Two-factor.
- **Role-based admin profiles** beyond `super_admin` (CIS 2.4) — System ▸ Admin Profiles.

## §2 — Encrypted protocols & strong ciphers (Checklist §4)
- CLI:
```
config system global
 set strong-crypto enable
 set ssl-static-key-ciphers disable
 set admin-https-ssl-versions tlsv1-2 tlsv1-3
end
```
- **SNMPv3** (never v2c `homelab`, `CM-0023`), **LDAPS** (least-privilege bind, not Domain Admin).
- ✅ `get system global | grep strong-crypto` → enable.
- 📷 captures/fgt01-crypto.png

## §3 — Secure storage & backup (Checklist §5)
- **`private-data-encryption enable`** — on 7.4.5 you set a **manual 32-hex key** (auto-key is **[7.6.1+]**). 🔴 **Record the key offline** (`POL-0002`) — a backup made with it only restores to a FortiGate with the *same* key (RMA implication).
  - CLI: `config system global set private-data-encryption enable end` → enter/record the 32-hex key.
- **Encrypted config backup after every change** → `E:\` (`Device-Backup-Runbook`). Never share a full unredacted config.
- ✅ `get system global | grep private-data-encryption`.

## §4 — Time (Checklist §8)
- NTP → the `ADR-0020` source (authenticated if supported), correct timezone.
- ✅ `get system ntp` / `diagnose sys ntp status` — **synced** (status, not the config line).

## §5 — DoS protection (Checklist §9)
- DoS policy, anomalies in **monitor** first (learn normal), then enforce `tcp_syn_flood`, `tcp_port_scan`, `ip_src/dst_session`; tune thresholds; NP offload if supported.
- GUI: Policy & Objects ▸ DoS Policy. ✅ `get firewall DoS-policy`.

## §6 — Logging to MON01 (Checklist §7 — the forward half; Phase 6)
- Forward syslog → **MON01** (no FortiAnalyzer in inventory). **Clock synced first** or timestamps are useless.
- CLI: `config log syslogd setting set status enable set server <MON01> end` *(when MON01 exists — Phase 6)*.
- ✅ a **denied** flow appears in the log **on MON01** with a correct timestamp.

## §7 — Operational hygiene (Checklist §10)
- **`cli-audit-log enable`** (confirm it exists on 7.4.5) — change control.
- **USB auto-install disabled** (`config system auto-install` — default disabled; confirm) — physical-security.
- **Firmware in support** (not EOS); read release notes before upgrading.
- ✅ `get system global | grep cli-audit-log`; `get system status` (firmware in support).

## Validation (read back with `get`)
- [ ] `get system global` — strong-crypto, cli-audit-log, private-data-encryption, non-standard admin ports. 📷
- [ ] `get system interface wan1` — no mgmt allowaccess. 📷
- [ ] `get system admin` — trusthosts + MFA + non-`admin` names. 📷
- [ ] 🔴 **Break-glass still works** after the local-in policy. 📷
- [ ] `diagnose sys ntp status` — synced.
- [ ] A denied flow logged on MON01 (Phase 6).

## Failure modes (from the checklist)
- 🔴 **Local-in mgmt-deny severs the break-glass** — exempt `192.168.1.99`/console; test before trusting.
- 🔴 **Losing the `private-data-encryption` key** — encrypted backup can never be restored.
- 🔴 **Ticking from `show`/`config` not `get`** — `MC-0001`.
- 🔴 **Attaching stale UTM** — not here; that's Guide 3, and only with a *verified* FortiGuard DB.
- **Assuming an 8.0/[7.6.1+] command exists on 7.4.5** — verify version-gated items.

## Related
`Build-Guide-Index` · `CIS-Hardening-FGT01.md` (control mapping) · `Build-Checklist` §3–10 · `ADR-0016`/`CM-0033` (break-glass) · `ADR-0004` (RADIUS→SRV01/NPS) · `ADR-0020` (clocks).

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-20 | Hardening draft — executes CIS-Hardening-FGT01 + Checklist §3–10 (admin access + local-in break-glass exempt, MFA, profiles, strong-crypto/TLS, SNMPv3/LDAPS, private-data-encryption key, encrypted backup, NTP, DoS, cli-audit-log, USB, firmware). GUI + CLI; `get` read-backs; version-gating flagged. Validate on device. |
