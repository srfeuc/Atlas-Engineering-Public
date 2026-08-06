---
Title: CCNA Ch5 — Introduction to TCP/IP Transport and Applications (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — reverse index for the transport/applications chapter (objectives 1.5/4.3). Objective → Atlas artifact + gaps. On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch5 (Vol 2) — Introduction to TCP/IP Transport and Applications

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it.* Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — never copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **1.5** (TCP vs UDP) + **4.3** (DHCP & DNS roles). Reverse-indexes into [`§1.5`](../../../Command-Library/Cisco-IOS.md#15--compare-tcp-to-udp) / [`§4.3`](../../../Command-Library/Cisco-IOS.md#43--explain-the-role-of-dhcp-and-dns).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap.

## On this page
1. [Transport & applications](#1--transport--applications)
2. [Gaps this page surfaces](#2--gaps-this-page-surfaces)

---

## 1 — Transport & applications

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🔧 Playbook | Status |
|---|---|---|---|---|---|
| 1.1 | **TCP vs UDP** — connection-oriented vs best-effort | [Cisco-IOS §1.5](../../../Command-Library/Cisco-IOS.md#15--compare-tcp-to-udp) | the `015` trap (`telnet host 443` = TCP-open) | [Test-a-Connection](../../../Playbooks/Test-a-Connection.md) | ✅ (concept) |
| 1.2 | **DHCP & DNS roles** | [Cisco-IOS §4.3](../../../Command-Library/Cisco-IOS.md#43--explain-the-role-of-dhcp-and-dns) | DHCP-on-DC01 · Pi-hole/AD-DNS | [Recover-from-a-DNS-Outage](../../../Playbooks/Recover-from-a-DNS-Outage.md) | ✅ |

> 🔴 **Atlas trap (`015`):** a successful `ping` proves ICMP, not that a TCP service (443/636) is open — prove the *real* protocol.

---

## 2 — Gaps this page surfaces

- 📋 **No transport/ports Concept page** (TCP handshake, why ICMP ≠ TCP — the `015` trap's teaching).

## Related
- 🔧 Commands: [`§1.5`](../../../Command-Library/Cisco-IOS.md#15--compare-tcp-to-udp) · [`§4.3`](../../../Command-Library/Cisco-IOS.md#43--explain-the-role-of-dhcp-and-dns) *(mutual links)*.
- 🔧 Playbook: [Test-a-Connection](../../../Playbooks/Test-a-Connection.md) · [Recover-from-a-DNS-Outage](../../../Playbooks/Recover-from-a-DNS-Outage.md).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objectives 1.5 / 4.3.
- 📄 **Atlas devices:** the `015` ICMP-vs-service trap; DHCP-on-DC01 + Pi-hole/AD-DNS.
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the TCP/IP-transport chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — Vol-2 reverse index for transport/apps (1.5/4.3): TCP-vs-UDP via the `015` trap + the DHCP/DNS roles (DC01/Pi-hole). Paraphrased from the public blueprint — no book text (Charter Rule 16). |
