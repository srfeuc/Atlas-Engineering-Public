---
Title: [System] Troubleshooting Guide
Path: [Path in Confluence]
---

# [System] Troubleshooting Guide

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Draft |
| Version | 0.1 |
| Applies To | Atlas 2.0 |
| Last Updated | [Date] |

## Purpose

This guide covers how to diagnose and resolve common problems with [System]. It assumes the system was previously working and something has changed. For initial build problems, see the Build Guide.

---

## Before You Start

Confirm the basics before assuming a complex failure:

- [ ] Is the device powered on?
- [ ] Is the physical cable connected and the link light on?
- [ ] Has anything changed recently — configuration, firmware, cabling, adjacent devices?
- [ ] Is this one device affected or multiple? (Scope narrows the cause)
- [ ] What is the exact symptom and error message?

---

## Diagnostic Approach

Work from Layer 1 upward. Do not jump to Layer 3 routing problems when the cable might be unplugged.

```text
Layer 1 — Physical: link state, speed, duplex, cable
Layer 2 — Switching: VLAN, trunk, STP, ARP, DHCP snooping
Layer 3 — Routing: gateway, route table, firewall rules
Layer 4+ — Services: DNS, NTP, authentication, application
```

---

## Symptoms and Resolution

### [Symptom 1 — Short Description]

**Symptom:** What the engineer observes. Include exact error messages where applicable.

**Scope:** Which devices or users are affected.

**Likely causes:**
- Cause A
- Cause B

**Diagnostic steps:**

```text
[Command to run]
```

Expected output if healthy:

```text
[What healthy looks like]
```

What to look for if broken:

```text
[What a failure looks like]
```

**Resolution:**

```text
[Command to fix it]
```

**Verify fix:**

```text
[Command to confirm the fix worked]
```

---

### [Symptom 2 — Short Description]

*(Repeat structure above)*

---

## Quick Reference — Common Commands

| Task | Command |
|---|---|
| [Description] | `[command]` |
| [Description] | `[command]` |

---

## Escalation

If the issue is not resolved after working through this guide:

1. Capture current state: run all diagnostic commands and save output
2. Check the Build Record — confirm current config matches verified state
3. Check the Lessons Learned page for similar past issues
4. Open a Change Record if a configuration change is needed to resolve
5. If the device needs to be rebuilt, use the Build Guide and Build Record as the baseline

---

## Related Pages

- [System] Build Guide
- [System] Build Record
- Network Lessons Learned
- Network Validation Guide
