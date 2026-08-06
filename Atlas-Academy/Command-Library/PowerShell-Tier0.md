---
Title: Command Library — PowerShell / Tier-0 (DC01, DC02, ICA01, NPS01)
Path: Atlas-Academy/Command-Library
Status: 🟢 LIVING (ADR-0032). Verify commands for the Windows/AD estate — DCs, AD CS, NPS, member servers. Grouped by service; healthy-vs-broken. Run from PAW01 as the right tier.
Version: 1.0
Date: 2026-07-28
---

# Command Library — PowerShell / Tier-0 (Windows / AD)

<!-- provenance -->
> **Atlas Academy — Command Library.** How to verify the Windows estate: **DC01** (PDCe/AD-DNS/forest root `10.20.0.2`), **DC02** (replica/GC), **ICA01** (AD CS issuing CA `10.20.0.4`), **NPS01** (RADIUS `10.20.0.12`), member servers. Quick refs: `DC-Domain-Controllers/Diagnostics-DC01.md`/`-DC02.md`, `RCA01-ICA01-ADCS/Diagnostics-ICA01.md`.

> 🔴 **Tiering (`ADR-0021`):** run Tier-0 checks **from PAW01 as `t0-seth`** — never a Tier-0 credential on a lower-tier box. 🔴 **`POL-0001`:** paste the output; a green cmdlet with no captured result is not evidence.

## §AD / Domain Controllers
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| Domain up | `Get-ADDomain` | `atlas.lab`, `NetBIOSName ATLAS` | RPC/LDAP error (AD DS down) | forest root |
| One forest only | `Get-ADForest \| Select Domains` | **one** domain | a second domain (rogue `Install-ADDSForest`) | DC02 = replica |
| DC inventory + roles | `Get-ADDomainController -Filter * \| ft Name,IPv4Address,IsGlobalCatalog,Site` | DC01+DC02, GC=True | DC02 absent / not GC | — |
| FSMO holders | `netdom query fsmo` | all 5 on DC01 (single-domain) | split/unexpected | Concept W1 |
| DC health | `dcdiag /s:DC01` (and `/s:DC02`) | all tests pass (Replications, SysVol, Advertising, KccEvent) | failures on any | Concept W2 |
| Replication | `repadmin /replsummary` ; `repadmin /showrepl` | **0 failures**, recent success both ways | `>0 fail`, latency growing | DC02 read-back |
| SYSVOL/DFSR | `dcdiag /test:sysvol` ; `Get-WinEvent -LogName 'DFS Replication'` | SYSVOL replicated; GPOs match on both DCs | SYSVOL divergent | Concept W2 |

## §DNS (AD-integrated)
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| Zone present | `Get-DnsServerZone atlas.lab` | Primary, AD-integrated | missing / not AD-integrated | — |
| Forwarder | `Get-DnsServerForwarder` | external forwarder set | root-hints only (slow/leaky) | — |
| Resolve a DC | `Resolve-DnsName dc01.atlas.lab` | `10.20.0.2` | NXDOMAIN | — |
| AD SRV records | `Resolve-DnsName -Type SRV _ldap._tcp.dc._msdcs.atlas.lab` | DC SRV records | missing (domain join/logon breaks) | — |
| External | `Resolve-DnsName microsoft.com` | resolves via forwarder | fails (forwarder down) | — |

## §Time (`ADR-0020`)
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| Source (DCs) | `w32tm /query /source` | **DC01**: external NTP; **DC02/members**: `DC01 (DOMHIER)` | CMOS/`Local` (member off the hierarchy) | `ADR-0020` |
| Sync detail | `w32tm /query /status` | small offset, stratum sane | large offset (Kerberos will fail >5 min skew) | — |

## §Identity / GPO / tiering
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| Tiered accounts exist | `Get-ADUser -Filter {Name -like "*-seth"}` | `t0-seth`,`t1-seth`,`seth` enabled | missing/disabled | Stage 8 |
| Group membership | `Get-ADGroupMember G-Tier0-Admins` ; `whoami /groups` | intended members only | sprawl; DA/EA non-empty | Concept (tiered-admin) |
| GPO result | `gpresult /r` ; `gpresult /h out.html` | baseline + Wave-A precedence, no lockout | missing baseline / wrong order | Stage 7a |
| PSO applies | `Get-ADUserResultantPasswordPolicy <finance-user>` | `PSO-FinanceHR` (min 15) | default policy (PSO not applied) | 7b (measure-first) |
| Tier-deny (7d) | attempt Tier-2 logon to a DC → `Get-WinEvent Security 4625` | denied by user-right | logon succeeds (boundary broken) | 7d |

