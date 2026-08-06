# ADR-0005 — FGT01 Firewall Policy Scope: Keep Broad Pending Network Redundancy

| Item | Value |
|---|---|
| Status | Accepted |
| Governing Policy | POL-0012 |
| Scope | **Lab-01-Mikrotik-Core** |
| Date | 2026-07-12 |

## Context

Live validation of FGT01 (2026-07-12) found policy 1 (`LAB-to-Internet`) using `srcaddr all`, while Build Record 021 documented a scoped design (`Lab-Network`, `Transit-Link` address objects) that doesn't actually exist on the device. This was initially logged as an unresolved discrepancy — unclear whether the scoped design was ever implemented or the policy was broadened later.

**Update, 2026-07-13 — resolved via an archived prior session:** the scoped design genuinely existed once. A richer ~10-policy set was built, including named rules `LAN-DNS-to-Pihole`, `Mgmt-SSH-to-Pi`, `Mgmt-SSH-to-MikroTik`, `WiFi-to-WAN-Internet`, and `Deny-All-Log`. That build also had a real, documented incident: the `Lab-Network` address object was scoped to `10.0.0.0/24` instead of `10.0.0.0/8`, causing an actual lab-wide internet outage before being corrected. A live pull from that same archived session (Thursday, July 9) already shows FGT01 back down to the single `LAB-to-Internet` policy with `srcaddr all` — the same state found in this session's own validation. So the current minimal policy isn't unexplained drift; it's consistent with a deliberate rebuild-from-scratch that predates this whole session, matching Build Record 021's own note that additional policies get "added via Change Records as services are deployed."

## Alternatives Considered

1. **Recreate the originally-documented scoped address objects** (`Lab-Network` = `10.0.0.0/8`, `Transit-Link` = `172.16.0.0/29`) and narrow the policy back to them, matching the original design intent.
2. **Retire broad internet access from the lab network entirely**, treating any access from `10.0.0.0/8` as an explicit, individually-justified exception rather than a standing allow — raised as an option during this session.
3. **Keep the current broad policy (`all`) as-is for now**, and revisit once the network has real redundancy (a second WAN path, redundant firewall/routing design) rather than a single FGT01/single-ISP-path topology. Chosen.

## Decision

**Keep `srcaddr all` on policy 1 for now.** Neither narrowing to the original scoped objects nor retiring broad access entirely happens at this time. This is a deliberate deferral, not an oversight — the discrepancy is resolved by being written down as an intentional choice rather than left as an unexplained gap.

## Rationale

With a single FGT01 and a single upstream path, aggressively narrowing outbound access now raises real risk of breaking something quietly (NTP, DNS-over-HTTPS/TLS, package updates across Pi01, MKT01, PVE01, and FGT01 itself all currently depend on broad outbound reachability) without the redundancy in place to safely test and recover from a misconfigured narrower policy. Tightening this is the right long-term move, but it's a "do it right, not first" item — better done once there's a redundant path to fail over to during testing, rather than rushed now under Network-freeze pressure.

## Consequences

- FGT01 Build Record's Known Deviations entry for this item updates from "unresolved" to "deliberately deferred per this ADR," not silently dropped.
- No CM record needed right now — there's no change to make.
- This becomes a real, scoped project once network redundancy exists, not something to half-do incrementally.

## Review Trigger

Revisit when the network gains real redundancy — a second WAN/ISP path, a redundant firewall or routing design, or equivalent. At that point, actually enumerate what needs outbound access (NTP, DNS, update repositories, etc.) and build a real scoped policy, tested against the redundant path before cutover. The recovered policy names above (`LAN-DNS-to-Pihole`, `Mgmt-SSH-to-Pi`, `Mgmt-SSH-to-MikroTik`, `WiFi-to-WAN-Internet`, `Deny-All-Log`) are a real starting reference, not a blank-slate redesign — and the `10.0.0.0/24`-vs-`/8` scoping mistake from the original build is a specific, documented thing to avoid repeating.
