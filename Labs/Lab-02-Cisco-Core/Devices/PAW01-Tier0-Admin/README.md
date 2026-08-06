# PAW01 — Tier-0 Privileged Access Workstation (+ the Win11 golden image)  ·  folder front-door

> **How to read this folder.** This README is the front door: *what this host is*, *what it connects to*, and *which document answers which question*. Start here, then follow the one link you need. Live status lives in **`Roadmap.md`** (build path) + **`Build-Checklist.md`** (line-item, dated, evidence-backed). The *how* is `Build-Guide.md`.

| Item | Value |
|---|---|
| Lab / Era | Lab-02 · Cisco-Core — ACTIVE (📋 authored, not built) |
| Host · Role | **PAW01** (Windows 11 Enterprise) · **Tier-0 Privileged Access Workstation** — the admin-only box you RDP into to run RSAT and administer Tier-0. **Also produces the reusable Win11 golden image** (sysprep → Proxmox template) every future client clones from. |
| Placement | **PVE02/EQR6** (always-on core, `ADR-0036` v1.2 principle 4 — Tier-0 admin reliably reachable; 🟡 the RAM swing item — may spin up on the R410 if EQR6 headroom is tight). VLAN 20 **tagged** (🔴 *not* native VLAN 10), static in `10.20.0.10–.55` (server range, **avoid the `.2–.9` Tier-0 block**), gw `10.20.0.1`, DNS `10.20.0.2`. |
| Silo | 🔴 Security (Tier-0 privileged access) |
| Status | 📋 **authored, not built** — golden image → clone → pre-stage OU → join → baseline + PAW hardening → RSAT. See **`Roadmap.md`** |
| Governs / related | `ADR-0021` (tiered identity — the Enterprise Access Model this realizes) · `ADR-0036` (placement) · Microsoft PAW / EAM (Privileged profile) · consumes `Admin\Tier 0\PAW` OU + `t0-seth` from `../DC-Domain-Controllers/Build-Guide/DC01/Tiered-Admin-and-Groups-Build.md` |

## Role this era

PAW01 is the **Tier-0 admin surface** — a hardened, admin-only Windows 11 box that you **RDP into** (Kerberos + clipboard both work) to run **RSAT** and administer the DCs, the CA (ICA01), and NPS *from*. It exists because `t0-seth` is in **Protected Users** (no NTLM) — so you can't RDP a DC by IP — and the Proxmox console has no copy/paste; the PAW is the correct fix *and* the correct Tier-0 pattern (Microsoft's **Privileged** profile). You rarely RDP onto a DC again. This is the **on-prem-achievable subset** of Microsoft's (now Intune/Entra-centric) PAW guidance — the cloud-managed pieces are a **designed deferred delta** (Part 3 / Phase H2, MD-102), not silently skipped.

It also builds the reusable **Win11 golden image** first, so the future VLAN-50 client fleet (`ADR-0042`) clones from the same sysprepped template.

## Connections — what this host touches (the map)

**Depends on (upstream — must be healthy first):**
- **DC01** — domain-join, the `Admin\Tier 0\PAW` OU (pre-staged computer object), the Win11 SCT baseline + PAW-hardening GPOs, `t0-seth` (Protected Users), Kerberos, **7d** deny-cross-tier. The whole point of the box is administering the DC.
- **The Win11 golden-image template** (Proxmox) — PAW01 is a full clone of it.
- **PVE02/EQR6** (hosts the VM; UEFI+SecureBoot+TPM2.0 = also the Credential Guard/VBS prereqs) → **SW01** → **MKT01** (VLAN-20 gw `10.20.0.1`).
- Addressing: `../../Architecture/IP-Addressing-Plan-VLSM.md` (`POL-0008`).

**Depended on by (downstream — the admin path runs through it):**
- **DC01/DC02 · ICA01 · NPS01 · every Tier-0 target** — administered *from* PAW01 via RSAT/RDP. If the PAW is unavailable, Tier-0 admin falls back to the (clumsier, discouraged) console path.
- **The client fleet** (`ADR-0042`) — reuses the Win11 golden image PAW01 produces.

**Services this host provides:** the Tier-0 admin console (RSAT: ADUC/ADAC/GPMC/DNS + AD PowerShell), and the golden-image template source.