## §PKI / AD CS (ICA01)
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| CA info | `certutil -cainfo` | Enterprise Subordinate, CN `Atlas Issuing CA` | not-a-CA / wrong type | AD-CS guide |
| CDP/AIA registered | `certutil -getreg CA\CRLPublicationURLs` ; `…CACertPublicationURLs` | HTTP `pki.atlas.lab` entries | wrong/absent (the `ADR-0009` defect) | guide §2.6 |
| PKI health | `pkiview.msc` (Enterprise PKI) | every CDP/AIA/CRL = **OK** | red (a location unreachable) | Part 4 gate |
| Cert chains + revocation | `certutil -verify -urlfetch <cert>.cer` | chains to Atlas Root CA; revocation checked | chain/revocation error | Part 4 |
| DC has LDAPS cert | (on DC) `certutil -store My` | Server-Auth cert, DC FQDN SAN, chains to root | none (LDAPS won't start) | guide §3.3 |
| LDAPS live | `ldp.exe` → dc01.atlas.lab:636 SSL | bind succeeds (RootDSE) | SSL fail (no/untrusted cert) | guide §3.4 |

## §NPS / RADIUS (NPS01, `ADR-0029`)
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| NPS installed/registered | `Get-WindowsFeature NPAS` ; NPS console → registered in AD | Installed; in **RAS and IAS Servers** group | not registered (can't read dial-in) | NPS01 guide |
| RADIUS auth works | test login from MKT01/SW01/1941 → `Get-WinEvent Security 6272/6273` | 6272 access-granted, right group→privilege | 6273 denied / no event | flow #14 |
| Server cert (PEAP) | `certutil -store My` on NPS01 | RAS-and-IAS-Server cert from ICA01 | none (PEAP won't work; PAP still does) | AD-CS §3.5 |

## §Services / roles / addressing / DHCP
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| Role/feature | `Get-WindowsFeature <name>` | Installed | absent | — |
| Service state | `Get-Service NTDS,ADWS,DNS,Netlogon,W32Time,certsvc` | Running (as applicable) | Stopped | — |
| IP config | `Get-NetIPConfiguration` | per the IP plan (`10.20.0.x /26 gw .1`) | wrong mask/gw/DNS | IP plan |
| DHCP (DC01, `ADR-0030`, forthcoming) | `Get-DhcpServerv4Scope` ; `Get-DhcpServerInDC` | scopes per IP plan; authorized in AD; dedicated DDNS acct (not DnsUpdateProxy) | unauthorized / wrong scope | `ADR-0030` |

## §Connectivity — L1→up
| Layer | Command | Tells you |
|---|---|---|
| L3 + TCP port | `Test-NetConnection <dst> -Port <p> -InformationLevel Detailed` | gateway, route, and whether the **TCP service** answers (not just ping) |
| Ping | `Test-Connection <dst> -Count 4` | ICMP reachability only |
| Trace | `Test-NetConnection <dst> -TraceRoute` | where the path dies |
| Which DC serving | `nltest /dsgetdc:atlas.lab` | the DC locator result |

## §Logging / security signals
| Purpose | Command | Healthy | Broken looks like |
|---|---|---|---|
| Failed logons (attack signal) | `Get-WinEvent -FilterHashtable @{LogName='Security';Id=4625} -Max 50` | few, expected | spikes / lockouts / off-hours (4771 Kerberos pre-auth fail) |
| New/changed admin (drift) | `Get-WinEvent … Id=4720,4728,4732` | none unexpected | a new account added to a privileged group |
| Directory / DNS / DFSR | `Get-WinEvent -LogName 'Directory Service','DNS Server','DFS Replication'` | clean | replication/zone errors |

## Related
- Device quick-refs: `Diagnostics-DC01.md`/`-DC02.md`/`-ICA01.md`, `NPS01-Network-Policy-Server/Build-Guide.md`.
- `AD-CS-Two-Tier-Build-Guide.md` · `303-Windows-Design-Standards.md` · `../Concepts/README.md` (W1 FSMO, W2 DFSR, W5 DSRM, tiered-admin).

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-28. Created (`ADR-0032`). PowerShell/Tier-0 verify commands by service — AD/DC (incl. `repadmin`/`dcdiag`/FSMO), AD-DNS, time (`w32tm`/DOMHIER), GPO/PSO/tiering, AD CS (`certutil`/`pkiview`/`ldp`), NPS/RADIUS, services/DHCP, connectivity (`Test-NetConnection` port-test), and security-signal logging (4625/4771/4720) — with healthy-vs-broken and the run-from-PAW tiering rule. |
