---
Title: Playbook — Domain Join Fails (a member won't join atlas.lab)
Path: Atlas-Academy/Playbooks
Status: 🟡 Method authored, lab-unverified (`POL-0001`) — per-step read-backs land the first time a real join is worked. AD facts per the DC build (`atlas.lab`, DC01 `10.20.0.2` / DC02 `10.20.0.3`); the failure *causes* are grounded in the frozen **Lab-01** DNS / time / silent-drop incidents (current-design-reconciled — `POL-0001` / `ADR-0022`).
Version: 1.0
Date: 2026-07-31
---

# Playbook — Domain Join Fails (a member won't join `atlas.lab`)

<!-- provenance -->
> **Book 9 — Atlas Academy · Playbook (`ADR-0053`).** Kind: problem / build-blocker. **A new Windows member server won't join `atlas.lab`** — the join wizard (or `Add-Computer`) returns "*An Active Directory Domain Controller … could not be contacted*", "*the specified domain either does not exist or could not be contacted*", a **Kerberos clock-skew** error, or **access denied**. This page finds which of the four real causes it is and fixes it.

**Why this is the highest-value commissioning playbook.** The domain join is **Phase 5** of the new-Windows-server commissioning checklist and the single most common place a Windows build stalls. Almost every join failure is one of four things — **DNS pointed at the wrong resolver**, **time skew past the Kerberos window**, **the network path to the DCs blocked**, or **the wrong credential** — and Atlas has felt three of those four for real in Lab-01 (just without AD on top). Nail the order below and you rarely need step 5.

> 🔗 **Building the box for the first time?** This failure has a *checklist* home: **Phase 5 (Domain join & identity)** of `00-Atlas-Foundation/Templates/New-Windows-Server-Commissioning-Checklist-TEMPLATE.xlsx`. If you got here mid-build, first re-check the earlier gates that *cause* join failures — **"Point DNS at the DCs"**, **"Disable hypervisor guest time-sync"**, and **"DCs reachable (DNS + LDAP)"** — before diagnosing here. (Convention: `ADR-0053` §8.)

## Symptoms / when you'd use this

- The join wizard / `Add-Computer` fails with one of:
  - "*An Active Directory Domain Controller (AD DC) for the domain `atlas.lab` could not be contacted.*"
  - "*The specified domain either does not exist or could not be contacted.*"
  - a **Kerberos** error mentioning **clock skew** / *"time difference … too great"*.
  - "*Access is denied*" / "*The user name or password is incorrect.*"
- An **already-joined** box logs "*The trust relationship between this workstation and the primary domain failed*" (that's the secure-channel path — step 6).
- You can `ping` the DC by IP but the join still fails (the classic reachability fallacy — see step 3).

## Cert anchor

- **AZ-800 / AZ-801** (AD DS: domain join, DNS for AD, Kerberos, secure channel) — the primary anchor.
- CCNA 4.0 IP Services (DNS/NTP) — the underlying causes.
- CompTIA **Security+** (Kerberos, time, availability).
- *(Grounding index: the AZ-800/801 lab map + the CCNA map.)*

## Grounded in — the Atlas identity + the real Lab-01 failure modes

Know the moving parts before you diagnose (`POL-0008` — the device pages own these facts, this page links):

- **Domain** `atlas.lab`; DCs = **DC01 `10.20.0.2`** / **DC02 `10.20.0.3`** (VLAN 20, Tier-0). AD-DNS runs *on* the DCs; the **PDC-emulator** is the domain time root (`ADR-0020`). Owner: `Devices/DC-Domain-Controllers/`.
- **A domain member must resolve `atlas.lab` via a DC**, not Pi-hole and not a public resolver — the join finds the DC through **DNS SRV records** that only AD-DNS serves.
- **Kerberos rejects a ticket when the clock is off by more than 5 minutes** — so a member's time must track the domain hierarchy, *not* the hypervisor/CMOS.

Three of the four causes below are **real Atlas history** (frozen Lab-01, `ADR-0022` — reconciled to today's design):

- **Time was a repeated, invisible failure.** Lab-01: *"there is no NTP server anywhere in Atlas; two of four devices have never had a clock"* — `show run` showed `ntp server …` (intent) while `show ntp status` showed `stratum 16, never synchronized` (truth). That exact gap is a Kerberos-skew join failure once AD is on top. (`CM-0030`; sibling `Fix-the-SW01-Clock.md`.)
- **A silent network drop looks exactly like "the domain doesn't exist."** Lab-01: a host missing from SW01's DHCP-snooping / ARP-ACL was *"dropped, full stop — no error, no warning; it simply appears broken"* — a false "should be unreachable" mystery that survived three handoffs. The join sees the same nothing. (Sibling `Trace-a-Blocked-Flow.md`.)
- **`ping` proves almost nothing.** Lab-01: *"the NIC answers ICMP — nothing about the service"* and *"being listed is not being reachable; listening is not serving."* A DC that answers `ping` can still be unreachable on 389/88/445. (Sibling `Test-a-Connection.md`.)

Command detail (link down — `POL-0008`): `../Command-Library/PowerShell-Tier0.md` (§DNS / §Kerberos / §domain). Why-it-works: `../Concepts/README.md` (AD-DNS SRV resolution; the Kerberos time dependency).

## ① Pin it down (capture these first — they're the ticket)

- a. **The exact error string** — "could not be contacted" (DNS/network) vs a **Kerberos/skew** message vs "access denied" (creds). The wording alone narrows it to one branch.
- b. **The host's resolver** — `Get-DnsClientServerAddress` → is it a **DC** (`10.20.0.2/3`) or something else (Pi-hole `10.10.0.x` / a public IP)? (Points straight at cause 1.)
- c. **New join or a working box that broke?** — a fresh join → causes 1–4; an already-joined box now failing → the **secure channel** (step 6).
- d. **What changed just before** — a snapshot restore, a NIC/DNS edit, a reboot after a long power-off (clock drift), a firewall/VLAN change, a cert rotation.
- e. **The join account** — which domain account + does it have rights to join / to the target OU? (`t1-seth` or a delegated join account, `ADR-0024`.)

## The diagnosis path — cheapest, most-likely cause first

Run from the **member** being joined unless noted.

**1. Is DNS pointed at a DC, and does it return the domain's SRV records? (the #1 cause)**

- a. Confirm the resolver:
  - `Get-DnsClientServerAddress -AddressFamily IPv4`
  - Reference: `../Command-Library/PowerShell-Tier0.md` §DNS.
  - Healthy: **`10.20.0.2`, `10.20.0.3`** (DCs).
  - Broken: a Pi-hole (`10.10.0.x`) or public (`1.1.1.1`) resolver → it cannot answer AD SRV records → join fails "*domain could not be contacted*."
- b. Confirm the DC-locator SRV records resolve:
  - `nslookup -type=SRV _ldap._tcp.dc._msdcs.atlas.lab`
  - Healthy: returns **dc01 / dc02** with their IPs.
  - Broken: `Non-existent domain` / empty → DNS is the cause.
- → Fix at cause 1 (below). Deep dive: `Recover-from-a-DNS-Outage.md`. 📸 the two outputs (resolver + SRV answer).

**2. Is the member's clock within 5 minutes of the DC? (the Lab-01 classic)**

- a. Compare against the DC:
  - `w32tm /stripchart /computer:dc01.atlas.lab /samples:5 /dataonly`
  - Healthy: offset well under **300 s**.
  - Broken: a large/growing offset, or an error reaching the DC's time — a Kerberos-skew join failure.
- b. Confirm the member isn't taking time from the hypervisor/CMOS:
  - `w32tm /query /source`
  - Broken: `VM IC Time Synchronization Provider` / `Local CMOS Clock` (the `ADR-0020` trap — disable the QEMU guest-agent time sync for this VM).
- → Fix at cause 2. Sibling: `Fix-the-SW01-Clock.md` (the same *show-run-≠-show-truth* lesson on the network side). 📸 the `stripchart` offset + `w32tm /query /source`.

**3. Is the *network path* to a DC actually open — on the ports the join needs? (not `ping`)**

- a. Test the required ports (not ICMP):
  - `Test-NetConnection dc01.atlas.lab -Port 389`  (LDAP)
  - `Test-NetConnection dc01.atlas.lab -Port 88`   (Kerberos)
  - `Test-NetConnection dc01.atlas.lab -Port 445`  (SMB)
  - Reference: `../Command-Library/PowerShell-Tier0.md` §domain; ladder in `Test-a-Connection.md`.
  - Healthy: `TcpTestSucceeded : True` on each.
  - Broken: `ping` may still succeed while a port is `False` — a **silent firewall / VLAN / switch-ACL drop** (the Lab-01 "dropped, full stop, no error"). ICMP answering the NIC says nothing about the service.
- → Fix at cause 3. Deep dive: `Trace-a-Blocked-Flow.md` (which enforcement point dropped it). 📸 the port tests (the `False` one is the finding).

**4. Can the member *locate* a DC?**

- a. `nltest /dsgetdc:atlas.lab`
  - Healthy: returns a DC name + IP + the site.
  - Broken: `ERROR_NO_SUCH_DOMAIN` → falls back to causes 1–3 (DNS/time/path), not a new problem.

**5. Only if 1–4 pass and the join is still refused — credentials / rights.**

- a. Re-run the join with an explicit domain account that has join rights:
  - `Add-Computer -DomainName atlas.lab -Credential atlas\t1-seth -OUPath "OU=<type>,OU=Servers,OU=Computers,DC=atlas,DC=lab" -Restart`
  - Broken: "*Access is denied*" → the account lacks the *add-workstations-to-domain* right or delegated create rights on the target OU (`ADR-0024` / `303` Part 3).

**6. Already-joined box logging "trust relationship … failed" — the secure channel.**

- a. Test it:
  - `Test-ComputerSecureChannel -Verbose`
  - Broken: `False` → the machine password is out of sync (often after a snapshot restore older than the last machine-password change).
- b. Repair without a full rejoin:
  - `Test-ComputerSecureChannel -Repair -Credential atlas\t1-seth`
  - → `True`. 📸 the before/after.

## Fix — by cause

- **Cause 1 · DNS.** Set the member's DNS to the DCs, then retry:
  - `Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.20.0.2,10.20.0.3`
  - `Clear-DnsClientCache` → re-run step 1b (SRV records must now answer).
- **Cause 2 · Time.** Disable the hypervisor guest-agent time sync for this VM (`ADR-0020`), point the member at the domain hierarchy, resync:
  - `w32tm /config /syncfromflags:domhier /update ; Restart-Service w32time ; w32tm /resync`
  - Re-run step 2 (offset < 300 s).
- **Cause 3 · Path.** Open **53 / 88 / 389 / 445 (+135/RPC)** from the member's VLAN to the Tier-0 DC block on the enforcement point that dropped it (`Trace-a-Blocked-Flow.md` names it); re-test the ports.
- **Cause 4 · Credentials / object.** Use a join-rights account; if a **stale computer object** exists, delete it on a DC first (`Get-ADComputer <host>` → `Remove-ADComputer`), then join with `-OUPath` set to the correct `Computers\Servers\<type>` OU (never the default container).

## Prove it's joined

- a. `Get-ComputerInfo | Select CsName,CsDomain,CsDomainRole`
  - → **`atlas.lab` / `MemberServer`** (after the reboot).
- b. `nltest /sc_query:atlas.lab` → **`Success`** (a healthy secure channel).
- c. `gpupdate /force` → the **Baseline Server Security + LAPS** GPOs apply (checklist Phase 5 read-back).
- d. On a DC: `Get-ADComputer <host> -Properties DistinguishedName` → the object sits under `…,OU=Servers,OU=Computers,DC=atlas,DC=lab`.
- e. 📸 the `Get-ComputerInfo` result + `nltest /sc_query` = Success. Mark ✅ only with the pasted read-backs (`POL-0001`).

## If still broken

- Join gets *further* but hangs applying settings → an **RPC / dynamic-port** block (135 + the high-port range) → `Trace-a-Blocked-Flow.md`.
- `atlas.lab` resolves but only via **one** DC, and that DC is unhealthy → target the other explicitly, and check DC health on a DC (`dcdiag` / `repadmin /replsummary` — the DC-down path, 📋).
- "Access denied" persists with a known-good account → a **duplicate SPN** or a pre-staged object owned by a different account → clean the object on a DC and retry.
- Everything passes but names still won't resolve *after* join → back to DNS (`Recover-from-a-DNS-Outage.md`).

## Related

- **Checklist (the reciprocal link, `ADR-0053` §8):** `00-Atlas-Foundation/Templates/New-Windows-Server-Commissioning-Checklist-TEMPLATE.xlsx` — **Phase 5 (Domain join & identity)**, with the causal prereqs in Phases 2–3 (DNS→DCs, disable guest time-sync).
- **Command-Library:** `../Command-Library/PowerShell-Tier0.md` (§DNS / §Kerberos / §domain).
- **Concepts:** `../Concepts/README.md` (AD-DNS SRV resolution; the Kerberos time dependency — why-it-works).
- **Decisions / owners:** `Devices/DC-Domain-Controllers/` (the DC facts) · `ADR-0020` (time architecture) · `ADR-0024` (tiered join accounts) · `303-Windows-Design-Standards` (OU placement) · `ADR-0003`/`ADR-0051` (the DNS split).
- **Sibling playbooks:** `Recover-from-a-DNS-Outage.md` (cause 1) · `Fix-the-SW01-Clock.md` (cause 2 lineage) · `Test-a-Connection.md` (ping ≠ service) · `Trace-a-Blocked-Flow.md` (cause 3) · `Proxmox-Inspect-and-Troubleshoot.md` (the VM's guest-agent time sync).
- **Real lineage:** frozen Lab-01 `Operations/016-Network-Lessons-Learned.md` (the no-NTP-anywhere saga; the silent ACL drop; ping ≠ service) · `CM-0030` (SW01 clock never synchronised).

## Worked log

| Date | Who | Time (RTO if a drill) | Host | Cause found | Outcome |
|---|---|---|---|---|---|
| _(add a row each time this playbook is actually run — `POL-0001`)_ | | | | | |

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-07-31 | Created (`ADR-0053`) — the domain-join failure playbook (the #1 Windows-commissioning blocker). Four-cause diagnosis path (DNS→DC · Kerberos time skew · blocked path on 53/88/389/445 · credentials/object) + the secure-channel repair, in golden-template shape (Pin-it · a/b/c steps · 📸 · Worked log). Grounded in the DC build (`atlas.lab`) and the real frozen-Lab-01 causes (the no-NTP saga, the silent switch-ACL drop, ping ≠ service — `016`/`CM-0030`, `ADR-0022`-reconciled). Carries the reciprocal cross-link to the commissioning checklist Phase 5 (`ADR-0053` §8). 🟡 until worked on a real join. |
