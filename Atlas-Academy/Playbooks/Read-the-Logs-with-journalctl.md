---
Title: Playbook — Read the Logs with journalctl (find why a Linux service misbehaved)
Path: Atlas-Academy/Playbooks
Status: 🟡 Method authored, lab-unverified (`POL-0001`) — the invocations are real; per-host read-backs are 🟡 until pasted.
Version: 1.1
Date: 2026-07-31
---

# Playbook — Read the Logs with journalctl

<!-- provenance -->
> **Book 9 — Atlas Academy · Playbook (`ADR-0053`).** Kind: problem. **A Linux service failed, restarted, or is misbehaving — read `journalctl` to find *why*, without drowning in the whole journal.** The skill is filtering: the right unit, the right time window, the right priority.

## Symptoms / when you'd use this
`systemctl status <svc>` shows `failed`/flapping; a service worked yesterday and doesn't now; you need the error a service printed as it died; or you're checking a host for auth/OOM/crash noise.

## Cert anchor
CompTIA **Linux+** (managing processes & log files) · CySA+ (log analysis). *(Grounding index: the Linux+ track — `../Academy-Vision-and-Scope.md`.)*

## Grounded in
The Atlas Linux hosts — **Pi01** (Pi-hole/chrony), **SRV01** (nginx-CRL/Oxidized/rsyslog), **MON01** (the syslog/telemetry sink), **NETBOX01/BKP01**, **PVE01**. Command detail: `../Command-Library/Linux.md` §Services + §Logging (link down, don't retype — `POL-0008`). *(rsyslog on SRV01 + MON01 is where the estate's central logging lands, Phase 6 — this playbook is the per-host journal.)*

## ① Pin it down (capture these first — they're the ticket)

- a. **Which unit + host** — the service (`<unit>`) and the box it runs on.
- b. **The symptom** — failed / flapping / a specific error / silence.
- c. **The time window** — roughly when it started (you'll filter to it).
- d. **Recent change** — a deploy, config edit, reboot, or package update?

## The method — filter, don't scroll
Each step links down to the Command-Library entry; **never invent output** (`POL-0001`).

1. **Start at the unit, not the whole journal.** `journalctl -u <svc> -e --no-pager` (`-e` jumps to the end). → Linux §Services. **Look for:** the last clean start vs the failure — the line just before the exit, plus the `code=exited, status=…` from `systemctl status`.
2. **Bound the time window** so you only see the incident: `journalctl -u <svc> --since "10 min ago"` (or `--since "2026-07-31 09:00" --until "09:15"`). Cuts weeks of history to the minutes that matter.
3. **Filter by priority** to surface only errors: `journalctl -p err -b` (this boot) across all units — the fastest "what's actually broken on this box" view. → Linux §Logging.
4. **This boot vs last boot.** `-b` = current boot; `-b -1` = the previous boot (did it fail *before* the reboot, or is this new?). `journalctl --list-boots` to see them.
5. **Follow it live** while you reproduce: `journalctl -u <svc> -f` in one pane, trigger the action in another — you see the log the instant it fails.
6. **Widen only if needed.** `journalctl -xe` (x = extra explanations) for the general tail; `journalctl -u ssh` or `/var/log/auth.log` for **auth** (brute-force / unknown source — a security signal, cross-ref CySA+). → Linux §Logging.

## What you're reading for (healthy vs broken)
- **Healthy:** a clean `Started <svc>` with no repeating errors after it. 
- **Broken, common shapes:** a config parse error at start (fix the unit/config, `systemctl daemon-reload`, restart); `Failed to bind`/`address already in use` → hand off to `Port-Already-In-Use.md`; repeated restart loops (`start-limit-hit`) → the underlying error is a few lines up; OOM-kills (`Out of memory: Killed process`) → sizing (#20); auth failures/unknown sources → escalate as a security signal.

## The fix
Fix the cause the log named (config, dependency, port, resource), then **prove it:** `systemctl restart <svc>` → `systemctl is-active <svc>` = `active (running)` and `journalctl -u <svc> -e` shows a clean start with no re-fail. Mark ✅ only with the pasted read-back.

## If still broken
The unit starts clean but the service still misbehaves → it's not a startup fault; test the path (`Test-a-Connection.md`) or trace a block (`Trace-a-Blocked-Flow.md`), and check the app's own logs (nginx `/var/log/nginx/`, etc.).

## Related
- `../Command-Library/Linux.md` (§Services `journalctl -u`; §Logging `-xe`/`-p err`/auth) · `Port-Already-In-Use.md` · `Test-a-Connection.md` · the host's `Devices/*/Troubleshooting.md` · MON01 (central syslog, Phase 6).

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.1 | 2026-07-31 | Added the **① Pin it down** opener (`ADR-0053` §5 template). |
| 1.0 | 2026-07-31 | Created (`ADR-0053`). The filter-don't-scroll method for `journalctl` — unit / time-window / priority / boot / follow — with the common broken shapes and the hand-offs to `Port-Already-In-Use` and `Test-a-Connection`. Links down to Linux §Services/§Logging. |
