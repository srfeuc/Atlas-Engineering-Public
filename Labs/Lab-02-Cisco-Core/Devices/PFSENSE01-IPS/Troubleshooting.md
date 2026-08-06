---
Title: PFSENSE01 — Troubleshooting (symptom → cause → fix)
Path: Labs/Lab-02-Cisco-Core/Devices/PFSENSE01-IPS
Status: 🟢 LIVING — symptom→cause→fix for the inline IPS. Seeded from the known inline-IPS traps; real incidents append. Verify commands in Diagnostics.md.
Version: 0.1
Date: 2026-07-30
---

# PFSENSE01 — Troubleshooting

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** Symptom → likely cause → fix for the transparent inline IPS. The checks that confirm a fix are in `Diagnostics.md`. **Never invent output** (`POL-0001`).

## Internet is down and PFSENSE01 has a fault
- **Symptom:** no egress; pfSense unresponsive/crashed.
  - **Cause:** 🔴 **fail-closed** — the bridge blocks when pfSense is down (`ADR-0038` v1.2, by design).
  - **Fix:** the **manual transit-bypass break-glass** — re-cable the FGT01↔1941 transit **directly** (bypass the appliance) to restore internet immediately; then recover pfSense out-of-band. This is *why* the bypass must be documented + tested before go-live.

## A legitimate flow is being blocked
- **Symptom:** a known-good site/app fails only through the estate.
  - **Cause:** 🔴 an **untuned Suricata rule** dropping legit traffic (a false positive) — worst under fail-closed.
  - **Fix:** put that rule **category back to monitor-only**, confirm the drop was Suricata (not FGT/MKT), tune/suppress the signature, then re-enable inline. Never enable a category inline before tuning.

## The 1941↔FGT OSPF adjacency dropped after inserting PFSENSE01
- **Symptom:** OSPF between 1941 and FGT01 falls out of FULL right after the appliance goes inline.
  - **Cause:** 🔴 a **bridge/MTU quirk** — the transparent bridge altered MTU or filtered OSPF/hello traffic on the transit.
  - **Fix:** ensure the bridge passes OSPF (protocol 89) + matches MTU end-to-end; confirm the bridge is truly transparent (no IP, no filtering of the routing protocol). Re-check `show ip ospf neighbor` (1941) / FGT.

## Alerts aren't reaching MON01 / Wazuh
- **Symptom:** Suricata logs locally but nothing shows in MON01/SIEM01.
  - **Cause:** syslog export unset/misdirected, or the mgmt path to MON01 is blocked.
  - **Fix:** set the syslog target to MON01/Wazuh; confirm the mgmt-VLAN path; generate a test alert and confirm it lands (one detection pane, K8).

## Don't give the bridge a data-plane IP
- **Symptom:** temptation to "just add an IP so I can route/monitor on the data path."
  - **Cause:** forgetting it is a **transparent bump-in-the-wire** (`ADR-0038`) — an IP + routing makes it an L3 hop competing with the 1941 (`ADR-0023`).
  - **Fix:** don't. Manage it on the **mgmt IP (VLAN 10)** only; the data path stays L2-transparent.

## Related
- `Diagnostics.md` · `Considerations.md` · `Build-Guide.md` · `ADR-0038` v1.2 · `../MON01-Monitoring/` · Academy `Atlas-Academy/Command-Library/`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Seeded from the known inline-IPS traps — the fail-closed internet-outage → manual transit-bypass; the untuned-rule false-positive → monitor-only that category; the bridge/MTU dropping the 1941↔FGT OSPF adjacency; alerts not reaching MON01/Wazuh; and the don't-give-the-bridge-an-IP rule. Real incidents append. |
