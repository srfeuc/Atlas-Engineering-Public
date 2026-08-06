# Next-Session Prompt — #22: the estate audit + per-device structure-tailoring pass

> ✅ **RETIRED — #22 is DONE (documentation-complete, 2026-07-30/31).** This brief was executed and is kept only as the **historical record of what #22 asked for** (`ADR-0012` quarantine-not-delete). Do not action it again.
>
> **What was delivered:** all **24 live devices** audited page-by-page + given the **Services map** (#27 CLOSED); the **8-diagram pre-v1.6 mermaid edge-label backfill** complete; **no template carry-over found** estate-wide (no Standard / `ADR-0037` / ADR-Index bump needed); the stale-guide reconciles **CLOSED** (NETBOX01 Phase-3→4 · Debian→Ubuntu on NETBOX01 + SRV01 · CA01-VAULT01 quarantined per `ADR-0012`); the **`2xx` R410-era Virtualization pack** reconciled to the device-verified Build-Records (drafted-from-records, 🟡-marked; manifest v1.5); per-device **Networking-Build-Guide** calls recorded (policy: *appliances point, hosts get new* — none added). A Foundation spot-check fixed the `301` / `305` nav defects (backlog **#29** owns the rest). The owed **Section-K ADRs** were then written — **`ADR-0050`** (TLS deep-inspection scope + ICA01 inspection-CA via GPO) + **`ADR-0051`** (Pi-hole owns DNS filtering, FGT DNS-filter off), `ADR-Index` **v1.22**, `Pre-Build-Decisions` §K1/§K2 → ✅. New backlog items captured: **#28** (Academy cert-tracking cross-links) · **#29** (Foundation currency audit) · **#30** (Academy improvement + cert-paths) · **#31** (AI-context "Claude" folder + Academy development).
>
> **▶ The next session is the AI-context folder + Academy development project (`#31`, with `#30`).** Fresh starting point: **`Operations/Session-23-Claude-Folder-and-Academy-Prompt.md`**. Full record of the #22 work: the **#22 entry** in `00-Atlas-Foundation/Roadmap/Atlas-Improvement-Backlog.md` + the latest blocks in `SESSION-HANDOFF.md`.


*(Lab-02-Cisco-Core. Docs-only session. Paste this into the next bot as the task brief. Written 2026-07-30, session 19, right after #21 (PVE01/PVE02 as `Devices/`) was fully closed. This is **phase 3 of 3** of the operator's forward sequence: #20 rules/placement ✅ → #21 hypervisors-as-devices ✅ → **#22 audit + tailoring**.)*

---

## Your task

The replication wave got **every device onto the standard page-set shape**. #22 makes that shape **real, tailored, and consistent estate-wide** — a page-by-page audit + tailoring pass now that the full picture exists (all devices done, placement/sizing settled in #20, hypervisors documented in #21). 🔴 **The authoritative task definition is the `#22` entry in `00-Atlas-Foundation/Roadmap/Atlas-Improvement-Backlog.md`** — read it in full; this brief operationalizes it. Five threads, do them per-device in one sweep:

1. **Make the §5 networking variant real + prune template carry-over.** Page-by-page, confirm each device's content matches its **real domain** and prune anything that reads like it was copied from the DC/Windows template. A Cisco switch's page foregrounds ports/VLANs/STP/trunks/`show`-commands — **not** SMB/AGDLP/gMSA/OU. A firewall foregrounds policy/zones/inspection. Flag or fix Windows-isms wherever they leaked in during the shape-first wave.
2. **Services-map backfill (`#27`, high-priority).** The **Services map** element (Standard **v1.7** — a README table *Service · Purpose · Consumed-by+port · Depends-on · Status*) was introduced on KALI01/SIEM01 and baked into PVE01/PVE02 (#21). **Backfill it into every README authored before v1.7** (see the list below). One row per service (≈ one per `Roles/` entry on multi-service hosts; 1–3 rows on single-service devices).
3. **Mermaid edge-label backfill (folds into #22).** The **8 device READMEs** whose connections diagram predates Standard **v1.6** have **unlabelled edges**. Add the protocol/port labels (`LDAPS/636`, `RADIUS/1812`, `RDP/3389`, …) so the *how-connected* story is on the picture. The 8: **DC · MON01 · NPS01 · PAW01 · FS01 · WSUS01 · SQL01 · RCA01/ICA01** (these got their diagrams at v1.5, before the v1.6 edge-label rule). Nodes keep role labels, never IPs.
4. **Re-check reality + reconcile stale guides.** Per device: does the `Automation/` slice, the sizing, and the diagram match reality? Reconcile the known stale flags: the **`2xx` R410-era Virtualization guides** (clean device-verified rewrite — deferred here from #21), the **Debian→Ubuntu checklist drift** (SRV01 & NETBOX01 checklists say Debian; the build-guides say Ubuntu 26.04 — guides win), the **NetBox Phase-3-vs-4** discrepancy (device's own guides say Phase 3; the build-order owner says Phase 4).
5. **Per-device host-networking bring-up guide (operator, 2026-07-30).** Decide **per device in this audit** which warrant a **`Networking-Build-Guide.md`-style doc** (à la **`Devices/NETBOX01-Source-of-Truth/Networking-Build-Guide.md`**) — a focused addressing / VLAN / trunk / console bring-up guide for devices whose network bring-up is **non-trivial** (**the networking devices especially** — 1941 · SW01 · MKT01 · FGT01 · PFSENSE01; and hosts with a fiddly tagged-VLAN/trunk story). Not every device needs one — it's a per-device call; record the decision in each `Considerations` "Decided".

**This is docs-only.** You run **no** device/AD/git commands — **print PowerShell commit blocks for Seth** (`Operations/Device-Page-Set-Replication-Prompt.md` §1). Follow the `ADR-0049` protocol: **ask design questions at planning** (this pass is expected to surface new decisions — see below), tailor per device, **refresh the handoff after each device (or logical batch)**. Work **one device / small batch at a time** — never a bulk restructure (the estate's own rule: bulk changes leave docs behind).

> ⚠️ **Expect planning, not just editing.** The operator's forward note: *"#22 = make the networking variant real; prune template carry-over; more planning expected (new ADRs / Standard tweaks)."* When a tailoring call is non-obvious (e.g. how deep a networking device's Automation slice goes, whether a Standard element needs a tweak), **ask at planning** and record the answer (`Considerations` "Decided" + the owner, `POL-0008`).

---

## Read first (in this order)

1. **`Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md`** — the **📍 CURRENT STATE block + the latest session block** (the `ADR-0049` read rule). #20 + #21 are closed there; this is your starting line.
2. **`Labs/Lab-02-Cisco-Core/Operations/Device-Page-Set-Replication-Prompt.md`** — the method + **§5 (the networking variant)** + **§11 (the forward sequence)** + the commit-block/Seth-runs-git rule.
3. **`00-Atlas-Foundation/Atlas-Documentation-Standard.md` (v1.7)** + **`…/Atlas-Documentation-Workflow.md` (v1.6)** — the page-set shape, the **Services map** + **edge-labelled Mermaid** elements, and the **fact-ownership map** (what links vs restates).
4. **`00-Atlas-Foundation/Roadmap/Atlas-Improvement-Backlog.md`** — the **#22** (audit + tailoring) and **#27** (Services-map backfill) entries in full; also the still-open #19/#23/#25 and the Section-K items (context, not this pass).
5. **`Labs/Lab-02-Cisco-Core/Review-Flag-Register.md`** — the open flags to reconcile as you touch each device.

## Gold-standard exemplars (the target shape)

- **`Devices/KALI01/`** + **`Devices/SIEM01-Wazuh/`** — the first pages with the **Services map** (Standard v1.7).
- **`Devices/PVE01-Hypervisor/`** + **`Devices/PVE02-Hypervisor/`** (#21) — v1.7 with a **hosted-VM Services map** + edge-labelled Mermaid; the "point into the deep records, don't duplicate" pattern (`POL-0008`).
- **`Devices/1941-Core-Router/`** + **`Devices/SW01-Access-Switch/`** + **`Devices/MKT01-East-West-Firewall/`** + **`Devices/FGT01-Perimeter-Firewall/`** — the networking-variant reference (already tailored to ports/VLANs/routing/policy; a good bar for the rest).
- **`Devices/DC-Domain-Controllers/`** (canonical) + **`Devices/MON01-Monitoring/`** (`Roles/` multi-service).

---

## The audit checklist (run per device folder)

For each `Devices/<host>/`, confirm against the Standard v1.7:

- [ ] **Full page-set present** — README · Roadmap · Considerations · Build-Guide(/) · Build-Record · Diagnostics · Troubleshooting · `Automation/` · `Changes/` (+ `Roles/` on multi-service hosts). README lists which exist.
- [ ] **Domain-correct content** — reads like *this device's* real job; no leftover DC/Windows/SMB/AGDLP language on a switch/router/firewall/Linux box. Prune or flag carry-over.
- [ ] **Services map** present (#27) — the `Service · Purpose · Consumed-by+port · Depends-on · Status` table; Status = built/verified, not merely installed (`POL-0001`).
- [ ] **Mermaid edges labelled** with protocol/port (v1.6); nodes = role labels, no IPs; ≤ ~8 load-bearing nodes; host `:::me`-highlighted.
- [ ] **Facts link, not restate** (`POL-0008`) — addresses → IP plan; decisions → ADR; flows → the matrix; placement/sizing → `Service-Server-Build-Plan`; commands → the Academy Command-Library.
- [ ] **Reality re-check** — Automation slice realistic (Oxidized/Ansible for network, Terraform/Ansible for hosts, DSC for Windows — **never** DSC on a network device); sizing matches the #20 budget; markers honest (`✅` only with a read-back).

## The specific backfill lists

- **Services map (#27) — backfill into every pre-v1.7 README:** DC · MON01 · NPS01 · PAW01 · RCA01/ICA01 · FS01 · WSUS01 · SQL01 · RDS01 · WAC01 · NETBOX01 · BKP01 · Pi01 · CNT01 · SRV01 · 1941 · SW01 · MKT01 · FGT01 · PFSENSE01. *(KALI01/SIEM01/PVE01/PVE02 already have it.)*
- **Mermaid edge-labels (v1.6) — backfill the 8 pre-v1.6 diagrams:** DC · MON01 · NPS01 · PAW01 · FS01 · WSUS01 · SQL01 · RCA01/ICA01. *(Every device authored at/after v1.6 already has labelled edges — **RDS01 is the v1.6 exemplar** to copy the labelling style from.)*

---

## Decisions/threads to carry (settled — don't re-open)

- **#20 closed** (session 18): placement/sizing owner = `Service-Server-Build-Plan`; `VM-and-Services-Inventory` retired; DC02→R410 cold-standby, DC01/ICA01/SRV01→EQR6 always-on; EQR6 64 GB holds ~44 GB always-on; two-hypervisor VLAN-10 rule; PAW01→VLAN 10 `.8`; SIEM01→VLAN 40 `.11`/16 GB; Pi01 DNS/NTP MGMT-ingress = scoped exception (flows #19).
- **#21 closed** (session 19): `Devices/PVE01-Hypervisor/` (built; points into the Virtualization records) + `Devices/PVE02-Hypervisor/` (target-state; `221` is its home). Manifest **v1.4**, **Freeze #3 closed** (new `Build-Records/PVE01-Storage.md` + `PVE01-Authentication.md`). Hypervisor front-doors wired both ways; the `2xx` clean rewrite was **deferred to this #22 pass**.

## Adjacent open items — NOT #22, but you'll bump into them (route, don't absorb)

- **#19 estate-capability ADR** (self-host git/CI · Gitea-vs-GitLab · GitOps model · runner placement · CNT01 platform/always-on). Its own ADR; CNT01's `Automation/` + sizing wait on it.
- **Section-K ADRs still owed:** K1/K2 (FGT TLS-inspect + DNS-filter — *decided*, ADRs owed) · K5 (1941 ZBF) · K7/K8 (pfSense tuning · Suricata↔Wazuh correlation). K3 FSSO → concept N4 + Backlog #26.
- **#23** test-workstation fleet (Win11 + Linux, VLAN 50) · **#25** storage/file-management design pass · **RDS01 CAL model** (per-user vs per-device).
- **🟡 read-backs owed:** the new PVE01 `Storage`/`Authentication` records (RAID/virtual-disk detail; ACL least-privilege) + everything on PVE02 (pending stand-up) + the wave's scattered `🟡`/`📋` interface/route/service read-backs (flip on the device, `POL-0001`).
- **Confluence manual redirect** for the old PVE01-networking page (`ADR-0034`) — out of repo scope; flag, don't chase.

## Propagation when done (per device + at the end)
- Per device: **refresh `SESSION-HANDOFF.md`** (STATE + a session block) — `ADR-0049` cadence.
- If the audit **changes a Standard element** → bump `Atlas-Documentation-Standard.md` / `Workflow.md` (+ amend `ADR-0037`). If a tailoring call is a **new decision** → new ADR + `ADR-Index` bump. Otherwise leave `ADR-Index` / `Review-Flag-Register` to status-only updates.
- Close the **#22** and **#27** backlog items as their coverage completes; leave a clear "what's still 🟡/owed" note (no silent truncation — if you cap the sweep, say what you skipped).

## Gotchas (carried from #21 / session-19 experience)
- **Bots print commit blocks; Seth runs all git.** If `git add` fails with a lock, Seth clears **`.git/index.lock`** first (the bridge can't `rm` it). Verify state with `git show HEAD:<path>` / `git --no-optional-locks status`, not the bridge cache.
- **One device / small batch per pass** — never a bulk restructure. Reviewed before commit.
- **Don't duplicate a fact to "help"** (`POL-0008`) — the #21 failure mode to avoid was copying `PVE01-Networking` into the device folder; the same rule holds estate-wide (link to the one home).
- **Networking ≠ Windows** (`§5`) — the single most common carry-over to prune. When in doubt, match the 1941/SW01/MKT01/FGT01 bar.

---

## Change Log
| Version | Date | Change |
| 1.0 | 2026-07-30 | Created (session 19, right after #21 closed) — the self-contained brief for the **#22** estate audit + per-device structure-tailoring pass (phase 3/3 of the forward sequence): make the §5 networking variant real + prune template carry-over · **Services-map backfill (#27)** into the ~20 pre-v1.7 READMEs · **mermaid edge-label backfill** of the 8 pre-v1.6 diagrams · reality/stale-guide reconcile (`2xx` rewrite, Debian→Ubuntu drift, NetBox Phase-3-vs-4). Read-order, gold-standard exemplars, the per-device audit checklist, the exact backfill lists, the settled #20/#21 threads, the adjacent-but-not-#22 items (#19/Section-K/#23/#25/read-backs/Confluence), propagation, and the commit-block/one-device-at-a-time gotchas. |
