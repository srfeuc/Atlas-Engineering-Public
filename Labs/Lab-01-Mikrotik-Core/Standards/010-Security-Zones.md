---
Title: Security Zones
Path: Labs/Lab-01-Mikrotik-Core/Standards
---

# Security Zones

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Standards

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | ✅ **Published to Confluence 2026-07-13** — page: *Security Zones*. Reconciled against live devices before publication. |
| Version | **2.1** |
| Applies To | Atlas 2.0 |
| Last Reconciled | 2026-07-15 |

| Zone | Networks | Policy Intent |
|---|---|---|
| Untrusted | Internet/home upstream | Never trusted by default |
| Transit | 172.16.0.0/29 | Infrastructure routing only |
| Management | VLAN 10 | Approved administration only |
| Server | VLAN 20 | Services exposed only as required |
| Web | VLAN 30 | Restricted application flows |
| Monitoring | VLAN 40 | Observe required systems; avoid broad admin rights |
| Client | VLAN 50 | User-to-service access |
| Deployment | VLAN 60 | Imaging/provisioning flows only |
| Testing | VLAN 70 | Internet only by target design |
| DMZ | VLAN 80 | Explicitly controlled access |
| Unused | VLAN 999 | No routed traffic |

## Enforcement Layers

FGT01 controls perimeter traffic. MKT01 controls east-west routing. SW01 provides Layer 2 protections. Windows Firewall and identity policy protect hosts and services.

## Unused Interface Policy

Any interface, port, or logical connection with no assigned purpose and nothing connected to it must be administratively disabled, not merely left undocumented at its default state.

This closes a real gap found during live validation, not a hypothetical: SW01 already practiced this correctly **by accident** (`Gi1/0/8-48` shipped `Shutdown, BPDU Guard`) — it was never written down as a rule, it was just how that device happened to arrive. FGT01 did not follow it: **four** factory-default interfaces were found still enabled or undocumented, discovered only through a full live validation pass rather than because anyone knew to look.

### 🔴 What was actually found on FGT01 (`CM-0004`)

| Interface | Found | Why it mattered |
|---|---|---|
| `internal` (hard-switch group) | Enabled, admin-reachable | **Still holding `192.168.1.99`** — the factory bootstrap address |
| `wan2` | Enabled, admin-reachable | Undocumented |
| `fortilink` | Enabled, admin-reachable | Undocumented |
| 🔴 **`modem`** | **Disabled — and in NO Atlas document at all** | 🔴 **Carries an encrypted PPPoE credential.** It is in the running config, and therefore **in every config backup you take.** |

> **`modem` is the sharper lesson of the two.** It was already disabled — so it was never a security exposure. **But nobody had written down that it should be**, which means a rebuilt FGT01 would leave it at whatever the factory default is, and **nobody would notice.** A correct state that nobody recorded is a correct state by luck.

## 🔴 Compliance — checked on the live devices, 2026-07-13

| Device | Unused interfaces | Compliant? |
|---|---|---|
| **SW01** | `Gi1/0/8-48`, `Gi1/0/49-52` | ✅ `Shutdown, BPDU Guard` |
| **SW01** | `Gi1/0/3` | ✅ Shut down deliberately (`ADR-0002`) |
| **FGT01** | `internal`, `wan2`, `fortilink`, `modem` | ✅ All four `set status down` — verified via `show full-configuration system interface \| grep -f "set status down"` |
| **PVE01** | `eno2` | ✅ `DOWN` — not `auto` in `/etc/network/interfaces` |
| **MKT01** | **`ether2`** | ✅ **YES — disabled 2026-07-13** (`X` flag verified, `CM-0015`). On-device comment names the policy and the record. **Was the only non-compliant device found.** |
| **Pi01** | `wlan0` | ✅ **Compliant — but by default, documented nowhere.** `ip link show` 2026-07-13: `wlan0` is **administratively DOWN** (no `UP` flag, `state DOWN`), MAC `00:00:5e:00:53:18`. **A reflash brings it back up and no document says to disable it** — the `modem` failure (`CM-0004`) exactly. |

