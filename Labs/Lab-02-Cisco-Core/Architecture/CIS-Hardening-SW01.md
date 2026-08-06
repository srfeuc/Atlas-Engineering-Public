---
Title: SW01 Hardening Checklist (CIS-Informed)
Path: Labs/Lab-02-Cisco-Core/Architecture
---

# SW01 Hardening Checklist (CIS-Informed)

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** - Host: SW01 - Role: **L2 Access/Distribution switch** (`ADR-0023`; carries all VLANs to MKT01, does not route)

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | 🟢 **Pass-1 device-verified 2026-07-22.** Execution evidence in `SW01/Build-Guide.md`. Follows `Operations/Device-Hardening-Standard.md`. |
| Version | 1.1 |
| Applies To | SW01 (Cisco Catalyst **2960X**, IOS 15.x) |
| Reference | [CIS Cisco IOS Benchmark](https://www.cisecurity.org/benchmark/cisco) + the shared `Device-Hardening-Standard`. Modeled on `CIS-Hardening-MKT01.md`/`FGT01`. |
| Governing Policy | `POL-0007` (Hardening Baseline); evidence per `POL-0001` R-A1 (`show` *status*, not `show run`, where a runtime read exists) |

> 🔴 **Break-glass:** SW01's OOB recovery is the **serial console (9600 8N1)** via `line con 0 login local` (any local user, e.g. `ciscoadmin`). Lower lockout risk than MKT01 (L2 + a mgmt SVI), but keep the console reachable before management-plane changes (`Device-Hardening-Standard` Part A). No lockout occurred this pass (the vty ACL keeps the admin host `10.10.0.20` in scope).

---

## 1. SSH / Management plane — ✅ 2026-07-22

- [x] ✅ **SSH v2 only** — `show ip ssh` → `version 2.0`.
- [x] ✅ **Strong ciphers (CTR only)** — `ip ssh server algorithm encryption aes256-ctr aes192-ctr aes128-ctr`; **CBC + 3DES removed**. Verified: `show ip ssh` → `aes256-ctr,aes192-ctr,aes128-ctr`.
- [x] ✅ **DH min key size 2048** — `ip ssh dh min size 2048` (was 1024). Verified in `show ip ssh`.
- [~] 🔴 **MACs = `hmac-sha1` / `hmac-sha1-96` only — IOS limitation.** `ip ssh server algorithm mac ?` offers **no SHA2** on this 2960X IOS. Left at SHA1 (documented, not a fixable gap without a newer image). *(Optional: pin to `hmac-sha1` to drop the truncated `-96`.)*
- [x] ✅ **Auth retries lowered** — `ip ssh authentication-retries 2`; timeout 60s.
- [x] ✅ **RSA host key = 2048, NOT regenerated** — deliberately left stable so client `known_hosts` stops churning (each `crypto key generate rsa` had been changing the fingerprint). Fingerprint `SHA256:rKBq…` trusted.
- [x] ✅ **vty locked down** — `ip access-list standard MGMT-SSH` (`permit 10.10.0.0 0.0.0.31` / `deny any log`) applied `access-class MGMT-SSH in` on `line vty 0 15`; `exec-timeout 5 0`; `transport input ssh`; `login local`.
- [x] ✅ **No cleartext mgmt** — `no ip http server`, `no ip http secure-server`; no telnet (`transport input ssh` only).

## 2. Users & secrets — ✅ 2026-07-22

- [x] ✅ **Single named admin** — `ciscoadmin` (priv 15). The generic **`cisco` priv-15 account removed** (`no username cisco`).
- [x] ✅ **Secrets upgraded to Type 9 (scrypt)** — `enable algorithm-type scrypt secret …` and `username ciscoadmin … algorithm-type scrypt secret …`; both now `secret 9 $9$…` (were **Type 5 / MD5**). *(scrypt = slow, memory-hard hash — resists offline cracking if the config leaks; the login prompt is guarded separately by retries/exec-timeout/access-class.)* Passwords in Vaultwarden (`POL-0002`).
- [ ] *(Optional)* a 2nd local break-glass admin (console-only). Single admin + console is acceptable for a lab; document it.

## 3. SNMP

- [x] ✅ **No v2c community** — the carried-over `homelab` community was removed 2026-07-21 (confirmed absent in the live config). SNMPv3 (auth+priv) → MON01 is **Phase 6** (deferred until MON01).

## 4. Time / NTP — ✅ 2026-07-22 (`CM-0030` closed)

- [x] ✅ **NTP synced** — `ntp server 10.20.0.2` (DC01, authoritative PDCe, `ADR-0020`). `show ntp associations` → `*~10.20.0.2` (sys.peer, st 2, ref `132.163.97.4`=NIST via DC01, reach climbing); `show ntp status` → **`synchronized, stratum 3, reference 10.20.0.2`**. Verified by runtime status, not `show run` (`045`).
- [x] ✅ **Stale NTP source removed** — a leftover `ntp server 10.10.0.5` (`.STEP.`, unreachable) was deleted; only `10.20.0.2` remains.
- [x] ✅ Timezone Central (CDT); `show clock` correct.

## 5. VLANs / Interfaces (`POL-0007`)

- [x] ✅ **VLAN1 unused = admin-down** — `show ip int brief` → `Vlan1 administratively down`. Only **`Vlan10` SVI** (`10.10.0.2`) up = the mgmt plane.
- [x] ✅ **No `ip routing`** — SW01 stays pure L2 (`ADR-0023`); MKT01 routes.
- [ ] Unused access ports parked/shut + port-security — per `SW01/Build-Guide.md` Step 4 (🔴 `Gi1/0/3` stays shut; **never `Gi1/0/7` = Pi01**). DHCP-snooping on; **DAI deferred to NetBox** (Phase 4) — generated, not hand-typed.

## 6. Recovery / logging

- [x] ✅ **Config saved** — `copy running-config startup-config` after changes; export → Oxidized/git once SRV01 exists (Phase 5).
- [~] **Console break-glass** — the recovery path (9600 8N1); available, a quick console login test recommended to formally close the gate (low risk, none needed this pass).
- [ ] **Logging → MON01** — deferred to Phase 6 (rsyslog + SNMPv3 when MON01 exists).

## Deferred / later
- SNMPv3 + syslog → MON01 (**Phase 6**).
- DAI generated from NetBox (**Phase 4**).
- **Pass-2** AD-backed admin auth (**RADIUS → NPS on `NPS01`**, `ADR-0029`; FreeRADIUS retired) — Phase-3/5-dependent; keep the local `ciscoadmin` + console as break-glass.
- SHA2 SSH MACs — would need a newer IOS (hardware/image limitation).

## Real Priorities — ✅ all done 2026-07-22 (Pass 1)
1. ✅ SSH crypto hardened (CTR ciphers, DH 2048, retries) — CBC/3DES/1024-DH gone.
2. ✅ vty scoped to the mgmt subnet + `exec-timeout`.
3. ✅ Secrets → Type 9 scrypt; generic `cisco` account removed.
4. ✅ NTP synced to DC01 (`CM-0030`); stale source removed.
5. ✅ No telnet/http; VLAN1 down; config saved; host key left stable.

## Related
- `Operations/Device-Hardening-Standard.md` (the shared recovery-first + Pass-1 pattern) · `SW01/Build-Guide.md` (execution) · `CIS-Hardening-MKT01.md` / `FGT01` (siblings) · `IP-Addressing-Plan-VLSM.md` · `ADR-0023` (L2 role) · `ADR-0029` (RADIUS→NPS on `NPS01`) · `Master-Build-Order.md` §2.5.

## Change Log
| Version | Changes |
|---|---|
| 1.1 | 2026-07-28. **C4 auth reconciliation.** Pass-2 AD-backed admin-auth target corrected **`ADR-0004`/SRV01-NPS → `ADR-0029`/NPS on `NPS01`** (FreeRADIUS retired) in the Deferred item + Related list. Local `ciscoadmin` + console break-glass unchanged. No device changes. |
| 1.0 | 2026-07-22. Created — SW01 CIS-Hardening doc (the box had none), Pass-1 **device-verified** in one session: SSH crypto (CTR-only ciphers, DH 2048, retries 2; MACs stuck at SHA1 = IOS limitation), vty `access-class MGMT-SSH` + `exec-timeout`, secrets upgraded **Type 5 → Type 9 (scrypt)** + generic `cisco` account removed, **NTP synced to DC01** (stratum 3, `CM-0030` closed) with the stale `10.10.0.5` source removed, VLAN1 admin-down, host key left stable to end `known_hosts` churn, config saved. Follows `Device-Hardening-Standard`. Deferred: MON01 logging/SNMPv3 (Phase 6), DAI (Phase 4), Pass-2 AD auth. |
