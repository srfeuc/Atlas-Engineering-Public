---
Title: Lab-02 Per-Device Config-Design Checklists
Path: Labs/Lab-02-Cisco-Core/Architecture
Status: Target Design — checklists, not build instructions. You write the config (Charter Locked Rule 17).
Version: 1.0
---

# Lab-02 — Per-Device Config-Design Checklists

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

> **How to use this.** One section per device. Each is a *design checklist*, not a command list: every item names **what to configure and why**, plus how to **prove it** and what **fails**. You write the actual CLI — that's the point (Learning Rule). Work top-to-bottom; the order is deliberate. When a device is built, this section becomes its `Devices/<DEVICE-Role>/Build-Guide` content.
>
> Builds on `ADR-0023` (Option B topology) and `Lab-02-Device-Role-Assignments.md`. Grounding: `Atlas-Firewall-Architecture.md` (§3 capability catalogue, §4 the E-W bar, §6 the verification method).

## Global gates — true before the network re-role starts

- [ ] **NETBOX01 is the source of truth** — device/interface/VLAN/IP data lives there; ACLs and configs are *generated from it*, not hand-typed. (Kills the hand-typed-ACL defect class at the root.)
- [ ] **MON01 exists and collects** — syslog + NetFlow, so you design the allowed-flows matrix **from observed flows**, not guesses, and have somewhere to ship deny logs.
- [ ] **Clocks are synced first** (`ADR-0020`) — especially SW01 (`CM-0030`). Logs and correlation are worthless on a wrong clock.
- [ ] **MKT01's console recovery path is tested** (`ADR-0016`, FTDI cable) — before MKT01 carries default-deny policy.
- [ ] **UPS + CR2032 installed on PVE01** — the dead RTC (`CM-0012`/`ADR-0017`) must not drop settings mid-build.

---

## 1941 — Core Router  🔵 Network

**Role:** the routed north-south backbone between MKT01 and FGT01. Routes; does not filter east-west; holds no VLAN gateways.

**Gates:** rack/power/IOS version confirmed and captured in NetBox; transit subnets (two /30s) allocated in NetBox first.

**Config-design checklist**

