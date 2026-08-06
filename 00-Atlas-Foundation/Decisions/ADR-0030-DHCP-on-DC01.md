# ADR-0030 — DHCP Consolidates on DC01 (Not Kea on SRV01)

| Item | Value |
|---|---|
| Status | **Accepted** (operator, 2026-07-28). |
| Governing Policy | POL-0008 |
| Scope | **Lab-02-Cisco-Core** |
| Date | 2026-07-28 |
| Supersedes | The **"DHCP = Kea on SRV01 (held)"** plan recorded in `IP-Addressing-Plan-VLSM` (v1.1/v1.2) and the SRV01 role rows. There was no prior DHCP **ADR** — this is the first decision record for the DHCP role, and it **inverts the assumed baseline** the 2026-07-24 audits were written against. |
| Related | `ADR-0027` (AD CS off the DC — role separation), `ADR-0029` (NPS off the DC — role separation), `ADR-0023` (gateways/SVIs on MKT01), `POL-0008` (one home per fact — the IP plan owns addresses). Captures Review-Flag-Register **A1**. |
| Evidence Status | **Decision** (operator, 2026-07-28). The DHCP role on DC01, the MKT01 relay re-target, and DC02 failover are all **`Target`** until built and verified on the devices (`POL-0001`). No `[ ]` here is device-confirmed yet. |

## Context

The addressing plan (`IP-Addressing-Plan-VLSM`) recorded DHCP as **Kea on SRV01 (Ubuntu, VLAN 20 `10.20.0.10`), "held for SRV01," not yet standing** — with a **RouterOS DHCP relay on MKT01** required per served VLAN because the gateways/SVIs live on MKT01 and SRV01 sits only in VLAN 20. Under that plan the client/deployment population would draw from Kea; infrastructure (Tier‑0 `.2–.9`, servers `.10–.55`) stays static regardless.

The 2026-07-24 doc-conflict audits treated that Kea-on-SRV01 design as the authoritative baseline and flagged "DHCP as a DC role" as an **error**:

- **Lab-02 audit M8** — `Lab-02-Device-Role-Assignments` "DC01/DC02 … DHCP …" → *"DHCP is **Kea on SRV01** (+ MKT01 relay); infra static. Not a DC service."*
- **Foundation audit H1** — `VM-and-Services-Inventory` "DHCP | DC01 or DC02" → *"DHCP shown as a **DC role**; current design = **Kea on SRV01**. Wrong-build + wrong NetBox data."*

The operator has now made the opposite call. This ADR records it and **flips the polarity** of M8/H1: DC01 becomes the correct DHCP host, and the Kea/SRV01 wording is what changes.

## Decision

**DHCP runs on DC01 (Windows DHCP Server), not Kea on SRV01. SRV01 sheds the DHCP role.**

- **Server:** the Windows **DHCP Server** role on **DC01** (`10.20.0.2`, VLAN 20), AD-authorized. **DC02** (`10.20.0.3`) becomes the failover peer **later** — see Availability.
- **Relay unchanged in shape, changed in target:** MKT01 keeps the **RouterOS DHCP relay** per served VLAN (gateways/SVIs are on MKT01, `ADR-0023`); the relay **helper target moves from SRV01 to DC01 (`10.20.0.2`)**.
- **Scope stays exactly as the IP plan defines it** — DHCP serves only the **client/deployment/testing** population, never infrastructure:
  - Clients `/25`: pool `.21–.126` (static `.2–.20`).
  - Deployment `/27`: pool `.11–.30` (static `.2–.10` for WDS/PXE).
  - **OT: no DHCP** — PLCs/HMIs/SCADA stay statically addressed.
  - **Tier‑0 `.2–.9` and servers `.10–.55` stay static regardless.** Nothing in Tier‑0 depends on DHCP.
- **Dynamic DNS:** DHCP performs secure dynamic DNS updates using a **dedicated low-privilege DHCP service account** as the DNS-update credential. **The DHCP server is NOT added to the `DnsUpdateProxy` group** — Microsoft's own guidance warns against `DnsUpdateProxy` when DHCP and DNS are co-located on a domain controller (it leaves records with insecure ownership/ACLs). A dedicated credential gives correct record ownership without that pitfall.
- **SRV01** keeps its real roles — nginx CRL host (`pki.atlas.lab`), Oxidized, rsyslog — and **loses Kea/DHCP entirely**.

## Rationale

**The driver is fewer VMs / fewer moving parts.** DC01 already exists and runs 24/7; putting DHCP there means the client population gets addressing without standing up and maintaining a separate Kea service (a second config language and lifecycle) on the Linux services box. DHCP integrates natively with AD-DNS on the same host, so scavenging and secure dynamic updates come for free. SRV01 stays lean and focused on the PKI/CRL and logging roles the AD CS build actually gates on.

## Reconciling with the estate's role-separation posture (the honest trade-off)

