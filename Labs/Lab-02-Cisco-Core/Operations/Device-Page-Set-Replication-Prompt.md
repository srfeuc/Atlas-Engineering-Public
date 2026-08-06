---
Title: Device Page-Set Replication — Successor-Bot Bootstrap Prompt
Path: Labs/Lab-02-Cisco-Core/Operations
Status: 🟢 LIVING bootstrap — hand this to a fresh assistant/session to continue replicating the DC page-set template across the estate. Self-contained: it assumes no memory of prior chats. **v1.1: the FortiGuard-UTM ADR (`ADR-0047`) is DONE, MON01 is DONE, the `Automation/` doc-type (`ADR-0048`) is added, and §4 is re-ordered to the operator's batches (Windows/DC-touch systems-engineering first → Linux service VMs → networking + security together).**
Version: 1.8
Date: 2026-07-30
---

# Atlas — Device Page-Set Replication (successor-bot bootstrap prompt)

> **Paste-me.** This is a standalone brief for a new assistant picking up the Atlas documentation build. It assumes you have the device bridge to Seth's machine and can read/write the repo. Read §10's docs on arrival, then work §4 one device at a time. Everything here is verifiable in the repo — trust the repo over this prompt if they ever disagree (`POL-0001`).

## 0. Your mission

Replicate the **DC-Domain-Controllers page-set** (the worked exemplar) across the remaining Atlas **Lab-02-Cisco-Core** devices, following **`00-Atlas-Foundation/Atlas-Documentation-Standard.md` (v1.4)**, so every device has the same fixed folder shape and the estate becomes **mechanically buildable** ("hash it all out before I touch a device; I hate placeholders"). **Docs-only.** Seth runs all device/AD commands and all git; you author docs and print commit blocks. **MON01 is the second worked exemplar (a multi-service `Roles/` host) — copy either.**

