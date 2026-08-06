---
Title: FGT01 — Logging & Flow-Tracing Field Guide (LIVING)
Path: Labs/Lab-02-Cisco-Core/Devices/FGT01-Perimeter-Firewall
Status: 🟢 LIVING (v0.1). FortiOS 7.4.5 on a physical **FortiGate-60E**. The operator's guide to *reading* FortiGate logs, *tracing a flow* end to end, and using what you see to *write least-privilege rules*. Companion to `Build-Guide-1-Networking.md` (Step 4 turned logging on) and the Phase-7 east-west work (rules-from-evidence).
Version: 0.1
Date: 2026-07-21
---

# FGT01 — Logging & Flow-Tracing Field Guide

> **Why this doc exists.** "Turn logging on" is one line; *using* logs is the actual skill — knowing which log a flow lands in, how to find it, how to trace a single connection across the box, and how to turn that evidence into firewall rules. This is the missing piece most people never get taught. Everything here is safe to run on a live box **as long as you follow the debug-cleanup rule** (§6).

---

## 1. The mental model — three questions, three tools

When something "doesn't work" (or you're deciding what a rule should allow), you're always answering one of three questions. Each has its own tool:

| Question | Tool | What it tells you |
|---|---|---|
| **Did it happen, and what was it?** (after the fact) | **Traffic log** (Log & Report ▸ Forward Traffic, or `execute log display`) | The record: who → who, which policy, allow/deny, bytes, NAT |
| **Is there a live connection right now?** | **Session table** (`diagnose sys session ...`) | The live state: NAT translation, which policy, state, expiry |
| **WHY did the box allow/drop this packet?** | **Debug flow** (`diagnose debug flow ...`) | The decision: route lookup, policy match, NAT, allow/deny *reason* |

A fourth, lower-level tool — the **packet sniffer** (`diagnose sniffer packet`) — answers "are the packets even arriving, and on which interface?" Use it when you suspect the traffic isn't reaching the box at all.

> Rule of thumb: **log** = history, **session** = present, **debug flow** = the "why", **sniffer** = the "is it even here". Most real troubleshooting is debug-flow + session together.

---

## 2. Where logs live (the log *types*)

FortiGate splits logs by what generated them. The two you'll use constantly:

- **Forward Traffic** — traffic *through* the box (interior → internet, and any inbound). **This is the one that drives firewall-rule design.** GUI: Log & Report ▸ Forward Traffic. Every session that matches a policy with logging on lands here; denied sessions land here too if implicit-deny logging is on (`fwpolicy-implicit-log enable`, set in Guide 1 Step 4).
- **Local Traffic** — traffic *to/from the FortiGate itself* (mgmt hits, its own DNS/NTP, etc.). GUI: Log & Report ▸ Local Traffic. Controlled by the `local-in-*`/`local-out` toggles in Log Settings.

Others you'll meet later: **Event** (System/Admin/VPN/User/Router — e.g. admin logins, config changes), and **Security** (UTM: web filter/AV/IPS — comes online with Guide 3 once FortiGuard is licensed).

**Where they're stored on this box:** the 60E has **no disk**, so logs go to **memory** (small, volatile — a reboot clears them). Durable retention arrives when we forward to **syslog/MON01** (Phase 6). Treat memory logs as "recent history," not forensics.

---

## 3. Anatomy of a Forward-Traffic log entry

A single forwarded session, decoded. (Fields vary; these are the ones that matter.)

```
date=2026-07-21 time=14:03:11 type="traffic" subtype="forward"
srcip=10.10.0.20 srcport=52344 srcintf="internal1"
dstip=1.1.1.1   dstport=443    dstintf="wan1"
policyid=1 poluuid=... action="accept" service="HTTPS" proto=6
transip=172.31.4.37 transport=52344         ← the SNAT: what the internet sees
sentbyte=5120 rcvdbyte=44210 duration=32 sessionid=98213
```

Read it left to right as a story: **who** (`srcip`/`srcintf`) → **to whom** (`dstip:dstport`/`dstintf`) → **which rule caught it** (`policyid`) → **verdict** (`action`) → **how it was translated** (`transip`) → **how much/how long** (`sentbyte`/`duration`).

The three fields you'll live on:

- **`policyid`** — *which firewall policy matched.* This is the link between a log line and a rule. **`policyid=0` means the implicit deny** — nothing you wrote matched, so the box dropped it. (This is why naming policies clearly pays off: readable logs.)
- **`action`** — the verdict. Common values:
  - `accept` — allowed (a session-close/`close` also appears when it ends).
  - `deny` — blocked by a deny rule or the implicit deny.
  - `start` — session opened (seen when you log at session start).
  - `close` / `timeout` — how the session ended (normal close vs idle-aged-out).
  - `client-rst` / `server-rst` — one side sent TCP RST.
- **`transip` / `transport`** — the **source-NAT** result. On a perimeter box this is what the outside world sees your interior host as. If NAT is misconfigured, this field is where you'll see it.

---

## 4. Finding a specific log (the "identify" skill)

**GUI (fastest for eyeballing):** Log & Report ▸ Forward Traffic. Use the **filter bar** — click a column value to filter by it, or add filters: `Source IP = 10.10.0.20`, `Action = Deny`, `Destination Port = 443`. Set the time range. Toggle **Details** to see all fields of one entry.

**CLI (scriptable, works over SSH/console):**
```
execute log filter category traffic       # forward/local traffic logs
execute log filter field srcip 10.10.0.20 # narrow to one source
execute log filter field action deny      # only denies
execute log display                       # print the matches
execute log filter reset                  # clear filters when done
```
Explore fields with `execute log filter field ?`. To pull the raw memory buffer quickly: `execute log display` after setting the category.

> **Tip:** to answer "is this host being blocked?", filter `srcip=<host>` + `action=deny` and read the `policyid`. `policyid=0` → no rule allows it (you need to add one, or it's correctly denied). A non-zero `policyid` on a deny → an explicit deny rule caught it.

---

## 5. Tracing a flow end to end (the session table)

The log tells you what *happened*; the session table shows what's *live right now* — including the NAT translation and which policy owns it.

```
diagnose sys session filter clear
diagnose sys session filter src 10.10.0.20     # the interior host
diagnose sys session filter dst 1.1.1.1         # the destination
diagnose sys session filter dport 443           # optional: narrow to a port
diagnose sys session list                       # show matching sessions
```

In the output, the fields that matter:
- `state=` (e.g. `may_dirty`, `redir`) and the proto state line — is the session established?
- `policy_id=` — **which policy is carrying this flow** (matches the log's `policyid`).
- `hook=post dir=org act=snat` with `10.10.0.20:52344->1.1.1.1:443(172.31.4.37:52344)` — the **NAT translation** in the arrow: original `->` destination `(translated source)`.
- `expire=` — seconds until it ages out.

Clear the session (to force a fresh one for testing): `diagnose sys session filter dst 1.1.1.1` then `diagnose sys session clear`. **Counts as a live change — only do it when you mean to.**

---

## 6. The "why" — debug flow (the most important tool here)

When a flow *should* work and doesn't (or you want to see exactly which policy and NAT a packet hits), `diagnose debug flow` narrates the FortiGate's decision packet-by-packet: route lookup → policy match → NAT → allow/deny **with the reason**.

```
diagnose debug reset
diagnose debug flow filter clear
diagnose debug flow filter addr 1.1.1.1        # focus on one peer (avoids a flood)
diagnose debug flow filter port 443            # optional
diagnose debug flow show function-name enable   # show the code path (very informative)
diagnose debug flow show iprope enable          # show policy evaluation
diagnose debug flow trace start 20              # capture up to 20 packets
diagnose debug enable                           # <-- output starts NOW
   ... generate the traffic (browse from the host) ...
diagnose debug disable                          # <-- 🔴 ALWAYS run this to stop
diagnose debug flow trace stop
```

What you're reading in the output:
- `vd-root received a packet ...` — the packet arrived (and on which interface).
- `find a route: ... via 172.31.4.1` / `gw-10.255.255.2` — the **routing decision** (out wan1 for internet, to the 1941 for interior).
- `Allowed by Policy-1: SNAT` — **matched policy 1, allowed, and source-NAT'd.** This is the golden line.
- `Denied by forward policy check` — hit the implicit deny (no policy allowed it). **This is your answer when a flow is blocked** — it means "write a rule" (or it's correctly denied).
- `reverse path check fail, drop` — an RPF/asymmetry problem (the box has no route back to the source — think missing return route).

> 🔴 **The one safety rule:** `diagnose debug flow` and `diagnose sniffer` print live and can flood the console and load the CPU. **Always** set a packet count (`trace start <n>`, sniffer `<count>`) and **always** run `diagnose debug disable` when done. If output runs away, `diagnose debug disable` + `diagnose debug reset` stops it.

---

## 7. Is the packet even arriving? (sniffer)

If debug flow shows *nothing*, the packet isn't reaching the box — sniff to confirm where it dies:

```
diagnose sniffer packet any 'host 10.10.0.20 and host 1.1.1.1' 4 20 l
#                            ^BPF filter                        ^ ^  ^
#                                                       verbosity | |  timestamp (l=local)
#                                                          count 20  packets
```
- verbosity `4` = print header + **interface name** (so you see it arrive on `internal1` and leave on `wan1`); `6` adds payload.
- Seeing it on `internal1` but never on `wan1` → it's being dropped *inside* the box (go back to debug flow). Not seeing it on `internal1` at all → it never arrived (problem is upstream: MKT01/1941/host routing).

---

## 8. From logs to rules — why this whole skill matters

This is the payoff, and it's the exact method Phase 7 (MKT01 east-west default-deny) uses:

1. **Run permissive, watch the logs.** With a broad allow policy + logging on, Forward Traffic shows you the *real* flows — who actually talks to whom, on which services. You're not guessing what to allow; you're reading it.
2. **Write least-privilege allow rules from that evidence.** For each legitimate flow you see (src zone → dst zone : service), write one narrow allow rule. Name it clearly so its `policyid` is readable in logs later.
3. **Flip to default-deny and verify the denies are logged.** Turn on the deny (or lean on the implicit deny), then confirm: every allowed flow still passes, every *denied* flow shows up in the log as `action=deny` with the right `policyid`. A deny you can't see in the log is a deny you can't trust.
4. **Read a deny to decide: rule or block?** When a flow is denied (`policyid=0`), the log + a quick debug flow tell you whether it's a legitimate flow you forgot to allow (add a rule) or something that *should* be blocked (leave it, and now you have the evidence it's blocked).

On FGT01 specifically (north-south): your one egress policy logs all allowed outbound; `fwpolicy-implicit-log` logs everything the internet throws at `wan1` that has no matching policy. That deny stream *is* your attack-surface visibility.

---

## 9. Practical exercises (do these on FGT01 now)

1. **Find your own browsing.** From the host (10.10.0.20), open a site. GUI ▸ Forward Traffic, filter `Source=10.10.0.20`. Open one entry, identify `policyid`, `action`, `service`, and the `transip` (your NATed address).
2. **Trace it live.** While a download runs: `diagnose sys session filter src 10.10.0.20` → `list`. Find the NAT arrow and `policy_id`.
3. **Watch the decision.** `diagnose debug flow` (filter to a test destination), generate one request, read the `find a route` + `Allowed by Policy-N: SNAT` lines. Then `diagnose debug disable`.
4. **Trigger and find a deny.** From outside (or a disallowed interior flow), hit something with no policy; filter Forward Traffic by `Action=Deny` and confirm `policyid=0`.
5. **Prove NAT.** In the same accepted log, confirm `transip` = your `wan1` address — that's what the internet sees.

---

## 10. Command cheat-sheet

```
# LOGS (history)
execute log filter category traffic
execute log filter field srcip 10.10.0.20
execute log filter field action deny
execute log display
execute log filter reset

# SESSIONS (present)
diagnose sys session filter clear
diagnose sys session filter src 10.10.0.20
diagnose sys session filter dst 1.1.1.1
diagnose sys session list
diagnose sys session clear            # (live change — flushes matched sessions)

# DEBUG FLOW (the "why")
diagnose debug reset
diagnose debug flow filter clear
diagnose debug flow filter addr <ip>
diagnose debug flow show function-name enable
diagnose debug flow show iprope enable
diagnose debug flow trace start 20
diagnose debug enable
diagnose debug disable                # 🔴 ALWAYS
diagnose debug flow trace stop

# SNIFFER (is it arriving?)
diagnose sniffer packet any 'host <ip>' 4 20 l
```

---

## 11. Gotchas

- 🔴 **Leaving debug on.** `diagnose debug enable` + a running flow trace can flood the console and spike CPU. `diagnose debug disable` (and `diagnose debug reset`) every time. Never walk away with debug enabled.
- **Memory logs are small and volatile** (60E, no disk). A reboot clears them; heavy logging rolls old entries out. Durable retention = syslog → MON01 (Phase 6).
- **Timestamps are only as good as the clock.** If NTP isn't synced, log times lie and correlation across devices breaks. (`ADR-0020`; verify with `get system status` / the device's NTP status.)
- **`policyid=0` is not a bug** — it's the implicit deny doing its job. Read it as "no rule matched," then decide rule-or-block.
- **No UTM/security logs yet** — web filter/AV/IPS logging needs FortiGuard (Guide 3). This doc is traffic/flow logging only.
- **Filter before you display.** On a busy box `execute log display` or an unfiltered sniffer is a wall of text — always narrow by src/dst/port first.

---

## Related
- `Build-Guide-1-Networking.md` (Step 4 — logging enabled: memory + `fwpolicy-implicit-log`).
- `Build-Guide-2-Hardening.md` (event/admin logging; syslog forward to MON01).
- `Master-Build-Order.md` Phase 6 (MON01/NetFlow) + Phase 7 (east-west rules **from this evidence**).
- MKT01 `Incremental-East-West-Firewall-Build-Worksheet.md` — same log→rule method, applied to inter-VLAN.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-21 | Created — operator field guide for FortiGate logging + flow tracing: the three-tool model (log/session/debug-flow) + sniffer; Forward-vs-Local log types; full Forward-Traffic field decode (policyid/action/transip); GUI + CLI log filtering; end-to-end flow trace via session table; `diagnose debug flow` as the "why" tool with the mandatory cleanup rule; sniffer for arrival; the logs→least-privilege-rules method (the Phase-7 pattern); hands-on exercises; command cheat-sheet; gotchas. Written against FGT01 (60E, FortiOS 7.4.5) with logging already live from Guide 1 Step 4. |
