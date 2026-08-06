# Next-Session Prompt — #21: PVE01/PVE02 as `Devices/` + `Virtualization/` tidy

> ✅ **RETIRED — #21 is DONE (session 19, 2026-07-30).** This brief has been executed and is kept only as the **historical record of what #21 asked for** (`ADR-0012` quarantine-not-delete). Do not action it again.
>
> **What was delivered:** `Devices/PVE01-Hypervisor/` (built; hypervisor variant pointing into the Virtualization Build-Records, `ADR-0034`) + `Devices/PVE02-Hypervisor/` (target-state; the `221` runbook is its home) — 9 files each; the two Freeze-#3 Build-Records `Virtualization/Build-Records/PVE01-Storage.md` + `PVE01-Authentication.md`; the `Virtualization/` tidy (pack manifest **v1.4**; front-doors wired both ways). Propagated: `Service-Server-Build-Plan` v1.9 · replication prompt v1.8 · `SESSION-HANDOFF` (session-19 block + STATE).
>
> **▶ The next session is #22.** Fresh starting point: **`Operations/Session-22-Audit-and-Tailoring-Prompt.md`** (the estate audit + per-device tailoring + the Services-map/#27 + mermaid-edge backfills). Full record of the #21 work: the **session-19 block** in `SESSION-HANDOFF.md`.

