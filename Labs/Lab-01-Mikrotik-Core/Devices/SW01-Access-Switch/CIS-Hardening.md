---
Title: SW01 Hardening Checklist (CIS-Informed)
Path: Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch
---

# SW01 Hardening Checklist (CIS-Informed)

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: SW01 - Role: Access Switch

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Reconciled to live 2026-07-16 — several items settled by the `056` verification run |
| Version | 1.1 |
| Applies To | SW01 (Cisco Catalyst 2960X, IOS 15.2(2)E6) |
| Reference | CIS Cisco IOS XE 17.x Benchmark v2.2.1 |

## Important Version Note

SW01 runs **classic Cisco IOS** (`15.2(2)E6`), not IOS XE. The referenced benchmark is written for IOS XE — the three-plane structure (Management/Control/Data) and the security concepts transfer directly, but **exact command syntax should be verified against SW01's actual running config before applying**, not assumed to match IOS XE syntax verbatim. Items below are cited by CIS category and recommendation title only, in Atlas's own words — not reproduced from the benchmark text itself, per CIS's usage terms.

> 🟢 **2026-07-16 — several items below carry a live result now.** The `056-SW01-Verification-Procedure.md` battery was run against the switch. Items it settled are marked **device-verified 2026-07-16**; the rest are still **Unverified** until a check runs. Device wins (Rule 13).

## How to Use This Checklist

Each item lists: the CIS category it comes from, what it checks, and — where already known — whether Atlas's live-validated state already satisfies it. Items marked **Unverified** need an actual live check before assuming either way.

---

## 1. Management Plane

### 1.1 AAA Rules
- [ ] **AAA authentication configured** (CIS 1.1) — **Gap, device-verified 2026-07-16** (`show run` → `no aaa new-model`). SW01 uses local `enable secret` + local `cisco` user only, no AAA/RADIUS integration, unlike FGT01 and MKT01 which both have working RADIUS via Pi01. Worth a real decision: extend RADIUS to SW01 too, or accept local-only auth here as a deliberate, recorded choice. Tracked as `057` row 5.

### 1.2 Access Rules
- [x] **SSH-only management, legacy protocols disabled** — confirmed live: `transport input ssh`, `ip ssh version 2`, `no ip http server`. Telnet not in use.
- [x] **VTY access-class restrictions** — **device-verified 2026-07-16.** Both `line vty 0 4` and `line vty 5 15` carry `access-class MGMT-ACCESS in` (permits 10.10.0.0/24 and 10.0.0.0/24, `deny any log`), `login local`, `transport input ssh`. *(Was "Unverified"; the `056` run settled it.)*

### 1.3 Banner Rules
- [ ] **Login warning banner present** (CIS 1.3) — **Gap, device-verified 2026-07-16.** No `banner` line in the running config; SW01 presents no legal/authorised-use banner. Low priority; add to close. Tracked as `057` row 9. *(Was "Unverified on SW01 specifically".)*

### 1.4 Password Rules
- [x] **Enable secret is a real, non-placeholder value** — confirmed: `enable secret` set (type 5), `service password-encryption` on. Historical note: an earlier build attempt used a literal placeholder password and caused a real lockout — kept as a permanent lesson (`039-SW01-Troubleshooting-Guide.md`).

### 1.5 SNMP Rules
- [x] **SNMP configured** — device-verified 2026-07-16: an RO community with a trap host and `snmp-server enable traps`.
- [ ] **SNMP community strings are non-default, SNMPv3 in use rather than v1/v2c** — **Gap, device-verified 2026-07-16.** SW01 runs **SNMP v2c**, not v3, with a cleartext RO community (redact + rotate pending, `CM-0023`), and its trap host `10.40.0.52` sits on a VLAN that is routed but empty (`027` §17) — traps go nowhere. Also live: `snmp-server location Home-Lab-California`, a location string `027` believed removed. Move to v3, point traps at a real collector (Book 5), strip the location string. Tracked as `057` rows 2 and 8.

---

## 2. Control Plane