- [ ] **Enable IP routing** — it's a router, not a switch, in this role.
- [ ] **Routed transit interface toward MKT01** (/30) — the internal-facing link; *why /30:* point-to-point, no wasted host space, clear routing boundary.
- [ ] **Routed transit interface toward FGT01** (/30) — the edge-facing link.
- [ ] **Routing protocol OR static routes** so MKT01's internal subnets are reachable toward the edge and back — *design choice:* OSPF (learn adjacency, areas, summarization) vs static (simpler, less to break). Pick one on purpose and record why.
- [ ] **Default route toward FGT01** — internal traffic with no better match heads to the edge.
- [ ] **Route summarization** of the internal subnets (if OSPF) — *why:* one summary toward the edge instead of nine specifics; a real design skill.
- [ ] **Transit ACL (optional, light)** — the 1941 is a router, not the policy point; keep any ACL minimal (e.g. anti-spoofing), not east-west policy (that's MKT01's job — don't split policy across boxes, `ADR-0018`).
- [ ] **Management + logging** — SSH-only admin, SNMPv3 to MON01, syslog to MON01, NTP client to the `ADR-0020` source.
- [ ] **Config export to Oxidized/git** once reachable.

**Validation**

- [ ] Routing table shows MKT01's internal subnets **and** a default toward FGT01.
- [ ] Both adjacencies/paths prove up (OSPF neighbor state, or ping across each /30).
- [ ] A trace from an internal host to the internet transits the 1941 on the expected path.
- [ ] Read the running config back off the device — don't trust "no error."

**Failure modes**

- 🔴 **Asymmetric/missing return route** — if the reply path differs from the request, MKT01's stateful inspection breaks silently (Firewall-Arch §3.1). Keep paths symmetric.
- 🔴 **No default-route origination** — internet-bound traffic blackholes with no obvious error.
- Putting VLAN sub-interfaces here "to help" — that steals the inter-VLAN gateway role from MKT01 and un-does the segmentation design.

---

## MKT01 — Internal East-West Segmentation Firewall  🔵 box / 🔴 policy

**Role:** L3 default gateway for every internal VLAN **and** the default-deny east-west enforcement point. Keeps inter-VLAN routing; gains policy; default route now points at the 1941.

**Gates:** console recovery tested (above); the **allowed-flows matrix written on paper first** (from NetFlow evidence) — the matrix is the design, the rules just render it; RADIUS already migrated off to SRV01/NPS.

**Config-design checklist**

- [ ] **VLAN interface + gateway IP per VLAN**, including the new **VLAN 90 OT** — MKT01 remains the inter-VLAN gateway.
- [ ] **Routed uplink /30 to the 1941** + **default route to the 1941** — *the re-role:* north-south now leaves via the core router, not straight to FGT01.
- [ ] **Confirm NO NAT on inter-VLAN paths** — real source IPs, or policy and logs are meaningless (Firewall-Arch §3.3). NAT stays at the edge (FGT01) only.
- [ ] **Default-deny between all segments, logged** — start closed; every allow is an explicit, named, per-service exception.
- [ ] **Render the allowed-flows matrix as rules** — one rule per justified flow (source zone → dest zone → service), written in the direction the connection initiates (state handles replies).
- [ ] **Rule order: specific before general** — a broad allow above a specific deny silently wins.
- [ ] 🔴 **Tier-0 Identity micro-zone** (DCs, CA) — the tightest rule set: almost nothing initiates *into* it except auth (LDAPS/Kerberos/DNS); it initiates *out* to manage. Higher-tier creds never land on lower tiers (`ADR-0021`).
- [ ] 🔴 **OT micro-zone (VLAN 90)** — one controlled IT/OT conduit; the corporate side never initiates into OT except the one named flow the process needs; availability outranks confidentiality here (`305` Part 2 / NIST 800-82).
- [ ] **Monitoring one-way rule** — MON01 reaches agents to poll/collect; nothing initiates a session *back into* monitoring.
- [ ] **Deny-logging shipped to MON01** (clocks synced first).
- [ ] **Management hardening** with the console recovery path preserved; config export to Oxidized/git.

**Validation** (Firewall-Arch §6 — the method)

- [ ] Read policy with the **runtime** view (rule stats), not the config view; count the rules; read each one in plain English.
- [ ] **Test the allowed flows** — generate the traffic, confirm it passes, find it in the session table.
- [ ] 🔴 **Test the denied flows** — attempt what should be blocked; confirm it is *refused* (not silently dropped) and the deny is *logged with a correct timestamp*.
- [ ] Confirm inter-VLAN policies do **not** NAT.
- [ ] **Reachability-matrix Game Day** (see end) — the whole point.
- [ ] Watch the SPAN to see what is *actually* crossing, independent of what policy claims.

**Failure modes**

- 🔴 **"Allow any-any to make bring-up work," then never tighten** — the single most common real-world east-west failure. Build the matrix first; fail closed; open one proven flow at a time.
- 🔴 **Locked out with no tested console** — a default-deny box that gates the whole interior is one bad rule from an outage. Prove recovery before going policy-critical.
- 🔴 **NAT applied east-west** — every internal host looks like the firewall; logs and policy become useless.
- **Segmentation on paper only** — verify the inter-VLAN path actually crosses MKT01 (in Option B it does by definition, but confirm it, don't assume).

---

## SW01 — L2 Access / Distribution Switch  🔵 Network

**Role:** Layer-2 access + the all-VLAN trunk to MKT01; L2 security controls; feeds the IDS.

**Gates:** clock fixed (`CM-0030`) before its logs are trusted; `STATIC-HOSTS` data in NetBox.

**Config-design checklist**

- [ ] **802.1Q trunk to MKT01** carrying all VLANs; access ports assigned per zone.
- [ ] **New VLAN 90 (OT)** defined and carried on the trunk.
- [ ] **DHCP snooping** (trust the uplink, limit access ports) + **Dynamic ARP Inspection**; the `STATIC-HOSTS`/snooping data **generated from NetBox**, not hand-typed.
- [ ] **Port security** on access ports as appropriate.
- [ ] **SPAN session on Gi1/0/5** mirroring the MKT01 trunk → the IDS host — *finally use the tap you built.*
- [ ] **Re-point SNMP at MON01** (it currently targets `10.40.0.52`, which doesn't exist); use **SNMPv3**, not v2c.
- [ ] **Syslog to MON01**; NTP client to the `ADR-0020` source.
- [ ] Config export to Oxidized/git.

**Validation**

- [ ] Trunk + VLAN membership correct (`show vlan`, `show interfaces trunk`).
- [ ] DHCP snooping/DAI active and not dropping legitimate hosts.
- [ ] SPAN session up **and** the IDS actually receiving mirrored traffic.
- [ ] Clock reads synced **before** trusting any timestamp; SNMP/syslog arriving at MON01.

**Failure modes**

- 🔴 **DAI silently dropping a host missing from a hand-typed ACL** — the Pi01 mystery that survived three handoffs. Generating from NetBox makes the omission structurally impossible.
- 🔴 **SPAN built and never plugged in** — free east-west telemetry, unused. Prove the sensor fires.
- Trusting logs on an unsynced clock.

---

## FGT01 — Perimeter / Edge Firewall  🔵 box / 🔴 policy

**Role:** north-south edge — NAT, egress policy, inbound deny. Role unchanged; internal link now faces the 1941.

**Gates:** verify the break-glass paths (console + `192.168.1.99`) work *before* touching anything.

**Config-design checklist**

- [ ] **Re-point the internal interface/route at the 1941 transit /30** — the only real topology change for FGT01.
- [ ] **Confirm egress policy + NAT** — keep `srcaddr all` for now (`ADR-0005`: don't narrow until a redundant path exists to test safely).
- [ ] **Confirm `admin-server-cert` is actually bound** — verify with the runtime view, not the config view (MC-0001 silently unbound it for hours).
- [ ] **UTM decision explicit** — either license + apply + verify updates, or keep none attached (an attached-but-stale profile is worse than none, `CM-0033`). "Possibly applied" is not a decision.
- [ ] **Logging** to MON01; NTP confirmed.

**Validation**

- [ ] Read policy with the runtime view (`get`, not `show`); session table shows live flows.
- [ ] Recovery path (`192.168.1.99`/console) reachable **before** relying on policy.
- [ ] Internet egress works from an internal host after the re-cable.

**Failure modes**

- 🔴 **A hardening change that severs management with no tested console.**
- 🔴 **The UTM confidence trap** — green column, 2015 signatures.

---

## PVE01 — Hypervisor  🟢 Systems

**Role:** the platform hosting the entire service + Windows estate. Not a network policy device.

**Gates:** UPS + CR2032 (dead RTC); confirm the real capacity baseline (62 GiB usable) still holds.

**Config-design checklist**

- [ ] **VLAN-aware bridge trunk to SW01** carrying every VLAN a VM needs.
- [ ] **Each VM's vNIC tagged to its zone's VLAN** — DCs/CA → the Tier-0 carve-out of VLAN 20; MON01 → 40; NETBOX01/SRV01/VAULT01 → 20; etc.
- [ ] **Host management on VLAN 10**; named admin (no shared root); host clock synced.
- [ ] **Storage layout** for the VM roster (sized against the VM Inventory); **backup target on separate media** (PBS/BKP01 — backing up to the same host it protects isn't backup).
- [ ] Host + guests into monitoring (SNMPv3/syslog → MON01).

**Validation**

- [ ] VLAN tags verified **on the wire**, not just in config (the Book 2 VLAN-20 tagging failure).
- [ ] Each VM reachable only within its intended zone (cross-check against the MKT01 matrix).
- [ ] Host clock synced; backups actually run **and restore-test** at least once (`ADR-0011`).

**Failure modes**

- 🔴 **Tag mismatch** putting a VM in the wrong zone — verify on the wire.
- 🔴 **"Backup" to the same physical host** — not real backup until it's on separate media and a restore has succeeded.

---

## Pi01 — DNS + NTP  🟡 Services

**Role:** reduced to two jobs. Everything else (RADIUS, Vault, both CAs) has moved off.

**Gates:** migrations of Vaultwarden → VAULT01, RADIUS → SRV01, Intermediate CA → CA01, Root CA → offline media are **complete and verified** before decommissioning those services here.

**Config-design checklist**

- [ ] **Pi-hole as the filtering forwarder** — non-domain devices use it; domain machines use AD DNS on the DCs (the `ADR-0003`/`ADR-0007` boundary). Coexistence, not replacement.
- [ ] **chrony as a lab stratum source** under the `ADR-0020` hierarchy.
- [ ] **Decommission the moved services** — and confirm nothing still points at Pi01 for RADIUS/Vault/CA (grep configs; check the wire).
- [ ] Monitoring + syslog → MON01.

**Validation**

- [ ] DNS resolves for the right client classes; NTP clients sync to it.
- [ ] Confirm **no residual dependency** on Pi01 for the moved services (a lingering pointer is the "factory cert" class of defect).

**Failure modes**

- 🔴 **Decommissioning a service something still depends on** — verify the dependents moved *before* removing.
- **Over-trust creeping back** — the reduction exists so Pi01 stops being a single point of failure. Don't re-pile services onto it.

---

## Cross-cutting: the reachability-matrix Game Day

The verification that proves the whole segmentation design (run it as an `ADR-0011` Game Day, not a one-off):

- [ ] From a host in **each** segment, attempt **each** service in **every other** segment.
- [ ] Allowed flows (per the matrix) **succeed**; everything else is **refused**, and the refusal is **logged** with a correct timestamp on MON01.
- [ ] Confirm the Tier-0 and OT micro-zones deny corporate-initiated sessions while passing the one flow each genuinely needs.
- [ ] Packet-capture on the SPAN to confirm what's *actually* crossing matches what policy claims.

> 🔴 **Isolation you didn't test is isolation you don't have.** A firewall rule whose deny was never tested is a hope, not a control.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-17. Per-device config-design checklists for the Lab-02 Option B topology (`ADR-0023`): 1941, MKT01, SW01, FGT01, PVE01, Pi01, plus the global gates and the reachability-matrix Game Day. Design intent + validation + failure modes only — no CLI, per the Learning Rule. Each section is the precursor to its `Devices/<DEVICE-Role>/Build-Guide`. |
