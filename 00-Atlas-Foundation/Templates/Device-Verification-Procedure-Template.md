---
Title: [Device] Verification Procedure
Path: [Path in Confluence]
---

# [Device] Verification Procedure

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Draft |
| Version | 0.1 |
| Applies To | [Device] ([role/IP]) |
| Evidence Status | [Unverified / Verified — date] |
| Last Run | [Date, or "never"] |

## Purpose

The **reconcile-to-live** procedure for [Device]: prove the running device actually matches its Build Guide(s) and Build Record, walking each doc from 🟡 (doc-consistent) to 🟢 (device-verified). This is the check you run before a Game Day (`ADR-0011`), after any change, or whenever you doubt a document.

**This page is read-only checks only.** Risks and open items live in the paired **Considerations & Risks** page.

## How to run

The battery is scripted — see `Tools/scripts/[device]-recon.sh`:

```bash
bash Tools/scripts/[device]-recon.sh 2>&1 | tee ~/[device]-recon-$(date +%F).txt
```

`tee` keeps a copy so a truncated paste can be re-read; the run ends with an `END` marker. Or run the batches below by hand.

> 🔴 **Empty output is not a pass.** A command that returns nothing is evidence the *capture* failed, not that the device is clean (Charter Rule 13; `016`). Re-run until you see real content.
> 🔴 **No secrets.** Nothing here prints a key or a shared secret. The one step that needs a secret (`radtest`, etc.) is run by hand — paste only the pass/fail line.

## Verification battery

Replace with the device's real checks. Each row: what proves it, and the expected value from the docs.

### Batch A — [group, e.g. base system]

| Check | Command | Expected (doc ref) |
|---|---|---|
| [e.g. hostname/OS] | `[command]` | `[expected]` ([doc]) |

### Batch B — [group] …

*(repeat batches as needed)*

## Interpreting results

- **Device wins** (Charter Rule 13). Any mismatch is a finding for the Considerations & Risks page, not a reason to "fix the device to match the doc" without thought.
- A **clean command is not a correct artefact** — read the state back, and where a rebuild reads from a *file*, check the file too, not just the wire (`CM-0032`, `016`).

## Last-run record

| Date | Run by | Result | Output |
|---|---|---|---|
| [date] | [who] | [🟢 all match / divergences: …] | [path/link to the tee'd log] |

## Related pages

- Build Guide(s): [NNN]
- Build Record: [NNN]
- **Considerations & Risks: [NNN]-[Device]-Considerations-and-Risks.md**
- Troubleshooting Guide: [NNN] · CIS Checklist: [NNN]
- Script: `Tools/scripts/[device]-recon.sh`
