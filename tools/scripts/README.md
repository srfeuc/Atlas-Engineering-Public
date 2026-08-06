# Tools/scripts — Atlas runnable scripts

Home for **runnable scripts** (bash today, PowerShell and others later). Documentation *about* how to build or verify a device lives in its numbered docs; this folder holds the executable that *does* the check.

## Conventions (every script here must follow)

1. **Read-only by default.** A verification/recon script reads state and prints it. It does not change the device. If a script ever writes, its name says so (`fix-*`, `apply-*`) and it is raised as a change record first.
2. **No secrets on screen or in output.** Never `cat` a key, a `.pem`, `clients.conf`, or a `users` file. Print counts and public fields only. Any step that needs a secret (e.g. `radtest`) is left as a manual step in the doc, run by hand, with only the pass/fail line pasted back.
3. **Self-labelling output.** Print each command before its output (`$ <cmd>`) so a pasted log is unambiguous, and bracket the run with `BEGIN`/`END` markers so a truncated paste is obvious.
4. **LF line endings.** Enforced by `.gitattributes` (`*.sh text eol=lf`) — a CRLF shebang breaks on Linux.
5. **Pair each verification script with its device's Verification Procedure doc**, which lists the expected outputs.

## Index

| Script | Type | Read-only | Secret-safe | Pairs with | What it does |
|---|---|---|---|---|---|
| `pi01-recon.sh` | bash | ✅ | ✅ | `052-Pi01-Verification-Procedure.md` | Reconcile-to-live battery for Pi01 — base system, Lab CA/PKI + `index.txt`, Pi-hole/DNS, FreeRADIUS, Vaultwarden + interfaces. |
| `fgt01-recon.fortios.txt` | FortiOS CLI | ✅ | ✅ | `058-FGT01-Verification-Procedure.md` | Reconcile-to-live battery for FGT01 — status/UTM DBs, interfaces (admin + link), NTP, firewall policy/address, cert binding, DNS. Paste into the FortiGate CLI, not bash. |
| `sw01-recon.ios.txt` | Cisco IOS CLI | ✅ | ✅ | `056-SW01-Verification-Procedure.md` | Reconcile-to-live battery for SW01 — identity, clock/NTP, VLANs/interfaces, L2 security (DAI/DHCP-snooping/STATIC-HOSTS), management hardening. Paste into the IOS CLI (`terminal length 0` first); SNMP community is a manual redacted step. |
| `pve01-recon.sh` | bash | ✅ | ✅ | `060-PVE01-Verification-Procedure.md` | Reconcile-to-live battery for PVE01 — platform/VT-x, CMOS/RTC durability, network, storage/VMs, iDRAC/BMC (local KCS). Run as **root** (no `sudo` on this host). |

## How to run a verification script

```bash
bash Tools/scripts/<script>.sh 2>&1 | tee ~/<device>-recon-$(date +%F).txt
```

`tee` keeps a copy so a truncated terminal paste can be re-read. The run ends with an `END` marker — if you don't see it, the paste is incomplete.

## Known holes / limitations

- `pi01-recon.sh` leaves `radtest` (RADIUS functional proof) as a manual step — it needs two secrets from Vaultwarden. Run it by hand and paste only `Access-Accept`/`Access-Reject`.
- These scripts prove *current* device state. They do **not** prove the build docs are followable end-to-end — only an `ADR-0011` Game Day does that.
- `pve01-recon.sh` Section B reads the RTC but does **not** prove CMOS durability on its own — that needs a full power-pull between a written RTC and the next boot (`CM-0012` Step 2). Its iDRAC section is local KCS (`ipmitool`), so it works even when `Gi1/0/4` is down.
