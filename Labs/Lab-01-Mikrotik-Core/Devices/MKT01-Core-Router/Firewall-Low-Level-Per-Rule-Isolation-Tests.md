---
Title: MKT01 (Lab-01, current) — Low-Level Per-Rule Isolation Tests (Part 2)
Path (suggested): Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/
Status: Companion to "MKT01 Current Firewall — Per-Rule Verification Tests". Part 1 proves the flow; this proves the *specific rule*, at packet level, individually.
Date: 2026-07-20
---

# MKT01 Current Firewall — Low-Level, Individual-Rule Verification

Part 1 answered "does the permitted flow work / is the denied flow blocked." This answers the harder, lower-level question: **"is rule N specifically the thing that acted — and can I make exactly that rule fire, alone, and watch it at packet level?"**

Two ideas do all the work:

- **A per-rule match signature.** Every rule has an exact tuple — ingress interface, egress interface, protocol, port(s), connection-state — that *only it* matches (RouterOS is first-match-wins and these rules are interface-disjoint). Craft a packet with that tuple and nothing else, and exactly one rule can claim it.
- **Isolation by mirror or by removal.** Confirm which rule acted either **non-destructively** (a temporary `passthrough`/`log` mirror rule that counts the exact traffic reaching that position without changing behavior) or **destructively** (disable the rule and watch the flow change — a permit's traffic falls through to the drop; a drop's traffic starts passing). The destructive test is definitive but can lock you out — see the safety box.

---

## 🔴 Safety — MKT01 has no safe recovery path, so choose the technique per chain

`ADR-0016` / Build-Record: **MKT01 has no serial console**, and **MAC-WinBox drops after ~15 seconds**. If you disable a rule that carries your own management session, you may not get back in without a physical trip and a rebuild.

| Chain / rule | Disable-to-prove? | Use instead |
|---|---|---|
| **input 0** (established,related), **4** (bridgeLocal), **5** (VLANs→router), **21** (INPUT-DENIED) | 🔴 **NO** — disabling any of these can drop your live SSH/WinBox session to the router | `log=yes` on the rule + `passthrough` mirror + counters |
| **forward 7** (established,related) | 🔴 **NO** — breaks return traffic for every flow, including yours if you're proxying through | mirror + counters |
| **forward 9** (Mgmt→all) | ⚠️ Caution — if you manage *across* VLANs it can cut those paths, not your router session | prefer mirror; disable only if managing from the router console/WinBox directly |
| **forward 11–19** (the other permits), **forward 20** (E-W drop), **input 1/3/6, forward 8** (the other drops) | 🟢 **Yes** — safe; they don't carry your management session | disable-to-prove is fine |

> Rule of thumb: **anything in the `input` chain, plus the two `established,related` rules, is log-and-mirror only.** Everything else you may disable briefly. And do the destructive tests from a **Management (10.10.0.x)** or **bridgeLocal (10.0.0.20)** seat, whose path to the *router itself* doesn't depend on the rule you're toggling.

---

## 1. The low-level toolkit (RouterOS-native + host-side)

**On the router — measure and observe:**

```
# Per-rule counters — the primary low-level signal
/ip firewall filter reset-counters [find]
/ip firewall filter print stats                       # bytes/packets per index

# Make a specific rule announce itself (accepts don't log by default)
/ip firewall filter set <index> log=yes log-prefix="TEST-R<index>:"
/log print follow where message~"TEST-R"              # live, per-rule match lines (in/out iface, src->dst, proto, ports, len)
/ip firewall filter set <index> log=no log-prefix=""  # revert when done

# Non-destructive mirror: count/observe the exact traffic reaching a position, without changing behavior
/ip firewall filter add chain=forward action=passthrough \
    in-interface=vlan50-client out-interface=vlan20-servers \
    place-before=12 log=yes log-prefix="MIRROR-R12:"     # passthrough = count + continue
# ...run stimulus, read its counter/log, then remove it:
/ip firewall filter remove [find log-prefix="MIRROR-R12:"]

# Connection tracking — see the state machine, not just the packet
/ip firewall connection print detail where dst-address~"10.20.0"

# Live per-interface flow (rate, addresses, ports) — did it cross the VLAN interface?
/tool torch vlan20-servers src-address=10.50.0.0/24 port=any

# Actual packet bytes — quick on-router capture, or stream to Wireshark
/tool sniffer quick interface=vlan20-servers ip-address=10.50.0.10
# or stream (TZSP) to a host running Wireshark:
/tool sniffer set streaming-enabled=yes streaming-server=10.10.0.50 filter-interface=vlan20-servers
/tool sniffer start
```

