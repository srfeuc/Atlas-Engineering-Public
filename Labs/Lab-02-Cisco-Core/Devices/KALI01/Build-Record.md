---
Title: KALI01 — Build Record (verified as-built state)
Path: Labs/Lab-02-Cisco-Core/Devices/KALI01
Status: ⬜ NOT BUILT — the offensive host does not exist yet. Records the not-built state + what will be verified. Records outrank guides (POL-0001).
Version: 0.1
Date: 2026-07-30
---

# KALI01 — Build Record (verified as-built state)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — ⬜ not built).** Right now the truth is: **it does not exist**. Each row fills in at build (`POL-0008`). Markers: ✅ device-verified · 🟡 lab-unverified · ⬜ not built.

## KALI01 — Kali Linux VM (offensive / validation, VLAN 70)

| Attribute | As-built | Status | Evidence |
|---|---|---|---|
| VM / OS | Kali Linux VM on PVE01/R410 | ⬜ | `Roadmap.md` |
| Addressing | VLAN 70 `10.70.0.x` (📋 proposed) | ⬜ | IP plan (`POL-0008`) |
| Isolation | internet-only; **no standing lab access** | ⬜ | `Diagnostics.md` (to verify) |
| Toolset | nmap · Responder · BloodHound · Metasploit · arpspoof/yersinia · certipy | ⬜ | README Services map |
| Validation wiring | negative test wired per control (tier-deny · L2 · E-W/IPS · PKI/ESC) | ⬜ | `../../Operations/Validation-and-Adversarial-Testing.md` |

> 🔴 **Nothing is built** — KALI01 is a proposed host. At build, fill these from the `Diagnostics.md` read-backs; the *attack* evidence lives in the validation matrix per Game Day (`POL-0001`).

## Related
- `Diagnostics.md` · `Build-Guide.md` · `Build-Checklist.md` · `Roadmap.md` · `Considerations.md` · `../../Operations/Validation-and-Adversarial-Testing.md`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — records the **not-built** state + the rows to verify at build (VM, VLAN-70 addressing, isolation, toolset, validation wiring). All ⬜. |
