# ADR-0042 — Client Workstation Fleet + Department Resource Access

| Item | Value |
|---|---|
| Status | **Accepted** (operator, 2026-07-29). Scope addition; phased, not built. |
| Governing Policy | POL-0007 (+POL-0010) |
| Scope | **Lab-02** (Cisco-Core) — the endpoint estate + the resource-access model. |
| Date | 2026-07-29 |
| Supersedes | — (extends `ADR-0021` tiered identity + `ADR-0039` hybrid scope with a client tier) |
| Related | `ADR-0021` (tiered identity) · `ADR-0039` (Intune, Phase H2) · `ADR-0041` (incremental, test-gated — each access proven one unit at a time) · `ADR-0030` (DHCP on DC01 for VLAN 50) · `ADR-0036` (compute placement) · `ADR-0037` (doc standard → the fleet folder) · `FS01` (department shares) · `301`/`305` (the scenario) · `Operations/Validation-and-Adversarial-Testing.md` (the access/segmentation proofs) · `Atlas-Academy/Concepts/Windows-Logon-Scripts-and-Drive-Mapping.md` (drive maps). |
| Governing docs | `Service-Server-Build-Plan.md` (estate) · `Architecture/IP-Addressing-Plan-VLSM.md` (VLAN 50 addresses) · a future `Devices/Workstations/` fleet folder + Roadmap. |
| Evidence Status | **Decision** (operator, 2026-07-29). Defines scope; the build is phased/future. |

## Context

