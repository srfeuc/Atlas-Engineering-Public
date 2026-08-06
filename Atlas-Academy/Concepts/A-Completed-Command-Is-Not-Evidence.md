---
Title: A Completed Command Is Not Evidence (read the running value back) — the estate's most expensive discipline
Path: Atlas-Academy/Concepts
Status: 🟢 Academy concept module — the "why" behind the verification Playbooks (`ADR-0053` mentality/machine split; `ADR-0032` concept layer). The first of the **§3 recurring themes** from the frozen Lab-01 seam turned into a Concept (`Lab-01-Playbook-Mining-Candidates.md` §3, theme 1). Grounded in real, device-verified Lab-01 incidents (`MC-0001` · `MC-0002` · `CM-0030`), current-design-reconciled (`ADR-0022`).
Version: 1.0
Date: 2026-08-01
---

# A Completed Command Is Not Evidence (one-pager)

<!-- provenance -->
> **Book 9 — Atlas Academy · Concepts.** A "why it works" module — the mentality layer under the action layer (`ADR-0053`: Concepts answer *why does this work and how does it fit*; Playbooks answer *what do I do*). This is the estate's **most-repeated (7×+) and most expensive** discipline (`Operations/016-Network-Lessons-Learned.md`, `015-Network-Validation-Guide`). Every claim below points at a **real Atlas artifact**. The Playbooks that *apply* this concept link **up** here for the reasoning; this page doesn't restate their commands (`POL-0008`).

> **The gap this closes:** the instinct that a command which *ran without error* has *done what you asked*. It hasn't necessarily — the exit code, the "saved" toast, and the config file are all **claims of intent**, not evidence of the running state. Knowing to distrust them — and what to read instead — is the single reflex that catches the largest class of Atlas incidents.

## The Concept

A command has two separate outcomes that people conflate:

- **It completed** — the tool accepted the syntax and returned. This is a **claim**.
- **It took effect** — the running system now behaves as intended. This is the **evidence**, and it lives somewhere the completion never touched.

Three faces of the same trap:

- **The exit code lies.** `set admin-server-cert <name>` returns cleanly and silently does nothing; the service keeps serving the old value. A `0` exit means *the command was accepted*, not *the state changed*.
- **The success log lies.** `openssl ca` prints a clean sign log for a certificate that has **no SAN at all** — the log describes the *action*, not the *artifact* it produced.
- **The config line lies.** `ntp server 10.x.x.x` sits in the running-config while `show ntp status` reports `stratum 16, never synchronized`. The file records *intent*; the service records *reality*, and they disagree.

**The rule:** verify a change by reading the **running value back with the runtime read command** — never the exit code, never a "saved" message, never the config file or the issuance log. `get`, not `show`; `show … status`, not `show run`; `print detail`, not `print`; `systemctl is-active` / `ss`, not the unit file; `openssl s_client` on the wire, not the imported object; `w32tm /query`, not the GPO. If you cannot produce a runtime read-back, the change is **unverified (🟡)**, not done (`POL-0001`).

