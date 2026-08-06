---
Title: Hardware-Evidence Run-Sheet — the 1941 CCNA Overlay (authored → device-verified)
Path: Labs/Lab-02-Cisco-Core/Operations
Status: 🟢 LIVING — the turnkey "run the overlay, grab the screenshot, flip the objective" capture sheet. Ties each Build-Guide stage → `SS-##` slot → the reverse-index objective it upgrades from 🟡 authored to ✅ device-verified. Complements the NetBox-facing `SoT-Evidence-Run-Sheet.md`.
Version: 0.1
Date: 2026-08-05
---

# Hardware-Evidence Run-Sheet — the 1941 CCNA Overlay

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE).** This is the **evidence-capture** sheet for the *one* hardware session that flips the biggest cluster of CCNA reverse-index objectives from **🟡 authored** to **✅ device-verified** in a single sitting. It does not re-teach the build — the [`Build-Guide-CCNA-Lab-Overlay`](../Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) is the executable procedure and the ⭐ [`Set-Up-the-1941-for-the-CCNA-Lab`](../../../Atlas-Academy/Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md) Playbook is the "why." This sheet is the **checklist that makes the evidence turnkey**: run the stage, capture the `SS-##`, paste it into the [`Build-Record`](../Devices/1941-Core-Router/Build-Record-CCNA-Lab-Overlay.md), and tick the objective it proves.

> **Why it exists.** The docs have run ahead of the hardware: the reverse-index is complete, but many rows read **🟡 (pattern authored to real Atlas values, not yet confirmed on the box)**. A ✅ needs a **command and its output** (`POL-0001`/`POL-0006`) — never upgrade a marker you can't prove. One overlay session closes that gap for trunking, inter-VLAN routing, and both ACL styles at once.

> 🔴 **House rules still apply.** **Operator types every command** (Charter Rule 17); **read the runtime state back**, never the config file (`POL-0001` R-A1); do **not** invent output. On teardown, run the §7 revert in the Build-Guide (hand the `.1` gateways back to MKT01 — never two devices on `10.<vlan>.0.1` at once).

## How to run this

1. Have the [`Build-Guide-CCNA-Lab-Overlay`](../Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) open beside this sheet — it holds the exact config to type per stage. This sheet holds the **capture + tick** discipline.
2. `tee` each verify to a file (`… | tee 1941-overlay-<stage>.txt`) *and* screenshot it — the text is the searchable record, the `SS-##` is the visual proof for the Build-Record.
3. After each stage, paste the `SS-##` into [`Build-Record-CCNA-Lab-Overlay`](../Devices/1941-Core-Router/Build-Record-CCNA-Lab-Overlay.md) §3 (the slots map 1:1) and tick the objective(s) below.
4. When every row is ✅, refresh the affected reverse-index sub-pages (🟡→✅) and the `SESSION-HANDOFF` (`ADR-0049`), then print the commit block.

---

## The capture matrix — stage → screenshot → objective flipped

| Stage (Build-Guide §6) | Capture | Read-back that proves it | Reverse-index objective(s) it upgrades 🟡→✅ |
|---|---|---|---|
| **1 — Trunk from SW01** | **SS-01** | `show interfaces trunk` (SW01) — trunking, native 999, allowed 10–90,999 | [`Vol1 Ch08 §1`](../../../Atlas-Academy/Certification/CCNA/Vol1/Ch08-Implementing-Ethernet-VLANs.md) (802.1Q trunk, native VLAN) · [`Vol1 Ch10`](../../../Atlas-Academy/Certification/CCNA/Vol1/Ch10-RSTP-and-EtherChannel-Configuration.md) (trunk verify) — blueprint **2.1/2.2** |
| **2 — Router-on-a-stick** | **SS-02/03/04** | `show ip interface brief \| include 0/0` (subints up/up) · `show ip route connected` (a route per VLAN) · VLAN-50→VLAN-20 ping (pre-ACL, open) | [`Vol1 Ch17`](../../../Atlas-Academy/Certification/CCNA/Vol1/Ch17-IP-Routing-in-the-LAN.md) (inter-VLAN routing, subinterfaces) — blueprint **3.x** |
| **3 — Standard ACL 10** | **SS-05/06/07** | `show access-lists 10` before · after (match-count delta) · the deny/permit ping matrix | [`Vol2 Ch06`](../../../Atlas-Academy/Certification/CCNA/Vol2/Ch06-Basic-IPv4-Access-Control-Lists.md) (standard, wildcard, placement, verify) — blueprint **5.6** |
| **4 — Extended named ACL** | **SS-08/09** | `show access-lists CLIENTS-TO-SERVERS` (match counts) · the 443-works / ping-fails test (the `015` trap) | [`Vol2 Ch07`](../../../Atlas-Academy/Certification/CCNA/Vol2/Ch07-Named-and-Extended-IP-ACLs.md) (5-tuple, named, placement) · [`Vol2 Ch08`](../../../Atlas-Academy/Certification/CCNA/Vol2/Ch08-Applied-IP-ACLs.md) (match-count read) — blueprint **5.6** |
| **Revert (§7)** | **SS-10/11** | `show ip ospf neighbor` (MKT01 FULL again) · `show ip route` (VLANs via 10.255.255.6, no subints) | [`Vol1 Ch20`](../../../Atlas-Academy/Certification/CCNA/Vol1/Ch20-Implementing-OSPF.md) / [`Ch21`](../../../Atlas-Academy/Certification/CCNA/Vol1/Ch21-OSPF-Network-Types-and-Neighbors.md) (point-to-point, FULL) — blueprint **3.4** |

