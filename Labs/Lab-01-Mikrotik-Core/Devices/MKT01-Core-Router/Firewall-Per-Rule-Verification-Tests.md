---
Title: MKT01 (Lab-01, current) — Per-Rule Firewall Verification Tests
Path (suggested): Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/
Status: Verification procedure for the LIVE 22-rule set (Build-Record v2.9, verified 2026-07-16). Runnable now; doubles as pre-teardown capture.
Date: 2026-07-20
Source of the rules: MKT01 Build-Record §"Firewall — 22 rules live" (read from /ip firewall filter print, post-CM-0009).
---

# MKT01 Current Firewall — How to Verify Each Rule

This is the live Lab-01 rule set (22 rules, indices 0–21), turned into one concrete test per rule. The rules match on **interface** (`in=vlanX out=vlanY`), so a test just needs a host in the right VLAN sending to the right place — the rule matches by which interface the packet entered/leaves, not by address.

## 0. Read this first — how to know a rule actually matched

Three ways to confirm, in order of trust:

1. **The rule's counter moved.** `/ip firewall filter print stats` shows per-rule packet/byte counters. Reset them right before a test so the delta is clean:
   ```
   /ip firewall filter reset-counters [find]        # zero all, then run one test
   /ip firewall filter print stats                  # read the row that should have moved
   ```
   Because RouterOS is **first-match-wins** and these rules are disjoint by interface, a given flow matches exactly **one** accept rule — so a counter bump on that index *is* the proof it matched. (Note: on an established connection, most packets hit rule 0/7 `established,related`; the specific accept rule only counts the **connection-opening** packets. A `+1` on rule 12 still confirms the match.)

2. **The deny log fired** (drops only). Rules 1, 3, 6, 8, 20, 21 carry log prefixes:
   ```
   /log print where message~"EAST-WEST-DENIED"     # rule 20, inter-VLAN drops
   /log print where message~"INPUT-DENIED"         # rule 21, router-input drops
   /log print where message~"DROPPED"              # rules 1/3/6/8
   ```
   🔴 The **accept** rules (0,2,4,5,7,9–19) have **no log** — you can only confirm them by the counter + the traffic succeeding, never by a log line.

