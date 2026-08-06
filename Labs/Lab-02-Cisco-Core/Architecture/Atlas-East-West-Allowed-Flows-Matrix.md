---
Title: Atlas — East-West Allowed-Flows Matrix (template + working copy)
Path: Labs/Lab-02-Cisco-Core/Architecture
Status: Draft — working design artifact. Fill from NetFlow evidence before writing Book 11 rules.
Version: 1.7
---

# Atlas — East-West Allowed-Flows Matrix

> **This is the artifact you build *before* a single east-west firewall rule.** The matrix is the design; the rules render it. It is a **Security-silo** artifact (`ADR-0018`) and the method comes from `Atlas-Firewall-Architecture.md` §3.6 and §4. It is deliberately a **template you fill** — the reasons are yours to write, because writing the reason is how you learn the zone.

## How to use this

1. **Default is DENY between every zone pair, and the deny is logged.** This document lists only the *exceptions*. Anything not on it is denied.
2. **One row per allowed flow.** Each row names **source zone → destination zone**, the **service (port)**, the **direction the connection initiates**, and — the point of the whole exercise — **the reason it exists.** No reason, no rule.
3. **Fill the `Evidence` column from NetFlow first.** Turn on NetFlow (roadmap Phase 3), watch the real traffic for a week, and let the flows you actually see drive the matrix. A flow you can't tie to evidence or a stated dependency is a flow you don't need.
4. **Scope to a service, never a whole zone.** `Clients → Servers:443` is a rule. `Clients → Servers` (any port) is a hole with a comment.
5. **Then test the deny.** For every zone pair *not* on the list, prove from a host in the source zone that the service is **refused** — a reachability-matrix Game Day (`ADR-0011`). Isolation you didn't test is isolation you don't have.

## Zones (map your VLANs to trust groups)

| Zone | VLAN(s) | Trust | One-line intent |
|---|---|---|---|
| **UNTRUSTED** | Internet (wan) | none | Nothing trusted; egress controlled at FGT01 (north-south) |
| **DMZ** | 80 | low | Internet-facing services; **must not reach the interior** |
| **IDENTITY (T0)** | DCs — carve from 20 or a new VLAN | highest | Auth in; almost nothing reaches it; it reaches out to manage |
| **SERVERS (T1)** | 20 | high | Reached by clients/web on named ports only |
| **WEB/APP** | 30 | controlled | Talks to Servers; three-tier pattern |
| **CLIENTS (T2)** | 50 | medium | Reaches Servers + internet; **not each other** |
| **MONITORING** | 40 | special | Reaches all read-only (poll/log); **nothing reaches back** |
| **MANAGEMENT** | 10 | highest (infra) | Admins reach devices; devices don't initiate to users |
| **DEPLOYMENT** | 60 | controlled | PXE/WDS to Servers |
| **TESTING** | 70 | isolated | Internet only; no lab access (already enforced) |
| 🆕 **OT ISOLATION** | **90 (new)** | isolated (Purdue 0–3) | The plant floor: PLCs, HMIs, SCADA, the un-patchable 2019 box, Facilities HVAC/badge. **One controlled IT/OT conduit; availability outranks confidentiality.** (`305` Part 2 / NIST 800-82) |
| **RECOVERY** | ~~bridgeLocal 10.0.0.0/24~~ ⚠️ **see note** | break-glass | Admin recovery. 🔴 **Reconcile: `ADR-0013` RETIRED the `bridgeLocal` recovery network.** Recovery posture is now console-based (`ADR-0016`), not a network zone — this row is stale and should be re-cast as "console break-glass," not a routed `10.0.0.0/24`. |

## Summary matrix (source → destination)

Cell = the allowed service(s), or **DENY** (default). Fill/scope each; this is seeded from MKT01's *current* rules, most of which are still whole-zone and need tightening to services.