**On the source host — craft the exact stimulus** (a precise packet is what makes the test "low level"):

- `hping3` — arbitrary TCP/UDP/ICMP, any flags/ports/rate, spoofed source. The workhorse.
- `nmap` — scan types that generate specific connection-states (`-sS` SYN, `-sA` ACK → `invalid`, `-sF`/`-sX`/`-sN` → out-of-state).
- `nc` / `Test-NetConnection` — simple one-shot TCP/UDP to a port.
- `scapy` — when you need to hand-build a frame.
- `ping -f` / `ping -c` — ICMP rate for the limit rules.

---

## 2. The individual-rule recipe (run this per rule)

1. **Baseline.** `/ip firewall filter reset-counters [find]`. Optionally `set <n> log=yes log-prefix="TEST-R<n>:"` on the target.
2. **Single stimulus.** From the correct source host/VLAN, emit **one** flow whose tuple matches *only* the target rule (§3 gives the exact command per rule). One connection, not a flood — so the counter delta is legible.
3. **Read the match at low level, three ways:**
   - **Counter:** target rule's `packets` incremented by the expected number (a new TCP connection = a few SYN/handshake packets on the specific accept rule; the bulk/return rides rule 0/7).
   - **Log line:** `TEST-R<n>:` shows `in:<iface> out:<iface>, proto TCP (SYN), 10.x.x.x:port->10.y.y.y:port, len …` — this is the packet-level proof of *which interfaces and tuple* matched.
   - **State/where:** `/ip firewall connection print` shows the tracked connection (for accepts); `/tool torch` shows it crossing the egress interface.
4. **Prove it was *this* rule, not a neighbor** — pick one:
   - **Mirror (safe):** the `passthrough` rule placed at the target's position counted exactly your stimulus → the traffic really arrives there with that tuple.
   - **Disable-to-prove (definitive, safe rules only per the box):** `set <n> disabled=yes`, re-run the stimulus, and confirm the **behavior changes** — a permit's flow now falls through to **rule 20 `EAST-WEST-DENIED`** (or 21 `INPUT-DENIED`); a drop's traffic now **passes**. `set <n> disabled=no` to restore. If disabling rule N changes the outcome and nothing else did, rule N is provably the actor.
5. **Revert** every temporary change (`log=no`, remove mirrors, `disabled=no`) and re-read `print stats` to confirm you're back to 22 rules, clean.

---

## 3. Per-rule stimulus + match signature

Source host is in the rule's `in` VLAN; router VLAN gateway is `10.N0.0.1`. "Confirm" = counter moves **and** the log/mirror shows the tuple.

### Input chain

