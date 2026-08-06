---
Title: Lab-01 → Lab-02 Reconciliation & Gap Map (the shared core + what changed + gap analysis)
Path: Atlas-Academy
Status: 🟢 LIVING cross-lab resource (`ADR-0053` Academy layer). Reconciles the frozen, **device-verified** Lab-01 machines to the current Lab-02 design — what carried over, where each machine's services split off to, and the **gaps** the new design closes (plus the gaps still open in the current partial build). The shared core you'd start a new lab from. Reconcile rule: `ADR-0022` (current design wins; Lab-01 loses where it disagrees).
Version: 1.0
Date: 2026-07-31
---

# Lab-01 → Lab-02 Reconciliation & Gap Map

<!-- provenance -->
> **Book 9 — Atlas Academy · cross-lab resource.** Frozen **Lab-01-Mikrotik-Core** is the estate's richest seam of *real, device-verified* incidents — **its docs were written at the machine**, so they record what actually happened, not what was planned. Much of Lab-01 is **the same hardware and the same discipline** as Lab-02 (SW01 · MKT01 · FGT01 · PVE01 · the Raspberry Pi), so a *reconciled* Lab-01 lesson carries straight into Lab-02 **and the next lab built from it.** This page is the map: **what each machine was, where its services split off to, what carried over, and — most usefully — the gaps the new design closes and the gaps still open today.**

**How to use it.** Three ways: (1) when **building a Playbook** from the Lab-01 seam, reconcile the incident to today's design here first (a Lab-01 fix on retired tech may teach a discipline that's still live but on a different box); (2) when **planning the next lab**, start from "The shared core" below — the parts that are identical are your proven foundation; (3) as a **gap-analysis tool** — read each "gaps closed / still open" row as a mini risk register (some gaps are security vulnerabilities).

## The reconcile rule (unchanged — `ADR-0022` / `POL-0001`)

- The **device beats the doc** (Charter Rule 13). Frozen Lab-01 **loses** where it disagrees with the current design.
- **Still live (same box, same posture):** the R410 hypervisor (PVE01) · SW01 Catalyst 2960X · MKT01 MikroTik RB1100AHx4 · FGT01 FortiGate 60E · the Raspberry Pi · the CMOS/RTC fault (`CM-0012`, UPS-mitigated).
- **Retired (concept-only — do not stand the tech back up):** FreeRADIUS → Windows **NPS** (`ADR-0029`) · the OpenSSL **Lab CA** → **AD CS** two-tier (`ADR-0031`) · Pi01 **DoH**/dnscrypt (`ADR-0009`) · the **flat `10.0.0.0/24`** network → the **VLSM** VLAN plan · **untagged `vmbr0`** → tagged `vmbr0.10`.

---

## The headline example — the Raspberry Pi (PI01 → Pi01)

This is the clearest "one machine, many jobs → split apart" story, and the reason the map exists.

**Lab-01 `PI01` — four services on one Raspberry Pi (a deliberate, documented SPOF):**

| Role (Lab-01) | What it held |
|---|---|
| **Lab CA** (OpenSSL) | Root + Intermediate **private keys** — the lab's whole trust chain |
| **Vaultwarden** | **every credential** in the lab |
| **Pi-hole DNS** | local DNS filtering / forwarding |
| **FreeRADIUS** | device AAA for FGT01 and MKT01 |

> 🔴 The recorded risk (Lab-01 `PI01/README` + `ADR-0004`): *"If PI01 dies, the lab loses its CA, every stored credential, local DNS, and device AAA at once."* One SD-card Pi held the crown jewels. This is the exact trap the teardown runbook (`048`) is built around — **wipe the Pi and you delete your own credentials.**

**Lab-02 `Pi01` — reduced to two jobs, everything else split onto dedicated hosts:**

