---
Title: PAW01 — Considerations (open risks & decisions)
Path: Labs/Lab-02-Cisco-Core/Devices/PAW01-Tier0-Admin
Status: 🟠 LIVING — open risks, gates, and unsettled decisions for the Tier-0 PAW + golden image. Closed items move to the Build-Record / Change Log.
Version: 1.1
Date: 2026-07-29
---

# PAW01 — Considerations (open risks & decisions)

> **What this is.** The honest "what could bite us / what's not settled" list for the Tier-0 PAW — separate from the steps (`Build-Guide.md`) and the checks (`Diagnostics.md`).

## Open gates
- 🔴 **Credential Guard (VBS) is gated on the Proxmox VBS check** — the same `msinfo32 → VBS Running` capability gate as the DC Wave-B GPOs; the hypervisor must expose the CPU security features to the VM. Win11's Secure Boot + vTPM satisfy the hardware side; the hypervisor exposure is the open question.
- 🔴 **7d deny-cross-tier must be applied for the PAW to mean anything.** Until the 7d GPOs exist + are linked, a Tier-1/Tier-2 account isn't actually denied logon here — the "Tier-0 only" property is structural (OU + GPO placement) but **not enforced**. Ties to the DC's open 7d gate.

## Standing risks (design)
- 🟡 **Placement is the RAM swing item (`ADR-0036` v1.2).** Recommended on the always-on **EQR6** (Tier-0 admin reliably reachable, principle 4), but a Win11 PAW at 8 GB is a real chunk of the EQR6's (upgraded) 64 GB alongside the always-on stack. If headroom is tight, PAW01 **spins up on the R410** when admin work is needed (a PAW doesn't strictly need 24/7 uptime). Decide at build once the EQR6 RAM picture is real.
- 🔴 **Native-VLAN-10 trap (corrected 2026-07-22).** Do **not** put the PAW on VLAN 10 — it's the *native* (untagged) VLAN on the PVE trunk, and a VM tagged VLAN 10 loses return traffic. Use VLAN 20 (tagged), server range `.10–.55`, **avoiding the `.2–.9` Tier-0 block**.
- 🔴 **`sysprep /generalize` breaks on a per-user Store app** ("installed for a user, but not provisioned for all users") and on an encrypted volume (Win11 24H2+). Keep the golden image clean (Audit Mode, no Store-app churn, BitLocker off) — `Test-SysprepReadiness.ps1` flags these.
- 🟡 **The PAW is deliberately locked down (AppLocker allow-list, no browser/mail).** That constrains what automation can run *on* it — factor into the `Automation/` design (agents/tooling must be allow-listed).

## Open decisions (need a call / ADR when reached)
- 🟡 **On-prem subset now vs the cloud-managed PAW (Part 3 / Phase H2).** Microsoft's current PAW guidance is Intune/Entra/Autopilot/Conditional-Access-centric; Atlas is on-prem AD today. The build implements the on-prem-achievable subset now and lands the cloud controls when hybrid identity (H1) + Intune (H2) exist — a **designed deferred delta** (MD-102), not a skip.
- 🟡 **AppLocker vs WDAC** — AppLocker allow-list now (simpler); WDAC is the stronger modern option to revisit.
- 🟡 **Edition** — Windows 11 **Enterprise** is the better PAW OS (Credential Guard/AppLocker first-class); Pro works with caveats. Confirm the licence/edition.
- 🟡 **Golden-image reuse scope** — the same template feeds the VLAN-50 client fleet (`ADR-0042`); keep the baked-in layer generic + role-neutral so it stays reusable.

## Decided (audit #22, 2026-07-30)
- **Services map + mermaid edge-labels backfilled** (Standard v1.7 / v1.6; Backlog #27) — the admin-console + golden-image rows + protocol/port on every diagram edge (`RSAT · RDP/3389 · LDAPS/636`, …). Both rows honest ⬜ (not built, `POL-0001`).
- **No separate `Networking-Build-Guide.md` for PAW01** *(operator policy — appliances point, hosts get new)*. Standard tagged-VLAN-20 VM; the one network subtlety (the **native-VLAN-10 trap** → use VLAN 20 tagged) already lives in Standing risks + the IP plan (`POL-0008`), not a bring-up guide.

## Related
- `Roadmap.md` · `Build-Checklist.md` · `Build-Guide.md` · `Scripts/` · the tier model (`../DC-Domain-Controllers/Build-Guide/DC01/Tiered-Admin-and-Groups-Build.md`) · `ADR-0036` (placement) · `../../Operations/Validation-and-Adversarial-Testing.md` (the 7d cross-tier-deny proof).

## Change Log
| Version | Changes |
|---|---|
| 1.1 | 2026-07-30. **#22 audit:** added a **Decided** section — Services map + mermaid edge-labels backfilled (Standard v1.7/v1.6, Backlog #27, both ⬜); no separate `Networking-Build-Guide.md` (VLAN-20 VM; native-VLAN-10 trap already captured in Standing risks). |
| 1.0 | 2026-07-29. Created — open gates (Credential-Guard VBS check, 7d enforcement), standing risks (placement RAM swing item, native-VLAN-10 trap, sysprep-generalize gotchas, AppLocker constrains on-box automation), and open decisions (on-prem-vs-cloud PAW delta, AppLocker-vs-WDAC, edition, golden-image reuse scope). |
