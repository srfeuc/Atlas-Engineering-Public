---
Title: Lab-01 Playbook Mining — Candidate Worksheet (#36)
Path: Labs/Lab-02-Cisco-Core/Operations
Status: 🟢 LIVING worksheet (Backlog **#36**). Flag-first pass over the frozen Lab-01 troubleshooting seam → a categorized, problem-name-keyed list of candidate Playbooks / failure-drills. **This is the plan, not the pages** — build the highest-value ones one at a time in the golden `ADR-0053` §5 mold. Hand-off-ready for another session/bot. **🔄 Build progress: §4 queue rows 1–6 BUILT (2026-07-31) — 4 left (rows 7–10); + the MikroTik east-west firewall set (3 Playbooks) BUILT 2026-07-31 (operator re-prioritisation).**
**🥇 Golden template BUILT 2026-08-01** — `Read-the-Cert-Not-the-Sign-Log.md` (from `MC-0002`), the reference the remaining rows are cut from; §5 `Reissue-a-Certificate-With-a-Correct-SAN` + `Install-a-Full-Chain-Not-a-Bare-Leaf` ticked. **🔄 §4 row 7 BUILT 2026-08-01** (`Rotate-a-Leaked-Key-Before-You-Back-It-Up`, `CM-0010`) — first under the locked command-first mold. **Still open: §4 rows 8–10 + the rest of §5.**
Version: 1.4
Date: 2026-08-01
---

# Lab-01 Playbook Mining — Candidate Worksheet (#36)

<!-- provenance -->
> **Backlog #36 (🔴), first pass.** Frozen **Lab-01-Mikrotik-Core** is a rich seam of *real, device-verified* incidents. This worksheet is the **flag-first audit** the #36 brief asks for: read the seam, flag candidate `Atlas-Academy/Playbooks/` leaves + failure-drills, each anchored to the real incident and **current-design-reconciled**. Then build the highest-value ones **one page at a time** (`ADR-0053` §5, the `Recover-from-a-DNS-Outage` golden mold). The operator runs #36 as a multi-session task, possibly with another bot — **this worksheet is the shared queue.**

## How to use this worksheet

1. Pick a row from **§4 the build queue** (highest value first).
2. Open its **real anchor** in Lab-01 and read the incident in full.
3. **Reconcile to today's design** (§2) — frozen Lab-01 loses where it disagrees.
4. Write the leaf in the golden mold (Pin-it → diagnosis path → fix → prove → Worked log), anchored to the real incident, honest 🟡 until run.
5. Add it to `Playbooks/README.md`, wire the checklist cross-link if relevant (`ADR-0053` §8), tick the row here, refresh the handoff.

## §1 Coverage — what was mined (and what wasn't)

**Mined this pass:** `Operations/016-Network-Lessons-Learned.md` (62 KB) · all five device `Troubleshooting.md` (PVE01 · MKT01 · SW01 · FGT01 · PI01) · the estate `Change-Management/CM-####` records (CM-0010/0013/0014/0020/0025/0026/0027/0032) · the incident-rich per-device `Changes/CM-####` (PVE01 0011/0012 · MKT01 0008/0009/0015/0017/0018/0021/0034/0035/MC-0002 · SW01 0003/0022/0030/0036/0037 · FGT01 0004/0005/0033/MC-0001 · PI01 0002/0019) · `Operations/015-Network-Validation-Guide` · `048-Teardown-and-Rebuild-Runbook` · `040-Remote-Access-Troubleshooting-Guide`.

**Not yet mined (a later pass):** `Operations/051-Book-1-Audit-Report.md` (**139 KB** — deferred by scope) · `035`/`042`/`043`/`049` (the retired OpenSSL-CA/PKI runbooks — mostly Retired-lesson) · a few pure doc-nit CMs (CM-0001 description fix · CM-0016 comment fix · CM-0006/0007 proxy/cert-install).

## §2 Reconcile rules (the current design wins — `POL-0001` / `ADR-0022`)

- Frozen Lab-01 **loses** where it disagrees with today. The **device beats the doc** (Charter Rule 13).
- **Retired (concept only, don't stand the tech back up):** FreeRADIUS → Windows **NPS** (`ADR-0029`) · the OpenSSL **Lab CA** → **AD CS** two-tier PKI (`ADR-0031`) · **Pi01 DoH** / Pi01's reduced role (`ADR-0009`). The Lab-01 **"untagged vmbr0"** resolution is **superseded** by today's tagged `vmbr0.10`.
- **Still live:** the R410 = PVE01 hypervisor · SW01 Catalyst · MKT01 MikroTik · FGT01 FortiGate · the **CMOS/RTC** fault (`CM-0012`, UPS-mitigated).
- **Status column:** **Build-now** (grounded in still-current tech) · **Reconcile-then-build** (real discipline, but re-skin to the current stack first) · **Retired-lesson** (keep as an anti-pattern/Concept; the current stack re-teaches the discipline).

## §3 The recurring themes (what the seam is really teaching)

These five patterns run through almost every incident — they're the *why* behind the queue, and each is a candidate **Concept** page too:

1. **A command completing is a claim, not evidence.** The lab's most-repeated (7+ times) and most expensive lesson: read the *value* back (`get` not `show`, `print detail`, `s_client`, `w32tm /query`), never the exit code. (`015`, MC-0001, CM-0030.)
2. **The config line ≠ the running service; the wire ≠ the file.** `ntp server` in the config while `show ntp status` = `stratum 16`; a served cert vs the `.crt` a rebuild reads from; a listening socket that's a *client*. Prove the thing that *runs* matches the thing that's *authoritative*.
3. **What hurt failed silently; what saved the project refused, out loud.** DAI drops "full stop, no error"; a `sudo`-on-`tee`-only pipe ships a keyless cert; `==` vs `:=` never matches. Hunt the silent-drop class deliberately.
4. **Recovery paths are load-bearing and invisible — hardening deletes them.** MKT01 has no console (MAC-WinBox on `ether4` is the only way in); FGT01's "unused" `internal3-7` are its break-glass. Enumerate and document the *reason* before shutting anything.
5. **Verify the negative, and count the OLD text.** A test that can't fail proves nothing; a correction that appends instead of replacing leaves the wrong value four lines down. Check by counting what must be *gone*.

## §4 The build queue — recommended order (Build-now, high value, not a dup)

| # | Proposed Playbook | Real anchor (Lab-01) | Cert | Why it's first-tier |
|---|---|---|---|---|
| 1 ✅ | `Diagnose-a-Host-Silently-Dropped-by-DAI.md` **— BUILT 2026-07-31** | SW01 `Troubleshooting` + **CM-0022**: `DHCP Permits: 0`, host absent from the ARP-ACL → "dropped, full stop, no error"; the phantom "Pi01 unreachable" that survived three handoffs | CCNA (DAI/DHCP-snooping) | The canonical "healthy device that looks dead"; already cited by `Trace-a-Blocked-Flow` + `Domain-Join-Fails` |
| 2 ✅ | `Confirm-a-Config-Change-Actually-Took.md` **— BUILT 2026-07-31** | **MC-0001**/FGT01: `set admin-server-cert` "ran, no error, did not take effect" — found only by `get`, not `show` (`show` prints non-default only). The 7×-repeated lesson (`015`) | FCP · all platforms | The single most reusable verification drill in the estate |
| 3 ✅ | `Enumerate-Every-Enabled-Interface-Before-Hardening.md` **— BUILT 2026-07-31** | **CM-0033**/FGT01: `internal3-7` UP, in no doc, carrying FGT01's only IP recovery path — "a hardening pass would have shut them and destroyed the recovery path" | Sec+ · FCP · CCNA | Correct-by-policy hardening deletes break-glass; "a group's state ≠ its members' state" |
| 4 ✅ | `Recover-a-Locked-Out-Router-Out-of-Band.md` **— BUILT 2026-07-31** | **CM-0017/0018**/MKT01: no console; MAC-WinBox on `ether4` is the only way back, built + proved by live MAC-connect | MTCNA · CCNA | The core router's break-glass; must be built + tested *before* it's needed |
| 5 ✅ | `Recover-the-Lab-from-a-Bare-Metal-Teardown.md` **— BUILT 2026-07-31** | **048**: "wipe Pi01 and you've deleted your own credentials"; SW01 serial 9600, MKT01 WinBox-by-MAC, FGT01 `192.168.1.99`; extract creds to offline media first | Sec+ · recovery | The one runbook guaranteed to run on the worst day; OOB + credential-on-the-wiped-host |
| 6 ✅ | `Respond-to-a-Committed-Secret.md` **— BUILT 2026-07-31** | **CM-0014**: the archive passphrase committed in `ac2182f` — the *same* commit shipping the runbook forbidding it; "git rm deletes a name, not a blob" → rotate-first, `git filter-repo`, verify from a fresh mirror clone | Sec+ · git | The most portfolio-relevant incident; the `git add .` scar the house rule exists for |
| 7 ✅ | `Rotate-a-Leaked-Key-Before-You-Back-It-Up.md` **— BUILT 2026-08-01** (first under the locked command-first mold) | **CM-0010**: "rotate before any backup, never the reverse"; two undocumented `.bak` key copies found by `ls`; "never destroy the rollback before the replacement verifies" | Sec+ | Three reusable rules (rotate-before-backup · inventory-every-copy · destroy-after-verify) from one incident |
| 8 | `Reconcile-a-Build-Guide-That-Rebuilds-a-Broken-Device.md` | **CM-0022**: a clean rebuild from `027` kills Pi01 four ways (ACL omit · port shutdown · VLAN 999 · wrong label) while the live switch is correct | ITIL · CCNA | The guide that *builds* a fact is the rebuild-fatal artifact — not just docs that *describe* it |
| 9 | `Verify-an-Edit-by-Counting-the-Old-Text.md` | **CM-0021** (RouterOS last-write-wins, line 47 overwrites line 41) + **CM-0026** ("both sentences are false" reprinted verbatim 21 lines later) | ITIL · config-mgmt | The append-don't-delete defect + the count-the-old-string check that catches it everywhere |
| 10 | `Trace-Three-Symptoms-to-a-Dead-CMOS-Battery.md` | **CM-0012**/PVE01: VT-x off + clock reset to 2018 + "invalid system configuration" = one dead cell; and the twist — a battery swap *didn't* fix the RTC (UPS-mitigated) | Server+ · A+ | One root cause behind three unrelated-looking faults + "the obvious fix didn't fix it" |

## §5 Candidate library — the full flagged set (by status)

### Build-now (grounded in current tech)

| Proposed Playbook | Real anchor | Maps to existing? | Cert | Pri |
|---|---|---|---|---|
| `Read-the-Device-Before-Running-a-Draft-Change.md` | CM-0011: a Draft hardening record run as a work-order "degraded a correctly-hardened BMC" | — | ITIL | H |
| `Disable-Unused-Ports-Without-Cutting-the-Break-Glass-Path.md` | CM-0033/CM-0018: the Unused-Interface policy vs the irreducible recovery port | — | CCNA · NSE4 | H |
| `Audit-the-Layer-2-Management-Plane.md` | CM-0017 (016 L19): MAC-WinBox/MAC-Telnet "speak Ethernet, not IP — the IP firewall never evaluates them" | — | Sec+ · MTCNA | H |
| `Prove-What-Is-Deployed-Matches-the-Source-of-Truth.md` | CM-0032: `index.txt` has 4 rows for 6 trusted certs; "verifying the wire proves nothing about the file you rebuild from" | reconcile → AD CS | Sec+ · Linux+ | H |
| `Fix-a-sudo-Pipeline-That-Wrote-a-Partial-File.md` | Pi01: `cat a b \| sudo tee` shipped a keyless cert; caught by a failing TLS handshake | — | Linux+ · Sec+ | H |
| `Find-the-Stale-Source-File-You-Edited.md` | CM-0008: `custom.list` edited + "confirmed correct in the file" but Pi-hole v6 reads `pihole.toml` — live query still stale | partial → DNS-Outage | Linux+ | M |
| `Make-a-Control-Survive-a-git-clone.md` | CM-0020: `.gitleaks.toml` committed but the `pre-commit` hook isn't — the scanner lives on one laptop | — | Sec+ · CIS | M |
| `Purge-a-Secret-Shaped-File-from-the-Backup-Directory.md` | CM-0019: world-readable `vaultwarden-container-env.txt` in `~/atlas-backup/` (twin of CM-0014) | — | Sec+ · CIS | M |
| `Choose-a-Passphrase-That-Survives-Recovery.md` | CM-0010/CM-0014: `£` unreadable on a rescue initramfs; `! ^ & @` broke bash/PowerShell/paste — "entropy is length, not tool-breaking chars" | — | Sec+ | M |
| `Validate-a-Negative-Security-Test.md` | 016 L4 (CM-0012): cipher-0 "proven by the exploit failing" — but IPMI-over-LAN was disabled the whole time; `nc -u -z 623` "succeeds" on no reply | — | Sec+ | M |
| `Catch-a-Validation-Step-With-the-Wrong-Expected-Result.md` | CM-0022: guide's Validation expects `hostname CoreSwitch` / 4 ACL entries — "takes a correct device, calls it a failure" | — | ITIL · CCNA | M |
| `Disable-the-Default-admin-Without-Locking-Yourself-Out.md` | CM-0034: `admin` disabled only after `SethAdmin` confirmed logged-in; fallback = MAC-WinBox, else factory reset | — | CCNA-Sec · CIS | M |
| `Recover-from-an-Enable-Secret-Lockout.md` | SW01: a placeholder `enable secret` was a real secret from the moment set → ROMMON password-recovery | — | CCNA | M |
| `Avoid-a-FortiGate-VDOM-Lockout.md` | FGT01: multi-VDOM; every interface command needs `set vdom "root"` — omitting it caused the lockout | partial → FGT inspect (📋) | FCP | M |
| `Isolate-a-Faulty-DIMM-Slot.md` | PVE01: slot B1 faulty (proved by moving the DIMM to B3); relocation silently drops triple-channel interleaving | — | Server+ · A+ | M |
| `Fix-a-Link-Renegotiated-Down-to-100Mbps.md` | 016: `Gi1/0/4` at 100 Mbps; "confirmed 1 Gbps post-reboot — monitor" … "IT RECURRED" (hypervisor uplink at 1/10 speed) | — | CCNA | M |
| `Establish-a-Standing-Validation-Account.md` | CM-0013: deleting the default test user left RADIUS unauthenticatable for a day → a privilege-less `radtest-verify` | reconcile → NPS | Sec+ | M |
| `Untangle-Which-Shell-You-Are-In.md` | 040: `ssh pihole` run *inside* Pi01 — "SSH aliases only exist on the workstation"; prompt tells | — | Linux+ | L |

### Retired-lesson (keep as Concept/anti-pattern — the current stack re-teaches the discipline)

| Proposed (concept) | Real anchor | Current-tech equivalent |
|---|---|---|
| `Reissue-a-Certificate-With-a-Correct-SAN` ✅ **BUILT 2026-08-01** as the 🥇 golden template `Read-the-Cert-Not-the-Sign-Log.md` | CM-0027/MC-0002: `035` issued certs with no SAN; `copy_extensions` unset CA-wide — "the sign log looks clean either way" | AD CS re-teaches: SAN required; read the cert, not the issuance log (`ADR-0031`). **Built as Build-now** — the read-the-artifact discipline is fully current; the filename foregrounds the transferable mentality (operator's call, `Session-26` planning) |
| `Install-a-Full-Chain-Not-a-Bare-Leaf` ✅ **folded into** `Read-the-Cert-Not-the-Sign-Log.md` §5 (prove on the wire) | MC-0001: bare leaf → `ERR_CERT_AUTHORITY_INVALID`; `s_client \| grep -c BEGIN CERTIFICATE` must be **3** | AD CS / any TLS service: verify the *served* chain on the wire — the golden template's wire-proof step covers it |
| `Fix-a-RADIUS-Test-User-Always-Rejected` | Pi01: `==` vs `:=` "silently never matches, no error" | NPS re-teaches AAA policy match (`ADR-0029`) — don't stand up FreeRADIUS |
| `Migrate-off-a-Removed-DoH-Feature` | Pi01: `cloudflared` removed the DoH proxy in 2026.2.0 → dnscrypt-proxy (port-53 conflict → `Port-Already-In-Use`) | Pi01 DoH retired (`ADR-0009`); keep "check the changelog for a removed feature" |
| `Onboard-a-BMC-iDRAC-Into-the-PKI` | CM-0011/0012: the iDRAC "has an IP and nothing else" — no cert, no vault, shared-LOM | Reconcile: enrol via **AD CS**, move to a dedicated NIC (a build, not a fix) |
| `Remove-a-Firewall-Rule-That-Has-Never-Matched` ✅ **BUILT 2026-07-31** as `Remove-a-MikroTik-Firewall-Rule-That-Has-Never-Matched.md` | CM-0009: two rules on pre-VLAN `10.0.0.5`, off-path — "never did anything" | Reconcile: the RADIUS flow moves to NPS; the *prove-a-rule-is-dead-before-removing* discipline survives (built as a Build-now Playbook — the discipline is fully current) |

## §6 Next steps

- **Build** from §4 top-down, one page at a time (`ADR-0049`), golden mold (`ADR-0053` §5). #1–#3 slot straight into the estate's commissioning/hardening story and the checklist cross-links (`ADR-0053` §8).
- ✅ **MikroTik east-west firewall set — BUILT 2026-07-31 (operator re-prioritisation: MKT01 was the core router with a lot of firewall-blocking problems).** Three Playbooks from the MKT01 firewall seam (`Firewall-Per-Rule-Verification-Tests` · `Firewall-Low-Level-Per-Rule-Isolation-Tests` · `CM-0009`): `MikroTik-EastWest-Inspect-and-Troubleshoot` (which rule dropped a flow — fulfils the Playbooks-README 📋 seed) · `Prove-Exactly-Which-MikroTik-Rule-Acted` (per-rule proof, console-less-safe) · `Remove-a-MikroTik-Firewall-Rule-That-Has-Never-Matched` (§5 above). These are the per-appliance MikroTik guides from the vision doc + the deep companion to `Trace-a-Blocked-Flow`.
- Several themes (§3) are also strong **Concept** pages (the *why* layer) — e.g. "a command completing ≠ a change confirmed" and "the wire ≠ the file." Route those to `Concepts/`, not `Playbooks/`.
- **Later passes:** mine `051-Book-1-Audit-Report.md` (139 KB) and the retired-PKI runbooks (`035`/`042`/`043`/`049`) for any surviving discipline.
- Tick rows here as they're built; keep this worksheet as the #36 shared queue.

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.4 | 2026-08-01 | **§4 queue row 7 built** — `Rotate-a-Leaked-Key-Before-You-Back-It-Up.md` from the device-verified `CM-0010`, the first Playbook under the now-locked command-first `ADR-0053` §5 mold (rotate-before-backup · inventory-every-copy-and-location · destroy-after-verify; passphrase-vs-key-material fork; ASCII-only rule; round-trip-from-the-vault). §4 row 7 ticked ✅. Reconciled → AD CS/BKP01 (`ADR-0022`/`ADR-0031`/`ADR-0029`). Remaining: §4 rows 8–10 + the rest of §5. **Nineteen Playbooks written.** |
| 1.3 | 2026-08-01 | **Golden template built (Lab-01 Playbook Project, `Session-26`).** `Read-the-Cert-Not-the-Sign-Log.md` cut from the real `MC-0002` (device-verified) — the 🥇 reference the rest of the library copies (On-this-page index · per-step provenance to `MC-0002` · Worked-example→the MC doc · optional Gap note). Anchor + filename confirmed with the operator at planning (`ADR-0049`): MC-0002, mentality-foregrounded name. Ticked §5 `Reissue-a-Certificate-With-a-Correct-SAN` ✅ (built as Build-now — discipline current) and `Install-a-Full-Chain-Not-a-Bare-Leaf` ✅ (folded into the wire-proof step). Reconciled OpenSSL Lab CA → AD CS (`ADR-0022`/`ADR-0031`). **Eighteen Playbooks written.** Remaining: §4 rows 7–10 + the rest of §5; the §3 themes → `Concepts/` (mentality split, operator-confirmed). |
| 1.2 | 2026-07-31 | **MikroTik east-west firewall set built (operator re-prioritisation — MKT01 was the core router with a lot of firewall-blocking problems; and Lab-01 exists to *teach the repeatable fix* so it isn't re-derived).** Built 3 MKT01 firewall Playbooks from the seam (`Firewall-Per-Rule-Verification-Tests` · `Firewall-Low-Level-Per-Rule-Isolation-Tests` · `CM-0009`): `MikroTik-EastWest-Inspect-and-Troubleshoot` (fulfils the Playbooks-README 📋 seed) · `Prove-Exactly-Which-MikroTik-Rule-Acted` · `Remove-a-MikroTik-Firewall-Rule-That-Has-Never-Matched` (§5 Retired-lesson row ticked — built as Build-now, the discipline is current). Reconciled to the Lab-02 E-W firewall role (`ADR-0022`; RADIUS→NPS `ADR-0029`). Also routed the AI-Context nav through Lab-01 (Pointers v1.1 · What-To-Check-First v1.2 · Directory-Map v1.2) so future sessions mine the seam. Seventeen Playbooks written. |
| 1.1 | 2026-07-31 | **Build progress (#36 Playbook-building slice, `Session-25` brief).** Built §4 queue **rows 1–6** as Playbooks in the golden `ADR-0053` §5 mold + the new `#32` "Symptoms & search terms" element: `Diagnose-a-Host-Silently-Dropped-by-DAI` · `Confirm-a-Config-Change-Actually-Took` · `Enumerate-Every-Enabled-Interface-Before-Hardening` · `Recover-a-Locked-Out-Router-Out-of-Band` · `Recover-the-Lab-from-a-Bare-Metal-Teardown` · `Respond-to-a-Committed-Secret`. Each anchored to its real frozen-Lab-01 incident, current-design-reconciled (`ADR-0022`), 🟡 until run. **Rows ticked ✅. Remaining: rows 7–10** (`Rotate-a-Leaked-Key-Before-You-Back-It-Up` · `Reconcile-a-Build-Guide-That-Rebuilds-a-Broken-Device` · `Verify-an-Edit-by-Counting-the-Old-Text` · `Trace-Three-Symptoms-to-a-Dead-CMOS-Battery`) + the §5 library. |
| 1.0 | 2026-07-31 | Created (#36 first pass). Flag-first mine of the Lab-01 seam (016 + 5 device Troubleshooting + the CM records + 015/040/048; 051 deferred) via three parallel read passes → 25 categorized, problem-name-keyed candidates + a 10-row build queue + the five recurring themes. Current-design-reconciled (`ADR-0022`/`0029`/`0031`/`0009`). Home = Lab-02 `Operations/` as the shared #36 queue. |
