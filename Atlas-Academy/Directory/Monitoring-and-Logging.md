---
Title: Monitoring and Logging — Full Directory
Path: Atlas-Academy/Directory
Status: 🟢 Living — the exhaustive twin of the Source-of-Truth router's §6. Telemetry, syslog, SNMP, and the SIEM — with the real frozen-Lab-01 telemetry-hygiene record.
Version: 0.1
Date: 2026-08-03
---

# Monitoring and Logging — Full Directory

> **The deep version of [Source-of-Truth §6](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#6-monitoring-and-logging).** The router gives you the one-glance answer; this page is the *encyclopedia* — the telemetry sinks, what ships where, the syslog/SNMP tooling, the decisions, and the **real, device-verified records** that teach why telemetry so often reads "configured" while being silently blind. Keep the router in a tab for speed; come here when you want the whole picture.
>
> Each device folder carries the standard page-set (`ADR-0037`): **README** (front door + Services map) · **Build-Guide** (target) · **Build-Record** (verified reality) · **Diagnostics / Troubleshooting** · **Considerations** · **Changes/** · **Automation/**.
>
> 🔒 **The real records here are frozen Lab-01 (`ADR-0022`) — history, not current guidance,** but the telemetry-hygiene lessons in them (clean SNMP, synchronised clocks, a cabled SPAN) carry straight into the Lab-02 MON01 build. Read them for *why a green config can still be blind*; reconcile to the live design.

## On this page

1. [The sinks](#1-the-sinks) — MON01 (network detect) + SIEM01 (host/correlation)
2. [The telemetry model](#2-the-telemetry-model) — what ships where, one-directional
3. [The tooling (#34)](#3-the-tooling-34) — commands + the log/SNMP playbooks
4. [Real telemetry-hygiene records (frozen Lab-01)](#4-real-telemetry-hygiene-records-frozen-lab-01) — the goldmine
5. [The rule and the decisions (ADRs)](#5-the-rule-and-the-decisions-adrs)
6. [The Academy and cert alignment](#6-the-academy-and-cert-alignment)

---

## 1. The sinks

The estate's **Detect** layer (NIST CSF) is split in two — the network half and the host half — deliberately kept off each other's box.

| Host | Role | Status |
|---|---|---|
| [`MON01-Monitoring`](../../Labs/Lab-02-Cisco-Core/Devices/MON01-Monitoring/) | The network-visibility + detection sink — rsyslog, SNMPv3→LibreNMS, NetFlow, Suricata IDS on the SW01 SPAN, Grafana + Uptime-Kuma | 📋 Not built — Phase 6; the gate for Phase-7 segmentation |
| [`SIEM01-Wazuh`](../../Labs/Lab-02-Cisco-Core/Devices/SIEM01-Wazuh/) | The host-based SIEM/XDR (Wazuh) — FIM/SCA/vuln + correlation; ingests MON01's Suricata + syslog for one pane | 📋 Committed, not built (dedicated host — OpenSearch is RAM-heavy) |

> **Honest status (`POL-0006`/`POL-0001`): this is the domain that is most *designed and least built*.** Both sinks are ⬜ — MON01's Build-Record reads *"every row is ⬜ until a real read-back is captured,"* and SIEM01's *"the host SIEM does not exist yet."* That matters beyond this page: **MON01 is the Phase-6 gate** — three SW01 punch-list items and the whole Phase-7 east-west default-deny cutover wait on it, because you can't tighten flows you can't yet see (the [allowed-flows matrix](../../Labs/Lab-02-Cisco-Core/Architecture/Atlas-East-West-Allowed-Flows-Matrix.md) is meant to be proven from MON01's NetFlow first). Nothing here is marked ✅ on intent.

## 2. The telemetry model

- **One direction only.** MON01 *polls out* and *receives* — nothing initiates a session back into monitoring (east-west matrix flow #2). The sinks are a collection point, not a service other zones call.
- **What ships where** — the devices send, MON01 collects, SIEM01 correlates: **syslog** (udp/514) from every device → rsyslog on MON01; **SNMPv3** (udp/161) polled by LibreNMS; **NetFlow** (2055) for the flow-matrix evidence; a **SPAN** off `SW01 Gi1/0/5` into **Suricata** (detect, not drop); MON01's Suricata + syslog then feed **SIEM01/Wazuh** for host+network correlation (Section K, K8).
- **Placement** — split by weight (`ADR-0036`): a light always-on probe (Uptime-Kuma + minimal syslog) on PVE02/EQR6; the heavy stack (LibreNMS/NetFlow/Suricata/Grafana) on PVE01/R410.
- **The senders live on their devices** — each device's `Diagnostics.md` owns its own send-side config; this page (and the Command-Library) is the cross-device *collector* view (`POL-0004` — point, don't restate).

## 3. The tooling (#34)

Backlog **#34** makes syslog + SNMP first-class troubleshooting tools. The method is authored now; the device read-backs land 🟡→✅ as MON01 and the senders come up (`POL-0001`).

- 🖥️ **Commands** — [Syslog-and-SNMP](../Command-Library/Syslog-and-SNMP.md) (the collector-side reads — rsyslog listening on 514, LibreNMS `validate.php` / `snmpwalk -v3`; and the per-platform sender config for Cisco/RouterOS/FortiOS/Linux) · [Linux](../Command-Library/Linux.md) (`journalctl`, `ss -tulpn`) · [Cisco-IOS](../Command-Library/Cisco-IOS.md) (`show ntp status`, `show snmp`)
- 🔧 **Playbooks** — [Trace-It-in-the-Logs](../Playbooks/Trace-It-in-the-Logs.md) (find an event in centralized syslog — 🟡 pending MON01) · [Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device](../Playbooks/Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device.md) (walk the poll chain; tells *device-down* from *up-but-SNMP-blind* — 🟡 pending MON01) · [Read-the-Logs-with-journalctl](../Playbooks/Read-the-Logs-with-journalctl.md) (per-host Linux journals — **usable today**, not gated on MON01) · [Fix-the-SW01-Clock](../Playbooks/Fix-the-SW01-Clock.md) (the clock a log needs)

## 4. Real telemetry-hygiene records (frozen Lab-01)

**The goldmine.** Telemetry is the classic *"configured ≠ working"* trap — a device can hold a perfect-looking SNMP or NTP line and be completely blind. Each record below is a real, dated finding read straight off the device. 🔒 Frozen (`ADR-0022`); each lesson carries into the MON01 build.

**The SNMP that pointed at a ghost**

- [`CM-0023` — remove the carried-over v2c SNMP community](../../Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Changes/CM-0023-Remove-Carried-Over-SW01-v2c-SNMP-Community.md) — a live **cleartext SNMPv2c community `homelab`** carried over from Lab-01, *plus a trap host pointed at an address that doesn't exist* — the origin of the SW01 `.52` mistarget the [MON01 Considerations](../../Labs/Lab-02-Cisco-Core/Devices/MON01-Monitoring/) still tracks as an open re-point:
  > ```
  > SW01# show run | include snmp-server
  > snmp-server community homelab RO
  > snmp-server host 10.40.0.52 version 2c homelab
  > ```
  > *Reconcile:* SNMP returns in Lab-02 as **SNMPv3 (auth+priv) to MON01** only; the cleartext community is a `POL-0002` defect, not a config to carry.
- [`CM-0037` — remove the live SNMP location string](../../Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Changes/CM-0037-Remove-Live-SNMP-Location-String-from-SW01.md) — the build *guide* claimed the `snmp-server location Home-Lab-California` disclosure was removed; the **device** never was (Rule 13 — the device wins; *"empty output is not a pass,"* read `show snmp` Location blank, don't trust an empty `include`).

**The clock that never ticked**

- [`CM-0030` — SW01's clock has never synchronised](../../Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Changes/CM-0030-SW01-Clock-Has-Never-Synchronised.md) — pointed at a host running no NTP server, so it sat at stratum 16 forever. This is the **hard gate for centralized logging** — correlated logs with wrong timestamps are worse than none:
  > ```
  > SW01# show ntp status
  > Clock is unsynchronized, stratum 16, no reference clock
  > ...  system poll interval is 8, never updated.
  > ```
  > *Reconcile:* time now flows from the AD PDC-emulator (`ADR-0020`); fix + proof via [Fix-the-SW01-Clock](../Playbooks/Fix-the-SW01-Clock.md). *Don't build centralised logging on devices whose clocks are unsynchronised.*

**The tap that wasn't cabled**

- [`CM-0036` — re-establish the SW01 SPAN session source](../../Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Changes/CM-0036-Re-establish-SW01-SPAN-Session-Source.md) — the SPAN that feeds MON01's Suricata IDS is only as good as its source port; a detector watching a dead mirror sees nothing while looking healthy.

> The estate-wide lesson (from [`016-Network-Lessons-Learned`](../../Labs/Lab-01-Mikrotik-Core/Operations/016-Network-Lessons-Learned.md)): *a green prompt is not evidence* — and in telemetry, a device that "has SNMP configured" is not a device you can see. The full ledger is [`Lab-01 SW01 Changes/`](../../Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Changes/).

## 5. The rule and the decisions (ADRs)

- **The rule** — [`POL-0006` Evidence & Verification](../../00-Atlas-Foundation/Policies/POL-0006-Evidence-and-Verification.md): a read-back is evidence, a completed command is not — the discipline the whole Detect layer exists to make mechanical · the audit home [`POL-0001`](../../00-Atlas-Foundation/Policies/POL-0001-Atlas-Audit-Policy.md) · the secrets rule the cleartext community broke, [`POL-0002`](../../00-Atlas-Foundation/Policies/POL-0002-Secrets-and-Credentials.md).
- [`ADR-0032`](../../00-Atlas-Foundation/Decisions/ADR-0032-Diagnostics-and-Verification-Doc-Architecture.md) — the diagnostics / detection (monitoring) doc architecture (backlog #34 = syslog + SNMP as first-class tools)
- [`ADR-0020`](../../00-Atlas-Foundation/Decisions/ADR-0020-NTP-Time-Source-Architecture.md) — the NTP time-source architecture (the clock every correlated log depends on)
- [`ADR-0036`](../../00-Atlas-Foundation/Decisions/ADR-0036-Compute-Topology-and-VM-Placement.md) — compute placement (MON01's light-probe / heavy-stack split)

## 6. The Academy and cert alignment

- 📋 **Templates** — [Build-Record](../../00-Atlas-Foundation/Templates/Build-Record-Template.md) · [Device-Verification-Procedure](../../00-Atlas-Foundation/Templates/Device-Verification-Procedure-Template.md) (the read-back a telemetry claim is proven with) · [Change-Record](../../00-Atlas-Foundation/Templates/Change-Record-Template.md)
- 🎓 **Concepts** — [A Completed Command Is Not Evidence](../Concepts/A-Completed-Command-Is-Not-Evidence.md) *(the mentality behind the whole Detect layer)* · the [Concepts index](../Concepts/)
- 🏅 **Cert alignment** — CCNA syslog/SNMP ([CCNA lab map](../Certification/Atlas-Certification-Lab-Map.md)) · log analysis / SIEM is cert-adjacent to **CySA+** *(a dedicated CySA+ map is a known gap — backlog #30-E)* and **[Security+ Domain-5](../Certification/Atlas-Security-Plus-Domain5-Coverage-Map.md)**
- 🔩 **Per-device** — [MON01](../../Labs/Lab-02-Cisco-Core/Devices/MON01-Monitoring/) + [SIEM01](../../Labs/Lab-02-Cisco-Core/Devices/SIEM01-Wazuh/) own their `Diagnostics.md` / `Troubleshooting.md`

## Related

[Source-of-Truth router §6](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#6-monitoring-and-logging) (the quick view) · [Security and Perimeter directory](./Security-and-Perimeter.md) (the flows MON01 proves) · [Servers and Compute directory](./Servers-and-Compute.md) · [Network and Addressing directory](./Network-and-Addressing.md) · [`POL-0006`](../../00-Atlas-Foundation/Policies/POL-0006-Evidence-and-Verification.md) · [`Command-Library/Syslog-and-SNMP`](../Command-Library/Syslog-and-SNMP.md).

## Change Log

| Version | Changes |
|---|---|
| 0.1 | 2026-08-03. First cut — the exhaustive twin of Source-of-Truth §6: the two Detect-layer sinks (MON01 network + SIEM01 host) with honest build status (both 📋 not built — MON01 the Phase-6 gate for Phase-7); the one-directional telemetry model (syslog/SNMP/NetFlow/SPAN → MON01 → SIEM01); the #34 tooling (Syslog-and-SNMP command library + the log/SNMP playbooks, method-authored/read-backs-pending); the **frozen Lab-01 telemetry-hygiene goldmine** (CM-0023 the ghost-host SNMP + cleartext community, CM-0030 the never-synced clock gate, CM-0037 the live location string, CM-0036 the SPAN) with real read-backs; the `POL-0006`/`ADR-0032`/`ADR-0020` rule + decisions; the Academy + cert alignment. Completes the four `Session-29` per-domain twins. |
