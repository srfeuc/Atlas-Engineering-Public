# ADR-0004 — NPS vs. FreeRADIUS: Coexist, Split on Domain Membership

| Item | Value |
|---|---|
| Status | **Accepted** — 🔴 **superseded in part by `ADR-0029` (2026-07-24):** the **FreeRADIUS half is retired**; network-device auth consolidates on **Windows NPS**. The **NPS half of this decision stands and expands** to cover MKT01/SW01/1941. `ADR-0028` had already moved **FGT01 → direct LDAPS**. Read the decision table below as **historical** for FreeRADIUS. |
| Governing Policy | POL-0010 |
| Scope | **Global** — estate-wide principle (applies across labs) |
| Date | 2026-07-11 |
| Revised | 2026-07-13 |
| Related | `ADR-0003` (AD CS vs OpenSSL Lab CA — the same question, asked about certificates) · `ADR-0028` (FGT01 → direct LDAPS) · **`ADR-0029` (drop FreeRADIUS → NPS)** |
| Evidence Status | **`Verified`** for the current-state facts; **`Target Design`** for the NPS half (DC01 does not exist yet) |

## Context

FreeRADIUS runs on Pi01 today, authenticating MKT01 and FGT01 admin logins (`033`). Book 4 plans **NPS**, Microsoft's RADIUS implementation. Once AD DS exists, the question is whether NPS replaces FreeRADIUS, or whether they coexist.

**This is `ADR-0003` asked a second time.** That decision split the CA on domain membership: non-domain devices use the OpenSSL Lab CA, domain machines will use AD CS. **The same fault line runs through RADIUS**, and for the same reason.

## 🔴 The technical fact that decides this

**"Just point FreeRADIUS at Active Directory" does not work for the case you actually want.**

| Approach | MS-CHAPv2 / PEAP? | Why |
|---|---|---|
| **FreeRADIUS → LDAP bind to AD** | ❌ **No** | An LDAP bind can verify a password you already hold in cleartext. **It cannot perform a challenge-response exchange.** MS-CHAPv2 requires the NT hash, which AD will not hand out over LDAP. **802.1X and PEAP with domain credentials are impossible this way.** |
| **FreeRADIUS + `ntlm_auth` / winbind** | ✅ Yes | Works — but requires **domain-joining Pi01** and running Samba/winbind to broker the NTLM exchange. |
| **NPS on Windows Server** | ✅ Yes, natively | It *is* AD. No glue, no brokering, no domain-joined Pi. |

**So the real options are not "FreeRADIUS or NPS." They are "domain-join the Pi, or run NPS."**

### And domain-joining Pi01 is the wrong move

Pi01 already holds, on one Raspberry Pi:

- The **Root CA** and **Intermediate CA** private keys
- **Vaultwarden** — every credential in the lab
- **Pi-hole** — all local DNS
- **FreeRADIUS** — device AAA

**That Pi had an unexplained hard hang requiring a physical power cycle. Root cause never found.**

Adding a **domain membership, a Samba/winbind stack, and a Kerberos dependency** to that host would make the lab's single point of failure also depend on the domain controller — which is a VM, on PVE01, whose **CMOS battery is failing** (`CM-0012`).

> **Tonight demonstrated why this matters.** `043` correctly deleted the `testing`/`password` account — and left FreeRADIUS **unauthenticatable for a full day.** Nobody noticed, because "the service is running" looked exactly like "the service works" (`CM-0013`). **Pi01 is already carrying more than it is being checked for. This decision must not add to it.**

## Decision

**Coexist. The boundary is domain membership — exactly as in `ADR-0003`.**

| Client | RADIUS server | Why |
|---|---|---|
| **MKT01, FGT01, SW01** — network devices, not domain-joinable | **FreeRADIUS on Pi01** | They cannot be domain members. NPS would authenticate them against AD accounts, but the devices themselves stay outside the domain — and FreeRADIUS already does this, working, today. |
| **Domain-joined machines** — 802.1X, VPN, wireless, anything using a **domain credential** | **NPS on Windows Server** | **The only way to get MS-CHAPv2/PEAP against AD without domain-joining a Linux host.** NPS is native, and it is what a Windows shop actually runs. |

**FreeRADIUS is not migrated away from. NPS is not bolted onto FreeRADIUS. Each owns the clients it is actually right for.**

## Alternatives Considered

**Replace FreeRADIUS with NPS entirely.** Rejected — for now. It is a genuine improvement (tying network-device logins to real domain accounts is real security), but it is **a deliberate migration project with its own testing and rollback**, not a byproduct of "NPS exists now." It also makes device admin access depend on AD being up, which is a real availability tradeoff on a lab with one DC.

**Domain-join Pi01 and use `ntlm_auth`.** Rejected. It technically works and is the standard Linux answer — **but it adds a domain and Kerberos dependency to the host that holds the Root CA, the vault, and all DNS.** The blast radius is wrong. If Pi01 is ever rebuilt as a VM with a narrower role, revisit.

**FreeRADIUS + LDAP bind to AD.** Rejected on the technical fact above: **it cannot do MS-CHAPv2**, so it does not solve the case that motivates AD-integrated RADIUS at all. It would look like progress and deliver nothing.

## Consequences

- **Book 4's NPS build is scoped to a use case, not to a takeover.** 802.1X for domain machines, or VPN — a real scenario, built deliberately. It does **not** silently absorb MKT01/FGT01 device AAA.
- **`033` and FreeRADIUS remain load-bearing.** They must be maintained, tested (`CM-0013`), and included in the backup (`049`) — not treated as legacy awaiting removal.
- **This mirrors `ADR-0003` exactly.** Two servers, one boundary: *can this thing join the domain?* **One rule, applied consistently, is worth more than two clever ones.**
- **A future consolidation is not blocked** — it is simply not a side effect. If NPS later takes over device AAA, that is its own change record with its own rollback.

## Review Trigger

- **When DC01 is actually promoted.** It is currently a stopped VM, never promoted — so the NPS half of this decision is `Target Design` and has never been tested.
- **If Pi01 is ever migrated to a VM** with a narrower role, the objection to domain-joining it weakens considerably. Revisit then.
- **Resolve alongside `ADR-0003`**, not separately. They are the same question and should not be allowed to drift apart.

## Note

**The instinct is "AD exists, so point everything at AD." The technical reality refuses.**

An LDAP bind cannot do challenge-response. That single fact turns a config change into either **a domain-joined Raspberry Pi** or **a Windows RADIUS server** — and once the choice is stated that way, it answers itself.

**This is why the ADR exists.** Without it, someone would spend an evening wiring FreeRADIUS to LDAP, watch PAP work, declare victory, and discover months later that 802.1X was never possible.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Raised 2026-07-11. Recommended coexist; not accepted. |
| 2.0 | **Accepted 2026-07-13.** Added the decisive technical constraint — **FreeRADIUS+LDAP cannot do MS-CHAPv2**, so AD-integrated RADIUS means either domain-joining Pi01 or running NPS. Rejected domain-joining Pi01 on blast-radius grounds (it holds the Root CA, the vault, and all DNS, and has an unexplained hard-hang history). **Boundary set on domain membership, mirroring `ADR-0003`.** Cross-referenced `CM-0013` — FreeRADIUS was unauthenticatable for a day and nobody noticed, which is evidence about how much Pi01 is already carrying. |