## Connections — the east-west rule
🔴 The MKT01 policy must let **PAW01 → the Tier-0 identity block (`10.20.0.2–.9`)** over the admin protocols (RDP/Kerberos/LDAPS/DNS) — confirm in `../../Architecture/Atlas-East-West-Allowed-Flows-Matrix.md` when segmentation is enforced (Phase 7). And inbound RDP to PAW01 is allowed only from the mgmt source.

## Connections diagram

```mermaid
flowchart LR
  subgraph up[⬆ Depends on]
    direction TB
    dc[DC01 · OU/GPO/join/7d]
    tmpl[Win11 golden image]
    host[PVE02/EQR6 · UEFI/TPM/VBS]
  end
  subgraph down[⬇ Administers / feeds]
    direction TB
    t0[Tier-0 targets via RSAT<br/>DC · ICA01 · NPS01]
    fleet[Client fleet · golden-image reuse]
  end
  paw[["PAW01<br/>Tier-0 PAW"]]:::me
  dc -->|join · GPO SMB/445 · Kerberos| paw
  tmpl -->|clone (template)| paw
  host -->|VLAN 20 · UEFI/TPM/VBS| paw
  paw -->|RSAT · RDP/3389 · LDAPS/636| t0
  paw -->|golden-image reuse| fleet
  classDef me fill:#1f6feb,stroke:#0b3d91,color:#fff;
```

> DC is both *upstream* (PAW depends on it for join/GPO) and *downstream* (you administer the DC **from** the PAW) — the graph shows the admin direction on the `t0` edge.

## Services map — what runs here and how it's used

> 🆕 **Services map (Standard v1.7).** A PAW's "services" are the **admin surface it provides** + the golden image it produces. Status mirrors `Build-Record.md` (`POL-0001`) — 📋 not built, so both rows ⬜.

| Service | Purpose | Consumed by · port | Depends on | Status |
|---|---|---|---|---|
| **Tier-0 admin console** (RSAT) | The hardened box you RDP into to administer Tier-0 (DCs · ICA01 · NPS01) | admin `t0-seth` → Tier-0 targets · RDP/3389, LDAPS/636 | DC (join/GPO/7d) + PAW hardening | ⬜ not built |
| **Win11 golden-image source** | Sysprepped Proxmox template every future client clones from (`ADR-0042`) | the VLAN-50 client fleet · Proxmox template | golden image built + sealed | ⬜ not built |

## Documents in this folder (what answers what)

- **`Roadmap.md`** — the build path (golden image → PAW clone → baseline/hardening → RSAT → cloud delta) + connections + cert alignment + future. *Start here.*
- **`Build-Checklist.md`** — the line-item, dated, evidence-backed status (`POL-0001`).
- **`Build-Guide.md`** (v0.6) — the detailed rebuild contract: Part 1 golden image · Part 2 the PAW · Part 3 the cloud-managed deferred delta. GUI-first + PowerShell + 📸.
- **`Considerations.md`** — open risks & decisions (placement swing item, Credential-Guard VBS gate, on-prem-vs-cloud delta, native-VLAN-10 trap).
- **`Build-Record.md`** — the verified as-built state (⬜ until built).
- **`Diagnostics.md`** — the read-only "is it built + does the tier model hold?" battery.
- **`Troubleshooting.md`** — symptom → cause → fix.
- **`Scripts/`** — the golden-image finalize PowerShell (`Prep-GoldenImage` · `Test-SysprepReadiness` · `Invoke-SysprepGeneralize`). Indexed by `Automation/`.
- **`Automation/`** — the `ADR-0048` automation slice (indexes `Scripts/` + the planned DSC/baseline/RSAT automation; the cloud/Intune path).
- **`Changes/`** — the `CM-####` ledger.

## Single source
- Estate index: `../../Service-Server-Build-Plan.md`. Tier model: `../DC-Domain-Controllers/Build-Guide/DC01/Tiered-Admin-and-Groups-Build.md`. Addressing: `../../Architecture/IP-Addressing-Plan-VLSM.md`. Flows: `../../Architecture/Atlas-East-West-Allowed-Flows-Matrix.md`.
