---
Title: MKT01 East-West Firewall — Rebuild & Per-Rule Verification Plan
Path (suggested): Labs/Lab-02-Cisco-Core/Devices/MKT01-East-West-Firewall/
Status: Target Design — verification method + procedure. You write the config (Charter Rule 17); this tells you how to prove each rule does what the matrix says.
Author: drafted with Claude (Cowork), reconciled to the Allowed-Flows Matrix, Firewall-Architecture §3/§4/§6, ADR-0023, the MKT01 build checklist, ADR-0013, and 015 Validation Guide
Date: 2026-07-20
Scope: MKT01 (RouterOS 7.x, RB1100AHx4) as the Lab-02 internal east-west segmentation firewall + inter-VLAN gateway. The legacy flat 10.0.0.0/24 (bridgeLocal) rules are NOT carried into Lab-02 — see §6.
---

# MKT01 East-West Firewall — Rebuild & Per-Rule Verification Plan

> 🧭 **Which MKT01 firewall doc is which (`POL-0008` — no overlap; each owns one job).** Three docs touch the MKT01 firewall and they are complementary, not duplicate:
> - **`Build-Guide.md`** — the *networking* build (VLAN gateways, 802.1Q trunk, OSPF, input-chain protection). The forward-chain east-west **policy is deliberately deferred out of it** to the two docs below.
> - **`Incremental-East-West-Firewall-Build-Worksheet.md`** — the **build sequence** for Phase 7: scaffold → one scoped permit per zone (tested) → shrink-the-catch-all cutover.
> - **THIS doc** — the **per-rule verification method** the worksheet calls at each step (positive + complement-deny + directionality), plus the full reachability Game Day (§5). *The worksheet builds; this proves.* Both render the same source of truth — the **Allowed-Flows Matrix**.

## The problem this solves

You have the design (the Allowed-Flows Matrix) and the method (Firewall-Arch §6). What's missing is the bridge between them: **a repeatable procedure that proves each individual rule does exactly what the matrix says — and, harder, that everything else is denied and logged.** Testing that permits *work* is the easy half everyone does. The half that makes this a real segmentation firewall is testing that the *denies deny* — and that they deny *loudly* (logged, timestamped). This plan is built around that.

Guiding rule, from `015` and `016`: **a command that returns no error is not a confirmed change, and a test that cannot succeed proves nothing when it fails.** Every check below reads state back off the device and proves the positive case before trusting a negative.

---

## 1. Where each rule lives (so "verify each rule" is well-defined)

MKT01 is not an edge router; its chains map to two different jobs (`build checklist` §"Three ways MKT01 is NOT a normal edge"):

- **`forward` chain = the east-west policy.** This *is* the Allowed-Flows Matrix rendered as rules. This is what "verify each rule" mostly means.
- **`input` chain = the management plane.** Protects the router itself: accept established/related, drop invalid, permit SSH/WinBox **only from Management (10.10.0.0/27)**, drop the rest. Verified separately (§5).
- **`nat` = must be empty east-west.** No masquerade/src-nat between VLANs (real source IPs for policy + logs). A standing check, not a rule to test positively.

"Each rule" = each **forward-chain rule**, which corresponds one-to-one with a **row in the Allowed-Flows Matrix** (flows 1–13), plus the two catch-all drops. Verifying a rule = proving its matrix row, in both the permit and the complementary-deny direction.

---

## 2. Gates — true before you write forward-rule #1 or trust a single deny

These are prerequisites, not nice-to-haves. Skipping them makes the verification results uninterpretable or locks you out.

| # | Gate | Why | Verify |
|---|---|---|---|
| 1 | 🔴 **Out-of-band console recovery tested** (FTDI cable, `ADR-0016`) | MKT01 becomes the gateway for the whole interior. One bad `forward` rule with no console = total lockout. Gates the Phase-7 default-deny specifically. | Reach the router over serial and log in, **before** the deny goes in. |
| 2 | 🔴 **Clocks synced** (`ADR-0020`); **SW01 clock fixed** (`CM-0030`) | A deny log with a wrong timestamp is near-useless, and correlation across devices breaks. The deny-log test (§4) is invalid without synced clocks. | `/system clock print` reads correct time; `show ntp status` = `Clock is synchronized` on SW01 (a `*` peer in `show ntp associations`). |
| 3 | **Deny logging has a destination** — MON01 syslog up, or local logging acknowledged as interim | Denies are the security signal; a firewall that logs only to itself loses them when it matters. | A test deny appears in `/log print` locally and (once MON01 exists) at the collector. |
| 4 | **Allowed-Flows Matrix filled and tightened** — every 🟡 whole-zone permit scoped to a service; every 🔴 justified to one host+port or deleted | You can't verify a rule whose intent is "all." The matrix is the spec the tests check against. | Read every row in English; no row says "all" without a written reason. |
| 5 | **Management access that the default-deny won't sever** | You configure MKT01 from Management (10); confirm the input-chain permit and your session survive the forward-chain deny going in. | A second SSH session from 10.10.0.0/27 stays up as you apply forward rules. |
| 6 | **No east-west NAT; no fasttrack on inspected flows** | NAT east-west destroys source identity; fasttrack lets established inter-VLAN flows skip inspection **and logging**. | `/ip firewall nat print` empty for inter-VLAN; no `fasttrack-connection` rule matching east-west traffic. |

