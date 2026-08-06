---
Title: MON01 · Suricata-IDS — Build Checklist (network detection on the SPAN)
Path: Labs/Lab-02-Cisco-Core/Devices/MON01-Monitoring/Roles/Suricata-IDS
Status: 📋 Target design. You write the config; the role is unproven until Suricata **fires on a test** (`POL-0001`, `016` lesson 4).
Version: 0.1
Date: 2026-07-29
---

# MON01 · Suricata-IDS — Build Checklist

<!-- provenance -->
> **Role:** the estate's **network detection** — Suricata on the `SW01 Gi1/0/5` **SPAN** (a passive mirror of the MKT01 inter-VLAN trunk). Detection, **not** prevention (it sees a copy; it can't drop — prevention is FGT01 UTM `ADR-0047` + pfSense IPS `ADR-0038` N-S, MKT01 E-W). On the R410 heavy-stack VM. Docs: https://docs.suricata.io/.

## Gate
- [ ] 🔴 **SPAN cabled** — `SW01 Gi1/0/5` → this sensor's capture interface (`ADR-0023`).
- [ ] `tcpdump -i <span-if>` shows mirrored frames arriving (prove the tap works *before* trusting the IDS).

## Build steps
- [ ] Install Suricata; bind it to the SPAN capture interface (promiscuous, no IP on that leg).
- [ ] Load + update a rule set (ET Open or similar); tune noisy categories (monitor-first).
- [ ] Ship alerts (`fast.log`/EVE JSON) → Grafana + later **SIEM01/Wazuh** (`ADR-0032`).

## Acceptance (🎯)
- [ ] 🔴 **Suricata alerts on a test** — trigger an EICAR-style / known-bad pattern from LabComputer and confirm the alert in `fast.log` (`../../Diagnostics.md` §3). *A sensor that never fired is unproven.*

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Created as the per-service checklist for the Suricata SPAN-IDS role — detection-not-prevention framing (`ADR-0038`/`ADR-0047`), the prove-the-tap-then-prove-it-fires discipline. |