A close sibling discipline — *the wire ≠ the file; the running service ≠ the config line* (§3 theme 2) — is the same idea aimed at **where** the truth lives; this page is aimed at **whether a completion counts as proof** (it doesn't).

## The Atlas Example (real artifacts)

- **`MC-0001` (FGT01) — the exit code.** Every certificate step was performed correctly, yet the admin GUI served the **factory** cert for the whole session because `set admin-server-cert` had **silently not taken** — and `show` couldn't reveal it (FortiOS `show` prints only non-default values, so it printed *nothing*). Only **`get system global`** exposed the factory default still bound. A multi-hour diagnosis that one runtime read would have closed in seconds.
- **`MC-0002` (MKT01) — the success log.** `openssl ca` signed a certificate with a completely clean log; `openssl x509 -text | grep SAN` on the resulting file returned **empty**. Reading the *artifact* instead of trusting the *sign log* caught a defect the CA had shipped since it was built (`copy_extensions` unset), in one command. *(This is the incident the golden-template Playbook is cut from.)*
- **`CM-0030` (SW01) — the config line.** `show run` showed the `ntp server` line present and correct while `show ntp status` reported `stratum 16` — the switch had **no working clock** despite a config that said it should. The line was intent; the status was reality.
- **The read-back table already exists.** The per-platform ✅-read-vs-❌-claim mapping (FortiOS `get` · IOS `show … status` · RouterOS `print detail` · Linux `systemctl`/`ss` · the wire `s_client` · Windows `w32tm`) is maintained in the Playbook `../Playbooks/Confirm-a-Config-Change-Actually-Took.md` and each `../Command-Library/` platform page — this concept is the *why* those exist.

## What Went Wrong (the pattern behind the incidents)

Read the three together and the shape is identical every time: **the command ran, returned no error, and the system was still wrong** — and each was only caught (or, in the frozen record, *nearly* missed) by looking at the running state rather than the completion.

- The cost scales with *when* you catch it. `MC-0002` caught the empty SAN at the **issuance** step (before installing) and saved the whole install effort; `MC-0001` didn't distrust the clean `set`, and paid for it with hours. The discipline is cheapest applied *immediately after every change*, most expensive applied *after the downstream failure*.
- It is the lab's **most-repeated** lesson — logged 7×+ across `015`/`016`. A discipline that recurs that often is not a series of unlucky bugs; it is the **default failure mode of trusting completions**, which is why it earns a Concept of its own.
- **Reconciliation (`ADR-0022`).** The tools change across labs — OpenSSL → AD CS, FreeRADIUS → NPS, RouterOS v6 → v7 — but the discipline is tool-independent and carries to every lab: read the value back. The frozen incidents are on retired tech; the reflex is fully current.

## How to Explain This in an Interview

*"The most expensive habit I broke in my lab was trusting that a command which ran had actually taken effect. A `set` that returns cleanly, a sign log with no errors, a config line that's present — those are claims, not evidence. The evidence is the running state, and you have to read it back with the right command: on a FortiGate that's `get`, not `show`, because `show` only prints non-default values, so a silently-failed change shows nothing; on a switch it's `show ntp status`, not `show run`; on a service it's `systemctl` and `ss`, not the unit file; for a certificate it's `openssl s_client` on the wire, not the object you imported. In one real case a certificate signed with a perfectly clean log and had no SAN at all — reading the file caught it instantly. So my rule is: if I can't paste a runtime read-back, the change isn't done, it's unverified."*

## Related

- **The Playbooks that apply this (link down):** `../Playbooks/Confirm-a-Config-Change-Actually-Took.md` (the general cross-platform read-back drill) · `../Playbooks/Read-the-Cert-Not-the-Sign-Log.md` (this concept applied to certificate issuance — the golden template) · `Verify-an-Edit-by-Counting-the-Old-Text.md` (📋 — the doc/script twin: count what must be *gone*).
- **The commands (link down):** `../Command-Library/README.md` (each platform page carries the read-back rule) · `../Command-Library/FortiOS.md` (`get` vs `show`) · `../Command-Library/Cisco-IOS.md` (`show … status`) · `../Command-Library/RouterOS.md` (`print detail`) · `../Command-Library/Linux.md` (`systemctl`/`ss`).
- **Sibling concept (§3 theme 2):** *the wire ≠ the file; the running service ≠ the config line* — 📋 planned, the "where the truth lives" companion to this "whether a completion is proof" page.
- **Real lineage:** frozen Lab-01 [`MC-0002`](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/MC-0002-MikroTik-Certificate-Reissuance-and-CA-Fix.md) (clean sign log, empty SAN) · `MC-0001` (silent `set`, `get`-not-`show`) · `CM-0030` (config line vs `stratum 16`) · `Operations/016`/`015` (the 7×-repeated rule) — `ADR-0022`-reconciled.
- **The seam + cross-lab map:** `../../Labs/Lab-02-Cisco-Core/Operations/Lab-01-Playbook-Mining-Candidates.md` (§3 recurring themes — this is theme 1) · `../Lab-01-to-Lab-02-Reconciliation-and-Gap-Map.md`.
- **Backlog:** `#36` (mine Lab-01 → Playbooks/Concepts) · `#32` (the searchable briefcase).

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-08-01 | Created (Lab-01 Playbook Project, `Session-26`) — the first **§3 recurring theme** turned into a Concept under the confirmed mentality/machine split (`ADR-0053`): *a command completing is a claim, not evidence — read the running value back.* The three faces (the exit code / the success log / the config line all lie), the rule (runtime read-back per platform; no read-back ⇒ 🟡, `POL-0001`), grounded in the real `MC-0001` (silent `set`, `get`-not-`show`) · `MC-0002` (clean sign log, empty SAN — the golden-template incident) · `CM-0030` (config line vs `stratum 16`), the 7×-repeated `015`/`016` lesson. The "why" the `Confirm-a-Config-Change-Actually-Took` and `Read-the-Cert-Not-the-Sign-Log` Playbooks link up to. `ADR-0022`-reconciled (tools change, discipline is current). |
