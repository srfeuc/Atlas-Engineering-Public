---
Title: MKT01 East-West Firewall — Incremental Build & Test Worksheet (Phase 7 method)
Path: Labs/Lab-02-Cisco-Core/Devices/MKT01-East-West-Firewall
Status: Target procedure — you build one scoped permit at a time and test it (Charter Rule 17; read state back, POL-0001 R-A1). Scoped ports below are seeded from the Allowed-Flows Matrix; confirm each against the real app before you commit it.
Version: 1.0
Date: 2026-07-20
---

# MKT01 East-West Firewall — Incremental Build & Test Worksheet

## 🔴 Reconciliation up front (how this fits the Master-Build-Order)

This **does not change** the build order. It is the **execution method for Phase 7** (Segmentation), and it leaves Phases 2 and 6 alone:

- **Phase 2** still brings the network up **permissive** — you are not default-deny during bring-up.
- **Phase 6** still runs NetFlow/Suricata for ~a week — that evidence still fills/tightens the **Allowed-Flows Matrix**.
- **Phase 7** is the only thing this refines: instead of flipping the whole default-deny policy on at once, you **build it one scoped permit per zone, testing each**, with a temporary catch-all so there's **no outage** during the cutover. The matrix stays the source of truth; this just renders it incrementally.

Why do it this way: a rule born with a passing positive *and* negative test is a rule you understand. Big-bang gives you 20 rules and a haystack when something's wrong; incremental gives you one variable at a time. It's the same "prove it, don't assume it" discipline as `Firewall-Rebuild-and-Per-Rule-Verification-Plan.md` — this worksheet is the **build sequence**; that plan is the **per-rule test method** you run at each step.

## The two things that make incremental firewalling safe

1. **RouterOS appends to the end.** `/ip firewall filter add` drops the new rule *below* your default-deny, where it's dead. Every permit must go in with `place-before=` an anchor. During the build the anchor is the **temporary catch-all**; at the end it's the deny.
2. **Don't blackhole yourself mid-build.** Keep a temporary, **logged** `accept all` in the forward chain just above the deny. While it's there, nothing breaks, and its log is your in-band evidence of any flow your matrix missed. You remove it **last** — that removal *is* the moment default-deny goes live.

---

## Step 0 — Gates (don't start Phase 7 without these)

- [ ] **Console break-glass tested** (FTDI cable, `ADR-0016`) — Phase 1 gate. This is the net under the whole cutover.
- [ ] **NetFlow week done** (Phase 6) and the **Allowed-Flows Matrix filled from that evidence**, scoped to services.
- [ ] **Management seat on VLAN 10** works (`vlan10-mgmt`), not just a legacy path.
- [ ] **Backup + export**: `/export file=phase7-pre` and `/system backup save name=phase7-pre`.
- [ ] Flat network (`bridgeLocal`) is **not** being recreated in Lab-02 (`ADR-0013`) — so rules 4/17/18 from Lab-01 simply never get built here.

## Step 1 — Scaffold (build once, before any zone permit)

Lay the skeleton so the box is structurally default-deny with a safe catch-all. **Input chain first** (protect the router / your seat), then forward.

**Input chain** — traffic *to the router itself* (management only; tighten the old "all VLANs → router"):
```
/ip firewall filter add chain=input action=accept connection-state=established,related comment="in: established,related"
/ip firewall filter add chain=input action=drop connection-state=invalid log=yes log-prefix="DROPPED:" comment="in: invalid"
/ip firewall filter add chain=input action=accept protocol=icmp limit=50,25:packet comment="in: icmp"
/ip firewall filter add chain=input action=accept in-interface=vlan10-mgmt protocol=tcp dst-port=22,443,8291 comment="in: MGMT->router mgmt ports"
/ip firewall filter add chain=input action=drop log=yes log-prefix="INPUT-DENIED:" comment="in: default deny"
```

**Forward chain** — the housekeeping + the deny + the **temporary catch-all** above it:
```
/ip firewall filter add chain=forward action=accept connection-state=established,related comment="fwd: established,related"
/ip firewall filter add chain=forward action=drop connection-state=invalid log=yes log-prefix="DROPPED:" comment="fwd: invalid"
/ip firewall filter add chain=forward action=accept log=yes log-prefix="TEMP-PASSED:" comment="TEMP-ALLOW-FORWARD (remove at cutover)"
/ip firewall filter add chain=forward action=drop log=yes log-prefix="EAST-WEST-DENIED:" comment="fwd: default deny"
```

Now every forward flow is accepted (by TEMP-ALLOW) and **logged as `TEMP-PASSED:`** — nothing is broken, and you can watch what's actually crossing.

## Step 2 — Add one zone's scoped permit(s), test, repeat

For each flow below: **add** it `place-before` the temp catch-all, **prove positive** (the flow works and its counter climbs), and note what to prove negative later. Ports are seeded from the matrix — **confirm the real app port before committing** (the whole point of scoping is that `Clients→Servers:443` is a rule and `Clients→Servers any` is a hole with a comment).

Template:
```
/ip firewall filter add chain=forward action=accept \
  in-interface=<src-vlan> out-interface=<dst-vlan|ether1> protocol=tcp dst-port=<ports> \
  comment="<SRC>-><DST>:<ports> (matrix #<n>)" \
  place-before=[find where comment="TEMP-ALLOW-FORWARD (remove at cutover)"]
```

Suggested build order (dependency-light first; identity/OT last, when those zones exist):