> 🔴 **When first checked (2026-07-13), `/interface print` on MKT01 showed the flags legend as `R - RUNNING; S - SLAVE`** — RouterOS prints only the flags in use, so **`X - DISABLED` did not appear, and not one interface was administratively disabled. That was the finding.** `CM-0015` fixed it — `ether2` now carries `X` (see the compliance table above).
>
> **`ether2` has no IP, no bridge membership and no route, so the realistic risk today is nothing.** It is raised anyway, because **the policy exists precisely so that you never have to make that judgement about an interface you did not know was on.** An undocumented enabled interface is not low-risk — **it is unassessed.**
>
**All five devices checked.** MKT01 `ether2` was disabled 2026-07-13 (`CM-0015`); Pi01 enumerated 2026-07-13 (`ip link show`).

> 🔴 **Pi01 was almost omitted from this table — by the very pass written to catch omissions.** It was added and enumerated only after the gap was caught. Pi01 is the session's most-omitted device: absent from `005-Device-Responsibilities`, `006-Network-Source-of-Truth`'s ARP ACL, `012-Management-Network`'s core addresses, and `014`'s Production Foundation.
>
> ### 🔴 What `ip link show` on Pi01 actually revealed (2026-07-13)
>
> | Interface | State | Finding |
> |---|---|---|
> | `eth0` (`…45`) | UP | Management — known |
> | `wlan0` (`…47`) | **DOWN (admin)** | ✅ Correctly disabled — but **documented nowhere.** Sequential MAC after `eth0`. |
> | 🔴 **`docker0`** | **UP** | 🔴 **A Docker bridge network — mentioned in NO Atlas network document.** |
> | 🔴 **`veth…@if2`** | **UP**, `master docker0` | 🔴 **A running container** — this is **Vaultwarden** (`044`). The credential vault has its own network namespace, recorded in no source of truth. |
>
> 🔴 **`006-Network-Source-of-Truth.md` shows Pi01 as a single `eth0` at `10.10.0.5`.** The device has **five** link-layer interfaces, one of which is the network side of the vault that holds every credential in the lab. **The "source of truth" describes 20% of Pi01's network reality.** Tracked for a future pass — it is a documentation gap, not a live exposure (`docker0` is host-internal, not routed).

> 🔴 **And the guide reconciliation found the real defect:** `026-MKT01-Build-Guide.md` **did not mention `ether2` at all.** So a router rebuilt from it came back with the interface **enabled, idle and undocumented** — *exactly the state the record was raised to fix.* **The guide recreated the finding.** Fixed.

**The rule, going forward, for every device:**

- An interface with no assigned role gets disabled (`shutdown` / equivalent), not just left at factory defaults.
- If an interface must stay enabled for a reason that isn't "actively passing production traffic today" (e.g., held in reserve for a near-term expansion), that reason is written down in the device's Build Record — an enabled-but-idle interface without a documented reason is the exact gap this rule exists to prevent.
- This applies uniformly: switch ports, firewall interfaces, router interfaces, hard-switch groups, fabric/management interfaces — not just the obvious "network port" case.
- Live validation passes (per `Labs/Lab-01-Mikrotik-Core/Operations/015-Network-Validation-Guide.md`) explicitly check for this — enumerate every interface a device has, not just the ones already expected to be in use, since an unexpected interface is precisely what won't show up if you only check the ones you already know about.

## Change Log

| Version | Changes |
|---|---|
| 2.0 | Security zones and the Unused Interface Policy, reconciled against the live devices and published to Confluence 2026-07-13. |
| **2.1** | 2026-07-15 (`CM-0015`) — corrected the compliance blockquote that still described the pre-fix finding in the present tense (it read as if MKT01 still had no administratively-disabled interface) directly beneath a table recording `ether2` as **disabled**. Reframed as the finding it was; the table (`ether2` = `X`, `CM-0015`) is the current state. |