### 2.1 Global Service Rules
- [x] **Unused services disabled** (CIS 2.1) — **device-verified 2026-07-16.** `no cdp run` (CDP off), `no ip http server` + `no ip http secure-server` (web UI off), `no service pad`, `service password-encryption`. Unused ports Gi1/0/8–48 shutdown in VLAN 999 per the Unused Interface Policy (`010-Security-Zones.md`). *(Was "partially confirmed — CDP/HTTP not audited".)*

### 2.2 Logging Rules
- [ ] **Centralized/remote logging configured** — **Gap, device-verified 2026-07-16.** No `logging host` in the running config; only SNMP traps are sent (to the possibly-nonexistent host above). Add a syslog target when Book 5 exists to receive it — **and note it is doubly blocked: it also needs §2.3's clock fixed, or the logs it forwards are timestamped meaninglessly.** Tracked as `057` row 4.

### 2.3 NTP Rules
- [ ] **NTP configured and synchronized** — 🔴 **FALSE-TICK CORRECTED 2026-07-16.** This item was previously ticked *"confirmed live during original SW01 validation."* **It is not, and never has been, synchronized.** `show ntp status` → `Clock is unsynchronized, stratum 16, no reference clock`, reference time 1899, `never updated`; `show ntp associations` → the one peer `10.10.0.5` (Pi01) is `.INIT.`, reach `0` — Pi01 serves no NTP. `ntp server 10.10.0.5` is a config line, not a working clock. This is the `016` lesson: a config line showed the intent; the status command showed the truth; nobody ran the second one. **Fix + proof are a design decision, tracked in `CM-0030` (Open).**

### 2.4 Loopback Rules
- [ ] **Dedicated loopback interface for management** — **Not applicable / not yet assessed** for this switch's role.

---

## 3. Data Plane

### 3.1–3.3 Routing, Border Filtering, Neighbor Authentication
- Routing security is **not applicable** — SW01 is a Layer-2 access/distribution switch (`no ip routing`, `ip default-gateway 10.10.0.1`). North-south/east-west routing security lives on FGT01 and MKT01 (MKT01's own firewall rule set is tracked in the MKT01 pass — the "23 rules" figure is an MKT01 count and is reconciled there, not here).
- 🟢 **But SW01 carries a real Layer-2 data-plane posture the earlier version under-credited, device-verified 2026-07-16:** Dynamic ARP Inspection on VLANs 10–80 (with the `STATIC-HOSTS` filter on VLAN 10), DHCP snooping on VLANs 10–80 (trust on the MKT01 uplink only), port-security on the access ports, storm-control with `action shutdown`, BPDU guard on edge ports, root guard on the uplink, and RSTP root. **Caveat (see `057` row 6):** DAI on VLANs 20–80 has no static ACL and the snooping binding table is empty, and the PVE01 trunk is untrusted — a real latent drop for static-IP VMs when PVE01 comes up.

---

## Real Priorities, Ranked

1. 🔴 **Fix the clock (`§2.3` / `CM-0030`).** It is the only *actively broken* item here — stratum 16, never synced — and it blocks Book 5 and corrupts every timestamp. This is the design decision (A/B/C in `CM-0030`), then a **proven** `Clock is synchronized`.
2. **AAA/RADIUS decision for SW01** — the biggest posture gap, matching what FGT01 and MKT01 already have. Record the decision either way.
3. **SNMP cleanup** — move v2c → v3, redact+rotate the community (`CM-0023`), point traps at a collector that exists, strip the `Home-Lab-California` location string before publication (`ADR-0010`).
4. **Confirm/add a login banner.**
5. **Establish centralized logging** — once Book 5 (Monitoring) exists to receive it, and the clock (item 1) is fixed.

## Related Pages

- `Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Verification.md` — the read-only battery that settled the items above
- `Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Considerations.md` — the open holes in full
- `Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Changes/CM-0030-SW01-Clock-Has-Never-Synchronised.md` — the §2.3 clock finding
- `Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Build-Record.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Troubleshooting.md`
- `Labs/Lab-01-Mikrotik-Core/Standards/010-Security-Zones.md`
