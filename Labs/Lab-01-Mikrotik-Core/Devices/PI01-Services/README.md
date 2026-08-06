# PI01 — Shared Services

| Item | Value |
|---|---|
| Lab / Era | Lab-01 · Mikrotik-Core — FROZEN 2026-07-16 |
| Host · Role | PI01 (Raspberry Pi) · **Four services on one box** |
| Status | Device-verified |

## Roles this era — documented individually

PI01 breaks the single-responsibility rule on purpose: it runs **four** roles. Each is documented as its own unit under `Roles/`, because in a later lab these split onto separate machines and the lineage carries forward.

| Role | Folder | What it holds |
|---|---|---|
| Lab CA | `Roles/Lab-CA/` | Root + Intermediate private keys — the lab's whole trust chain |
| Vaultwarden | `Roles/Vaultwarden/` | every credential in the lab |
| Pi-hole DNS | `Roles/PiHole-DNS/` | local DNS filtering / forwarding |
| FreeRADIUS | `Roles/FreeRADIUS/` | device AAA for FGT01 and MKT01 |

Host-level docs (`Build-Guide-Base.md`, `Build-Record.md`, `Troubleshooting.md`, `CIS-Hardening.md`, `Verification.md`, `Considerations.md`) cover the Pi itself; each role's build guide lives in its `Roles/` folder.

## 🔴 Concentration of risk

If PI01 dies, the lab loses its CA, every stored credential, local DNS, and device AAA **at once** — and it has hard-hung once, unexplained, root cause never found. This is a recorded, accepted risk (see `Considerations.md` and `ADR-0004`, which is *why* PI01 must not be domain-joined). Not an oversight — a deliberate, documented single point of failure.
