---
Title: Playbook — Port Already In Use (find the owner, pick a free port)
Path: Atlas-Academy/Playbooks
Status: 🟡 Method authored, lab-unverified (`POL-0001`) — the commands are real; per-host read-backs are 🟡 until pasted.
Version: 1.2
Date: 2026-07-31
---

# Playbook — Port Already In Use

<!-- provenance -->
> **Book 9 — Atlas Academy · Playbook (`ADR-0053`).** Kind: problem. **A service won't start because its port is already taken ("address already in use") — find what owns the port, decide who should keep it, and pick a conflict-free port for the other one.**

## Symptoms / when you'd use this

- A daemon fails to start with `bind: address already in use` / `EADDRINUSE` (Linux).
- A Windows service fails with `Only one usage of each socket address is normally permitted`.
- Or: you're **assigning a port to a new service** and want to confirm it's free *before* it collides.

## Cert anchor

CompTIA **Linux+** (processes, services, sockets, troubleshooting) · CCNA 4.0 IP Services (ports/services) · CompTIA A+/Network+ (ports). *(Grounding index: the Linux+ track — `../Academy-Vision-and-Scope.md`; CCNA map §4.)*

## Grounded in

The real Atlas hosts that run several services on one box — **Pi01** (Pi-hole 53 + chrony 123), **SRV01** (nginx-CRL 80/443 · Oxidized · rsyslog 514 · TFTP/SFTP), **NETBOX01** (NetBox 8000 · PostgreSQL 5432 · Redis 6379), **BKP01**, **PVE01** (8006) — plus any Windows member server.

Each device's **Services map** (its README, Standard v1.7) records *which service is supposed to own which port* — that's the tie-breaker in step 3.

## ① Pin it down (capture these first — they're the ticket)

- a. **The exact port + protocol** from the bind error (e.g. TCP 8080).
- b. **Which service** is failing to bind, on **which host**.
- c. **Scope** — one host, or the same port clashing across several?
- d. **Recent change** — a new service, a config edit, or a reboot that started something extra?

## Diagnosis path

Each step links **down** to the Command-Library for the full entry (`POL-0008`); **never invent output** (`POL-0001`).

**1. Find what's listening on it.**

- **Linux:**
  - a. `sudo ss -tulpn | grep :<port>` — the modern tool; shows the PID/process
  - b. or `sudo lsof -i :<port>`
  - c. then `systemctl status <unit>` — the owning service
  - Reference: `../Command-Library/Linux.md` §Services
  - Healthy (free): no row for the port
  - Taken: one row → the `users:(("proc",pid=N,...))` field is your culprit
- **Windows:**
  - a. `Get-NetTCPConnection -LocalPort <port> | Select LocalAddress,State,OwningProcess`
  - b. `Get-Process -Id <pid>` — resolve the PID to a process
  - c. or `netstat -ano | findstr :<port>`
  - Reference: `../Command-Library/PowerShell-Tier0.md` §Networking

**2. Decide who should own the port.**

Cross-check the host's **Services map** (its README) + the estate's assignments (`Architecture/IP-Addressing-Plan-VLSM`, and NetBox as it comes online). Two cases:

- The **existing** listener is the legitimate owner (it's in the Services map) → the **new** service must move → step 4.
- The listener is a **stray / duplicate** (not in the Services map — e.g. a leftover test process) → stop and disable it (`systemctl stop <unit>` / `systemctl disable <unit>`, or end the Windows process), re-check step 2. That may be the whole fix.

**3. Pick a conflict-free port** (when the new service must move).

- Choose one that is **not** well-known (avoid 0–1023 unless intended).
- Choose one **not already assigned** to another Atlas service (check the Services maps + IP plan).
- Update the service's config to the new port.
- Update the **device's Services map** — the port is a fact it owns (`POL-0008`).
- Open any firewall rule the new port needs (E-W matrix / host firewall).

**4. Record it** *(built devices only).*

- Log the change as a `CM-####`.

## Prove it's fixed

- Restart the service.
- Re-check it's now **listening on the intended port** and nothing else is:
  - Linux: `sudo ss -tulpn | grep :<port>` — exactly one listener, the right process.
  - Windows: `Get-NetTCPConnection -LocalPort <port>`.
- Run a `Test-a-Connection` check from a client.
- Mark ✅ only with the pasted read-back.

## If still broken

- It binds but clients still can't reach it → not a port-ownership problem; it's connectivity/policy → `Trace-a-Blocked-Flow.md` + the Command-Library "No / partial connectivity" index.

## Related

- Command-Library: `../Command-Library/Linux.md` (§Services / §Networking — `ss`/`lsof`/`systemctl`) · `../Command-Library/PowerShell-Tier0.md` (§Networking).
- Owners: the host's **Services map** (its `Devices/*/README.md`) · `Architecture/IP-Addressing-Plan-VLSM` (port/address owner).
- Sibling playbooks: `Test-a-Connection.md` · `Read-the-Logs-with-journalctl.md` (the service's `journalctl -u <unit>` tells you *why* it couldn't bind).

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.2 | 2026-07-31 | Added the **① Pin it down** opener (`ADR-0053` §5 template); folded the old "confirm the port" step into it and renumbered the diagnosis path. |
| 1.1 | 2026-07-31 | **Reformatted for readability** (operator) — compound bullets broken into one-idea-per-line sub-lists (`a/b/c` for command sequences; Healthy/Broken and the Command-Library reference each on their own line). No method change. Fixed the Command-Library section name to §Services/§Networking. |
| 1.0 | 2026-07-31 | Created (`ADR-0053`, second Playbook sample). Find-the-owner-then-pick-a-free-port method across Linux (`ss`/`lsof`/`systemctl`) + Windows (`Get-NetTCPConnection`), tie-broken by each host's Services map. 🟡 — commands real, per-host read-backs pending. |
