> ✅ **SUPERSEDED 2026-07-31 — retired, not deleted (`ADR-0012`).** The active brief is now **`Session-25-Playbook-Building-Prompt.md`** (build the Lab-01 Playbooks from the #36 queue — very descriptive, searchable-by-problem-name, ticket-ready per **#32**). This #33→#36 brief's first slices are **done**: #33 the PVE02 + **Windows-golden** commissioning checklist · the `Domain-Join-Fails` Playbook + `ADR-0053` §8 checklist↔Playbook cross-links · the **#36 first-pass candidate worksheet** (`Operations/Lab-01-Playbook-Mining-Candidates.md`). **Still open in the backlog (carried forward):** #33 (the **Linux-server** + **Pi-hole** checklists) · **#34** (syslog+SNMP) · **#35** (services layer). Kept for history.

# Next-Session Prompt — #33 → #34 → #35 → #36: Atlas-Academy development (checklists · tools · services · Lab-01 mining)

*(Lab-02-Cisco-Core / estate-wide. **Docs-only** session. Paste this into the next bot as the task brief. Written 2026-07-31, retiring the #31 brief `Session-23-Claude-Folder-and-Academy-Prompt.md` — the AI-context folder + the Academy Playbooks foundation are built; this continues the Academy build. Meant to be run across **several sessions** — the operator hands slices to different bots.)*

---

## Your task — work these in this ORDER (operator, 2026-07-31)

Four backlog items, executed **in sequence**. 🔴 **The authoritative definitions are the `#33`–`#36` entries in `00-Atlas-Foundation/Roadmap/Atlas-Improvement-Backlog.md`** — read them in full; this brief operationalizes them. Every artifact follows **`ADR-0053`** (the Atlas Academy Documentation Standard) and is anchored to a **real Atlas device/artifact**.

1. **#33 — standardized xlsx commissioning checklists** (new-server + per-service).
2. **#34 — syslog + SNMP as first-class troubleshooting tools** (grounded in MON01).
3. **#35 — develop the services layer + inter-device/service connectivity testing.**
4. **#36 🔴 — mine frozen Lab-01 for Playbook + failure-drill candidates** (the big multi-session task).

Then the estate moves to **#25 (file & storage systems)** — firmed as the next major design pass right after this batch.

**Docs-only.** Run **no** device/AD/git commands — write files + **print a PowerShell commit block for Seth** (repo root `C:\Users\atlas\Atlas\Atlas-Engineering-Repository`; Seth runs all git). Follow `ADR-0049`: ask design questions at planning · **one piece at a time** · **refresh `SESSION-HANDOFF` after each piece**.

---

## Read first (in this order)

1. **`Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md`** — the **📍 CURRENT STATE block + the latest session block** (`ADR-0049` read rule). *(Note: sessions 2–17 were archived 2026-07-31 → `99-Archive/Lab-02-SESSION-HANDOFF-archive-2026-07-31.md`; read on demand.)*
2. **`00-Atlas-Foundation/Roadmap/Atlas-Improvement-Backlog.md`** — **#33 · #34 · #35 · #36** in full (+ **#25** the next pass, **#30** Academy currency, **#32** ticketing).
3. **`00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md`** — **the standard you build to.** The layers (Cert-maps · Concepts · Command-Library · **Playbooks** · House-style; **Runbooks** deferred to the automation work), the **cert-grounded spine**, the strict **3-click rule**, and the **Playbook template §5** (Pin-it · granular lists · 📸 captures · Worked-log).
4. **`Atlas-Academy/Playbooks/`** — the action layer. Read `README.md` (the index) + the exemplars: ⭐ **`Recover-from-a-DNS-Outage.md`** (the golden-standard, high-detail bar) · **`Proxmox-Inspect-and-Troubleshoot.md`** (per-appliance, grounded in frozen Lab-01) · `Trace-a-Blocked-Flow` · `Test-a-Connection`.
5. **`Atlas-Academy/Academy-Vision-and-Scope.md`** — the *briefcase principle* + where each layer's content lands.
6. **`00-Atlas-Foundation/AI-Context/What-To-Check-First.md`** — the house rules (docs-only · evidence · POL-0004/0008 · **"newer docs usually win"**).
7. **`Labs/Lab-02-Cisco-Core/Devices/PVE02-Hypervisor/PVE02-New-Proxmox-Server-Commissioning-Checklist.xlsx`** — the **xlsx format model** for #33.

---

## The work — in order

### #33 — Standardized xlsx commissioning checklists

**Done as the model:** `Devices/PVE02-Hypervisor/PVE02-New-Proxmox-Server-Commissioning-Checklist.xlsx` (24 steps · 6 phases · from `221`). **Build the rest to the same shape:**
- A **new-Windows-server** commissioning checklist (ground it in the DC/member-server build — `Devices/DC-Domain-Controllers/Build-Guide/` + `210-Windows-Server-Base-Configuration` etc.).
- A **new-Linux-server** commissioning checklist (ground it in `220-Prepare-the-Ubuntu-Golden-Image` + the SRV01/NETBOX01 build set).
- **Per-service setup checklists**, starting with the operator's named example: **Pi-hole on an unconfigured Linux box** (ground it in Lab-01 `Devices/PI01-Services/Roles/PiHole-DNS/Build-Guide.md`, current-design-reconciled).
- **Format (match the PVE02 xlsx):** fillable, **phase-gated**, columns *Phase · # · Task · What to do · Verify (command) · Expected (healthy) · **Done ✓ · Date · Who · Time · Notes/📸***, a `COUNTIF` progress cell, a legend + one greyed example row. Professional font (Arial). Model on `201`'s Completion Checklist. **Use the `xlsx` skill; run `recalc.py` (0 errors) before delivering.**
- **Home:** the specific-host checklist → that `Devices/<host>/` folder; the reusable shells → consider `00-Atlas-Foundation/Templates/` (decide at planning). **Note:** add `*.xlsx binary` to `.gitattributes` if the CI LF-check flags the binary.

### #34 — Syslog + SNMP as first-class troubleshooting tools

- **Command-Library:** add syslog (rsyslog) + SNMP (SNMPv3/LibreNMS) verify entries — the runtime read-backs (`show logging`, `journalctl`, SNMP polls) with healthy-vs-broken — into the platform pages + a by-tool index. Grounded in **MON01** (the estate syslog/SNMP/telemetry sink, Phase 6) + the senders (SW01/FGT01/1941/hosts). Mind the estate scars: `CM-0037` (live SNMP location string removed), `CM-0036` (SPAN re-establish), the `homelab` community rotation.
- **Playbooks:** e.g. `Is-SNMP-Polling-Healthy.md` / `Why-Is-a-Device-Not-in-LibreNMS.md` and `Find-It-in-the-Logs.md` (syslog→MON01 path). Cert-aligned: CCNA 4.0 · CySA+. Ties to #27 (Services map) + the observability build.

### #35 — Services layer + inter-device/service connectivity testing

- The Academy hasn't hashed out **the services** or **how to test connectivity between devices *and* services**. Build: per-service *what it is · how it's consumed · how to test it end-to-end*, plus a **connectivity-testing matrix** (device→device and client→service) that extends `Playbooks/Test-a-Connection.md` + each device's **Services map** (#27) + the **east-west allowed-flows matrix**. Ground every row in the real topology. Cert-aligned: CCNA/Network+ · Linux+.

### #36 🔴 — Mine frozen Lab-01 for Playbook + failure-drill candidates (BIG — multi-session)

- **The seam (`Labs/Lab-01-Mikrotik-Core/`, frozen `ADR-0022`):** `Operations/016-Network-Lessons-Learned.md` (62 KB — the richest), every device's `Troubleshooting.md` (PVE01 · PI01 · MKT01 · SW01 · FGT01), the `Change-Management/CM-####` + per-device `Changes/CM-####` records, `040-Remote-Access-Troubleshooting`, `048-Teardown-and-Rebuild`, `015-Network-Validation`, `051-Book-1-Audit-Report`.
- **The task:** read through, **flag candidate `Playbooks/` + failure-drill scenarios**, each **anchored to the real incident** and **current-design-reconciled** — frozen Lab-01 **loses** where it disagrees with a live doc (`POL-0001`/`ADR-0022`; e.g. the Lab-01 "untagged vmbr0" resolution is *superseded* by the tagged `vmbr0.10`; the FreeRADIUS/OpenSSL-CA/Pi01-DoH material is *retired* — see `ADR-0029`/`ADR-0031`/`ADR-0009`).
- **Deliverable:** a categorized, **problem-name-keyed candidate list** (a flag-first pass, `POL-0001` audit-style) → then **build the highest-value ones one page at a time** in the golden-standard mold (`Recover-from-a-DNS-Outage`). The operator runs this as a big task **with another bot**; scope + slice it with them.

---

## The rules (estate-wide)

- **Docs-only.** No git/device/AD commands — write files + **print a PowerShell commit block** for Seth. Never `git add .` (the `CM-0014` scar); LF endings; `gitleaks` clean.
- **`POL-0001`/`POL-0006` evidence** — nothing `✅` without a runtime read-back; method authored = 🟡; planned = 📋. **Never invent command output.**
- **`POL-0002`** — never record a live secret. **`POL-0004`/`POL-0008`** — one home per fact; **link down** to the Command-Library / device page, never restate.
- **`ADR-0053` template** for every Playbook: **① Pin it down** → granular list steps (command/reference/healthy/broken each on its own line; `a/b/c` for sequences) → **📸 capture markers** (filled by running the real `show` commands) → **Worked log** (Date·Who·Time·outcome). Cert-anchor each; keep the strict **3-click rule**.
- **`ADR-0049`** — ask at planning · one piece at a time · **refresh `SESSION-HANDOFF` after each piece** · newer docs win over older ones (but a fact-owner beats a newer non-owner, and the device beats every doc).

---

## After this batch

- **#25 — estate storage & file-management design pass** (🔴 firmed: right after this batch). File services (DFS/FSRM/VSS/ABE/AGDLP) + storage (the 8 TB · PBS/BKP01 · S2D/cluster · TrueNAS-vs-Proxmox), as its own lab + device(s); capacity tie-in to #20. AZ-800.

## Adjacent owed work (context, not this pass)

- **#19** estate git/CI ADR (self-host-vs-GitHub · GitOps · runner placement — unblocks CNT01; the home for **Runbooks** + runnable tooling). · Section-K **K5** (1941 ZBF) · **K7/K8** (pfSense tuning · Suricata↔Wazuh). · The build critical path is the operator's (Phase-3 Identity → AD CS ceremony → NetBox → MON01 → BKP01 restore-test).

---

*When a slice is done, refresh `SESSION-HANDOFF`, and when the whole #33–#36 batch is complete, retire this prompt with a ✅ DONE banner (`ADR-0012` pattern) and write the #25 brief.*