| # | Exact stimulus (from host) | Only-this-rule tuple | Low-level confirm | Individual-isolation proof |
|---|---|---|---|---|
| 0 | Existing SSH session from `10.10.0.x` to `10.10.0.1:2222`, send data | `in:vlan10`, state=established, dst=router | Rule 0 packets climb with traffic; `/ip firewall connection print` shows the session | 🔴 mirror/log only (don't disable) |
| 1 | `nmap -sA 10.10.0.1` (ACK scan → invalid) or `hping3 -A -p 2222 10.10.0.1` | state=**invalid**, dst=router | Rule 1 counter; `DROPPED:` log shows the stray ACK | 🔴 log-only; or `-sA` then read the `DROPPED` prefix (distinguishes from rule 21's `INPUT-DENIED`) |
| 2 | `ping -c 5 10.10.0.1` | proto=icmp, within 50/s, dst=router | Rule 2 counter = echo count; torch shows icmp on vlan10 | mirror/log |
| 3 | `hping3 --flood --icmp 10.10.0.1` (or `ping -f`) | proto=icmp, **over** 50/s | Rule 3 counter climbs; `DROPPED:` log | log-only |
| 4 | From `10.0.0.20`: `hping3 -S -p 2222 -c 1 10.0.0.1` | `in:bridgeLocal`, dst=router | Rule 4 counter; log shows `in:bridgeLocal` | 🔴 don't disable |
| 5 | From `10.20.0.x`: `ping -c 1 10.20.0.1` | `in-interface-list=VLANs`, dst=router | Rule 5 counter; log shows `in:vlan20-servers` | 🔴 don't disable (it carries VLAN mgmt-plane input) — instead see the **rule-21 test**, which proves rule 5 by contrast (VLAN 70 isn't in VLANs → skips rule 5 → hits 21) |
| 6 | From a `172.31.4.0/22` home host: `hping3 -S -p 2222 -c 1 172.16.0.2` (arrives on ether1) | `src=172.31.4.0/22 in:ether1`, dst=router | Rule 6 counter; `DROPPED:` log (vs rule 21's `INPUT-DENIED` — the **prefix is how you tell them apart**) | 🟢 disable rule 6 → same packet now falls to rule 21 → log flips `DROPPED`→`INPUT-DENIED`. That prefix flip *is* the proof rule 6 (not 21) was catching it. Re-enable. *(May be blocked at FGT01 first — if the counter never moves, note it, don't call it a pass.)* |
| 21 | From `10.70.0.x` (VLAN 70 ∉ VLANs list): `nc -vz 10.70.0.1 2222` | falls past 0–6 (not established, not icmp, not in VLANs list, not bridgeLocal) | Rule 21 counter; `INPUT-DENIED:` log | 🔴 don't disable; proven by the fact rule 5 didn't catch VLAN 70 |

### Forward chain

| # | Exact stimulus (from host) | Only-this-rule tuple | Low-level confirm | Individual-isolation proof |
|---|---|---|---|---|
| 7 | Any permitted inter-VLAN flow, return direction | state=established, forward | Rule 7 carries bulk/return; conntrack shows reply | 🔴 don't disable |
| 8 | From `10.50.0.x`: `nmap -sA 10.20.0.10` (through the router) | state=invalid, forward | Rule 8 counter; `DROPPED:` | 🟢 safe to disable briefly |
| 9 | From `10.10.0.x`: `hping3 -S -p 22 -c 1 10.20.0.10` | `in:vlan10 out-list=VLANs` | Rule 9 counter; log `in:vlan10 out:vlan20` | ⚠️ disable only from the router seat (§safety) → flow falls to rule 20 |
| 10 | From `10.40.0.x`: `hping3 -S -p 161 -c 1 10.20.0.10` | `in:vlan40 out-list=VLANs` | Rule 10 counter | 🟢 disable → falls to rule 20; also test the **reverse** (`10.20→10.40`) is denied (proves the poll direction) |
| 11 | From `10.20.0.x`: `hping3 -S -p 443 -c 1 1.1.1.1` | `in:vlan20 out:ether1` | Rule 11 counter; torch on ether1 | 🟢 disable → `10.20→internet` now hits rule 20 `EAST-WEST-DENIED` |
| 12 | From `10.50.0.x`: `hping3 -S -p 443 -c 1 10.20.0.10` | `in:vlan50 out:vlan20` | Rule 12 counter; log `in:vlan50 out:vlan20` | 🟢 disable → same flow now `EAST-WEST-DENIED`. **This is the cleanest individual-rule demo.** |
| 13 | From `10.50.0.x`: `hping3 -S -p 443 -c 1 1.1.1.1` | `in:vlan50 out:ether1` | Rule 13 counter | 🟢 disable → internet from clients now denied |
| 14 | From `10.60.0.x`: `hping3 -S -p 69 -c 1 10.20.0.10` | `in:vlan60 out:vlan20` | Rule 14 counter | 🟢 disable → falls to rule 20 |
| 15 | From `10.30.0.x`: `hping3 -S -p 1433 -c 1 10.20.0.10` | `in:vlan30 out:vlan20` | Rule 15 counter | 🟢 disable → falls to rule 20 |
| 16 | From `10.70.0.x`: `hping3 -S -p 443 -c 1 1.1.1.1` | `in:vlan70 out:ether1` | Rule 16 counter | 🟢 disable → Testing loses internet too (full isolation); confirms 16 is its *only* permit |
| 17 | From `10.0.0.20`: `hping3 -S -p 22 -c 1 10.20.0.10` | `in:bridgeLocal out-list=VLANs` | Rule 17 counter | 🟢 safe |
| 18 | From `10.0.0.20`: `hping3 -S -p 443 -c 1 1.1.1.1` | `in:bridgeLocal out:ether1` | Rule 18 counter | 🟢 safe |
| 19 | From `10.10.0.x`: `hping3 -S -p 443 -c 1 1.1.1.1` | `in:vlan10 out:ether1` | Rule 19 counter | 🟢 safe |
| 20 | From `10.20.0.x`: `hping3 -S -p 443 -c 1 10.50.0.10` (Servers→Client, unpermitted) | falls past 7–19 | Rule 20 counter; `EAST-WEST-DENIED:` log with the exact `src->dst` | 🟢 disable rule 20 → the same flow now **passes** (RouterOS default-accept) — the starkest proof of what rule 20 is holding back. **Re-enable immediately.** |

---

## 4. Two techniques worth calling out

**The passthrough mirror (non-destructive, works on *any* rule incl. the unsafe ones).** Insert a counting-only twin just above the target with the identical match and `action=passthrough log=yes`:

```
/ip firewall filter add chain=input action=passthrough in-interface-list=VLANs \
    place-before=5 log=yes log-prefix="MIRROR-R5:"
```

Your stimulus hits the mirror first (counts + logs the exact tuple), then `passthrough` continues to the real rule 5 which accepts — **behavior unchanged, but you've proven the traffic reaches rule 5's position with that match.** This is how you get low-level, per-rule evidence for the input/established rules you must not disable. Remove it after.

**The prefix-flip (distinguishing two drops that look identical).** Rules 6 and 21 both *drop* a home-LAN packet to the router — same outcome. The only low-level difference is the **log prefix** (`DROPPED:` vs `INPUT-DENIED:`). Watch `/log print follow`, disable rule 6, resend: if the prefix flips to `INPUT-DENIED`, you've proven rule 6 (not 21) was the one catching it. Same trick separates rule 1 (`DROPPED` invalid) from rule 21.

---

## 5. Clean-up & acceptance

- [ ] Every temporary `log=yes`, every `MIRROR-*` passthrough, and every `disabled=yes` **reverted**. Re-run `/ip firewall filter print` and confirm **exactly 22 rules**, indices 0–21, none disabled, none with a stray `log-prefix` (`/ip firewall filter print stats` should look like the Build-Record table again).
- [ ] For each rule you have: a **counter delta**, a **captured match/log line or mirror count**, and (for the safe rules) a **disable-to-prove behavior flip**.
- [ ] `/ip firewall connection print` and `/tool torch` observations saved for the flows you sniffed.
- [ ] `/ip firewall nat print` still empty; you added nothing permanent.

> 🔴 The single most important line in this doc: **revert everything, then read the rule table back off the device.** A test harness you forget to remove is a policy change you didn't mean to make (`016`: a config left in a non-default state is a defect waiting to be discovered by the next person — here, you, mid-teardown). Leaving a `passthrough log` mirror behind also silently fills the log.

## Related

- Part 1: `MKT01 Current Firewall — Per-Rule Verification Tests` (the flow-level tests + counter/log basics).
- `015 Validation Guide` (read-back + negative-result discipline) · Build-Record §Firewall (the 22-rule source) · `ADR-0016` (no console — the reason input-chain rules are log-only).