| # | Matrix flow | Rule to add (scope — confirm ports) | Positive test | Negative to prove at cutover |
|---|---|---|---|---|
| 1 | MGMT→all (#1) | `in=vlan10-mgmt out-list=VLANs` — scope to `tcp 22,443,8291` | From 10.10.0.x reach a device in each VLAN on a mgmt port; counter climbs | Non-mgmt port from MGMT is denied+logged |
| 2 | MONITORING→all (#2) | `in=vlan40-monitoring out-list=VLANs` — `udp 161` + `icmp`; syslog inbound to 40 | Poller SNMP-walks a host in each VLAN | A host in any VLAN cannot *initiate* back into MON |
| 3 | SERVERS→internet (#7) | `in=vlan20-servers out=ether1` — `tcp 80,443` `udp 53` | Server `curl -I https://…`, resolves DNS | Servers→any interior VLAN denied+logged |
| 4 | CLIENTS→SERVERS (#3) | `in=vlan50-client out=vlan20-servers` — `tcp 443` (+ app port) | Client hits the app on 443 | Client→any other port on Servers denied |
| 5 | CLIENTS→internet (#6) | `in=vlan50-client out=ether1` — `tcp 80,443` `udp 53` | Client browses out | Client→Clients (same zone) and Client→other zones denied |
| 6 | WEB→SERVERS (#4) | `in=vlan30-web out=vlan20-servers` — `tcp 1433` (or app/db port) | Web tier reaches the DB port | Web→internet and Web→any other zone denied |
| 7 | DEPLOYMENT→SERVERS (#5) | `in=vlan60-deployment out=vlan20-servers` — `udp 69` + PXE/HTTP | PXE/TFTP pull works | Deployment→anything else denied |
| 8 | TESTING→internet (#8) | `in=vlan70-testing out=ether1` — `tcp 80,443` | Testing browses out | Testing→**any** lab VLAN denied+logged (isolation) |
| 9 | MGMT→internet (live rule 19) | `in=vlan10-mgmt out=ether1` — scope as needed | Mgmt host reaches internet | — |
| 10 | (T1/T2)→IDENTITY (#9) — **add when AD lands** | `in=<client/server vlans> out=<T0>` — `tcp 636,88` `udp 53,88` | Domain auth succeeds | Anything to T0 *other than* auth denied — the tightest zone |
| 11 | IT→OT conduit (#11) — **add with VLAN 90** | one host, one port only | The single named flow works | **Every other** corporate→OT denied+logged (availability first) |
| 12 | MONITORING→OT (#13) — **add with VLAN 90** | passive/poll read-only | Read-only visibility | OT never initiates into corporate (#12) |

> Each committed rule = a small **Change Record** (`CM-00xx`) capturing the rule text + its positive/negative evidence. That's how each rule is documented the moment it's born.

## Step 3 — Shrink the catch-all to zero, then remove it (the cutover)

- [ ] Watch `TEMP-PASSED:` in the log and the temp rule's counter. Every hit is a flow **not yet covered** by a scoped permit — either add a rule for it (if legitimate, tighten it to a service) or confirm it should die.
- [ ] When `TEMP-PASSED:` goes **quiet** under normal load, you've captured every real flow. Remove the catch-all:
```
/ip firewall filter remove [find where comment="TEMP-ALLOW-FORWARD (remove at cutover)"]
```
- [ ] **Default-deny is now live.** Uncovered traffic falls to `EAST-WEST-DENIED:`.

## Step 4 — Negative test / reachability Game Day (`ADR-0011`)

The half that makes it a control: from a host in each source zone, attempt a service in each **denied** destination and confirm it is **refused and logged with a correct timestamp** (needs synced clocks, `ADR-0020`). Watch the SPAN (`SW01 Gi1/0/5`) to see what's actually crossing, independent of what the policy claims. This is the same negative discipline as the verification plan — run it per the matrix's denied cells.

## Acceptance criteria

- [ ] Temp catch-all removed; `TEMP-PASSED:` no longer in the ruleset or the log.
- [ ] Every matrix **allowed** flow passes and is scoped to a **service**, not a whole zone (no 🟡 left).
- [ ] Every matrix **denied** cell is refused **and** logged (`EAST-WEST-DENIED:` / `INPUT-DENIED:`).
- [ ] Management still reachable from VLAN 10; console break-glass still proven.
- [ ] `/ip firewall filter print` read back; no disabled leftovers, no stray test mirrors (`016`).

## Rollback

Instant: re-add the `TEMP-ALLOW-FORWARD` catch-all (restores full connectivity), or `/import file=phase7-pre`. Console cable covers the worst case (management path lost).

## Related

- `Atlas-East-West-Allowed-Flows-Matrix.md` — the source; every rule here renders a matrix row, scoped to a service.
- `Firewall-Rebuild-and-Per-Rule-Verification-Plan.md` — the per-rule test method this build sequence calls at each step.
- `Master-Build-Order.md` Phase 7 — this is that phase's execution method (no change to Phases 2/6).
- `Atlas-Firewall-Architecture.md` §6 — the verification method. `ADR-0023` (MKT01 = in-path gateway), `ADR-0013` (no bridgeLocal), `ADR-0016` (console net), `ADR-0021` (Tier-0 identity), `ADR-0020` (clocks for log timestamps).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-20. Incremental per-zone build method for Phase 7 — scaffold (input+forward housekeeping, default-deny, temporary logged catch-all), one scoped permit per matrix flow added `place-before` the catch-all with positive test, shrink-catch-all-to-zero cutover, then the negative-test Game Day. Reconciled to Master-Build-Order (refines Phase 7 only; leaves permissive bring-up and NetFlow evidence intact). Ports seeded from the Allowed-Flows Matrix, flagged to confirm per real app. |
