---
Title: KALI01 — Roadmap (build path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/KALI01
Status: 📋 PROPOSED / not built — the offensive/validation host. Runs alongside every phase as the negative test (ADR-0041). Mirrors Build-Checklist (POL-0001).
Version: 0.1
Date: 2026-07-30
---

# KALI01 — Roadmap (build path + connections)

> **How to read this.** Each row is a build/enable stage on the attacker host (the security variant — toolset + the controlled-attack model, not services). Checkbox = status. **Needs** = healthy-first; **Unblocks** = what proceeds. Cert objective per stage (`ADR-0044`). 🔴 The attacks run **per Game Day** against a **granted path** (`ADR-0011`), never standing.

## The build path (in order)

### 🔴 GATE-0 — isolation + a safe test model
- [ ] 🔴 **VLAN 70 (Testing) isolation confirmed** (internet-only, no lab access — already enforced) + the **Game-Day path model** agreed (open a specific path → test → close). *Why:* an attacker box with standing lab access undercuts the segmentation it tests. *Cert:* Security+ (test safety).

### Phase (alongside all) — Stand up the host
- [ ] 📋 **Kali Linux VM on PVE01/R410**, VLAN 70, `10.70.0.x` (📋 proposed). Snapshot-friendly (revert after messy tests). *Needs:* GATE-0. *Unblocks:* the toolset. → `../../Architecture/IP-Addressing-Plan-VLSM.md`. *Cert:* Security+ (Linux/tooling).
- [ ] 📋 **Offensive toolset** — recon (nmap), credential-capture (Responder), AD recon (BloodHound), exploitation (Metasploit), L2 (arpspoof/yersinia), AD CS abuse (certipy). *(See the README Services map.)* *Cert:* PenTest+/Security+.

### Phase-matched — wire into the validation matrix (the negative test for each control)
- [ ] 📋 **Tier-deny** (Phase 3) — a Tier-2 credential cannot touch a Tier-0 object. *Proves:* the deny-logon GPOs.
- [ ] 📋 **L2 / switch** (Phase 2/7) — ARP-spoof/DAI + port-security. *Proves:* SW01 L2 security.
- [ ] 📋 **East-west + IPS** (Phase 6/7) — a denied E-W flow is refused + logged; an exploit/C2 is dropped. *Proves:* MKT01 E-W + FGT UTM + **PFSENSE01** IPS.
- [ ] 📋 **PKI / ESC** (Phase 8) — AD CS template abuse (ESC1-8). *Proves:* the PKI is safe.
- Each is a **Game Day** (`ADR-0011`): open the path → attack → confirm refused + logged → close. *Cert:* PenTest+/CySA+ · the specific control's cert.

### Phase 10 — Automation onboarding (`ADR-0048`)
- [ ] 📋 **The box as code** — rebuildable Kali + tool config (cloud-init/Ansible); the **attacks stay hand-run** (the learning). → `Automation/`.

### Future (Backlog)
- [ ] 📋 **OWASP web-app testing** (Backlog #17, when VLAN 30 has a web app) · **SCAP/OpenSCAP compliance scanning** (Backlog #18). *Cert:* PenTest+/CySA+.

## Connections at a glance
| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | PVE01/R410 → SW01 → MKT01 (gw `10.70.0.1`) | VLAN-70 (isolated) reachability |
| ⬆ Depends on | a granted attack path (per Game Day) · internet | the target zone/service · tool updates |
| ⬇ Serves | the Validation-and-Adversarial-Testing matrix | the negative test for every control |
| ⬇ Serves | Game-Day evidence (`ADR-0011`) | proves each deny is real + logged |

## Certification alignment (learning lens)
| KALI01 stage | Exercises (exam objective) | Cert |
|---|---|---|
| Recon / scanning | enumeration, footprinting | PenTest+ · Security+ |
| Credential-capture / AD recon | attacks + AD attack paths | PenTest+ · CySA+ |
| Exploitation / C2 (vs IPS) | exploitation, evading/triggering IPS | PenTest+ · FCP/NSE (from the defender side) |
| L2 attacks (vs DAI) | L2 security testing | Security+ · CCNP security |
| AD CS ESC | PKI abuse (ESC1-8) | PenTest+ · security |
| OWASP / SCAP (future) | web-app testing / compliance scanning | PenTest+ · CySA+ |

## Related
- The matrix (owner): `../../Operations/Validation-and-Adversarial-Testing.md`. The how: `Build-Guide.md`. Line-item: `Build-Checklist.md`. Open risks: `Considerations.md`. Verify: `Diagnostics.md`.
- Owners: `../../Architecture/IP-Addressing-Plan-VLSM.md` (VLAN 70) · `../../Architecture/Atlas-East-West-Allowed-Flows-Matrix.md` · `../../Operations/Build-Order-and-Dependencies.md` · `ADR-0011` (Game Days) · `ADR-0042` (VLAN-70 fleet).

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — the build path for the proposed KALI01 offensive/validation host: 🔴 GATE-0 (VLAN-70 isolation + the Game-Day path model) → Kali VM (PVE01/R410, VLAN 70) → offensive toolset → wire the negative test into the validation matrix per control (tier-deny · L2 · E-W/IPS · PKI/ESC, each a Game Day, `ADR-0011`) → automation (box-as-code, attacks hand-run) → OWASP/SCAP future (#17/#18). Cert-aligned Security+/PenTest+/CySA+. All 📋 (not built). |