## The bonus objective this same session can bank — the OSPF adjacency-stuck drill

The 1941↔MKT01 link is the estate's **real Cisco↔RouterOS interop** case, and it is **device-verifiable on the hardware you already own** (no Packet Tracer needed). While you're on the box, run the flagged Playbook build target from [`Vol1 Ch21 §3`](../../../Atlas-Academy/Certification/CCNA/Vol1/Ch21-OSPF-Network-Types-and-Neighbors.md):

- Force **EXSTART/EXCHANGE** by mismatching MTU on the /30, capture `show ip ospf neighbor` stuck, then fix with `ip ospf mtu-ignore` (or matching MTU) and capture it going **FULL** — that is the whole "the adjacency won't come up" Playbook, from real output.
- **SS-12** `show ip ospf neighbor` (stuck at EXSTART) · **SS-13** the same after the fix (FULL). This seeds the ⭐ `Diagnose-a-Stuck-OSPF-Adjacency` Playbook that Ch21 flags as 📋.

> 🖥️ **Not on this sheet — needs the Packet-Tracer twin.** DR/BDR election, broadcast network types, FHRP/HSRP, inter-switch STP/EtherChannel and DHCP relay need 3+ devices Atlas doesn't have on one /30. Those are captured in the [`Packet-Tracer-Twin-Build-Spec`](./Packet-Tracer-Twin-Build-Spec.md), not here.

## Propagation (after the session)

- [ ] Every `SS-##` pasted into [`Build-Record-CCNA-Lab-Overlay`](../Devices/1941-Core-Router/Build-Record-CCNA-Lab-Overlay.md) §3; the "Lessons Learned" captured for real (SSH drop on the `Gi0/0` re-address? native-VLAN match? dot1q surprises?).
- [ ] The reverse-index rows above flipped **🟡→✅** with the read-back cited (Ch06/07/08, Ch17, Ch08/Ch10-trunk, Ch20/21).
- [ ] Build-Guide `Lessons Learned from Actual Deployment` filled from the real run (not invented).
- [ ] `SESSION-HANDOFF` refreshed (`ADR-0049`) + backlog #44 evidence ticked.
- [ ] Commit block printed for Seth (docs-only; never `git add .`; LF).

## Related

- Procedure: [`Build-Guide-CCNA-Lab-Overlay`](../Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) · evidence sink: [`Build-Record-CCNA-Lab-Overlay`](../Devices/1941-Core-Router/Build-Record-CCNA-Lab-Overlay.md) · teaching: ⭐ [`Set-Up-the-1941-for-the-CCNA-Lab`](../../../Atlas-Academy/Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md).
- Sibling capture sheets: [`SoT-Evidence-Run-Sheet`](./SoT-Evidence-Run-Sheet.md) (NetBox inventory facts) · [`Device-Confirmation-Commands`](./Device-Confirmation-Commands.md).
- Next tracks: [`Packet-Tracer-Twin-Build-Spec`](./Packet-Tracer-Twin-Build-Spec.md) · `Go-Public-Pre-Flight-Checklist` · the session brief `Session-35-Hardware-Evidence-Packet-Tracer-and-Go-Public-Prompt`.
- Commands: [`Command-Library · Cisco-IOS`](../../../Atlas-Academy/Command-Library/Cisco-IOS.md) · map: [`Atlas-Certification-Lab-Map`](../../../Atlas-Academy/Certification/Atlas-Certification-Lab-Map.md).

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44 → hardware phase). The turnkey evidence sheet for the 1941 CCNA overlay: stage→`SS-##`→objective-flipped matrix (2.1/2.2 trunking, 3.x inter-VLAN, 5.6 standard + extended ACLs), plus the same-session OSPF adjacency-stuck drill (SS-12/13, seeds the Ch21 Playbook). Points multi-device objectives at the Packet-Tracer spec. Complements the NetBox `SoT-Evidence-Run-Sheet`. |