3. **The traffic did (or didn't) do the thing** — host-side, with the *real* protocol.

**Negative-test discipline (`015`):** a `ping` reply proves only that ICMP works, nothing about TCP/443. `nc -u -z` reports UDP "success" even when blocked. **Prove the positive case first** — a test you can't make succeed on purpose tells you nothing when it fails.

## 1. Test hosts you need

One host in each VLAN you want to prove (LabComputer can be moved between access ports, or use a VM on PVE01 with the NIC tagged to that VLAN). Minimum useful set: Management (10.10.0.x), Servers (10.20.0.x), Client (10.50.0.x), Testing (10.70.0.x), and the admin laptop on bridgeLocal (10.0.0.20). Router gateway in VLAN N is `10.N0.0.1`.

Host tools: `ping`, `nc -vz <ip> <port>` / `Test-NetConnection <ip> -Port <port>`, `curl`, `traceroute`/`tracert`. Router side: the three commands above + `/tool ping`.

---

## 2. Input chain — protecting the router itself (rules 0–6, 21)

| # | Rule (plain English) | Concrete test | Expected | Confirm |
|---|---|---|---|---|
| 0 | accept established,related to router | Open an SSH session from a Mgmt host to `10.10.0.1:2222`; keep it up | Session stable | Rule 0 counter climbs continuously while connected |
| 1 | **drop** invalid to router (`DROPPED:`) | From any host: `nmap -sF 10.10.0.1` (FIN scan → out-of-state packets) | Scan gets nothing useful | Rule 1 counter moves; `DROPPED` in log |
| 2 | accept ICMP (rate-limited 50/s) | From a Mgmt host: `ping 10.10.0.1` | Replies | Rule 2 counter = your ping count |
| 3 | **drop** excess ICMP (`DROPPED:`) | Flood: `ping -f 10.10.0.1` (Linux) or `hping3 --flood --icmp 10.10.0.1` | Most echoes dropped past ~50/s | Rule 3 counter climbs; `DROPPED` in log |
| 4 | accept bridgeLocal → router (full) | From admin laptop `10.0.0.20`: `ping 10.0.0.1` and SSH `10.0.0.1:2222` | Both work | Rule 4 counter moves; you get a login prompt |
| 5 | accept VLAN devices → router | From a **Servers** host `10.20.0.x`: `ping 10.20.0.1` | Ping **works** | Rule 5 counter moves |
| 6 | **drop** home LAN → router via ether1 (`DROPPED:`) | From a device on the home network (`172.31.4.0/22`, upstream of FGT01): try to reach `172.16.0.2` (MKT01 transit) | Refused/timeout | Rule 6 counter moves; `DROPPED` in log *(may be blocked at FGT01 first — if so, note that)* |
| 21 | **drop** everything else to router (`INPUT-DENIED:`) | From a **Testing** host `10.70.0.x` (VLAN 70 is **not** in the `VLANs` list, so rule 5 won't catch it): `nc -vz 10.70.0.1 2222` | **Refused** | Rule 21 counter moves; **`INPUT-DENIED`** in log |

> 🔴 **Your example — "from a 10.20.0.x PC, SSH the router" — is a subtle one.** At the *firewall* level, rule 5 **accepts** VLAN-20 traffic to the router (so a `ping 10.20.0.1` succeeds and there's **no** `INPUT-DENIED` log). SSH is then refused a layer up, by the **service address ACL**: `/ip service` restricts SSH/WinBox/www-ssl to `10.0.0.0/24` and `10.10.0.0/24` only. So `ssh 10.20.0.1 -p 2222` **fails**, but because the *service* dropped it, not the firewall. Verify that restriction directly: `/ip service print detail` → the `address=` field, and confirm SSH works from `10.10.0.x`/`10.0.0.20` and fails from `10.20.0.x`. This distinction (firewall drop vs service ACL) is exactly the kind of thing that looks like one rule and is actually another.

Rule 21 is **load-bearing**: RouterOS defaults a chain to **ACCEPT** if nothing matches, so rule 21 is the only thing denying unmatched input. The old `026` guide never built it — verify it exists and its counter is non-zero after the VLAN-70 test.

---

## 3. Forward chain — the east-west policy (rules 7–20)

Positive tests (the permits). Each is "from a host in the `in` VLAN, reach the `out` destination":

| # | Rule (plain English) | Concrete test | Expected | Confirm |
|---|---|---|---|---|
| 7 | accept established,related through router | Any permitted inter-VLAN flow below, sustained | Return traffic flows | Rule 7 carries the bulk/return packets |
| 8 | **drop** invalid through router (`DROPPED:`) | `nmap -sF 10.20.0.x` from a *different* VLAN host | Out-of-state dropped | Rule 8 counter; `DROPPED` log |
| 9 | Mgmt → all VLANs (full) | From Mgmt `10.10.0.x`: `ping 10.20.0.x`, SSH `10.50.0.x`, hit `10.80.0.x` | All reachable | Rule 9 counter moves per new flow |
| 10 | Monitoring → all VLANs (full) | From Mon `10.40.0.x`: `nc -vz 10.20.0.x 22`, `ping 10.50.0.x` | Reachable | Rule 10 counter |
| 11 | Servers → internet | From Servers `10.20.0.x`: `curl -I https://example.com`, `ping 1.1.1.1` | Works (NAT at FGT01) | Rule 11 counter |
| 12 | Clients → Servers | From Client `10.50.0.x`: `nc -vz 10.20.0.x 443` (or any port) | Reachable | Rule 12 counter |
| 13 | Clients → internet | From Client `10.50.0.x`: `curl -I https://example.com` | Works | Rule 13 counter |
| 14 | Deployment → Servers | From Deploy `10.60.0.x`: `nc -vz 10.20.0.x 69` (or any) | Reachable | Rule 14 counter |
| 15 | Web → Servers | From Web `10.30.0.x`: `nc -vz 10.20.0.x 1433` (or any) | Reachable | Rule 15 counter |
| 16 | Testing → internet only | From Testing `10.70.0.x`: `curl -I https://example.com` | Works | Rule 16 counter |
| 17 | bridgeLocal → all VLANs | From laptop `10.0.0.20`: `ping 10.20.0.x` | Reachable | Rule 17 counter |
| 18 | bridgeLocal → internet | From laptop `10.0.0.20`: `ping 1.1.1.1` | Works | Rule 18 counter |
| 19 | Mgmt → internet | From Mgmt `10.10.0.x`: `ping 1.1.1.1` | Works | Rule 19 counter |

Negative test (the deny that makes it segmentation) — **rule 20, the one everyone skips:**

| # | Rule | Concrete test | Expected | Confirm |
|---|---|---|---|---|
| 20 | **drop** everything else east-west (`EAST-WEST-DENIED:`) | From Servers `10.20.0.x`: `nc -vz 10.50.0.x 443` (Servers→Client is **not** permitted) | **Refused/timeout** | Rule 20 counter moves; **`EAST-WEST-DENIED`** in log with a correct timestamp |

---

## 4. The denies worth testing on *this* rule set (the other half)

Because the permits are interface-scoped and there's no "allow any," several zones are more isolated than people expect. Each of these should hit **rule 20 + `EAST-WEST-DENIED`**. Testing them is what proves the isolation is real:

- **Testing (70) → any lab VLAN** — e.g. `10.70.0.x → 10.20.0.x`. Must be **denied** (only rule 16, internet, is permitted). This is *the* VLAN-70 isolation proof. (`10.70.0.x → internet` should still work — rule 16.)
- **DMZ (80) → anything** — VLAN 80 has **no** forward permit as a source, not even to the internet (there's no `in=vlan80 out=ether1`). So `10.80.0.x → 1.1.1.1` and `10.80.0.x → 10.20.0.x` both **denied**. DMZ is reachable only *by* Mgmt/Monitoring (rules 9/10).
- **Web (30) → internet** and **Deployment (60) → internet** — denied (they only have `out=vlan20-servers`, no internet rule).
- **Monitoring (40) → internet** — denied (rule 10 is VLANs only, no `out=ether1`).
- **Servers (20) → any other VLAN** (e.g. `10.20.0.x → 10.50.0.x`) — denied; Servers only get `out=ether1` (rule 11).
- **Client (50) → Web/Deploy/Mgmt/DMZ** — denied; Clients only reach Servers (12) and internet (13).
- **Any VLAN → Monitoring (40)** initiating inbound — denied. Monitoring initiates *out* (rule 10); nothing initiates *back* (proves the `poll` direction).
- **Reverse of any permit** — e.g. `10.20.0.x → 10.50.0.x` (reverse of Clients→Servers). Denied, because rule 12 only permits `in=vlan50 out=vlan20`. Good directionality proof.

For each: run it, confirm **refused**, and confirm the **`EAST-WEST-DENIED`** log line appears with a right timestamp (needs synced clocks — MKT01 is synced; SW01 is not, `CM-0030`, but MKT01's own log timestamp is fine here).

---

## 5. Gotchas specific to this rule set

- **Counters, not guesses.** Reset counters before each test; watch the one index. First-match-wins + disjoint interfaces means the counter names the matching rule unambiguously.
- **Accept rules don't log.** Only the six drop rules do. Don't wait for a log line on rules 9–19 — use the counter.
- **`established,related` (0/7) eat most packets.** The specific accept rule only counts the first packet(s) of a new connection. Open a *fresh* connection to see it move; reset counters to make the `+1` obvious.
- **Router SSH from a VLAN is a service-ACL test, not a firewall test** (see the callout in §2). Firewall rule 5 accepts the packet; `/ip service` `address=` is what refuses non-mgmt sources. Check both.
- **VLAN 70 and 999 are not in the `VLANs` interface list.** That's the mechanism behind Testing's isolation (rules 5, 9, 10, 17 all key off `in/out-list=VLANs`, which excludes 70). Confirm `/interface list member print` shows 70 absent.
- **Home-LAN test (rule 6) may be intercepted at FGT01.** If `172.16.0.2` is unreachable from the home network for a different reason, rule 6's counter won't move — note it rather than calling it a pass (`015`: a test that can't succeed proves nothing).
- **No NAT east-west** — confirm `/ip firewall nat print` is empty (Build-Record v2.9 says it is). If a masquerade appears, inter-VLAN source IPs would be hidden and your logs would lie.
- **bridgeLocal rules (4, 17, 18) are the recovery-network rules** — they won't carry into Lab-02 (`ADR-0013`), but they're live now, so test them now as part of pre-teardown capture.

---

## 6. Evidence capture (do this before teardown)

Reset counters, run the battery, and save the proof — it's one-shot once you wipe:

```
/ip firewall filter reset-counters [find]
# ... run the tests ...
/ip firewall filter print stats                 # every permit rule should be non-zero; note any zero (dead/unused)
/log print where message~"DENIED"               # capture the EAST-WEST-DENIED / INPUT-DENIED lines
```

| Rule # | Test run | Expected | Result | Counter moved? | Log seen? | Date |
|---|---|---|---|---|---|---|

**Acceptance:** every permit rule (9–19) shows a **non-zero** counter after its positive test; rule 20 fires on a representative denied inter-VLAN flow **and** logs `EAST-WEST-DENIED`; rule 21 fires on the VLAN-70→router test **and** logs `INPUT-DENIED`; the service ACL refuses management from a non-mgmt VLAN; `/ip firewall nat print` is empty. A permit rule that stays **zero** after its test is a dead or misscoped rule — investigate before you tear down (it may be a documentation truth you'd otherwise lose).

> This battery is also your Network+ 5.0 troubleshooting evidence and a pre-teardown capture (CompTIA catalogue Tier-1 #3): the live rule behavior — including the interface-scoped quirks and the service-ACL-vs-firewall distinction — disappears the moment MKT01 is rebuilt as the Lab-02 east-west firewall.
