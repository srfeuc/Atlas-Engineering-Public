# MC-XXXX — Major Change Title

Use this template for high-risk, multi-system, or complex changes — a full policy rebuild, a domain promotion, a storage migration, anything where the lightweight `CM-XXXX` template's single Backup/Implementation/Validation/Rollback flow doesn't give enough structure to plan and execute safely. For ordinary changes (a port description, a client IP correction, disabling an unused interface), use the standard Change Record Template instead — this one is deliberately heavier, and using it for a small change slows work down for no benefit.

## Document Information

| Item | Value |
|---|---|
| **Status** | **Draft** / Implemented / **Implemented — reconciliation open** / Closed / Superseded |
| **Risk** | Low / Medium / High |
| **Evidence Status** | `Verified` (read off the device) / `Target Design` (not yet executed) |
| Change ID | MC-XXXX |
| Engineer | |
| Date | |
| Maintenance Window | |

> 🔴 **The `Status` row is MANDATORY, and it was missing from this template until 2026-07-13.**
>
> **Consequence:** `MC-0001` and `MC-0002` were both written without one. Both were asserted **Closed** — in the Change Management README and in the pack manifest — **by documents that are not the record.** For weeks, the only place either record's status existed was in an index.
>
> **A status that lives only in an index is a status nobody can verify at the source.** When the index and the record disagree, the record wins — but only if the record actually says something.
>
> 🔴 **A record does NOT move to `Closed` while any closeout box is unticked.** If a box cannot be ticked, the status is **`Implemented — reconciliation open`**. `CM-0009` was marked `Closed` with its *"Build Record updated"* box unticked, and the Build Record then described a firewall that no longer existed **for a full day.**
| Estimated Time | |
| Priority | |
| Risk | |
| Affected Systems | |
| Silo(s) / boundary crossed | *e.g. `Network → Security`; or `within Systems, accepted design` (`ADR-0018`)* |
| Approval Required | |

## Phase 1 — Planning

**Objective** — Why are we making this change?

**Scope** — What devices will be touched?

**Dependencies** — What must already exist? (e.g. VLANs, DNS, Active Directory, PKI, Internet)

**Risks** — What could break?

**Rollback Plan** — If something fails, exactly how do we restore service?

## Phase 2 — Pre-Implementation

**Verify Documentation**
- [ ] Build Guide reviewed
- [ ] Build Record reviewed
- [ ] Standards reviewed
- [ ] Related ADRs reviewed
- [ ] Lessons Learned reviewed

**Verify Backups**
- [ ] FortiGate exported
- [ ] MikroTik exported
- [ ] Cisco configuration saved
- [ ] Proxmox backup completed
- [ ] Windows backup verified

*(Trim this list to what's actually affected — not every change touches every device.)*

**Verify Environment**
- [ ] UPS healthy
- [ ] Storage healthy
- [ ] Time synchronized
- [ ] DNS healthy
- [ ] Internet healthy
- [ ] Monitoring healthy

## Phase 3 — Implementation

Track every step as it happens, not reconstructed afterward:

| Step | Expected Result | Actual Result | Completed By | Time |
|---|---|---|---|---|
| | | | | |

## Phase 4 — Validation

Check only the categories actually relevant to this change:

**Network**
- [ ] Internet
- [ ] Routing
- [ ] DNS
- [ ] VLANs
- [ ] Trunks
- [ ] Management

**Virtualization**
- [ ] Host healthy
- [ ] Storage healthy
- [ ] VM networking
- [ ] Templates

**Windows**
- [ ] AD
- [ ] DNS
- [ ] DHCP
- [ ] PKI

**Monitoring**
- [ ] Wazuh
- [ ] LibreNMS
- [ ] Grafana

## Phase 5 — Documentation

- [ ] Build Record updated
- [ ] Revision History updated
- [ ] Lessons Learned updated
- [ ] Related ADR updated, if applicable
- [ ] Atlas published

## Phase 6 — Closeout

**Did the change succeed?** Yes / No

**Unexpected Issues**

**Improvements for Next Time**

**Lessons Learned**

**Final Status** — Production Accepted / Needs Follow-up / Rolled Back