| Lab-01 role on the Pi | → Where it lives now (Lab-02) | Decision |
|---|---|---|
| Lab CA (OpenSSL Root+Intermediate) | → **AD CS two-tier** — offline root **RCA01** + issuing **ICA01** | `ADR-0031` |
| Vaultwarden | → **BKP01** (dedicated backup/secrets host) | `Devices/BKP01-Backup/Roles/Vaultwarden` |
| FreeRADIUS (device AAA) | → **Windows NPS** on **NPS01** | `ADR-0029` |
| Pi-hole DNS | → **stays on Pi01**, but **reduced**: filtering DNS for the *non-domain* side only; domain machines use **AD-DNS on the DCs**; Pi01 conditional-forwards `atlas.lab` → the DCs | `ADR-0003` / `ADR-0007` |
| *(new)* NTP | → **chrony on Pi01**, inside the estate time hierarchy (PDCe DC01 is the authority) | `ADR-0020` |
| *(reflex to avoid)* DHCP | → **DC01**, never the Pi | `ADR-0030` |

**Gaps this split closes:**

- 🔒 **The crown-jewels SPOF** — the CA, the vault, DNS and AAA no longer die together. Losing Pi01 now costs *non-domain filtering DNS + NTP*, not the entire PKI + every password. (Security vulnerability closed: a single SD-card compromise no longer yields the whole trust chain and credential store.)
- 🔒 **Credential-on-the-wiped-host** — the `048` trap (rebuild wipes the box holding your passwords) is defused: secrets are on BKP01, the CA is offline (RCA01/ICA01), so a Pi rebuild is survivable.
- 🔒 **No NTP server anywhere** — Lab-01 had no time source at all (`CM-0030`, SW01 stuck `stratum 16` pointing at a Pi that served no time). Lab-02 adds an **AD-anchored NTP hierarchy** (`ADR-0020`) — time is now a real, verifiable service.
- 🔒 **OpenSSL-CA fragility** — the manual Lab CA shipped certs with **no SAN** (`MC-0001`/`CM-0027`), had a `copy_extensions`-unset gap, and a `index.txt` that disagreed with the served certs (`CM-0032`). AD CS re-teaches the same PKI with enterprise tooling + auto-enrolment.
- 🔒 **FreeRADIUS foot-guns** — the `==` vs `:=` silent-never-match, the test-user deletion that left RADIUS unverifiable (`CM-0013`). NPS re-teaches AAA policy match on a Windows-integrated stack.

**Gaps still open today (the build is partial — track these):**

- ⬜ **Pi01 itself is a 📋 rebuild** — the reduced-role Pi isn't stood up yet (`Devices/Pi01-DNS-NTP/Roadmap`).
- ⬜ **AD CS ceremony not done** — RCA01 offline root → ICA01 issuing is the tallest dependency; until it's built, "CA → AD CS" is a plan, not a running service.
- ⬜ **NPS not built** — device AAA is designed (`ADR-0029`) but not yet serving.
- ⬜ **Backup never restored** — Vaultwarden on BKP01 is planned; the Tier-1 risk (no backup has ever been restored) is unclosed until a real restore test runs.

---

## Per-machine reconciliation (the still-live boxes)

Each is the **same hardware** in Lab-01 and Lab-02; the role/posture shifted. "What carried" = the proven foundation for the next lab; "What changed" = reconcile a Lab-01 lesson against it.

### SW01 — Catalyst 2960X access switch (same box, same role)

- **What carried:** L2 access + trunking; **DHCP snooping + Dynamic ARP Inspection** with the `STATIC-HOSTS` ARP ACL (`DHCP Permits: 0`, no fallback → a host missing from the ACL is silently dropped, `CM-0022`); the 9600-baud console; the legacy-SSH client quirk.
- **What changed:** the flat VLAN-10 management network → the **VLSM VLAN plan**; ARP/DAI bindings intended to be **rendered from NetBox** (Phase 4), not hand-typed; the port map reconciled.
- **Gaps closed:** **no working clock** (`CM-0030`, stratum 16) → AD-anchored NTP (`ADR-0020`); a Build Guide that rebuilt the switch wrong (`CM-0022`, four ways to drop Pi01) → reconciled guide.
- **Gaps still open:** SW01's clock fix depends on the time source existing; NetBox-rendered bindings depend on Phase 4.
- **Playbooks:** `Diagnose-a-Host-Silently-Dropped-by-DAI` · `Fix-the-SW01-Clock`.