The north star (Seth's words): *"if I leave the company another person could pick this up and know exactly what to do."*

## 1. Environment & how you work

- **Repo:** on Seth's machine at `C:\Users\atlas\Atlas\Atlas-Engineering-Repository`; via the bridge it's under `/sessions/*/mnt/Atlas-Engineering-Repository` (use `device_bash`). A stale read-only copy may also appear under uploads — **ignore it; the device path is live.**
- **You edit docs** by writing files on the device (`device_bash`, e.g. `cat > file <<'EOF'` or a `python3` splice for precise edits). **You do NOT run device/AD/network commands, and you do NOT commit.** After each logical change, **print an exact PowerShell commit block** (`cd … ; git add <paths> ; git commit -m "…" ; git push`) and Seth runs it.
- **Ground-truth reads:** use `git show HEAD:<path>` — the file-bridge cache has served stale content before. Verify state with **git**, not the bridge cache.
- **Never** leave a bot-edited doc open in VS Code with unsaved changes (an autosaved editor buffer once clobbered a bridge write). Git via the **PowerShell terminal**, not the VS Code Source Control panel.
- If a `.git/index.lock` appears (a bridge-side `git status` can leave one) or you need to "delete" a file, you **can't `rm`** over the bridge — `mv` it into `_to_delete/` and tell Seth to delete that folder.
- Use `git --no-optional-locks status` to avoid lock churn.

## 2. Ground rules (non-negotiable — carry these)

- **`POL-0001` — the device is the source of truth.** If a doc disagrees with a device, the device wins; verify, then fix the doc. **Never fabricate** config, IPs, group/CA names, or command output. Mark anything not yet read back from a device **🟡 lab-unverified**.
- **`POL-0008` — one home per fact.** Addresses → `Architecture/IP-Addressing-Plan-VLSM.md` (→ NetBox); decisions → an ADR; east-west flows → `Architecture/Atlas-East-West-Allowed-Flows-Matrix.md`; reusable commands → `Atlas-Academy/Command-Library/`; "where we are" → `SESSION-HANDOFF.md`; line-item status → the device `Build-Checklist.md`. Everything else **links** to the owner — never restates.
- **Marker convention:** ✅ device-verified · 🟡 lab-unverified · 📋 planned · 🔴 blocker/gate.
- **`ADR-0041` — incremental, test-gated:** one unit at a time; a positive **and** negative acceptance gate; ✅ only on a passing gate.
- **`ADR-0044` — enterprise-first, certs anchor the skills:** build the realistic enterprise; label the cert objective each role exercises; **gated stubs are designed, not placeholders** (`ADR-0043`).
- **Readability (Seth):** lay build items out as **checkboxes/bullets**, not dense paragraphs — "I'll miss stuff if I read it in one paragraph."
- **GUI-primary:** GUI (GPMC/ADUC/Server Manager/device console) first, PowerShell/CLI alongside, with 📸 screenshot capture points.
- **Security hygiene:** never record live secrets (LAPS/DSRM/account/CA passwords); CA passphrases → Vaultwarden per `ADR-0009`.

## 2a. Planning & Handoff Protocol (`ADR-0049`) — carry these

Adopted 2026-07-30 (operator). These make the wave "right the first time" and shrink the later sweeps:

- **Ask design questions at planning.** For each device, surface its open design calls to the operator **as explicit questions** at planning time — placement/uptime tier · role scope · VLAN/addressing · tiering & access · which optional services are in scope — and resolve them **then**, not in the #20/#22 sweep. Record each in the device `Considerations.md` **"Decided"** section + propagate to the owner (`POL-0008`: IP plan / flows matrix / estate index / an ADR). The operator may answer directly or point you at the owning doc. *(RDS01 is the worked example — placement → EQR6, gateway included, VLAN 20, all asked + resolved at planning.)*
- **Connections diagram edges carry protocol/port** (Standard **v1.6**) — e.g. `LDAPS/636`, `RDP/3389`, `RADIUS/1812`; nodes keep role labels, no IPs. The diagram is a top-priority artifact (operator) — the *how connected* story goes on the picture.
- **Per-device narrowing.** The DC template is a **starting shape**; tailor to the device's real roles/services/connections; prune template carry-over. Capture `Considerations`/Academy items inline when they don't disrupt the device, else placeholder/backlog (#22) — never drop them.
- **Handoff = Living STATE + append log.** `SESSION-HANDOFF.md` has a pinned **`📍 CURRENT STATE`** block on top (always current) above the append-only session log. **Read the STATE block + the latest session block in full before acting** (the read rule). **Refresh STATE + append a session block after each device folder.** Archive the oldest blocks to `99-Archive/` past ~8 blocks / ~80 KB.

## 3. The template you're copying — the DC page-set

**Exemplar:** `Devices/DC-Domain-Controllers/`. Copy this **fixed folder shape** (`ADR-0037`); adapt content per device.

| Doc | Owns | Authored |
|---|---|---|
| `README.md` | Front-door: identity table · "Role this era" · the **Connections map** (Depends-on / Depended-on-by / Services-provided) · a "documents in this folder" index · single-source links | Planning |
| `Roadmap.md` | The per-role/stage **build path** (each row a role/stage; dated checkbox; **Needs / Unblocks**) · a Connections-at-a-glance table · a **Certification-alignment** table · a **Future — hybrid/cloud** (gated) section | Planning |
| `Build-Checklist.md` | The **line-item, dated, evidence-backed** status — the authoritative status (`POL-0001`) | Planning → bench |
| `Considerations.md` | Open risks & decisions that live on this host | Planning |
| `Build-Guide/` | The **rebuild contract** — phased/gated (`ADR-0043`): mirrors the Roadmap 1:1, a per-phase 🔴 **GATE** header, standard sections **Certificate-application / Service-setup / Automation-onboarding**, future phases as **designed gated stubs**. Nest per sub-host (`Build-Guide/<HOST>/`); use `Roles/<svc>/` for genuinely separate services | Bench |
| `Build-Record.md` | The **verified as-built state** (records outrank guides) | Bench |
| `Diagnostics-<HOST>.md` | The read-only health/verify battery (links up to the Academy `Command-Library`); **doubles as the live source of truth** + Troubleshooting seeds | Bench |
| `Troubleshooting.md` | Symptom → cause → fix | Bench |
| `Changes/README.md` | The `CM-####` change ledger (starts empty) | — |
| `Automation/README.md` | 🆕 The device's **automation slice + how-tos** (`ADR-0048`, Standard v1.4): Ansible/IaC to build the device repeatably, authored **after** the manual first pass (automate what you've learned by hand — Learning Rule). Runnable shared code = the estate capability (self-hosted git/CI, Backlog #19). Early on a designed stub. | Post-manual build |

**Also apply the 4 analytical elements (Standard v1.2) to every device:** (1) 📸 **capture markers** at key Build-Guide points; (2) a Roadmap **Certification-alignment** slice linking the cert-lab-maps; (3) a **staged traffic-flow** view (owner = the flows matrix); (4) a **Validation link** to `Operations/Validation-and-Adversarial-Testing.md`.

**CIS/hardening** is central in `Operations/Device-Hardening-Standard.md` + the GPO baseline — no per-device hardening doc unless it grows.

**Two lifecycles:** author **README + Roadmap + Build-Checklist + Considerations now** (planning); author **Build-Guide + Build-Record + Diagnostics at the bench** as Seth builds. Do **not** bulk-restructure — one device per pass, per-wave.

## 4. The device worklist + order (batched — operator, 2026-07-29)

**The ordering principle (operator's words):** *"do the things that touch the DC the most first, so we keep things in context — the Microsoft VMs first, then come back around to the Linux service VMs. Systems engineering first, then networking and security together (they're inline with each other). As neat as possible, so a replacement knows exactly what to do."* So: **group by discipline, sequence by DC-proximity, Windows before Linux, keep related context loaded together.**

**✅ Done:** **DC-Domain-Controllers** (the template) · **MON01** (`Roles/` exemplar) · **NPS01** · **PAW01** · **RCA01-ICA01-ADCS** (standard-audit) · **FS01** · **WSUS01** · **SQL01** · **RDS01** · **WAC01** *(Batch A)* · **NETBOX01** · **BKP01+Vaultwarden** · **Pi01** · **CNT01** *(Batch B)* · **1941 · SW01 · MKT01 · FGT01 · PFSENSE01 · KALI01 · SIEM01** *(Batch C+D — COMPLETE 2026-07-30)*. **🎉 The replication wave is COMPLETE — every device has its standard page-set.** Next: the **#20/#21** compute/sizing/hypervisor sweeps → the **#22** audit (+ the high-priority **Services-map backfill**, Backlog **#27**).

### Batch A — Systems engineering: Windows identity/service VMs (highest DC-touch first)
Do these together so the AD/GPO/PKI context stays loaded.
1. ✅ **NPS01** — RADIUS member server (network-device AAA vs AD; PEAP cert from ICA01). *(page-set done)*
2. ✅ **PAW01** — Tier-0 admin workstation + the Win11 golden image (domain-joined, tier-0 hardened; `Scripts/` indexed by `Automation/`). *(page-set done)*
3. ✅ **FS01** — file services (AGDLP shares / DFS / FSRM / VSS) — on the EQR6 + the 8 TB (`ADR-0036` v1.2). *(page-set done; the HR→HR/HR→IT proof + VSS≠backup gate baked in)*
4. ✅ **WSUS01** — patch management (PVE01/R410 spin-up; content-store vdisk; first-sync/FGT-UTM note). *(page-set done)*
5. ✅ **SQL01** — SQL Server (PVE01/R410; gMSA/A1 · ICA01 TLS · backups→BKP01; folds into the AG, `ADR-0046`). *(page-set done)*
6. ✅ **RDS01** — Remote Desktop (Gateway CAP/RAP via **NPS01** + TLS from **ICA01**; users not admins, **not** the Tier-0 path). *(page-set done 2026-07-30 — full set incl. README Mermaid connections + Automation/ + Changes/; host placement PVE01 flagged for #20)*
7. ✅ **WAC01** — Windows Admin Center gateway (Tier-0 mgmt surface; PAW-only; ICA01 cert; `ADR-0045`). *(page-set done 2026-07-30 — PVE02/EQR6 always-on · **VLAN 10** · Arc gated stub; folder created; §4 Batch A complete)*

### Batch A2 — Windows growth / gated (still DC-touch; later phases, designed stubs now)
- **Entra Connect** sync host (H1) · **RODC** (Tier-B, `ADR-0045`) · **ADFS01 + WAP01** (Tier-B) · **EXCH01** (H3) · the **failover-cluster pair** `SQLN1`/`SQLN2` (on-demand, `ADR-0046`) · the **client fleet** WS-HR01 / WS-ENG01 / LT-SALES01 / WS-IT01 (`ADR-0042`).

### Batch B — Linux service VMs ✅ FOLDERS COMPLETE (2026-07-30)
- ✅ **NETBOX01** (source of truth; full page-set + `Roles/` NetBox·PostgreSQL·Redis; PVE01/R410) · ✅ **BKP01 + Vaultwarden** (full page-set + `Roles/` PBS·Vaultwarden; PVE02/EQR6 + 8 TB) · ✅ **Pi01** (DNS+NTP; flat; physical Pi, VLAN 10) · ✅ **CNT01** (NEW folder — container host; gated stub scoped to the estate self-hosted git/CI #19; hybrid Linux-primary + Windows slice; `ADR-0045`). *(SRV01 already had the `Roles/` set — untouched.)* Owner-doc propagation done: IP plan v1.7 · flows v1.5 · estate index v1.4 · build-order v1.3 · ADR-Index v1.18 · backlog.

### ✅ Batch C — Networking (the §5 variant) — DONE 2026-07-30
- **1941** (core router) · **SW01** (access switch) · **MKT01** (E-W firewall) · **FGT01** (perimeter). Cert-aligned CCNA / CCNP / FortiGate. Several have CIS + Build-Guides under `Architecture/` → **reconcile/point, don't duplicate**.

### ✅ Batch D — Security (inline with networking) — DONE 2026-07-30
- **PFSENSE01** (inline IPS, `ADR-0038`) · **KALI01** (validation/attacker, J-series) · **SIEM01-Wazuh** (host SIEM; ingests MON01's Suricata; Wave-B stub → extend). In parallel, work the **`Pre-Build-Decisions` Section K** security-inspection decisions (K1–K10: TLS deep-inspection · DNS-filter overlap · FSSO · E-W matrix depth · 1941 ZBF · wireless/WLC · IPS tuning · correlation · CCNP infra-sec) each into its own ADR as decided.

**Already partly done — don't recreate, extend:** `SRV01-Network-Services` (the `Roles/` exemplar) · `RCA01-ICA01-ADCS` (has Build-Guide + Diagnostics — high DC-touch Windows PKI, effectively the identity partner of Batch A) · FS01/WSUS01/SQL01/RDS01/SIEM01 (README + Build-Checklist stubs from Wave B).

> **Why this order serves the learner (operator's north star).** Batch A keeps the whole Windows/AD story in one context block (identity → member services → admin surface), so a successor learns the enterprise core as one coherent unit before switching mental models to Linux (Batch B) and then to the network/security plane (Batches C+D together). Each batch is internally dependency-ordered (e.g. RDS01 after NPS01).

## 5. The networking variant (routers/switches/firewalls)

🔴 **These are NOT Windows servers — do not carry over the Windows framing (operator, 2026-07-30).** A Cisco switch's page-set foregrounds **ports/VLANs/trunks/STP/PoE**, not SMB/AGDLP/gMSA/OU. Copy the *folder shape* (README+connections+diagram · Roadmap · Considerations · Build-Checklist · Build-Guide · Diagnostics · Troubleshooting · Changes · Automation) but **rewrite the content to the device's real domain** — prune anything that reads like it was copied from DC01.
- **README** connections map + Mermaid diagram still apply (what it routes / switches / filters, for whom) — edges point the way traffic/among-devices flows.
- **Roadmap** = the **config path** (interfaces / VLANs / routing / ACLs / hardening passes), cert-aligned to the **CCNA / CCNP / FortiGate** maps.
- **Build-Guide** phased/gated as a **config guide**; **Diagnostics** = a **show-command battery** (the Academy `Cisco-IOS` / `RouterOS` / `FortiOS` libraries already exist — link up, don't restate).
- **Automation** = config-backup (Oxidized) + Ansible network automation (CCNP ENAUTO), not DSC.
- Several already have **CIS-Hardening + Build-Guides** under `Architecture/` — **reconcile/point, don't duplicate** (`POL-0008`).

> **The tailoring is deliberate + revisited.** Getting the *shape* consistent first (this wave) then *tailoring the content* per device is the plan — the operator's **Backlog #22** audit pass (after the wave + the #20/#21 sweeps) goes page-by-page to make the networking variant real and prune template carry-over estate-wide. If in doubt during the wave, get the shape right + flag Windows-isms for #22 rather than forcing a bad fit.

## 6. Per-device facts — pull them, never invent

- **Roles/silos + estate index:** `Service-Server-Build-Plan.md` + `Architecture/Lab-02-Device-Role-Assignments.md`.
- **Addressing:** `Architecture/IP-Addressing-Plan-VLSM.md` → NetBox. **If an address isn't assigned, mark it `📋 proposed` and flag it for the IP plan — do not hard-code a guess.**
- **Decisions:** `00-Atlas-Foundation/Decisions/ADR-Index.md`.
- **Flows:** `Architecture/Atlas-East-West-Allowed-Flows-Matrix.md`.
- **Build order + dependencies:** `Operations/Build-Order-and-Dependencies.md` (the single order owner, Phases 0–11).
- **Open decisions/scope:** `Pre-Build-Decisions.md`; **flags:** `Review-Flag-Register.md`.
- **Cert alignment:** the four maps in `Atlas-Academy/` (`Atlas-Certification-Lab-Map` CCNA, `Atlas-CCNP-Lab-Map`, `AZ-800-801-Windows-Server-Hybrid-Lab-Map`, `Atlas-FortiGate-FCP-Lab-Map`) + `00-Atlas-Foundation/Roadmap/Atlas-Cert-Objective-Gap-Analysis.md`.

## 7. ✅ DONE — the FortiGuard-UTM ADR (`ADR-0047`)

~~Do this first.~~ **Completed 2026-07-29 (committed `6f1888c`).** `ADR-0047` was written: it **reverses `ADR-0035`** (FGT now runs licensed UTM) and **reshapes `ADR-0038`** (pfSense kept as the free/complementary IPS + free-vs-licensed comparison), with the full 5-step propagation done (`ADR-Index` v1.13 · `ADR-0035` v1.1 · `ADR-0038` v1.1 · `Atlas-Firewall-Architecture` v1.2 · FCP map v1.1 · `Review-Flag-Register` v0.26 · handoff). The FCP §3 content-inspection domain is unlocked. **Also landed since:** `ADR-0048` (Automation/IaC model + the `Automation/` doc-type; Standard/Workflow v1.4), `Pre-Build-Decisions` **Section K** (security-inspection cluster), and **PVE02 acquired** (Beelink EQR6; `ADR-0036` v1.2 placement inversion — EQR6 = always-on core, R410 = spin-up). *No blocking pre-work remains — proceed straight to §4 Batch A.*

## 8. Cert-label consistency note

Target = **AZ-800/801** (Seth's choice), but **AZ-802 replaces them 2026-09-30** (same skills). In new Certification-alignment tables use the label **"AZ-800/801 (→AZ-802 2026-09-30)"**. The DC Roadmap still carries bare `AZ-802` tags from an earlier pass — **true those up** when you next touch it.

## 9. Verify each pass (before the commit block)

- All new relative links resolve (mind the folder depth — a doc under `Build-Guide/<HOST>/` needs `../../../` to reach `Architecture/`).
- Version bump + change-log row on any register/index you touch.
- Update the **estate index** status row in `Service-Server-Build-Plan.md` for the device.
- Update `SESSION-HANDOFF.md` (session block + `Version`).
- Print the commit block; after Seth runs it, confirm `git status` clean = origin.

## 10. Read these on arrival (in order)

1. `Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md` — where we are: read the **📍 CURRENT STATE block + the latest session block** in full first (`ADR-0049` read rule).
2. `00-Atlas-Foundation/Atlas-Documentation-Standard.md` (**v1.6**) + `00-Atlas-Foundation/Atlas-Documentation-Workflow.md` (**v1.6**) — the governing standard + capture workflow (incl. the `Automation/` doc-type `ADR-0048` + the README **Connections diagram (Mermaid)** element, now with **protocol/port-labelled edges** `ADR-0049`).
3. `Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers/` — the worked exemplar (copy this shape; README + Roadmap are the planning-time models).
4. `Labs/Lab-02-Cisco-Core/Devices/MON01-Monitoring/` — the **second** worked exemplar: a multi-service `Roles/` host with the full set incl. `Automation/`. (`SRV01-Network-Services/` is the older `Roles/` example.)
5. `Labs/Lab-02-Cisco-Core/Operations/Build-Order-and-Dependencies.md` — the estate order + dependency map.
6. `Pre-Build-Decisions.md` · `Review-Flag-Register.md` · `00-Atlas-Foundation/Decisions/ADR-Index.md`.
7. The four cert-lab-maps in `Atlas-Academy/`.

## 11. After the replication wave — the next phases (operator sequence, 2026-07-30)

The wave (getting every device onto the standard *shape*) is **phase 1 of 3**. Don't stop at the wave:
1. **Finish the wave** — Batch A (RDS01 · WAC01) → Batch B (Linux VMs) → Batches C+D (networking + security).
2. **The #20/#21 sweeps** — ✅ **#20 DONE (session 18, 2026-07-30):** compute-placement + VM-sizing reconciliation → `Service-Server-Build-Plan` is the placement/sizing authority (`VM-and-Services-Inventory` retired). ✅ **#21 DONE (2026-07-30):** **PVE01/PVE02 as documented `Devices/`** — `Devices/PVE01-Hypervisor/` (built, points into the Virtualization records) + `Devices/PVE02-Hypervisor/` (target-state; the `221` runbook is its home) — plus the **`Virtualization/` tidy** (pack manifest v1.4; **Freeze #3 closed** — Storage + Authentication Build-Records added; the `2xx` guides flagged as R410-era carry-over for #22). (`Atlas-Improvement-Backlog` #20/#21.)
3. **The #22 audit + per-device structure-tailoring pass** — page-by-page, **make the §5 networking variant real** (a Cisco switch ≠ the DC/Windows template), prune template carry-over, re-check Automation/sizing/diagrams against reality. **More planning expected** (new ADRs / Standard tweaks). (`Atlas-Improvement-Backlog` #22 + "Forward sequence".)

Run these **in order** — #22's audit needs the full picture (all devices done + placement/sizing settled).

## Related
- Governing: `00-Atlas-Foundation/Atlas-Documentation-Standard.md` · `…/Atlas-Documentation-Workflow.md` · `ADR-0037` (standard) · `ADR-0043` (phased/gated Build-Guides) · `ADR-0044` (enterprise-first) · `ADR-0041` (test-gated).
- Exemplars: `Devices/DC-Domain-Controllers/` · `Devices/SRV01-Network-Services/`.
- Status: `SESSION-HANDOFF.md` · `Service-Server-Build-Plan.md`.

## Change Log
| Version | Date | Change |
| 1.8 | 2026-07-30 | **#21 done — PVE01/PVE02 as `Devices/`.** §11 item 2 marks the #20 sweep (session 18) **and** the #21 sweep DONE: `Devices/PVE01-Hypervisor/` (built; hypervisor variant — points into the Virtualization Build-Records, `ADR-0034`) + `Devices/PVE02-Hypervisor/` (target-state; `221` is its home procedure) authored, and `Virtualization/` tidied (manifest v1.4; Freeze #3 closed with the new Storage + Authentication Build-Records; `2xx` carry-over flagged for #22). Next ▶ the **#22** audit + Services-map backfill (#27). |
| 1.7 | 2026-07-30 | **Batch C+D COMPLETE → the replication wave is DONE.** §0/§4 mark **1941 · SW01 · MKT01 · FGT01** (networking-variant docs around the device-verified guides; existing CIS/guides pointed-to) + **PFSENSE01** (inline IPS, `ADR-0038` v1.2) · **KALI01** (offensive/validation) · **SIEM01** (dedicated host) ✅. **Every device now has the standard page-set.** Adopted the **Services map** element (Standard **v1.7**; backfill = high-priority Backlog **#27**). Section K: K1/K2 (FGT) decided (ADRs owed) · K3 FSSO → concept N4 + #26 · K7/K8 noted. Next: #20/#21 → #22. |
| 1.6 | 2026-07-30 | **Batch B (Linux service VMs) — FOLDERS COMPLETE.** §0/§4 mark **NETBOX01 · BKP01+Vaultwarden · Pi01 · CNT01** ✅ (CNT01 a new gated-stub folder scoped to the estate self-hosted git/CI #19). Next = **Batches C+D** (networking + security). Owner-doc propagation batched (IP plan v1.7 · flows v1.5 · estate index v1.4 · build-order v1.3 · ADR-Index v1.18 · backlog). |
| 1.5 | 2026-07-30 | **WAC01 ✅ → Batch A COMPLETE.** §0/§4 mark WAC01 done (Windows Admin Center gateway; PVE02/EQR6 always-on · VLAN 10 · Arc gated stub). Next = **Batch B (Linux service VMs)**, recommended as a **fresh session** (operator). |
| 1.4 | 2026-07-30 | **Added §2a Planning & Handoff Protocol (`ADR-0049`)** — ask-design-questions-at-planning norm, edge-labelled connection diagrams (Standard v1.6), per-device narrowing, and the handoff **Living-STATE + append-log** model with a read rule. Updated §10 reading order (read the STATE block + latest session block first; Standard/Workflow → v1.6). |
| 1.3 | 2026-07-30 | **RDS01 ✅ (Batch A).** Full page-set authored under `Devices/RDS01-Remote-Desktop/` per Standard v1.5 (README+Mermaid · Roadmap · Considerations · Build-Checklist · Build-Guide · Build-Record · Diagnostics · Troubleshooting · Changes/ · Automation/). §0/§4 mark RDS01 done → **Batch A: 1 left, resume at WAC01**; estate index status flipped; placement PVE01-vs-always-on flagged for #20. |
| 1.2 | 2026-07-30 | **Marked FS01/WSUS01/SQL01 ✅ (Batch A → RDS01, then WAC01 left); Standard/Workflow refs → v1.5** (README Mermaid connections diagram element). **Strengthened §5**: the networking devices are NOT Windows servers — copy the folder *shape* but rewrite the *content* (ports/VLANs/STP, not SMB/AGDLP/gMSA); prune DC01 carry-over. **Added §11 (after-the-wave phases):** finish the wave → the #20/#21 compute/sizing/hypervisor sweeps → the **#22 audit + per-device structure-tailoring pass** (make the networking variant real; more planning expected). Operator's 2026-07-30 forward sequence. |
|---|---|---|
| 1.1 | 2026-07-29 | **Re-ordered §4 to the operator's batches** (Windows/DC-touch systems-engineering first → Linux service VMs → networking + security together; Windows-before-Linux; keep related context loaded — for the successor-learner). Marked **MON01 ✅ done** (2nd exemplar, multi-service `Roles/`) and **NPS01 next**. **§7 FortiGuard-UTM ADR marked ✅ DONE** (`ADR-0047`, `6f1888c`) + noted `ADR-0048` (Automation model), Section K, and PVE02-acquired landed since. Added the **`Automation/` doc-type** row (`ADR-0048`) to §3; trued Standard/Workflow refs to **v1.4**; pointed the reading order at MON01 as the second exemplar. |
| 1.0 | 2026-07-29 | Created — a self-contained successor-bot bootstrap for the device page-set replication: mission, environment/workflow, non-negotiable ground rules, the DC page-set template + the 4 analytical elements, the device worklist + order, the networking variant, where to pull per-device facts, the FortiGuard-UTM-ADR-first instruction, cert-label note, per-pass verification, and an on-arrival reading order. |