| src ↓ \ dst → | UNTR | DMZ | IDENT | SRV | WEB | CLI | MON | MGMT | DEPL | TEST |
|---|---|---|---|---|---|---|---|---|---|---|
| **MANAGEMENT** | 🟡 all | 🟡 all | mgmt | mgmt | mgmt | mgmt | mgmt | — | mgmt | mgmt |
| **MONITORING** | DENY | poll | poll | poll | poll | poll | — | poll | poll | poll |
| **SERVERS** | 🟡 all | DENY | auth→IDENT | — | DENY | DENY | DENY | DENY | DENY | DENY |
| **WEB** | DENY | DENY | auth | app-port | — | DENY | DENY | DENY | DENY | DENY |
| **CLIENTS** | 🟡 all | DENY | auth | 🟡 app | DENY | — | DENY | DENY | DENY | DENY |
| **DEPLOYMENT** | DENY | DENY | DENY | pxe/img | DENY | DENY | DENY | DENY | — | DENY |
| **DMZ** | reply | — | DENY | 🔴 1 host? | DENY | DENY | DENY | DENY | DENY | DENY |
| **TESTING** | 🟡 all | DENY | DENY | DENY | DENY | DENY | DENY | DENY | DENY | — |
| **RECOVERY** | all | all | all | all | all | all | all | all | all | all |

🟡 = exists today but is **whole-zone / unscoped** — tighten to a service. 🔴 = a flow to justify to a *single host + port* or delete. `poll` = one-directional (monitoring initiates; nothing initiates back). `auth` = LDAPS/Kerberos/RADIUS to Identity only.

