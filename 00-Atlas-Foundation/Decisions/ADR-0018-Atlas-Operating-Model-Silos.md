# ADR-0018 — The Atlas Operating Model: Team Silos and Ownership Boundaries

| Item | Value |
|---|---|
| Status | ✅ **Accepted** — 2026-07-17 |
| Governing Policy | Charter (constitutional — governed directly by the Charter, not a POL; see Atlas-Governance-Framework §1) |
| Scope | **Global** — estate-wide principle (applies across labs) |
| Date | 2026-07-14 (accepted 2026-07-17) |
| Related | `ADR-0015` (pack sequencing), `Atlas-Service-Architecture.md`, `Atlas-Charter.md` |
| Evidence Status | **`Target Design`** |

> **This ADR exists because the operating model lived in a chat message and nowhere else** — the exact failure `ADR-0012` and `ADR-0015` were written to stop.

## Context

Atlas is a one-person lab. **The silos below are roles, not people.** You will play all of them. **The point is not to pretend to be a team — it is to force the boundaries a real team creates**, because those boundaries are what make IaC, change control, and least-privilege *mean* something instead of being ceremony.

> **A silo you can freely cross whenever you like is not a silo. It is a comment.** The value is that crossing one is a deliberate act with a record.

## The silos

| Silo | Owns | May change without asking | Must NOT touch |
|---|---|---|---|
| 🔵 **Network Infrastructure** | SW01, MKT01, 1941, FGT01, VLANs, routing, physical layer | Switch/router config **within an accepted design**, port assignments **recorded in NetBox** | Server OS, service configs, AD |
| 🟢 **Systems / Compute** | PVE01, VMs, Proxmox, storage, the Linux estate | VM lifecycle, host patching, resource allocation | Network device configs, firewall rules, PKI roots |
| 🔴 **Security / PKI** | The CA hierarchy, Vaultwarden, firewall *policy*, RADIUS, IDS, CIS baselines | Certificate issuance, firewall **rule** changes, secret rotation | Routing, VM provisioning (may **audit** both) |
| 🟡 **Network Services** | DNS, DHCP, NTP, syslog, SNMP, NetFlow, TFTP, monitoring | Service config, monitoring thresholds, DHCP scopes | The devices being monitored; the network they run on |
| ⚪ **Platform / DevOps** | NetBox, Ansible, Terraform, Oxidized, CI, the git repo itself | Automation code, the source of truth **schema** | Production state directly — **changes flow THROUGH automation, not around it** |

## 🔴 The rule that makes the silos real

> **A change that crosses a silo boundary requires a Change Record. A change within a silo, within an accepted design, does not.**

**Worked example — "add a new VLAN":**

1. **Platform** adds it to NetBox (source of truth). *(within silo)*
2. **Network** renders and applies the switch/router config **from NetBox**. *(within silo)*
3. **Security** decides the east-west firewall policy for it. *(crosses into Security → CR)*
4. **Services** adds a DHCP scope and DNS records. *(within silo)*

**Four silos, one VLAN, and the only Change Record is the one that crosses into firewall policy** — the one that can actually break isolation. **That is the point.** The boundary tells you where the risk is.

## 🔴 Silos own functions, not boxes

**The boundary is drawn around the function being changed — not the hardware it runs on.** Atlas runs consolidated hardware, so a single box routinely hosts more than one silo, and the model collapses the moment you treat "which host am I on" as the boundary:

- **FGT01 is split.** The appliance, its interfaces, and its routing are 🔵 **Network**; the firewall *policy* on it is 🔴 **Security**. Editing an interface and editing a rule are two different silos on the same box.
- **Pi01 carries two silos at once.** DNS, DHCP, and NTP are 🟡 **Services**; the CA, Vaultwarden, and RADIUS are 🔴 **Security** — all on one Raspberry Pi. Touching Pi-hole is Services; touching the CA is Security, and that is a boundary crossing **even though you never left the box.**
- **MKT01 already holds a mis-filed function.** A 🟡 Services concern (RADIUS) lives there as a 🔵 Network firewall rule — the exact cross-silo artefact this ADR cites below.

> **You do not cross a boundary by SSHing to a different host. You cross it by changing a different function.** A box is not a silo. The work is.

## Why this matters for a lab of one

**Every disaster in Atlas was a boundary crossing that nobody noticed:**

- `CM-0011` — a **Network** action (BMC hardening) executed against a stale baseline. **No boundary, no pause, degraded hardware.**
- `CM-0014` — a **Platform** action (`git add .`) that committed a **Security** artefact (a passphrase). **The two silos would never have let that through the same hands.**
- The RADIUS rules on MKT01 — a **Services** concern implemented as a **Network** firewall rule on the wrong device.

> **The silos are not bureaucracy. They are the pauses that would have caught the mistakes.**

## Consequences

- **Least privilege becomes concrete.** Ansible service accounts get scoped **per silo** — the automation that configures switches cannot touch the CA.
- **IaC gets a shape.** Repos/roles map to silos. **`ADR-0015`'s Book 6 (IaC) builds on this, not the reverse.**
- **The Charter gains the learning rule** (below), because the operator playing every silo must not let the AI play them instead.

## Companion Charter amendment — the Learning Rule

> 🔴 **Locked Rule 17: Atlas exists to teach. Where a configuration is itself the learning objective — a router, a switch, a service the operator is studying — the assistant provides the design, the validation method, and the failure modes, and the OPERATOR writes the configuration. The assistant does not hand over finished config for the operator to paste, on the systems the operator is trying to learn.**

> ⚠️ **Numbering correction (2026-07-17).** This ADR originally proposed the Learning Rule as *"Locked Rule 16."* But the Charter had already assigned Rule 16 to *"Verify a correction by COUNTING the OLD text"* — added the **same day** (2026-07-14) out of the `ADR-0019` audit. The two collided, and the Learning Rule was the one that fell through the gap: it was **never filed in the Charter and operated on the honor system across every session since.** It is now **Charter Locked Rule 17**, filed in the locked-rules list. The rule Atlas has been working under is finally a rule — which is the precise `ADR-0008` / `ADR-0012` failure this ADR was written to stop, caught in the act one level down.

**This rule would have changed tonight.** It does **not** apply to remediation under time pressure (the passphrase rotation, the git purge) — those were operations, not lessons. **It applies to Book 10 and beyond**, where the whole point is that *you* learn to configure SNMP, QoS, and a Cisco router. **The assistant's job there is to be the senior engineer who reviews and explains — not the one who types.**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Proposed 2026-07-14. Captures the silo operating model from chat into the repo. Defines five silos, the boundary-crossing = Change Record rule, and proposes Charter Locked Rule 16 (the Learning Rule). |
| 1.1 | **Accepted 2026-07-17.** Learning Rule **renumbered to Charter Locked Rule 17** (16 was already taken by the count-the-OLD-text rule) and filed in the Charter — it had never actually landed. Added **"Silos own functions, not boxes"** (the model was collapsing on Pi01/FGT01, which each span two silos). Boundary-crossing = Change Record **wired into the Change Management Process** (named as a CR trigger) and **the Change Record templates** (a `Silo(s) / boundary crossed` field), so the rule no longer lives only here. |
