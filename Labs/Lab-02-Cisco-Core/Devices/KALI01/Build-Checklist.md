---
Title: KALI01 — Build Checklist (offensive / validation host)
Path: Labs/Lab-02-Cisco-Core/Devices/KALI01
Status: 📋 PROPOSED / not built — line-item, all ⬜. Mirrors Roadmap (POL-0001).
Version: 0.1
Date: 2026-07-30
---

# KALI01 — Build Checklist (offensive / validation host)

<!-- provenance -->
> 🔴 **NOT STARTED.** The offensive host is 📋 proposed. Every `[ ]` → `[x]` only with a read-back once built (`POL-0001`). 🔴 The **controlled-attack model** (isolated by default; paths per Game Day) is non-negotiable — see `Considerations.md`. Detail: `Build-Guide.md`.

## 🔴 GATE-0 — isolation + test model
- [ ] ⬜ **VLAN 70 isolation confirmed** (internet-only; no standing lab access).
- [ ] ⬜ **Game-Day path model agreed** (open one path → test → close; snapshot the target first).

## Stand up
- [ ] ⬜ **Kali Linux VM** on PVE01/R410; VLAN 70; `10.70.0.x` (📋 proposed); take a clean snapshot.
- [ ] ⬜ **Offensive toolset** installed + updated (nmap · Responder · BloodHound · Metasploit · arpspoof/yersinia · certipy). *(README Services map.)*
- **🎯 Gate:** from VLAN 70, KALI01 reaches the internet but **not** the lab (isolation holds).

## Wire into the validation matrix (per control — each a Game Day, `ADR-0011`)
- [ ] ⬜ **Tier-deny** (Phase 3): Tier-2 cred vs Tier-0 object → **refused**.
- [ ] ⬜ **L2/switch** (Phase 2/7): ARP-spoof → **DAI/port-security drops it**.
- [ ] ⬜ **East-west + IPS** (Phase 6/7): denied E-W flow **refused + logged**; exploit/C2 **dropped by FGT UTM / PFSENSE01**.
- [ ] ⬜ **PKI/ESC** (Phase 8): AD CS ESC attempt → **safe**.
- **🎯 Gate (each):** the attack **fails**, the deny is **logged** (correct timestamp), and the path is **closed** after.

## Automation
- [ ] ⬜ Box-as-code (rebuildable Kali + tool config) → `Automation/`; attacks stay hand-run.

## Failure modes (pre-empt)
- 🔴 **A path left open after a Game Day** → a standing threat. Close + re-verify isolation every time.
- 🔴 **Destructive test with no target snapshot** → you break the thing you were testing. Snapshot first.
- 🔴 **Off-scope targets** → out of bounds. VLAN 70 / own lab only.
- 🔴 **Inventing an IP** → drift (`POL-0008`); `10.70.0.x` is 📋 proposed.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created to the standard — all ⬜, opening on the isolation/test-model gate; stand-up (Kali VM VLAN 70 + toolset) → wire the negative test into the validation matrix per control (each a Game Day) → automation; with the pre-empt failure modes (path-left-open; no-snapshot; off-scope; invented-IP). |