---

## 3. The rebuild approach — permissive → default-deny, one proven flow at a time

Per the build checklist and Firewall-Arch §4:

1. **Bring-up (Master-Build-Order Phase 2): forward chain PERMISSIVE**, commented `TEMPORARY — tighten in Phase 7`, so the network comes up and you can generate every flow.
2. **Baseline the real traffic** — turn on logging (or NetFlow) and watch a period of normal operation, so the matrix's `Evidence` column is filled from what actually flows, not guesses (matrix "How to use" #3).
3. **Phase 7: render the matrix as forward rules — default-deny + log, service-scoped**, Tier-0 (Identity) and OT (90) micro-zones tightest. Optional but blessed: **phase it** — enforce default-deny on the crown-jewel zones first (Servers/Identity/OT — the Option-C shape from `ADR-0023`), prove them, then expand default-deny to all segments.
4. **After each rule (or small batch), run its per-rule verification (§4) before moving on.** Don't write the whole policy then test at the end — a shadowed or misscoped rule is far cheaper to find one at a time.

> The failure to design against, above all others (Firewall-Arch §4): making it work by allowing everything and never tightening. Start denied; open one *proven* flow at a time.

---

## 4. Per-rule verification — the core procedure

Run this **for every forward rule** (= every matrix flow). Five steps; all five are required for a rule to count as verified.

### Step 1 — Read it in English
State aloud what the rule permits: source zone → dest zone, service/port, initiating direction, and the reason. If you can't, you don't know your policy (Firewall-Arch §6.2). Example: *"Flow 3: Clients (50) may initiate to Servers (20) on 443 and the app port, for user app access — nothing else."*

### Step 2 — Positive test (the permit works)
From a host **in the source zone**, generate the **exact** permitted service to the **exact** destination, and prove three things:

- **The traffic succeeds** (host-side): `nc -vz <dst> 443`, `Test-NetConnection <dst> -Port 443`, `curl`, `dig @<dns> …`, `ldapsearch`/`ldp.exe` for LDAPS, `iperf3` for a throughput flow. Use the *real* protocol — an ICMP ping proves the host answers ICMP, nothing about 443 (`015`).
- **The permit rule matched** (device-side): `/ip firewall filter print stats` — that rule's `bytes`/`packets` counter incremented for this test. Config intent ≠ runtime reality; the counter is the runtime proof (Firewall-Arch §6.1).
- **The connection is stateful** (device-side): `/ip firewall connection print where dst-address~"<dst>"` shows the live tracked connection.

### Step 3 — Scope test (the complement is denied)
From the **same source host**, attempt something the rule should **not** cover — an adjacent port, or a different destination in the same zone. Prove it's **refused, not silently working**:

