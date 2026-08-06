# 050 — PVE01 iDRAC Onboarding Runbook

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Operations

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | **Target Design — NOT yet executed. Blocked on `CM-0012` (CMOS battery).** |
| Version | 1.0 |
| Applies To | PVE01 iDRAC6 (Dell PowerEdge R410 BMC) |
| Last Updated | 2026-07-13 |
| Blocked by | `CM-0012` — the CMOS battery must be replaced and the board proven durable first |

## Purpose

**The iDRAC was never onboarded.** It has an IP (`10.10.0.100`) and nothing else. This runbook brings it to the same standard as every other management interface in Atlas.

> 🔴 **This is a BUILD, not a fix.** `CM-0011` proposed *hardening* the iDRAC as if it had been configured and left insecure. The device disproved that: the iDRAC was never configured at all. **You cannot harden what was never built. You build it.**

## Why this exists — the gap, stated plainly

Every management interface in Atlas is in the PKI, in the vault, and behind a named account. **The iDRAC is in none of them.**

| Standard | Every other device | iDRAC (today) |
|---|---|---|
| Lab CA certificate | ✅ FGT01, MKT01, Pi-hole, Vaultwarden | 🔴 **None** |
| Credential in Vaultwarden | ✅ | 🔴 **None** |
| Named / documented admin account | ✅ | 🔴 Factory `root`, password unknown |
| In a Build Guide | ✅ | 🔴 `201-Dell-PowerEdge-R410-Preparation.md` has **no iDRAC section** |
| Genuinely out-of-band | — | 🔴 **No** — shared LOM on `eno1`/`Gi1/0/4`, dies with SW01 |
| Remotely reachable | — | 🔴 **No** — IPMI-over-LAN disabled, web UI unreachable |

**The iDRAC is not exposed. It is absent.** Onboarding it is net-new configuration, and it must happen in a specific order or it recreates the very problems it fixes.

## 🔴 Prerequisite — `CM-0012` must be Closed first

**Do not run any step below until the CMOS battery is replaced and the board is proven to hold config across a full power cycle** (`CM-0012` Step 2).

> **Configuring a BMC that cannot hold its settings is documenting a lie.** Every value you set — password, certificate, IPMI channel state — may silently revert on the next power loss, and on a board with no working remote path you would have **no way to detect that it had.** That is the trap this entire session exists to prevent, applied to the one device that most invites it.

## Order of operations — do NOT reorder

Each step depends on the one before. The order is chosen so that **nothing is configured on a surface that cannot be verified.**

### Step 1 — Move iDRAC to the dedicated NIC (same chassis visit as the battery)

The R410 has an **unused dedicated iDRAC port** on the back panel. Today the iDRAC rides `eno1`'s shared LOM (`Gi1/0/4`), which means it **dies with SW01** — step one of any teardown — and is therefore not out-of-band at all.

- **Do this while the chassis is already open for the CMOS battery.** Same screwdriver, one visit.
- Cable the dedicated iDRAC port to a switch access port on VLAN 10.
- 🔴 **The iDRAC MAC changes** when it moves off the shared LOM. Update SW01 `STATIC-HOSTS` and `006-Network-Source-of-Truth.md` with the new MAC, or ARP inspection will silently drop it (`DHCP Permits: 0`, no fallback).

> **This is what makes "out-of-band" true rather than aspirational.** An iDRAC on the dedicated port survives an SW01 wipe on a *different* port; an iDRAC on the shared LOM does not.

### Step 2 — Enable the management path deliberately

IPMI-over-LAN is currently `Access Mode : disabled`. The web UI is unreachable. **Enable exactly one path on purpose, with a plan to secure it — not by default.**

- Prefer the **web UI** (HTTPS, cert-capable) over raw IPMI-over-LAN unless a specific tool needs IPMI.
- If enabling IPMI-over-LAN: set `Access Mode` to a usable value on channel 1, and immediately confirm cipher 0/1/2 stay `X` (`ipmitool lan print 1` → `Cipher Suite Priv Max : XXXaXXXXXXXXXXX`).

### Step 3 — Named account + password in Vaultwarden