### MKT01 — MikroTik RB1100AHx4 (core router → east-west firewall)

- **What carried:** the box, RouterOS, the **firewall discipline** (interface-scoped rules, first-match-wins, the catch-all drops, `print stats` counters + the deny-log prefixes); **no serial console + MAC-WinBox drops ~15 s** (`ADR-0016`) — the console-less recovery constraint is identical; the `hw=no` trunk-offload requirement.
- **What changed:** **role narrowed** — Lab-01 MKT01 was the *core router* (routing + firewall); Lab-02 splits north-south routing to the **1941** and makes MKT01 the **east-west segmentation firewall** (`ADR-0023`); RADIUS **client → NPS** (`ADR-0029`); the flat `10.0.0.x` → VLSM; OSPF via `redistribute=connected` (v7).
- **Gaps closed:** dead pre-VLAN firewall rules that never matched (`CM-0009`); a Build Guide that never built an **input-chain default-deny** (RouterOS defaults to ACCEPT) → the catch-all drops are now load-bearing and verified.
- **Gaps still open:** the **serial console** is a hard prerequisite for the default-deny E-W role and isn't proven yet (`ADR-0023` gates on it); the E-W rule set is Phase 7.
- **Playbooks:** `MikroTik-EastWest-Inspect-and-Troubleshoot` · `Prove-Exactly-Which-MikroTik-Rule-Acted` · `Remove-a-MikroTik-Firewall-Rule-That-Has-Never-Matched` · `Recover-a-Locked-Out-Router-Out-of-Band`.

### FGT01 — FortiGate 60E perimeter firewall (same box, same role)

- **What carried:** the box; the **`192.168.1.99` break-glass** on `internal3-7` (the only IP recovery path — `CM-0033`); **`get`-not-`show`** (the silent binding failure, `MC-0001`); the hidden Certificates menu; the VDOM model.
- **What changed:** **no-UTM → licensed FortiGuard UTM** (`ADR-0047`, reversing the Lab-01/early-Lab-02 "no UTM"); **selective TLS deep-inspection** with an ICA01 inspection-CA via GPO (`ADR-0050`); **direct LDAPS admin auth** (`ADR-0028`); DNS filtering owned by **Pi-hole, FortiGuard DNS-filter OFF** (`ADR-0051`).
- **Gaps closed:** **stale/absent UTM** (8–11-year-old signatures that protected nothing while appearing to — `CM-0033`) → licensed, maintained UTM; undocumented live interfaces that a hardening pass would have shut → enumerated + reasoned (`Enumerate-Every-Enabled-Interface-Before-Hardening`).
- **Gaps still open:** UTM licensing/config is `ADR-0047` scope, not yet all applied; TLS deep-inspect depends on ICA01 (AD CS).
- **Playbooks:** `Enumerate-Every-Enabled-Interface-Before-Hardening` · `Confirm-a-Config-Change-Actually-Took` · `Trace-a-Blocked-Flow`.

### PVE01 — Dell R410 hypervisor (same box; joined by PVE02)

- **What carried:** the R410; **root-only, no `sudo`**; the **CMOS/RTC fault** (`CM-0012` — the battery swap did *not* fix it; UPS is the mitigation); the VT-x count trap.
- **What changed:** **untagged `vmbr0` → tagged `vmbr0.10`** (native-999); a **second hypervisor PVE02** (Beelink EQR6) added as the **always-on** critical tier while the R410 becomes the **mostly-off spin-up** tier (`ADR-0036`); **DC01 placed on PVE02/EQR6** specifically to avoid the R410 CMOS risk.
- **Gaps closed:** a single hypervisor holding everything → a two-host split with the critical tier off the faulty board; the flat/untagged bridge → tagged VLAN model.
- **Gaps still open:** the `CM-0012` **board-fault decision** (replace vs UPS-forever) is deferred, not resolved; PVE02 is acquired-not-built; the single-8 TB storage SPOF is flagged for Phase 9.
- **Playbooks:** `Proxmox-Inspect-and-Troubleshoot` · `Trace-Three-Symptoms-to-a-Dead-CMOS-Battery` (queued) · `Recover-the-Lab-from-a-Bare-Metal-Teardown`.