- Host-side: a **timeout/refused** (not a hang you assume). Beware the `015` traps — `nc -u -z` reports UDP "success" even when blocked; prove UDP denies another way (no reply + a logged drop).
- Device-side: the **drop rule** counter incremented, and a **logged `EAST-WEST-DENIED` entry** appears (`/log print where topics~"firewall"`) with a **correct timestamp** (Gate #2).

This is what turns "Clients→Servers works" into "Clients→Servers **on 443 only** works" — the difference between a rule and a hole with a comment.

### Step 4 — Directionality / stateful return
The matrix specifies the **initiating** direction. Prove it:

- **Return traffic works without a second rule** — the reply to the permitted flow comes back via established/related (that's stateful inspection doing its job).
- **The reverse initiation is denied** — from the *destination* host, initiate a *new* connection back into the source zone (a flow the matrix doesn't permit); confirm it's dropped + logged. This proves `poll`/`auth`/`init-from` semantics (e.g. Monitoring initiates to agents; **nothing initiates back into MON** — flow 2).

### Step 5 — Record it
One row in the results table (§8): rule #, matrix flow, expected, actual (pass/fail), counter delta seen, deny-log line + timestamp, date. A rule with no recorded positive **and** complement-deny result is unverified.

> **A firewall rule whose deny has never been tested is a hope, not a control** (Firewall-Arch §6). Steps 3–4 are the ones that make it a control.

---

## 5. The deny matrix — the reachability Game Day (the half everyone skips)

Per-rule testing proves the *listed* flows. This proves **everything else is denied** — the actual point of segmentation (`ADR-0011` reachability Game Day; matrix "Verification plan" #3).

Build the full grid: **every source zone × every destination zone**. Each cell is either a matrix flow (already covered in §4) or **DENY**. For every DENY cell, from a host in the source zone attempt a representative service in the destination and confirm **refused + logged**.

| From ↓ \ To → | MGMT | IDENT(T0) | SRV | WEB | CLI | MON | DEPL | DMZ | OT(90) | UNTRUST |
|---|---|---|---|---|---|---|---|---|---|---|
| **MGMT** | — | mgmt✓ | mgmt✓ | mgmt✓ | mgmt✓ | mgmt✓ | mgmt✓ | mgmt✓ | mgmt✓ | (N-S/FGT) |
| **IDENT** | DENY | — | DENY | DENY | DENY | DENY | DENY | DENY | DENY | DENY |
| **SRV** | DENY | auth✓ | — | DENY | DENY | DENY | DENY | DENY | DENY | 80/443/53✓ |
| **WEB** | DENY | auth✓ | app-port✓ | — | DENY | DENY | DENY | DENY | DENY | DENY |
| **CLI** | DENY | auth✓ | 443/app✓ | DENY | — | DENY | DENY | DENY | DENY | 80/443/53✓ |
| **MON** | poll✓ | poll✓ | poll✓ | poll✓ | poll✓ | — | poll✓ | poll✓ | poll(read-only)✓ | DENY |
| **DEPL** | DENY | DENY | pxe/img✓ | DENY | DENY | DENY | — | DENY | DENY | DENY |
| **DMZ** | DENY | DENY | 🔴1 host/port? | DENY | DENY | DENY | DENY | — | DENY | reply-only |
| **OT(90)** | DENY | DENY | DENY | DENY | DENY | DENY | DENY | DENY | — | DENY |
| **TEST(70)** | DENY | DENY | DENY | DENY | DENY | DENY | DENY | DENY | DENY | 80/443✓ |

✓ = a permitted flow (verify positive per §4). Every **DENY** cell = pick a service, attempt it from the source zone, confirm refused + `EAST-WEST-DENIED` logged. **OT (90) is the strictest zone: DENY both ways in every cell** except the single named IT→OT conduit (flow 11, if built) and Monitoring's read-only poll (flow 13). **Identity (T0) is reached only by `auth` (LDAPS/Kerberos/DNS) and initiates nothing inbound.**

> Isolation you didn't test is isolation you don't have. A DENY cell you didn't attempt is an assumption, not a control.

---

## 6. Legacy flat 10.0.0.0/24 — explicitly NOT carried forward

Per your constraint and `ADR-0013`: the flat `10.0.0.0/24` **is** `bridgeLocal` (MKT01's old "Legacy flat management" recovery net) — one object, not a separate dead network. In Lab-02 it is **not recreated**; recovery is the **console break-glass** path (FTDI, `ADR-0016`), which is Gate #1 above. So:

- **No forward or input rule references `10.0.0.0/24`, `10.0.0.0/8`, or `bridgeLocal`.** Verify by counting to zero, not by eyeballing: search the exported ruleset for `10.0.0.` → **zero hits** (Charter Rule 16 — prove removal by counting the old string to 0, don't trust that a redaction was appended).
- **No `bridgeLocal` interface / address on the box** — `/ip address print` and `/interface bridge print` show it absent (or, if the hardware bridge lingers, with no `10.0.0.1/24` and no routed path).
- **Add one explicit negative test:** source a packet from a `10.0.0.x` address (or toward it) and confirm it is **denied + logged**, not silently accepted by a leftover permit. A retired network that still has a permit is a hole with history.
- **Reconcile the guides** that still tell a reader to use `bridgeLocal` for recovery (`026`, `048`, `003`) so a rebuild doesn't recreate it (`ADR-0013` execution step 3). The Lab-02 build simply never adds it.

*(Distinct from FGT01's north-south `10.0.0.0/8` return route — that's a perimeter routing concern, not an east-west MKT01 rule. Don't confuse the two.)*

---

## 7. Standing structural checks (ordering, NAT, path, bypass)

Beyond individual rules, verify the policy *as a whole*:

- **Ordering / no shadowing.** RouterOS evaluates top-down, first match wins. Confirm every specific permit sits **above** the catch-all drops; the two drops (inter-segment default-deny + final) are **last**. A broad permit above a specific deny silently wins (Firewall-Arch §3.2).
- **No dead / misscoped permits.** After a full §4+§5 pass, **every permit rule must have a non-zero counter** (`/ip firewall filter print stats`). A zero-counter permit means that flow never happened — a dead rule, or scoped so it never matches. Investigate each.
- **NAT empty east-west.** `/ip firewall nat print` — nothing matches inter-VLAN traffic (§2 Gate 6).
- **No fasttrack on inspected flows.** Confirm inter-VLAN flows are not fast-tracked (they'd skip inspection *and* logging). Fasttrack for the router's own management is fine; the east-west policy flows are not.
- **The path actually crosses MKT01 (anti-"paper segmentation").** Under `ADR-0023` Option B, MKT01 *is* the inter-VLAN gateway, so it's in-path by construction — but **confirm, don't assume**: the rule counters incrementing (§4) is one proof; the **SW01 Gi1/0/5 SPAN → Suricata/Wireshark** is the independent oracle — watch what's *actually* crossing between segments, separate from what the policy claims. If a flow you denied shows up on the SPAN as delivered, you have a bypass path.
- **`print detail` / `print stats`, never plain `print`** (`016`/`026`) — plain `print` hid a dynamic row once and was misread. Read the real state.

---

## 8. Evidence capture & acceptance

Record results in a per-rule table (matches the Device-Verification-Procedure template; keep a `tee`'d log — empty output is not a pass):

| Rule # | Matrix flow | Src→Dst : service | Positive (pass/fail, counter) | Complement-deny (refused + logged?) | Return/direction | Timestamp OK? | Date |
|---|---|---|---|---|---|---|---|

**Acceptance — the E-W firewall is verified when:**

- [ ] Every forward rule has a recorded **positive pass** and a recorded **complement-deny** (refused + `EAST-WEST-DENIED` logged, correct timestamp).
- [ ] The **full deny matrix** (§5) has been run end-to-end; every DENY cell attempted and confirmed refused + logged.
- [ ] **Every permit rule shows a non-zero counter**; no dead rules; ordering has no shadowing.
- [ ] `/ip firewall nat print` **empty east-west**; no fasttrack on inspected flows.
- [ ] **Legacy `10.0.0.` count = 0** in the ruleset; bridgeLocal absent; a legacy-range packet is denied + logged.
- [ ] **Recovery path proven** (console) *before* the default-deny went live.
- [ ] Independent **SPAN capture** agrees with the policy — nothing denied is crossing.

---

## 9. Failure modes specific to this build

- 🔴 **Default-deny with no tested console** → lockout of the box the whole interior depends on. Gate #1 is non-negotiable.
- 🔴 **Untrustworthy deny logs** (SW01/clock skew) → your negative tests are uninterpretable (Gate #2; `CM-0030`).
- 🔴 **Asymmetric path / paper segmentation** → stateful drops of legit return traffic, or a denied flow crossing anyway. Option B avoids the classic case, but confirm via counters + SPAN (§7).
- 🔴 **Fasttrack / east-west NAT** → flows skip inspection/logging, or lose source identity. Standing checks (§2, §7).
- 🔴 **`nc -u -z` false pass on UDP; ICMP success mistaken for service reachability** → prove the positive with the real protocol; don't trust connectionless "success" (`015`).
- 🔴 **Leftover legacy permit** → a retired network silently reachable. §6 count-to-zero + explicit deny test.
- **Reading `print` not `print detail`/`print stats`** → misread runtime state (`016`/`026`).

---

## Reconciliation / related

- **Allowed-Flows Matrix** — the spec these tests check against (fill `Reason`/`Evidence`, tighten every 🟡, resolve every 🔴 *before* Phase 7).
- **Firewall-Architecture §3.6 / §4 / §6** — the method this operationalizes. **ADR-0023** — the Option-B topology (MKT01 = gateway + filter; symmetric by construction). **MKT01 build checklist** — the config steps (you write them, Rule 17).
- **ADR-0013 / ADR-0016** — legacy bridgeLocal retirement + console recovery. **015 Validation Guide** — the read-back and negative-result discipline. **CM-0030 / ADR-0020** — clocks. **POL-0005** — this verification pass is a restore/recovery-adjacent Game Day; log the result there too.
- This plan is **verification methodology**, not the ruleset — per Charter Rule 17 you write the forward rules; this proves each one does what the matrix says.
