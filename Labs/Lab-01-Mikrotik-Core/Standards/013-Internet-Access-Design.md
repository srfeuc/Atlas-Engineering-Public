---
Title: Internet Access Design
Path: Labs/Lab-01-Mikrotik-Core/Standards
---

# Internet Access Design

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Standards

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | ✅ **Published to Confluence** — page: *Internet Edge*. |
| Version | **2.0** |
| Applies To | Atlas |
| Last Reconciled | 2026-07-14 |

## Target Path

```text
Atlas VLAN -> MKT01 -> 172.16.0.0/29 -> FGT01 -> Home/ISP Router -> Internet
```

## Responsibilities

- FGT01 owns upstream routing, perimeter policy, logging, and NAT.
- MKT01 owns internal gateways and east-west policy.
- FGT01 requires a return route to Atlas networks.
- MKT01 requires an active default route through `172.16.0.1`.
- Outbound FortiGate policy must match traffic entering `internal1` and enable NAT.

> 🔴 **Match the policy to the *actual* ingress interface.** A narrow `Lab-Network` address object can **silently exclude VLANs** — the policy looks correct and the traffic is dropped with no error. See `016-Network-Lessons-Learned.md`, FortiGate section.

## 🔴 DNS — corrected 2026-07-14

**v1.0 of this page said:**

> *"Current infrastructure may use public resolvers and public NTP temporarily. Target state is Windows DNS and the Active Directory time hierarchy. **Pi-hole is optional later and not authoritative enterprise DNS.**"*

**That was written before Pi-hole became the lab's actual resolver, and it was never revisited.** On the running system:

| Claim in v1.0 | Reality |
|---|---|
| *"may use public resolvers temporarily"* | **Pi-hole on Pi01 (`10.10.0.5`, VLAN 10) is the resolver.** It is not temporary and it is not optional. |
| *"Pi-hole is optional later and not authoritative"* | 🔴 **Pi-hole is authoritative for the lab today.** It holds the local DNS records for `vault.lab`, the MikroTik, and the CA hosts. Local records live in `pihole.toml` — **`/etc/pihole/custom.list` is inert on Pi-hole v6** (`CM-0008`). |
| *"public NTP"* | Still true, and still fine. |
| FGT01 upstream resolution | **DNS-over-TLS**, not plain DNS. Confirmed during the FortiGate Build Record reconciliation. |

**The *target* is unchanged:** once Book 3 exists, Windows DNS and the AD time hierarchy take over for domain machines. **That is a coexistence, not a replacement** — the same split `ADR-0003` (AD CS vs Lab CA) and `ADR-0004` (NPS vs FreeRADIUS) draw for certificates and RADIUS. **Non-domain devices stay on Pi-hole.**

> **The lesson is not that the target changed. It is that a document describing an intended future was left describing the present.** A reader following v1.0 would have concluded Pi-hole was disposable and removed a load-bearing service.

## NTP

Public NTP today (`pool.ntp.org`). Target state is the Active Directory time hierarchy once a domain controller exists. **DC01 is currently stopped and not promoted** — do not write documents that assume it. **The time-source architecture is now decided in `ADR-0020`** — the AD PDC-emulator becomes the authoritative internal source, with an external-pool bridge until the domain exists. 🔴 **SW01 is the exception today:** it points at Pi01 (which serves no NTP) and has never synced, stratum 16 (`CM-0030`).

## Validation

```text
FGT01:   get system dns
FGT01:   diagnose test application dnsproxy 3
Pi01:    pihole status
Any host: nslookup vault.lab 10.10.0.5
```

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Initial internet access design. |
| **2.0** | 🔴 **2026-07-14 — DNS section corrected.** v1.0 called Pi-hole *"optional later and not authoritative enterprise DNS"* and said the lab *"may use public resolvers temporarily."* **Both were false on the running system:** Pi-hole is the lab's resolver, holds the local records, and FGT01 resolves over **DNS-over-TLS**. The target (Windows DNS for domain machines) is unchanged and is a **coexistence**, per `ADR-0003`/`ADR-0004`. Added the ingress-interface warning and validation commands. Found during the Confluence publication pass — the page was about to be published as fact. |
| **2.1** | 2026-07-16 — NTP section now references **`ADR-0020`** (the recorded time-source decision) and flags SW01 as the un-synced exception (`CM-0030`). |