---

## Gap analysis as a tool (a key Atlas practice)

The "gaps closed / gaps still open" columns above are a **gap analysis** — the difference between *where a machine was* and *where the design says it should be*, read as a risk register. Use it deliberately:

- **Two kinds of gap.** (1) **Design gaps the new lab closes** — a real weakness in the old build that the reconciled design removes (the Pi SPOF, no-NTP, stale UTM). Many are **security vulnerabilities** — name them as such. (2) **Build gaps still open** — the current lab is only partly configured, so a *designed* mitigation may not be *running* yet (AD CS not built, no restore test). A closed design gap with an unbuilt mitigation is **still an open risk today.**
- **Where it goes.** A gap that's a standing risk → the **Review-Flag-Register** / the backlog (with a tier). A gap that a specific fix addresses → a **Playbook** (optionally as a short *"Gap / what this closes"* note — `ADR-0053` §5, the optional element). A cross-lab structural gap → **here**.
- **The discipline (`POL-0001`).** A gap is "closed" only when the mitigation is **device-verified running**, not when it's designed. Mark designed-but-unbuilt gaps ⬜/📋, not ✅ — same evidence rule as everywhere.

---

## The shared core — what you'd start a new lab from

If you build a **third lab** from this lineage, these are the proven, reconciled foundations to carry (they're identical or near-identical across Lab-01 and Lab-02):

- **The hardware set** — SW01 (2960X) · MKT01 (RB1100AHx4) · FGT01 (60E) · the R410 hypervisor · a Raspberry Pi — with their known quirks documented (console bauds, `get`-not-`show`, `hw=no`, root-only, CMOS).
- **The disciplines** (platform-independent, carry everywhere): read the *running value* back, never the exit code; enumerate every interface before hardening; prove a firewall rule is dead before removing it; rotate a leaked secret first; extract credentials before a teardown; a group's state ≠ its members'.
- **The reconciled design decisions** — split single-box services onto dedicated hosts (the Pi lesson); AD-anchor time; AD CS over hand-rolled OpenSSL; NPS over FreeRADIUS; VLSM segmentation with an east-west firewall.
- **The gap register** — start the new lab by *closing the still-open gaps* above, in dependency order (AD CS → NPS → NetBox → MON01 → backup-restore).

---

## Related

- **Reconcile rule / owners:** `ADR-0022` (freeze Lab-01) · `Labs/Lab-01-Mikrotik-Core/` (the frozen, device-verified seam) · `Devices/Pi01-DNS-NTP/` + `Devices/{SW01,MKT01,FGT01,PVE01}...` (the current-design owners) · the ADRs cited per row.
- **The Playbook project:** `Labs/Lab-02-Cisco-Core/Operations/Lab-01-Playbook-Mining-Candidates.md` (the #36 queue) · `Atlas-Academy/Playbooks/README.md` (the leaves this map reconciles for).
- **Gap tracking:** `Labs/Lab-02-Cisco-Core/Review-Flag-Register.md` · `00-Atlas-Foundation/Roadmap/Atlas-Improvement-Backlog.md`.
- **Backlog:** `#36` (mine Lab-01 → Playbooks) · `#37` (gap analysis as a tool + this map) · `#32` (the offline briefcase).

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-07-31 | Created — the cross-lab reconciliation & gap map (operator ask: "what's common vs what changed, Lab-01 → Lab-02" + gap analysis as a key tool). The Raspberry Pi worked example (four services on one box → split to AD CS / BKP01-Vaultwarden / NPS / reduced Pi-hole+chrony) + per-machine reconciliation for SW01 · MKT01 · FGT01 · PVE01, each with what-carried / what-changed / gaps-closed / gaps-still-open. Gap analysis framed as a tool (design gaps vs build gaps; security-vuln angle; evidence rule). "The shared core you'd start a new lab from." Reconcile rule `ADR-0022`. |
