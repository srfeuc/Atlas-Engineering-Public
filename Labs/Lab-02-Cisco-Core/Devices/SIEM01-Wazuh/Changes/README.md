# SIEM01 — Change Ledger (`Changes/`)

> **Post-build change records for the host SIEM.** One file per change — `CM-####-Short-Kebab-Title.md`, continuing the estate CM sequence. The rule: **never silently edit the `Build-Record`** — record the change here first. 🔴 **Adding an active-response rule is high-blast-radius** (it can block a legitimate host/IP) — log each response rule + the tuning that justified it, and start alert-only (`ADR-0041`).

_No change records yet — the device is committed but not built (dedicated host decided; VLAN/sizing → #20). Current state: `../Build-Record.md` (⬜) + `../Roadmap.md`._
