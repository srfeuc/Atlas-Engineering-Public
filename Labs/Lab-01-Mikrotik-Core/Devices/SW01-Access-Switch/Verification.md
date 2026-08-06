---
Title: SW01 Verification Procedure
Path: Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch
---

# SW01 Verification Procedure

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: SW01 - Role: Access Switch

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified |
| Version | 1.0 |
| Applies To | SW01 (10.10.0.2, VLAN 10 SVI — Cisco Catalyst 2960X, IOS 15.2(2)E6, Layer-2 switch) |
| Evidence Status | **Verified** — full read-only battery run against the live device 2026-07-16 |
| Last Run | 2026-07-16 |

## Purpose

The **reconcile-to-live** procedure for SW01: prove the running switch matches `023` (Build Record) and `027` (Build Guide), walking each doc from 🟡 (doc-consistent) to 🟢 (device-verified). Run before a Game Day (`ADR-0011`), after any change, or when a doc is in doubt.

**Read-only checks only.** Risks and open items live in `057-SW01-Considerations-and-Risks.md`.

## How to run

SW01 is Cisco IOS, not Linux — there is no bash script. SSH in and paste the block in `Tools/scripts/sw01-recon.ios.txt` (also summarised below). IOS 15.2 offers only deprecated SSH algorithms, so Windows needs the legacy-flag form or an `ssh sw01` alias (see `027` §3):

```text
ssh -oKexAlgorithms=+diffie-hellman-group14-sha1 -oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa -oMACs=+hmac-sha1 cisco@10.10.0.2
SW01# terminal length 0        # pager off, this session only
```

> 🔴 **Empty output is not a pass** (Rule 13; `016`). A command that returns nothing means the capture failed, not that the device is clean. Re-run until you see real content.
> 🔴 **No secrets.** Do **not** run `show running-config` in full — it prints `enable secret`, `username … secret`, and the SNMP community. The battery uses scoped `show run |` sections that carry no secret. SNMP is a **manual, redacted** step: run `show snmp host` by hand and paste only the version and trap host — **redact the community** (live cleartext v2c, `CM-0023`).

## Verification battery

### Batch A — Identity + platform (`027`, `023`)

| Check | Command | Expected (device-verified 2026-07-16) |
|---|---|---|
| Hostname / model / IOS | `show version` | hostname **`SW01`**, `WS-C2960X-48FPS-L`, IOS **`15.2(2)E6`**. 🔴 Live hostname is **SW01**, not the old `CoreSwitch` name — the stale docs were corrected by the 2026-07-16 CoreSwitch sweep (`CM-0022`, `057` row 10) |
| Hostname / domain / gateway | `show run \| include hostname\|ip domain-name\|ip default-gateway` | `hostname SW01`, `ip domain-name lab.local`, `ip default-gateway 10.10.0.1` |

### Batch B — Clock + NTP (`CM-0030` — the headline finding)

| Check | Command | Expected (device-verified 2026-07-16) |
|---|---|---|
| Clock sync state | `show ntp status` | 🔴 **`Clock is unsynchronized, stratum 16, no reference clock`**, reference time 1899, **`never updated`** — the switch has never synced (`CM-0030`). 🟢 only *after* CM-0030 remediation is proven here |
| NTP peer | `show ntp associations` | 🔴 one peer `~10.10.0.5` (Pi01), ref clock **`.INIT.`**, **reach `0`**, disp ~16000 — configured, never answered. Pi01 serves no NTP (`053` row 4) |
| Local clock | `show clock detail` | timezone `CST -6` / `CDT` summer-time; time is manually/boot-set and **not NTP-disciplined** — it drifts (that is the CM-0030 risk) |

> 🔴 **This is the one batch where "expected" is a known-broken state.** The device *wins*, so the honest expected value today is stratum 16. A row here flips to 🟢 only when CM-0030 is remediated per **`ADR-0020`** (external-pool interim for SW01; AD PDC-emulator target) and `show ntp status` returns `Clock is synchronized`.

### Batch C — VLANs + interfaces (`023`, `027`)

| Check | Command | Expected (device-verified 2026-07-16) |
|---|---|---|
| VLAN database | `show vlan brief` | 9 VLANs active: 10 Management, 20 Servers, 30 Web, 40 Monitoring, 50 Client, 60 Deployment, 70 Testing, 80 DMZ, 999 Unused. Gi1/0/8–52 sit in 999 |
| SVI / addressing | `show ip interface brief` | `Vlan10` **`10.10.0.2` up/up**; `Vlan1` admin-down; access/uplink ports up. 🔴 **`Gi1/0/4` (PVE01) down/down** — link down (`057` row 8) |
| Port roles | `show interfaces status` | Gi1/0/1 trunk (MKT01), Gi1/0/4 trunk (PVE01), Gi1/0/2 LabComputer, Gi1/0/6 FGT01-mgmt, Gi1/0/7 Pi01, Gi1/0/5 SPAN dest; Gi1/0/3 + Gi1/0/8–52 disabled |
| Trunks | `show interfaces trunk` | Gi1/0/1 native **999**, Gi1/0/4 native **10**; both allow 10–80,999 (`027` §11–12) |