- Set a password on the admin account. 🔴 **≤ 20 characters** — `ipmitool` rejected a >20-byte password this session; this is a real IPMI 2.0 client constraint, not a style choice.
- Generate the value **in Vaultwarden**. Store as `PVE01 - iDRAC - BMC Admin` (flat naming, `044`).
- **Read the credential back with an authenticated session before trusting it:**
  ```bash
  # From Pi01, after the path is up:
  ipmitool -I lanplus -H <idrac-ip> -C 3 -U root -P '<pw>' chassis status
  # Expect: System Power: on
  ```
  🔴 **This authenticated read-back is the proof the onboarding worked. Without a reachable path it is impossible — which is why Steps 1–2 come first.**

### Step 4 — Lab CA certificate

The iDRAC is the **only management interface in Atlas outside the PKI.** Issue it a Lab CA certificate per `035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md`.

- Give it a real hostname — e.g. `idrac.lab` — and a Pi-hole DNS record.
- SAN must include the current management IP **and** the hostname (`042` / the MKT01 SAN lesson: a certificate whose SAN omits the browsed address throws a name mismatch even with a perfect chain).
- Verify on the wire: `openssl s_client -connect <idrac-ip>:443` shows `issuer=CN=Home Lab Intermediate CA`.

### Step 5 — SNMP

`SNMP Community String : public` is the vendor default. **There is no SNMP collector in Atlas** (SW01 points SNMP at `10.40.0.52`, a monitoring host that does not exist).

- **Disable the SNMP agent entirely** rather than renaming the community. There is nothing to monitor with it, and a disabled agent is a smaller attack surface than a renamed one.
- Revisit only when monitoring (Book 5) actually exists.

## Validation — the whole onboarding, read back from outside

```bash
# From Pi01 (a second VLAN 10 host) unless noted
ipmitool -I lanplus -H <idrac-ip> -C 3 -U root -P '<pw>' chassis status    # System Power: on
ipmitool -I lanplus -H <idrac-ip> -C 0 -U root -P '' chassis status        # MUST fail
openssl s_client -connect <idrac-ip>:443 </dev/null 2>/dev/null | openssl x509 -noout -issuer -ext subjectAltName
```

- [ ] Authenticated cipher-3 session returns `System Power: on`
- [ ] Cipher-0 session **rejected** — and this time the rejection is *meaningful*, because the channel is now open (unlike `CM-0012`, where the channel was disabled and the same result proved nothing)
- [ ] Certificate issuer is `CN=Home Lab Intermediate CA`; SAN includes the IP and `idrac.lab`
- [ ] Credential is in Vaultwarden as `PVE01 - iDRAC - BMC Admin`
- [ ] New MAC (post-NIC-move) is in SW01 `STATIC-HOSTS` and `006-Network-Source-of-Truth.md`
- [ ] SNMP agent disabled

> 🔴 **The cipher-0 test is only valid once the channel is open.** In `CM-0012` the same command "passed" against a *disabled* channel and proved nothing. Onboarding is what makes that test mean something — the control finally exists.

## Documentation updates — on completion

- [ ] `201-Dell-PowerEdge-R410-Preparation.md` — add an **iDRAC onboarding pointer** to this runbook; hardware prep should hand off here.
- [ ] `024-PVE01-Network-Build-Record.md` — record the iDRAC's real state: dedicated NIC, new MAC, `idrac.lab`, Lab CA cert, credential vaulted.
- [ ] `006-Network-Source-of-Truth.md` — new iDRAC MAC in the MAC table **and** `STATIC-HOSTS`.
- [ ] `044`-convention Vaultwarden entry created.
- [ ] `048-Teardown-and-Rebuild-Runbook.md` — once the NIC move is done, iDRAC **becomes** a valid bootstrap path. Update the bootstrap table (it currently, correctly, says iDRAC is not independent).

## Note

**This runbook exists because `CM-0011` asked the wrong question.** It asked *"how is the iDRAC misconfigured?"* The device answered *"it isn't configured."* Those need different documents: a Change Record moves a live system from one state to another; **a Build Guide brings something into existence.** The iDRAC needs the second.

> **The absence of a document is itself a finding.** `201-Dell-PowerEdge-R410-Preparation.md` has no iDRAC section — so a rebuild produces exactly today's state: an IP and nothing else. This runbook is the section that was missing.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Created 2026-07-13. Replaces the "hardening" framing of `CM-0011` (closed as substantially false) with an onboarding build: NIC move → deliberate path enable → named account + vaulted password → Lab CA cert → SNMP disable. Blocked on `CM-0012` (CMOS battery) — do not configure a BMC that cannot hold its settings. |
