---
Title: 1941 Hardening Checklist (CIS-Informed)
Path: Labs/Lab-02-Cisco-Core/Architecture
---

# 1941 Hardening Checklist (CIS-Informed)

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** - Host: 1941 - Role: **Core router** (`ADR-0023`; two routed `/30`s + loopback, OSPF with MKT01, default → FGT01; **no VLANs**)

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | 🟢 **Pass-1 device-verified 2026-07-22.** Execution evidence in `1941/Build-Guide.md`. Follows `Operations/Device-Hardening-Standard.md`. |
| Version | 1.1 |
| Applies To | Cisco **1941 ISR G2**, IOS 15.x (older train than the 2960X) |
| Reference | [CIS Cisco IOS Benchmark](https://www.cisecurity.org/benchmark/cisco) + the shared `Device-Hardening-Standard`. Sibling of `CIS-Hardening-SW01.md`. |
| Governing Policy | `POL-0007`; evidence per `POL-0001` R-A1 (runtime `show` status, not `show run`) |

> 🔴 **Break-glass:** the **serial console (9600 8N1)** via `line con 0 login local` (`ciscoadmin`). The 1941 has **no VLAN SVI** — it's reached over the loopback `10.255.0.1` or the transit `/30`s (`10.255.255.2`/`.5`), routed from the mgmt host via OSPF. Keep the console reachable before mgmt-plane changes (`Device-Hardening-Standard` Part A). This pass was done on the console (SSH was blocked by legacy-crypto negotiation — see §1).

---

## 1. SSH / Management plane — ✅ 2026-07-22

- [x] ✅ **SSH v2 only**; **CTR-only ciphers** (`aes256/192/128-ctr`; CBC + 3DES removed); **DH min size 2048** (was 1024); **retries 2**. Verified: `show ip ssh`.
- [~] 🔴 **MACs = `hmac-sha1`/`-96` only — IOS limitation** (no SHA2 on this ISR image). Documented, not fixable without a newer image.
- [~] 🔴 **KEX cannot be pinned — `ip ssh server algorithm kex` is not in this IOS.** The router keeps *offering* SHA1 KEX (`group-exchange-sha1`, `group14-sha1`, `group1-sha1`). **Mitigation applied: `ip ssh dh min size 2048`** — raises the DH modulus floor to 2048, so the weak `group1` (768-bit) won't negotiate even though it's still offered.
- [x] ✅ **RSA host key regenerated** (2026-07-22) then **left stable** — accept the new fingerprint once (`SHA256:BWLS…`) and don't regenerate again (each regen churns client `known_hosts`).
- 🔴 **Client-side reality (document it):** a modern OpenSSH client must be told to accept the ISR's legacy algorithms. Put this in `~/.ssh/config`:
  ```
  Host 1941 10.255.0.1 10.255.255.2 10.255.255.5
      User ciscoadmin
      KexAlgorithms +diffie-hellman-group14-sha1
      HostKeyAlgorithms +ssh-rsa
      MACs +hmac-sha1
  ```
  This is the box's ceiling — the 1941 simply can't speak modern SSH; the client meets it at group14-sha1 / ssh-rsa / hmac-sha1.
- [x] ✅ **vty locked down** — `ip access-list standard MGMT-SSH` (`permit 10.10.0.0 0.0.0.31` / `deny any log`) applied `access-class MGMT-SSH in` on **both** vty ranges (`0 4` and `5 15`); `exec-timeout 5 0`; `transport input ssh`; `login local`.
- [x] ✅ **No cleartext mgmt** — `no ip http server`/`secure-server`; SSH-only (base build).

## 2. Users, secrets & brute-force — ✅ 2026-07-22

- [x] ✅ **Single named admin** — `ciscoadmin` (priv 15); no generic/default account present.
- [x] ✅ **Secrets → Type 9 (scrypt)** — `enable secret 9 $9$…` + `username ciscoadmin … secret 9 $9$…` (were Type 5 / MD5). Passwords in Vaultwarden (`POL-0002`).
- [x] ✅ **Login throttling** — `login block-for 30 attempts 3 within 500` (already configured; kept) — quiet-period after 3 bad tries in 500s.

## 3. Time / NTP — ✅ 2026-07-22 (`CM-0030`)

- [x] ✅ **NTP → DC01** — `ntp server 10.20.0.2` (authoritative PDCe, `ADR-0020`). `show ntp associations` → `*~10.20.0.2` (**selected sys.peer**, st 2, ref `132.163.97.4`=NIST via DC01). Was `%NTP is not enabled`. ⏳ **Converging at capture** ("unsynchronized / FREQ drift being measured", ~100 s after enable) — confirm `show ntp status` → `synchronized, stratum 3` after a few poll cycles.
- [x] ✅ Timezone Central (CST/CDT).

## 4. SNMP / logging
- [ ] **SNMP** — SNMPv3 → MON01 is **Phase 6** (no v2c community present). Logging → MON01 also Phase 6.

## 5. Recovery
- [x] ✅ **Config saved** — `copy running-config startup-config`; export → Oxidized/git once SRV01 exists (Phase 5).
- [x] ✅ **Console break-glass** — used for this pass (SSH was blocked mid-hardening by client-side legacy-crypto until `~/.ssh/config` flags were added). Recovery path proven.

## Deferred / later
- SNMPv3 + syslog → MON01 (**Phase 6**).
- **Pass-2** AAA (**RADIUS → NPS on `NPS01`**, `ADR-0029`; FreeRADIUS retired) — keep local `ciscoadmin` + console as break-glass.
- SHA2 SSH MACs + KEX pinning — need a newer IOS image (hardware/image limitation).

## Real Priorities — ✅ done 2026-07-22 (Pass 1)
1. ✅ SSH crypto (CTR ciphers, DH 2048, retries) — CBC/3DES/1024 gone; KEX un-pinnable but floored at 2048.
2. ✅ vty scoped to mgmt subnet + `exec-timeout`; `login block-for` kept.
3. ✅ Secrets → Type 9 scrypt; single named admin.
4. ✅ NTP → DC01 (`CM-0030`).
5. ✅ No telnet/http; host key regenerated then left stable; config saved.

## Related
- `Operations/Device-Hardening-Standard.md` · `1941/Build-Guide.md` (execution) · `CIS-Hardening-SW01.md` / `MKT01` / `FGT01` (siblings) · `ADR-0023` (core-router role) · `ADR-0029` (RADIUS→NPS on `NPS01`) · `Master-Build-Order.md` §2.5.

## Change Log
| Version | Changes |
|---|---|
| 1.1 | 2026-07-28. **C4 auth reconciliation.** Pass-2 AAA target corrected **`ADR-0004`/SRV01-NPS → `ADR-0029`/NPS on `NPS01`** (FreeRADIUS retired; RADIUS now on the dedicated member server) in the Deferred item + Related list. Local `ciscoadmin` + console break-glass unchanged. No device changes. |
| 1.0 | 2026-07-22. Created — 1941 CIS-Hardening doc, Pass-1 **device-verified** in one session: SSH crypto (CTR-only ciphers, DH 2048, retries 2; **MACs SHA1-only** + **no `ip ssh server algorithm kex`** = older-ISR IOS limitations, `dh min size 2048` as the KEX mitigation; documented the required client-side `~/.ssh/config` legacy-algo flags), vty `access-class MGMT-SSH` on both ranges + `exec-timeout`, secrets **Type 5 → Type 9 scrypt**, `login block-for` kept, **NTP → DC01** (peer selected/converging; `CM-0030`), host key regenerated then stabilized, config saved, console break-glass used/proven. Deferred: MON01 logging/SNMPv3 (Phase 6), Pass-2 AAA. |