The estate has servers and infrastructure but **no client endpoints** — so the work a real enterprise spends most of its policy effort on is untestable: GPO targeting (the operator's stated weak area), department-scoped file access (AGDLP), workstation LAPS, segmentation *from* a client zone, and Intune enrollment. The `301` scenario is built around messy client cases — Finance/HR PSO; Sales split between field laptops and inside desktops; Engineering CAD workstations a Finance GPO would wreck; shared shop-floor logins — none of which can be exercised without client machines. The operator asked (2026-07-29) to add workstations across VLANs, connected to department resources (e.g., the HR file server), with access managed through GPOs, and to *see what is blocked vs allowed* as each control is applied.

## Decision

**Add a lean, representative client workstation fleet as the estate's test clients, and adopt an AGDLP department-resource-access model proven incrementally (`ADR-0041`).**

**Fleet** (operator, lean representative set):
- **WS-HR01** — HR desktop. Exercises the Finance/HR **PSO**, the HR file-share access proof (**HR folder allowed / IT folder denied**), folder redirection + drive maps.
- **WS-ENG01** — Engineering **CAD** workstation. The "a GPO that suits Finance wrecks these" case — a distinct GPO/OU scope + loopback processing.
- **LT-SALES01** — Sales **field laptop**. Roaming profile, **BitLocker**, VPN — the mobile-endpoint policy dimension.
- **WS-IT01** — a **Tier-2** IT admin desktop. **Not** a PAW (PAW01 is the Tier-0 admin box, `ADR-0036`); this is the everyday Tier-2 workstation used to prove **tier-deny** (a Tier-2 account cannot touch a Tier-0 system).

**Placement + addressing:** VLAN 50 (Clients, `10.50.0.0/25`, DHCP from DC01 once stood up — `ADR-0030`); **at least one client is movable to VLAN 70 (Testing)** for the pen-test pass (J-series). Addresses are owned by the IP plan / NetBox (`POL-0008`), not this ADR. Compute: PVE01 for the lab-switch-attached clients; **home-PC Hyper-V** is an option for the Intune/AZ-802-heavy client labs (`ADR-0036`) — build-time sub-decision.

**Identity + access model:**
- **Role-based OUs, not departmental** (`301` §1: "Sales proves departmental OUs are wrong"). Client computer objects in the client OU; users in `Employees` by role; GPOs **security-filtered / OU-scoped** by department group.
- **AGDLP for resource access:** `G-<Dept>-Users → DL-<Dept>-Share-<perm> → NTFS` on the FS01 department folders. HR owns HR data (`301`). The flagship proof: **WS-HR01 (HR user) reads `\FS01\HR` and is denied `\FS01\IT`** — same PC, same path, different ACL.
- **GPO learning targets** (the operator's weak area): folder redirection, drive maps, **loopback processing** (CAD), **PSO** resultant policy, security filtering, **BitLocker** (laptop), and **tier-deny logon rights** on WS-IT01.
- **Intune** (Phase H2, `ADR-0039`): the fleet is the enrollment/**co-management** target — compliance + configuration profiles, co-management alongside GPO.

## Alternatives Considered

- **No client machines (servers only).** Rejected — leaves GPO targeting, AGDLP, client-zone segmentation, client LAPS, and Intune untestable; the `301` scenario is unusable.
- **One VM per department (broad fleet).** Rejected for now — most faithful to the 156-person scenario but the most to build/maintain; the lean set covers every *policy dimension* (PSO, CAD/loopback, mobile/BitLocker, Tier-2) without the sprawl. Revisit per the trigger below.
- **A folder per workstation** (the doc-standard's per-device default). Rejected for the fleet — the four clients clone from one **Win11 golden image** (the PAW/Ubuntu golden-image pattern) and differ only in identity/OU/department group; a **`Devices/Workstations/` fleet folder** (one Build-Guide + golden image + per-machine Roadmap rows) is cleaner than four near-identical folders. This is the same "template variant for a device class" judgment the doc-standard allows per wave.

## Consequences

- **New machines enter the estate** — WS-HR01, WS-ENG01, LT-SALES01, WS-IT01 — added to the estate single-source (`Service-Server-Build-Plan`) + the IP plan (VLAN 50), documented as a `Devices/Workstations/` fleet (README + Roadmap + a shared Build-Guide off a Win11 golden image), phased after the core.
- **FS01 gains department shares + AGDLP domain-local groups** (HR, Engineering, IT, Sales…) — the resource side of the model; its Build-Checklist gains the share/ACL units.
- **The DC gains client-targeting GPOs** (folder redirection, drive maps, loopback, BitLocker, tier-deny) + department OU/group scoping — each a test-gated unit (`ADR-0041`).
- **New Validation-matrix rows:** department resource access (**HR→HR ✓, HR→IT ✗**), client-zone segmentation (VLAN 50 → VLAN 20 *allowed flows only*), and Tier-2 (WS-IT01) → Tier-0 **denied**. These are exactly the cells the **staged flow charts** visualize.
- **A Win11 golden image is a prerequisite** (parallels the PAW/Ubuntu golden images).
- **Cert alignment:** GPO/AGDLP/OU design (**70-742, AZ-802**), Intune/co-management/BitLocker (**MD-102, MS-102**), segmentation + tier-deny (**Security+, PenTest+**). Directly serves the operator's **GPO-mastery** goal.

## Review Trigger

- If a department-specific case needs hands-on proof (Marketing internet/Adobe, QA cross-dept read, the Facilities unpatched box, shop-floor shared logins), add that specific client — the lean set is a **floor, not a ceiling**.
- If Intune co-management diverges materially from on-prem GPO, split a dedicated Intune-managed client to compare (co-management authority).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-29. Accepted. Adds a lean representative client fleet (WS-HR01, WS-ENG01, LT-SALES01, WS-IT01) on VLAN 50 (one movable to VLAN 70) as the estate's test clients for GPO, AGDLP department resource access (HR→HR ✓ / HR→IT ✗), LAPS, segmentation, and Intune co-management; role-based OUs + security-filtered GPOs; AGDLP to FS01 department shares; modeled as a `Devices/Workstations/` fleet off a Win11 golden image. Serves the operator's GPO-mastery goal; each access proven incrementally (`ADR-0041`). |