*(Lab-02-Cisco-Core. Docs-only session. Paste this into the next bot as the task brief. Written 2026-07-30, session 18, right after #20 was fully closed.)*

---

## Your task

Bring the two Proxmox hypervisors into the estate's per-device documentation model, and tidy the `Virtualization/` book so the two don't overlap:

1. **Create `Devices/PVE01-Hypervisor/`** — the R410. It is **built + device-verified**, so treat it like the networking devices (1941/SW01), *not* like an unbuilt Windows server: copy the folder **shape**, but **point to** the existing device-verified `Virtualization/` records/guides — **do not duplicate** them (`POL-0008`).
2. **Create `Devices/PVE02-Hypervisor/`** — the EQR6. It is **acquired but NOT stood up**, so its page-set is **target-state**: everything `📋`/`⬜` until execution (`POL-0001` — the device wins; nothing is `✅` without a read-back). Its build companions already exist (the `221` runbook + the `V1` Academy lab — see below).
3. **Tidy `Virtualization/`** — reconcile the pack manifest and the `2xx` guide series against the new `Devices/` front-doors: the `Devices/PVE0x-Hypervisor/` folders become the **front door**; `Virtualization/Build-Records/` + `Build-Guides/` stay the **deep build-record/procedure home** they link into (fact-ownership per the Standard). Close the manifest's freeze residuals where you can.

**This is docs-only.** You run **no** device/Proxmox/AD/git commands — **print PowerShell commit blocks for Seth** (`Operations/Device-Page-Set-Replication-Prompt.md` §1). Follow the `ADR-0049` protocol: **ask design questions at planning**, narrow the template per device, and **refresh the handoff after each device folder**.

---

## Read first (in this order)

1. **`Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md`** — the **📍 CURRENT STATE block + the latest session block** (the `ADR-0049` read rule). #20 is closed there; this is your starting line.
2. **`Labs/Lab-02-Cisco-Core/Operations/Device-Page-Set-Replication-Prompt.md`** — the replication method + the commit-block/Seth-runs-git rule. Read on arrival.
3. **`00-Atlas-Foundation/Atlas-Documentation-Standard.md` (v1.7)** + **`…/Atlas-Documentation-Workflow.md` (v1.6)** — the page-set shape and the fact-ownership map.

## The page-set shape (Standard v1.7)

Each `Devices/<host>/` folder: `README.md` (front-door + **edge-labelled Mermaid** connections diagram + a **Services map** table) · `Roadmap.md` · `Considerations.md` · `Build-Guide.md` (or `Build-Guide/`) · `Build-Record.md` · `Diagnostics.md` · `Troubleshooting.md` · `Automation/README.md` (`ADR-0048`) · `Changes/README.md`.

## Exemplars to copy from

- **`Devices/1941-Core-Router/`** and **`Devices/SW01-Access-Switch/`** — the closest model: **built + device-verified infrastructure** whose page-set was added *around* existing verified guides (points to them, doesn't restate). PVE01 is the same situation.
- **`Devices/DC-Domain-Controllers/`** + **`Devices/MON01-Monitoring/`** — the canonical template + the `Roles/` (multi-service) exemplar.

---

## Relevant pages (the pointers)

### Placement + sizing (settled in #20 — build on it, don't re-litigate)
- **`Decisions/ADR-0036-Compute-Topology-and-VM-Placement.md` (v1.3)** — the placement **principle**: tier-by-uptime. **PVE02/EQR6 = always-on critical tier**; **PVE01/R410 = mostly-off spin-up heavy tier**. DCs on *different physical hosts* (principle 1). **Standalone hosts — NO Proxmox cluster** (quorum fragility + R410 mostly off); manual migrate (`qm remote-migrate` / backup-restore).
- **`Labs/Lab-02-Cisco-Core/Service-Server-Build-Plan.md` (v1.8)** — the **placement + sizing single source** (which VM runs on which host, the EQR6 RAM budget). Every VM's host cell is here; the hypervisor pages should *link* to it, not restate the roster.
- **`Decisions/ADR-0046-Two-Node-Failover-Cluster-and-S2D.md`** — the **Windows** failover cluster + S2D is a **separate on-demand lab** (power both hosts up); build-gate lifted but re-scoped to spin-up. 1GbE-only storage caveat (USB-C 2.5/5GbE adapter / iSCSI-on-FS01 fallback / accept slow-S2D).

### The live PVE config (the ownership rule — critical for PVE01)
- 🔴 **`Labs/Lab-02-Cisco-Core/Virtualization/Build-Records/PVE01-Networking.md`** — the **authoritative live-config owner** of PVE01 networking (`ADR-0034`: a frozen doc can't be the live owner; the active book owns it). `Devices/PVE01-Hypervisor/` **links to this**, does not copy it.
- **`Decisions/ADR-0034-PVE01-Networking-Config-Ownership.md`** — that ownership decision (resolves manifest Freeze #2). Residual: the Confluence copy still needs a **manual redirect** (out of repo scope).
- **`Labs/Lab-02-Cisco-Core/Virtualization/Build-Records/`** — `PVE01 Current State`, `Windows Golden Image Historical Record`, `PVE01-Networking`. **Still missing (manifest Freeze #3):** a **Storage** Build-Record (`local`/`local-lvm`) and an **Authentication** Build-Record (`seth-admin@pve`, ACLs, root policy) — good candidates to add during the tidy.
- **`Labs/Lab-02-Cisco-Core/Virtualization/Reference/217-Verified-Facts-and-Reconciliation-Notes.md`** — the verified-facts source (caught the RAM 32-vs-64 error, the logical-CPU error, the `10.10.0.254`/FGT01 collision). Use it to ground PVE01's `Build-Record`.
- **`Labs/Lab-02-Cisco-Core/Virtualization/VIRTUALIZATION-PACK-MANIFEST.md` (v1.3)** — the pack index + the freeze residuals. Update it as part of the tidy.
- **`Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides/`** — the **`2xx` series** (`201`–`214` R410→Proxmox→…→DC01 deploy, `220` Ubuntu golden image, GNS3, **`221` PVE02 bring-up**). ⚠️ **The `2xx` guides are R410-era carry-over (some pre-Atlas)** — point PVE02's current truth at `PVE01-Networking` + the SW01 page-set, and frame the clean device-verified PVE02 set as coming from the fresh install.

### The #21 build companions (already written)
- **`Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides/221-PVE02-EQR6-Bring-Up-and-VM-Migration.md`** — the phased/gated **target-state migration runbook** (PBS restore = the Game Day; the DC USN-rollback / VM-GenerationID trap; dependency-order DC01→ICA01→NPS01→SRV01→Vaultwarden→FS01). `Devices/PVE02-Hypervisor/` is its home page.
- **`Atlas-Academy/Concepts/Proxmox-VM-Migration-and-Host-Bring-Up.md` (V1)** — the teaching companion (the "why").

### Addressing + physical
- **`Labs/Lab-02-Cisco-Core/Architecture/IP-Addressing-Plan-VLSM.md` (v1.11)** — both hypervisor **management** interfaces on VLAN 10: **PVE01 `10.10.0.10`** (`vmbr0.10`, native VLAN 10 on Gi1/0/4, `ADR-0034`) and **PVE02/EQR6 `10.10.0.11`** (📋). The VLAN-10 static map + the "host is on VLAN 10, its VMs are VLAN-20/40 workloads" rule live here. (Host *placement* is owned by the Service-Server-Build-Plan; addresses here.)
- **`Labs/Lab-02-Cisco-Core/Architecture/Cabling-and-Port-Map.md`** — PVE01's physical trunk (SW01, native 999) and the topology.
- **`Labs/Lab-02-Cisco-Core/Architecture/Atlas-East-West-Allowed-Flows-Matrix.md` (v1.7)** — the flows (PVE hosts push backups → BKP01 8007, flow #18; etc.).

### Automation
- **`Decisions/ADR-0048-Automation-and-IaC-Model.md`** — each hypervisor gets an `Automation/` slice (Proxmox provider for Terraform on-prem; Ansible; the `221` migration is the IaC exercise).

---

## Hardware facts to bake in (ground the Build-Records — `POL-0001`)

- **PVE01 = Dell R410** — 16 logical CPUs (2× Xeon E5620), **62 GiB usable / 64 GB physical** (DIMM slot B1 faulty), `local` ~94 GB + `local-lvm` ~793 GB thin. Live gaps: **`CM-0012` CMOS battery physically dead** (BIOS re-enable holds only on continuous power), **iDRAC on factory-default creds** (real gap), **noVNC/GUI shell broken** (SSH is a full substitute). Spin-up heavy tier.
- **PVE02 = Beelink EQR6** — Ryzen 9 6900HX (8C/16T), **32→64 GB DDR5 (64 GB is a hard prerequisite** before it carries the always-on stack), 500 GB NVMe (2× M.2, each to 4 TB), **dual 1GbE**, USB-C 10 Gbps, **Wake-on-LAN + Auto-Power-On**, built-in PSU, **8 TB external** (→ FS01 shares + BKP01 datastore). **Not yet stood up — all target-state.** Confirm every spec at Proxmox install (`POL-0001`).

## Decisions/threads to carry (don't re-open)
- **#20 is closed** (session 18): placement/sizing owner = `Service-Server-Build-Plan`; `VM-and-Services-Inventory` retired; DC02→R410, ICA01/SRV01→EQR6; EQR6 RAM budget confirmed (64 GB holds ~44–52 GB always-on); two-hypervisor VLAN-10 rule; PAW01→VLAN 10 `.8`; SIEM01→VLAN 40 `.11`/16 GB; Pi01 ingress = scoped exception (flows #19).
- **CNT01 platform detail** (Gitea-vs-GitLab · always-on-vs-spin-up · runner placement) belongs to the **still-owed #19 estate-capability ADR**, *not* #21.
- **Single-8 TB SPOF** (FS01 + BKP01 datastore + Vaultwarden store on one drive on the EQR6): the mandatory off-site copy (`ADR-0009`) is the recovery guarantee + must be **restore-tested**; consider a dedicated 2nd NVMe for the BKP01 datastore. Reflect this in PVE02's `Considerations`.

## Propagation when done
Estate index host rows already point at PVE01/PVE02 → add the `Devices/PVE0x-Hypervisor/` **links**; update the **replication prompt** (mark PVE01/PVE02 done), the **manifest**, the **handoff** (new session block + STATE), and `Review-Flag-Register` / `ADR-Index` **only if** a new decision is taken.

## Gotchas (session-18 experience)
- **Bots print commit blocks; Seth runs all git.** If `git add` fails with a lock, Seth clears **`.git/index.lock`** first (a stale 0-byte lock blocked commits this session; the bridge can't `rm` it).
- Keep the two hypervisor folders **thin front-doors** — the deep truth stays in `Virtualization/`. The failure mode to avoid is duplicating `PVE01-Networking` into the device folder and creating a second, drifting home (`POL-0008`).
