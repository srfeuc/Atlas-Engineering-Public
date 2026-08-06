# PVE01 — Change Ledger (`Changes/`)

> **Post-build change records for the R410 hypervisor.** One file per change — `CM-####-Short-Kebab-Title.md`, continuing the estate CM sequence — recording **what changed, why, and the read-back evidence**. The rule: **never silently edit the `Build-Record` / the Virtualization Build-Records** — record the change here first, then update the record.

## Open items tracked as CM records
- **`CM-0011` — iDRAC on shared LOM + factory-default credentials.** iDRAC rides `eno1`/`Gi1/0/4` (not out-of-band); factory creds unchanged. See `../Considerations.md`. Owner detail in the Virtualization `PVE01-Networking` / current-state records.
- **`CM-0012` — CMOS/RTC battery dead** (`ADR-0017` defer). RTC resets `2026`→`2018` on power loss; keep on UPS. See `../Considerations.md`.

_No standalone `CM-####-*.md` files in this folder yet — the two open items above are carried in `../Considerations.md` + the Virtualization records; promote to their own files here when a change action is taken._
