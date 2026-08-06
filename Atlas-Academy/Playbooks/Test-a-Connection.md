---
Title: Playbook — Test a Connection (and know what each test proves)
Path: Atlas-Academy/Playbooks
Status: 🟡 Method authored, lab-unverified (`POL-0001`) — the tests are real; per-host read-backs are 🟡 until pasted.
Version: 1.1
Date: 2026-07-31
---

# Playbook — Test a Connection

<!-- provenance -->
> **Book 9 — Atlas Academy · Playbook (`ADR-0053`).** Kind: problem. **You need to know whether A can reach B — and, just as important, what a passing or failing test *actually proves*.** The wrong test gives a confident wrong answer (a ping "succeeds" while the service is dead).

## Symptoms / when you'd use this
"Is it reachable?" — before *and* during troubleshooting: confirming a new service is reachable, or isolating where a failing path dies. This is the test the other playbooks call ("re-run the connection test").

## Cert anchor
CCNA 4.0 IP Services + 1.0 Fundamentals (TCP/UDP) · CompTIA **Linux+** / Network+ (connectivity tools). *(Grounding index: `../Atlas-Certification-Lab-Map.md` §1/§4.)*

## Grounded in
Every Atlas host. The command detail lives in the Command-Library (link down, don't retype — `POL-0008`): `../Command-Library/Linux.md` §Networking · `../Command-Library/Cisco-IOS.md` §Connectivity · `../Command-Library/PowerShell-Tier0.md` §Networking · RouterOS/FortiOS §Connectivity.

## ① Pin it down (capture these first — they're the ticket)

- a. **From → to** — the source host and the target (`source → dest`).
- b. **The real port/proto** you actually need open (443? 636? 53/udp?) — not just "is it up."
- c. **Expected result** — what a success looks like for *this* service.
- d. **From where** — which host/VLAN you're testing from (a firewall may allow it from one VLAN and not another).

## The ladder — test low, climb up; each rung proves one thing
Run in order; **stop at the first rung that fails — that's where the problem is.** Each rung: the test → what a pass proves → what it does **not** prove.

| # | Rung | Test (see Command-Library for the full entry) | A pass proves | A pass does **NOT** prove |
|---|---|---|---|---|
| 1 | **L2/link** | Linux `ip -br link`/`ethtool`; IOS `show interfaces status` | the cable/port is up at the right speed/duplex | anything above L2 |
| 2 | **L3 to the gateway** | `ping <gateway>` | you can reach your **own** gateway (L3 on your subnet) | you can leave the subnet |
| 3 | **L3 to the destination** | `ping <dst>` ; `mtr <dst>` / IOS `traceroute` | ICMP reaches the host **and it answers ICMP** | 🔴 that **any TCP/UDP service** is open (see the trap) |
| 4 | **L4 — the real port** | Linux `nc -vz <dst> <port>` ; Windows `Test-NetConnection <dst> -Port <n>` ; IOS `telnet <dst> <port>` (crude) | the **specific** TCP port is open end-to-end (firewall + listener) | the app-layer answer is correct |
| 5 | **L7 — the service** | `curl -I https://<dst>` ; `dig @<resolver> <name>` ; `getent hosts <name>` | the service actually responds (HTTP 200, DNS ANSWER) | — (this is the real answer) |

> 🔴 **The trap (`015`).** A successful **`ping` proves ICMP only — not that port 443/636/whatever is open.** A host can answer ICMP while the service is down or a firewall blocks the port. **Always finish at rung 4/5 on the *real* protocol.** ICMP may even be blocked while the service is fine — so a *failed* ping isn't proof of a dead service either.

## Reading the result
- **Fails at rung 2** → local L3 / VLAN / gateway problem (not the remote end). → the device's `Diagnostics.md`.
- **Fails at rung 3 but the port later opens** → ICMP is filtered; not a real fault. Note it and move on.
- **Rung 3 passes, rung 4 fails** → the host is up but the **port** is blocked or not listening → `Trace-a-Blocked-Flow.md` (is a firewall dropping it?) or `Port-Already-In-Use.md` (is the service even bound?).
- **Rung 4 passes, rung 5 fails** → network is fine; it's the **application/service** (wrong vhost, cert, auth) → the service's logs (`Read-the-Logs-with-journalctl.md`).

## If still unclear
Work the Command-Library **"No / partial connectivity" failure index** (L1→up) end to end: `../Command-Library/README.md`.

## Related
- `../Command-Library/README.md` (the by-failure-category index) · `Trace-a-Blocked-Flow.md` · `Port-Already-In-Use.md` · `Read-the-Logs-with-journalctl.md` · `Domain-Join-Fails.md` · the device `Diagnostics.md` quick-refs.
- **Checklist (reciprocal, `ADR-0053` §8):** `00-Atlas-Foundation/Templates/New-Windows-Server-Commissioning-Checklist-TEMPLATE.xlsx` — **Phase 0 "DCs reachable"** + **Phase 3 "Verify gateway reach"** use this ladder (ping ≠ service).

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.1 | 2026-07-31 | Added the **① Pin it down** opener (`ADR-0053` §5 template). |
| 1.0 | 2026-07-31 | Created (`ADR-0053`). The 5-rung test ladder (L2→L7), each rung's *proves / does-not-prove*, and the `015` ICMP≠TCP trap; routes to the sibling playbooks by which rung fails. Links down to the Command-Library. |