> 🆕 **Add the OT column and row** (VLAN 90) to the grid above: **DENY in every cell both ways**, except the single named IT→OT conduit (flow #11) and monitoring's read-only visibility (flow #13). OT is the strictest zone in the matrix — it defaults denied even where other zones get a 🟡. See the per-flow rows 11–13 and `305` Part 2.

## Per-flow detail (the working table — fill and tighten)

| # | Source | Dest | Service / port | Dir | Reason (write this) | Evidence | Rule status |
|---|---|---|---|---|---|---|---|
| 1 | MANAGEMENT (10) | all zones | *scope: SSH/443/WinBox* | init from MGMT | Admin manages every device — but scope to mgmt ports, not "all" | current rule 9 | 🟡 exists, unscoped |
| 2 | MONITORING (40) | all zones | SNMP/161, ICMP; syslog **inbound to 40** | poll out; logs in | Poller reaches agents; agents never initiate into MON | current rule 10 | 🟡 exists, unscoped |
| 3 | CLIENTS (50) | SERVERS (20) | *scope: 443 (+ app ports)* | init from CLI | Users reach the app on the server tier | current rule 12 | 🟡 exists, unscoped |
| 4 | WEB (30) | SERVERS (20) | *scope: SQL/1433 or app port* | init from WEB | Three-tier: web tier → backend/db only | current rule 15 | 🟡 exists, unscoped |
| 5 | DEPLOYMENT (60) | SERVERS (20) | TFTP/69, HTTP, PXE | init from DEPL | WDS/PXE pushes images | current rule 14 | 🟡 exists, unscoped |
| 6 | CLIENTS (50) | UNTRUSTED | 80/443/53 | init from CLI | User internet access | current rule 13 | ✅ ok |
| 7 | SERVERS (20) | UNTRUSTED | 80/443/53 | init from SRV | Updates, external APIs | current rule 11 | ✅ ok |
| 8 | TESTING (70) | UNTRUSTED | 80/443 | init from TEST | Isolated — internet only, no lab | current rule 16 | ✅ ok (isolation) |
| 9 | *(any T1/T2)* | IDENTITY (T0) | LDAPS/636, Kerberos/88, DNS/53 | init inbound to T0 | Domain auth — the ONLY thing that reaches Tier 0. **RADIUS to NPS01 is *not* here** — NPS01 lives in the server range, not the `.2–.9` carve, so network-device RADIUS is flow #14, keeping this micro-zone LDAPS/Kerberos/DNS-only | **add when AD lands (`ADR-0021`)** | ⬜ to build |
| 10 | DMZ (80) | SERVERS (20) | *one host, one port — or DELETE* | — | Only if a DMZ app truly needs one backend call | — | 🔴 justify or deny |
| 11 | *(corporate: any IT zone)* | OT ISOLATION (90) | 🔴 **one host, one port — the single named conduit, or DENY** | init inbound to OT | The **only** IT→OT flow the process genuinely needs (e.g. a SCADA historian pull). Everything else corporate→OT is denied and logged. Availability first — a deny must never risk the line (`305` Part 2) | **build with the OT zone** | ⬜ to build |
| 12 | OT ISOLATION (90) | *(any corporate zone)* | 🔴 **DENY (default)** | — | The plant floor never initiates into corporate IT, the internet, or identity. The un-patchable box is *why* — segmentation is the compensating control it can't be patched into | — | ⬜ default DENY |
| 13 | MONITORING (40) | OT ISOLATION (90) | passive/poll only, read-only | poll out | Visibility into OT without touching it; nothing initiates back. Prefer passive taps over active polling on fragile OT | **build with the OT zone** | ⬜ to build |
| 14 | **network devices** (MKT01 / SW01 / 1941, MGMT plane) | **SERVERS (20) → NPS01 `10.20.0.12`** | **RADIUS — UDP 1812/1813** | init inbound to SRV (NPS01) | The network devices are RADIUS clients of **NPS01** for admin login (`ADR-0029`; FreeRADIUS retired). 🔴 **NPS01 sits in the server range, deliberately *not* in the `.2–.9` Identity micro-zone (flow #9)** — so RADIUS to NPS01 does **not** widen the Tier-0 zone, which stays LDAPS/Kerberos/DNS-only. Scope to the two RADIUS ports + the three device source IPs, not a whole zone. | **build with NPS01 (`ADR-0029`)** | ⬜ to build |
| 15 | **CLIENTS (50)** | **SERVERS (20) → RDS01 `10.20.0.17`** | **RD Gateway TCP 443** (+ gateway→session-host **RDP 3389**, intra-server) | init from CLI | Standard users reach **published desktops/RemoteApps** via the RD Gateway on RDS01 over TLS; the gateway proxies to the session host on 3389. Authorization enforced by **NPS01 CAP/RAP** (`ADR-0029`); TLS cert from **ICA01** (`ADR-0027`). Scope to 443→RDS01 + the gateway→host 3389 — not a client→server-zone hole. Refines flow #3 for the RDS case; `G-Tier0-Admins` excluded (`ADR-0021`). | **build with RDS01** | ⬜ to build |
| 16 | **PAW01** (mgmt) → **WAC01** `10.10.0.5`; then **WAC01 → estate** | WAC gateway + managed nodes | **PAW→WAC TCP 443** (admin browse); **WAC→nodes WinRM 5985/5986** | init from PAW / from WAC | WAC01 is the **Tier-0 management gateway** on **VLAN 10**: only **PAW01** may reach its 443; WAC then manages the Windows estate (DCs / member servers) over WinRM. Scopes the generic mgmt flow #1 to WAC's ports; **deny 443→WAC from any non-PAW source** (`ADR-0021` / `ADR-0045`). | **build with WAC01** | ⬜ to build |
| 17 | MANAGEMENT (10) + automation | SERVERS (20) → NETBOX01 `10.20.0.11` | HTTPS 443 (UI + REST/GraphQL API) | init from MGMT/automation | Admins use the NetBox UI; automation reads the API to render device configs (`POL-0004`/`ADR-0048`). Scope to 443→NETBOX01; refines flow #1/#3. | build with NETBOX01 | ⬜ to build |
| 18 | PVE hosts + MGMT/CLIENTS | SERVERS (20) → BKP01 `10.20.0.18` + Vaultwarden `10.20.0.13` | PBS 8007 (backup) · Vaultwarden HTTPS 443 | init to SRV (BKP01) | PVE hosts push VM/system-state backups to PBS (8007); admins/clients reach the vault over ICA01 TLS (443). Off-site restic/borg egress is separate (N-S). Scope to the two ports on BKP01. | build with BKP01 | ⬜ to build |
| 19 | **DCs (`10.20.0.2/.3`) + infra/network devices** | MANAGEMENT (10) → Pi01 `10.10.0.6` | DNS 53 (Pi-hole) · NTP 123 (chrony) | init to Pi01 | Pi01 (VLAN 10) is the estate's filtering DNS forwarder + chrony NTP; it conditional-forwards `atlas.lab`→the DCs. **DECIDED (operator, #20 2026-07-30): a scoped, logged exception** to the 'nothing initiates into MGMT' rule — allow **only named sources** to Pi01 on **53/123**: the **DCs** (upstream/forwarded DNS) and **infra/network devices** (NTP + non-domain DNS). **Domain clients resolve via AD-DNS (DC01/DC02), not Pi01**, so the ingress stays small; everything else into MGMT is denied+logged. Same pattern as flow #14 (RADIUS→NPS01) and #21 (→SIEM01): a tightly-scoped, one-service exception, not a MGMT-wide hole. | build with Pi01 | ⬜ to build (scoped exception) |
| 20 | MGMT/devs + Oxidized | SERVERS (20) → CNT01 `10.20.0.19` | git SSH 22 + HTTPS 443 · CI | init to SRV (CNT01) | The estate self-hosted git/CI (Gitea/GitLab + runner, Backlog #19): devs push/browse; Oxidized commits device configs (GitOps → PR → deploy); CI runs Ansible/Terraform against the estate. ICA01 TLS. Scope to git/CI ports on CNT01. | build with CNT01 (gated on the #19 ADR) | ⬜ to build |
| 21 | estate hosts (agents) + MON01 | **SIEM01 (Wazuh) `10.40.0.11` (VLAN 40)** | agent **1514/1515** · Suricata+rsyslog **514** · dashboard 443 | agents/MON01 init **in** | Wazuh **agents push** FIM/SCA/vuln to SIEM01 (1514) + MON01 ships Suricata/rsyslog (514) → one security pane (K8). 🔴 **Scoped exception:** this is *ingress into the monitoring plane* (normally 'nothing initiates into MON', flow #2) — allow **only** the agent/syslog ports to SIEM01, nothing else. | build with SIEM01 | ⬜ to build |
| 22 | KALI01 (VLAN 70) | *the zone under test* | *scoped, per Game Day* | init from KALI01 | 🔴 **No standing flow.** KALI01 is isolated (VLAN 70, internet-only); an attack path is **opened per Game Day** (`ADR-0011`), tested, then **closed**. The default is DENY; the only allows are the deliberate, temporary test paths. | per Game Day (`ADR-0011`) | ⬜ / by-test |
| 23 | **PAW01 (MGMT 10 `10.10.0.8`)** | **IDENTITY (T0) `10.20.0.2–.9`** (DC01/DC02/ICA01) | admin: **RDP 3389** · **WinRM 5985/5986** · RSAT (MMC/RPC) | init from PAW (MGMT) | The **Tier-0 admin path**: PAW01 now sits on the **management plane (VLAN 10, `#20`-decided)**, not inside the Tier-0 carve, so administering the DCs/CA is a **MGMT→IDENTITY** flow. This is the *only* interactive-admin path into Tier 0 (`ADR-0021`: the admin path exists **only** from the Management zone, `305` Part 4). Scope to PAW's source IP + the Tier-0 hosts + the admin ports; **deny admin logon to Tier-0 from any non-PAW source.** Complements flow #9 (auth-only) and #16 (PAW→WAC). | build with PAW01 / Phase 3g | ⬜ to build |
| — | *everything else* | *everything else* | — | — | **No reason = denied + logged** | — | default DENY |

## Verification plan (the Game Day that proves it)

1. **Read the rules in English**, top to bottom. If you can't say what a rule permits, you don't know your policy.
2. **Test every allowed flow** — generate it, confirm it passes, find it in the session table.
3. 🔴 **Test the denied flows** — the half everyone skips. From a host in each source zone, attempt a service in each *denied* destination; confirm it is **refused**, and confirm the deny is **logged with a correct timestamp** (needs synced clocks — `ADR-0020`).
4. **Watch the SPAN** (`SW01 Gi1/0/5` + Suricata/Wireshark) to see what's *actually* crossing, independent of what the policy claims.
5. **Confirm the path physically crosses the E-W firewall** (`ADR-0023` Option B: MKT01 *is* the inter-VLAN gateway, so it's in the path by construction — the 1941 handles north-south/core — but confirm it, don't assume it; segmentation on paper only is the failure to catch).

> **The failure to design against, above all others:** allowing everything to make bring-up easy and never tightening. Start denied. Open one proven flow at a time. Every 🟡 above is a flow that "works" today but is scoped to a whole zone — turning each into a named service is the exercise.

## Related pages

- `00-Atlas-Foundation/Atlas-Firewall-Architecture.md` — the method, in depth (§3.6 segmentation, §4 the Book 11 design bar, §6 the verification method)
- `00-Atlas-Foundation/Decisions/ADR-0021-AD-as-Tiered-Identity-Backbone.md` — where the Identity (Tier 0) zone and flow #9 come from
- `00-Atlas-Foundation/Decisions/ADR-0018-Atlas-Operating-Model-Silos.md` — Security owns firewall *policy*; this matrix is a Security artifact
- `Labs/Lab-01-Mikrotik-Core/Standards/008-VLAN-Standards.md` — the current east-west permit list (seed for this matrix)
- `Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Build-Record.md` — the live rules 9–19 this matrix is seeded from

## Change Log

| Version | Changes |
|---|---|
| 1.7 | 2026-07-30. **#20 address-deconflict flows (operator decisions).** **Resolved flow #19 (Pi01)** from an open question to a **scoped, logged exception** into MGMT — only the **DCs** (forwarded DNS) + **infra/network devices** (NTP/DNS) may reach Pi01 `10.10.0.6` on 53/123; domain clients use AD-DNS, keeping the ingress minimal. **Added flow #23 — PAW01 (MGMT 10 `10.10.0.8`) → IDENTITY/Tier-0 (`10.20.0.2–.9`)** admin (RDP 3389 / WinRM / RSAT): PAW moved to the management plane in the #20 sweep, so Tier-0 admin is now a MGMT→IDENTITY flow (the only interactive admin path, `ADR-0021`/`305` Part 4). Annotated **flow #21** with SIEM01's firmed address `10.40.0.11` (VLAN 40). |
| 1.6 | 2026-07-30. **Batch C+D security-device flows.** Added **#21** hosts/MON01 → **SIEM01** (agent 1514 + Suricata/rsyslog 514 → one pane, K8; a **scoped exception** to 'nothing into monitoring') + **#22** **KALI01** controlled-attack (no standing flow — paths opened per Game Day, `ADR-0011`, then closed). PFSENSE01 is a transparent bridge (no data-plane flow of its own). |
| 1.5 | 2026-07-30. **Batch B (Linux service VMs) flow rows.** Added **#17** MGMT/automation → NETBOX01 (443 UI + API, `POL-0004`), **#18** PVE/MGMT/CLIENTS → BKP01 (PBS 8007) + Vaultwarden (443), **#19** non-domain/infra → Pi01 (DNS 53 + NTP 123 — 🔎 flags the MGMT-VLAN-ingress design question), **#20** MGMT/devs + Oxidized → CNT01 git/CI (SSH 22 + 443; Backlog #19, gated on the #19 ADR). All ⬜ to build. |
| 1.4 | 2026-07-30. **Added flow #16 — PAW01 → WAC01 (443) + WAC01 → estate (WinRM 5985/5986).** The Tier-0 management gateway: only PAW01 reaches WAC's 443; WAC manages the Windows estate over WinRM. Scopes the generic management flow #1 to WAC's ports; deny 443→WAC from non-PAW sources (`ADR-0021`/`ADR-0045`). Added with the WAC01 replication pass. |
| 1.3 | 2026-07-30. **Added flow #15 — CLIENTS(50) → RDS01 (RD Gateway 443 + gateway→host RDP 3389).** Standard users reach published desktops via the RD Gateway (TLS from ICA01), authorized by NPS01 CAP/RAP (`ADR-0029`); refines the generic flow #3 for the RDS case; Tier-0 excluded (`ADR-0021`). Added with the RDS01 replication pass (Gateway/Web now in scope, operator 2026-07-30). |
| 1.0 | 2026-07-16. Template + working copy seeded from MKT01's current east-west rules (`022` / `008`). Zones mapped to VLANs with a Tier 0 identity zone (`ADR-0021`); summary matrix + per-flow detail table; every current whole-zone permit flagged 🟡 to tighten to a service; verification/Game-Day plan included. Fill the `Reason` and `Evidence` columns from NetFlow before writing Book 11 rules. |
| 1.2 | 2026-07-28. **Added flow #14 — network-device RADIUS → NPS01** (register A2b): MKT01/SW01/1941 (management plane) → **NPS01 `10.20.0.12`** in the Servers zone, **UDP 1812/1813**, per `ADR-0029` (FreeRADIUS retired, auth consolidated on Windows NPS). Deliberately keeps NPS01 in the server range and **out of the `.2–.9` Identity micro-zone** (flow #9), so RADIUS does not widen Tier 0 — annotated flow #9 to say so. Scope to the two ports + the three device source IPs. No zone/matrix-grid changes. |
| 1.1 | 2026-07-17. **Added the OT ISOLATION zone (VLAN 90)** from `305` Part 2 / NIST 800-82 — the zone `301`'s VLAN table was missing: default-deny both ways, one named IT→OT conduit (flow #11), OT never initiates into corporate (#12), monitoring read-only into OT (#13). Flagged the **stale RECOVERY/`bridgeLocal` row** for reconciliation (`ADR-0013` retired that network; recovery is now console break-glass per `ADR-0016`). Aligned the verification note to `ADR-0023` Option B (MKT01 is the inter-VLAN gateway, in-path by construction). |