This estate deliberately keeps services **off** the domain controllers: `ADR-0027` puts **neither CA on a DC** ("keep DC and CA blast radii apart") and `ADR-0029`/**D7** just moved **NPS off the DC** onto a dedicated member server (`NPS01`) for the same reason. Putting DHCP **on** DC01 runs against that grain, so it is recorded as a deliberate, mitigated trade-off — not an oversight:

- **What NPS and a CA carry that DHCP does not.** NPS holds the **RADIUS shared secrets that authorize admin access to the core routers/switch/firewall**; a CA is the **trust anchor** for the whole estate. Both are high-value credentials whose compromise widens the DC's blast radius materially. **DHCP for the client/deployment VLANs holds no Tier‑0 credential** — it hands leases to sales laptops and imaging targets.
- **Nothing in Tier‑0 depends on it.** All infrastructure (Tier‑0 `.2–.9`, servers `.10–.55`) is **statically addressed**, so a DHCP failure or compromise cannot strand a DC, CA, or NPS.
- **The classic "DHCP on a DC" DNS-poisoning pitfall is mitigated by design** — dedicated DDNS credential, **no `DnsUpdateProxy`** (see Decision).
- **Scale.** At lab scale the operational saving of one fewer VM outweighs the marginal blast-radius increase from a low-sensitivity, client-facing service.

The threshold to re-separate: if DHCP ever needs to serve a Tier‑0 / sensitive population, or the DC's exposure becomes a real concern, move DHCP to a dedicated member server (the `NPS01` pattern) — that would be a new decision, not a silent drift.

## Alternatives Considered

- **Kea on SRV01 (the prior plan).** Rejected — adds a second DHCP stack (Kea config + lifecycle) on the Linux box for a service Windows DHCP does natively with tighter AD-DNS integration; more VMs/parts for no lab benefit. This is the plan this ADR supersedes.
- **A dedicated Windows DHCP member server** (the strict role-separation answer, mirroring `NPS01`). Rejected **for now** — it is the "more VMs" option this decision is explicitly avoiding, and DHCP's blast radius doesn't justify a dedicated host at lab scale. Named as the **Review Trigger** exit.
- **RouterOS DHCP on MKT01 itself** (no relay, no server VM). Rejected — loses AD-integrated DDNS and central scope management, and spreads the addressing source of truth onto the router; the whole point is one AD-integrated DHCP/DNS.

## Consequences

- **Docs to reconcile (each its own tracked change, `POL-0003`) — polarity flipped from the 07-24 findings:**
  - `IP-Addressing-Plan-VLSM` — change the "DHCP = SRV01 (Kea), held" note and the **SRV01 role row** (drop **Kea DHCP**) to **DHCP = DC01 (+ DC02 failover later)**; the MKT01 relay now targets `10.20.0.2`. (`POL-0008` — the IP plan is the address home.)
  - `Lab-02-Device-Role-Assignments` + `Atlas-Service-Architecture` — the **M8** row inverts: DHCP **is** now a DC01 service (with the scope/mitigation caveats); SRV01 role rows drop DHCP.
  - `Foundation/VM-and-Services-Inventory` — the **H1** row ("DHCP as a DC role" = error) inverts to **correct**, with this ADR cited and the mitigations noted.
  - `Master-Build-Order` — DHCP step moves from SRV01 to DC01 (the SRV01 build no longer carries Kea).
  - **NetBox** must ingest DC01 as the DHCP host, not SRV01 (these rows are exactly the "before NetBox population" reconciliation the audits flagged).
- **MKT01** gains/keeps a **DHCP-relay** config per served client VLAN pointing at `10.20.0.2` (buildable once DC01 DHCP is authorized).
- **Availability:** with a single DHCP server, a DC01 outage stops *new/renewing* client leases (existing leases ride their lease time; all infrastructure is static and unaffected). Mitigate by adding **DC02 as a Windows DHCP failover peer (hot-standby)** once DC02 promotion is verified (`repadmin /replsummary` clean) — deferred to **DC01-now / DC02-later** per the operator's call. Set a lease time long enough to absorb a DC01 reboot.
- **Security follow-through at build time:** create the dedicated DHCP DDNS service account (low privilege, used only as the DNS-update credential); confirm the DHCP server is **not** in `DnsUpdateProxy`; scope DHCP administration to Tier‑0 admins.

## Review Trigger

- If DHCP ever needs to serve a **Tier‑0 or otherwise sensitive** population, or DC exposure becomes a real concern → **move DHCP to a dedicated member server** (the `NPS01` pattern) and re-separate.
- If single-server DHCP availability proves painful before DC02 is ready → bring the **DC02 failover peer** forward.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-28. Accepted. **DHCP consolidates on DC01** (Windows DHCP), superseding the held "Kea on SRV01" plan; SRV01 sheds DHCP. Driver = fewer VMs/parts + native AD-DNS integration. **Inverts** the 2026-07-24 audits' M8 (Lab-02) / H1 (Foundation) "DHCP-on-a-DC is wrong" findings and lists the docs whose polarity flips. **Failover = DC01 now, DC02 (hot-standby) later** (gated on verified DC02 promotion). **DDNS via a dedicated low-privilege service account; DHCP server NOT in `DnsUpdateProxy`** (avoids the co-located DHCP+DNS-on-DC ownership pitfall). Reconciled head-on with the estate's role-separation posture (`ADR-0027` CA-off-DC, `ADR-0029`/D7 NPS-off-DC): DHCP carries no Tier‑0 credential, nothing in Tier‑0 depends on it (infra is static), and the DNS-poisoning pitfall is mitigated by design — the marginal blast-radius cost is accepted at lab scale, with a dedicated-member-server exit named in the Review Trigger. Captures Review-Flag-Register **A1**. |