### Batch D — Layer-2 security (`023` L2 Security, `027` §8/§9/§16)

| Check | Command | Expected (device-verified 2026-07-16) |
|---|---|---|
| ACLs | `show ip access-lists` | user ACL `MGMT-ACCESS` (3 ACEs: permit 10.10.0.0/24, permit 10.0.0.0/24, deny any log). *(`CISCO-CWA-URL-REDIRECT-ACL` / `preauth_ipv4_acl` are IOS auto-generated, not build config.)* |
| DAI | `show ip arp inspection` | enabled + Active on VLANs 10,20,30,40,50,60,70,80; VLAN 10 carries filter **`STATIC-HOSTS`**; global src/dst/IP validation **Disabled**. 🟨 VLANs 20–80 have **no** static ACL (`057` row 7) |
| DHCP snooping | `show ip dhcp snooping` | enabled + operational on VLANs 10–80; **trust on `Gi1/0/1` only** |
| Snooping bindings | `show ip dhcp snooping binding` | 🟨 **`Total number of bindings: 0`** — every VLAN-10 host is static, permitted by the ARP ACL, not by a binding (`057` row 7) |
| Static ARP ACL | `show arp access-list` | `STATIC-HOSTS` = **five** entries incl **Pi01 `10.10.0.5`** (`CM-0022` fix holds): .5, .10, .50, .100, .254 |
| Port security | `show port-security` | configured on the access ports (Gi1/0/2 max 2, Gi1/0/4 max 16, Gi1/0/7 max 2), violation `restrict` |

### Batch E — Control plane + management hardening (`045`, `027`)

| Check | Command | Expected (device-verified 2026-07-16) |
|---|---|---|
| STP root | `show spanning-tree summary` | Rapid-PVST+, priority 4096 — **this bridge is root** for all VLANs |
| SPAN | `show monitor session 1` | 🔴 **destination `Gi1/0/5` only — NO source configured** on the device (`023`/`027` say source `Gi1/0/1 both`; the live config has only the destination line). Divergence — `057` row 6 |
| Hardening one-liner | `show run \| include no cdp run\|no ip http\|logging host\|aaa new-model\|snmp-server location` | `no cdp run`, `no ip http server`, `no ip http secure-server` present ✅; **no `logging host`** (no remote syslog — `057` row 4); `no aaa new-model` (local auth only — `057` row 5); 🔴 `snmp-server location Home-Lab-California` **still live** (`027` said it was removed — `057` row 11) |
| VTY | `show run \| section line vty` | both `line vty 0 4` and `5 15`: `access-class MGMT-ACCESS in`, `login local`, `transport input ssh` ✅ (settles `045` §1.2) |
| SNMP *(manual, redacted)* | `show snmp host` | **v2c**, RO community (**redact**), trap host `10.40.0.52`. 🔴 v2c not v3 (`045` §1.5); trap host may not exist (`027` §17) — `057` row 2 |

## Interpreting results

- **Device wins** (Rule 13). A mismatch is a finding for `057`, not licence to edit the device to match a doc.
- **A clean command is not a correct artefact** — read the state back. On this switch the trap is the reverse of FGT01's: a *config line that looks right is not a working service*. `ntp server 10.10.0.5` reads fine in `show run`; `show ntp status` shows it has never worked. **Always run the status command, not just the config.** (`CM-0030`, `016`.)
- **`show run |` scopes, never the full config** — the full running-config carries three secrets; the scoped sections in the battery do not.

## Last-run record

| Date | Run by | Result | Output |
|---|---|---|---|
| 2026-07-16 | Seth | 🟢 Live state matches `023`/`027` on identity, VLANs, trunks, DHCP-snooping/DAI scope + trust, the five-entry `STATIC-HOSTS`, STP root, VTY ACL, CDP/HTTP off — **except** the divergences tracked in `057`: clock stratum 16 (`CM-0030`), SPAN has no source, SNMP location string still live, and `Gi1/0/4`→PVE01 link down. | pasted CLI session |

## Related pages

- Build Guide: `027` · Build Record: `023`
- **Considerations & Risks: `057-SW01-Considerations-and-Risks.md`**
- Troubleshooting: `039` · CIS: `045`
- Change records / decisions: `CM-0030` (clock — Open), **`ADR-0020`** (time-source decision), `CM-0022` (guide/record rebuild + hostname), `CM-0001`/`CM-0003`, `ADR-0002`
- Script: `Tools/scripts/sw01-recon.ios.txt`
