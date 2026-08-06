---
Title: GNS3 Simulation Build Guide — Atlas Lab (MKT01 / FGT01 / Cisco + services)
Path (suggested): Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides/  (or a new Simulation/ area)
Status: Reference / build guide. Image sources verified 2026-07-20; licensing changes often — reconfirm at the linked source before you buy or download (Rule 13).
Author: drafted with Claude (Cowork)
Date: 2026-07-20
Scope: How to stand up a GNS3 server and source every node image legitimately to simulate the Atlas lab — MKT01 (RouterOS), FGT01 (FortiOS), the Cisco backbone, and the Linux/Windows services.
---

# GNS3 Simulation Build Guide — Atlas Lab

## TL;DR — the licensing reality

| Vendor | Legit free option? | What it costs to be faithful |
|---|---|---|
| **MikroTik (MKT01)** | ✅ **Yes — CHR free tier.** Runs real RouterOS 7.x, your actual `/ip firewall filter` rules | Free (1 Mbps cap — fine for a lab). Uncap for $45–$250 one-time if you ever want to. |
| **FortiGate (FGT01)** | ✅ **Yes — FortiGate-VM permanent trial.** Runs real FortiOS | Free (limited: ~1 vCPU / 2 GB / low throughput / no FortiGuard). Needs a free FortiCloud account. |
| **Cisco (1941, SW01)** | ⚠️ **No clean free path.** DevNet/CML images are licensed **for CML only** — using them in GNS3 violates Cisco's EULA | **CML-Personal ≈ $199/yr** is the only legitimate way to get IOSv/IOSvL2 for GNS3. Otherwise keep Cisco in Packet Tracer (free) or substitute an open-source node. |
| **Linux services** (Pi01, MON01, NETBOX, CA/Vault, SRV01) | ✅ Yes | Free — Ubuntu/Debian or Docker, running the real apps. |
| **Windows / AD (DC)** | ✅ Yes | Free — Windows Server **180-day eval** from Microsoft. |

**The honest headline:** GNS3 is the right home for the two devices Packet Tracer can't do — MKT01 and FGT01 — and both are free and legitimate. Cisco is the only place money or a compromise enters, because Cisco does not license its virtual images for third-party emulators. Do **not** use torrented/"free IOSv" images — that's the piracy Cisco's EULA is aimed at, and it's easy to avoid.

---

## Part 1 — Stand up the GNS3 server

GNS3 is two pieces: the **GUI** (on your desktop) and a **server backend** that actually runs the nodes. For appliances like CHR and FortiGate (QEMU/KVM), the backend must have **hardware virtualization (nested virt)** available — so the standard pattern on a Windows host is to run the backend as the **GNS3 VM**, not the local Windows server.

Current versions (2026-07): **GNS3 3.0** (GUI, current major), **GNS3 VM v0.15.0** (latest). Keep the GUI and the VM on matching 3.x versions.

Three ways to run the server — pick one:

**Option A — GNS3 VM on your desktop (simplest).**
Install the GNS3 GUI on Windows, then import the **GNS3 VM** appliance into a hypervisor and let the GUI drive it.
- Hypervisor: **VMware Workstation Pro** (now free for personal use) is the smoothest for nested virtualization; Hyper-V and VirtualBox also work (you have Hyper-V installed). If you use Hyper-V, enable nested virtualization on the GNS3 VM (`Set-VMProcessor -ExposeVirtualizationExtensions $true`).
- Give the VM plenty: 4+ vCPU, 16–24 GB RAM for the full Atlas topology.

**Option B — GNS3 as a VM on PVE01 (fits your lab).**
You already run Proxmox (PVE01, the R410). Build an **Ubuntu Server 22.04/24.04** VM there, enable CPU passthrough (`host` CPU type in Proxmox for nested KVM), and `apt install gns3-server`. Your desktop GUI connects to it over the network as a **remote server**. This turns "a GNS3 server" into a real always-on lab backend and keeps the heavy lifting off your laptop.

**Option C — dedicated bare-metal Ubuntu box.**
Same as B but on spare hardware. Best performance, most "server-like," no nesting overhead.

For your ask ("a GNS3 server"), **Option B is the one I'd steer you toward** — it matches how the rest of Atlas is virtualized and gives you a persistent backend.

---

## Part 2 — Where to get each image, legitimately

### MKT01 → MikroTik CHR (RouterOS 7.x) — FREE
- **Download:** MikroTik's site → Downloads → **Cloud Hosted Router (CHR)**. Formats offered: **RAW (.img)**, **VMware (.vmdk)**, **Hyper-V (.vhdx)**, **VirtualBox (.vdi)**. For GNS3/QEMU, the RAW `.img` or the `.vmdk` imports cleanly.
- **License tiers:** **Free = full features, throughput capped at 1 Mbps** (plenty for control-plane and firewall-rule testing). Paid one-time uncaps: **P1 $45** (1 Gbps), **P10 $95** (10 Gbps), **P-Unlimited $250**. A **60-day trial** of the paid tiers exists if you want to benchmark.
- **Why it matters for you:** this runs your actual `/ip firewall filter` rules, the `INPUT-DENIED` / `EAST-WEST-DENIED` log-prefixes, OSPF to the Cisco side — i.e., the firewall-verification pack the audit flagged as *un-testable in Packet Tracer* becomes testable here.

### FGT01 → FortiGate-VM (FortiOS) — FREE (permanent trial)
- **Download:** create a free account at **support.fortinet.com** → **Download → VM Images → FortiGate** → select the **KVM** package (a `.qcow2`, usually zipped). That's the one for GNS3.
- **License:** activate **permanent trial mode** (never expires) with a free **FortiCloud/FortiCare** account. Trade-off: limited to roughly **1 vCPU, 2 GB RAM, low throughput, no FortiGuard live updates, no HA, no support** — but it fully builds and enforces policies, NAT, and zones, which is all a lab needs. Confirm the current limits on the Fortinet doc (they tweak them per release).

### 1941 / SW01 → Cisco — the one that isn't free-and-clean
Cisco's virtual images (IOSv, IOSvL2, IOL, CSR/Cat8000v) are distributed through **Cisco Modeling Labs (CML)** and, per Cisco's EULA, are **licensed for use inside CML only — not GNS3/EVE-NG**. So your legitimate options are:

1. **Buy CML-Personal (~$199/yr)** and lab the Cisco pieces there. Cleanest if you want authentic IOSv in a virtual environment. (Note: even with CML, extracting the images to run in GNS3 is a gray area — the licensed use is *within CML*. If you go CML, do your Cisco labs in CML.)
2. **Keep Cisco in Packet Tracer** (free, you already use it). Your 1941 build works perfectly there. Run the Cisco slice in PT and the RouterOS/FortiOS/services slice in GNS3.
3. **Substitute an open-source node** for the Cisco *role* in the GNS3 topology so the lab is complete end-to-end without Cisco licensing:
   - **VyOS** (rolling release, free) — a full Linux router; great stand-in for the 1941's OSPF/routing backbone.
   - **FRRouting** — free routing stack.
   - **Arista vEOS** (free with an Arista account) or **Nokia SR Linux** (free) — if you want vendor-grade CLI that isn't Cisco.
   - For the switch (SW01): **IOSvL2** needs CML; otherwise use an **Ethernet switch** built-in node or Arista vEOS for L2.

**Recommended hybrid for Atlas:** GNS3 runs MKT01 (CHR) + FGT01 (FortiGate) + the Linux/Windows services + a **VyOS** stand-in for the 1941 backbone, giving you a complete, legitimate, fully-free topology. Keep authentic Cisco IOS practice in Packet Tracer (or CML if you buy it). That way nothing in the free path touches Cisco's EULA.

### The services (all FREE, run the real thing)
| Node | Image | Source |
|---|---|---|
| Pi01 (DNS/NTP/RADIUS) | Ubuntu/Debian Server, or Docker | ubuntu.com / Docker Hub — run Pi-hole + FreeRADIUS + chrony |
| DC / Active Directory | **Windows Server 2022/2025 Eval (180-day)** | Microsoft Evaluation Center |
| MON01 (SNMP/syslog) | Ubuntu + your stack | ubuntu.com |
| NETBOX01 | NetBox Docker | Docker Hub / netbox-community |
| CA01 / VAULT01 | Debian + your PKI + Vaultwarden | debian.org / Docker Hub |
| End hosts | GNS3 **VPCS** (built-in), Ubuntu Desktop, or Docker | built-in / free |
| Proxmox PVE01 | Proxmox VE ISO | proxmox.com — note: it's a hypervisor, so in-sim you usually run its *guests* directly rather than nesting Proxmox |

GNS3 can also pull many of these as ready-made **appliance templates** from the GNS3 GUI's "New appliance" catalogue (it fetches the official free ones and tells you where to get the licensed ones).

---

## Part 3 — Import steps (the two that matter)

**MikroTik CHR:**
1. Download the RAW `.img` (or `.vmdk`) from MikroTik.
2. GNS3 GUI → New appliance template → QEMU → point it at the CHR disk. RAM 256 MB, 1 vCPU is plenty.
3. Boot; default login `admin` / no password. Add your VLAN interfaces, paste your MKT01 config, and run the firewall rules.

**FortiGate-VM:**
1. Download the **KVM (.qcow2)** package from support.fortinet.com; unzip.
2. GNS3 GUI → New appliance template → QEMU → attach the qcow2. 1 vCPU / 2 GB RAM. Add a small second "log/data" disk if the template asks.
3. Boot; default `admin` / no password → set password → register/activate permanent trial with your FortiCloud account → build your policies.

---

## Part 4 — Sizing the whole topology

Everything here is light except Windows. Rough RAM budget for the full Atlas lab:
- CHR (MKT01): 256 MB · FortiGate: 2 GB · VyOS (1941): 512 MB · switch node: 512 MB
- Pi01/MON01/NETBOX/CA/Vault (Linux): ~512 MB–1 GB each
- Windows Server DC: 2–4 GB · hosts (VPCS): negligible

**~16 GB RAM runs a solid slice; 24–32 GB runs the whole thing comfortably.** Your R410/PVE01 handles this easily — another reason to put the GNS3 server there (Option B).

---

## Next steps I can do for you
- Draft the **topology-wiring plan** that maps this GNS3 lab to your `Cabling-and-Port-Map` and `IP-Addressing-Plan-VLSM` (which node port connects to which, VLAN trunks, the two /30 transits).
- Write the **step-by-step CHR + FortiGate import runbook** in your numbered Build-Guide style.
- Produce the **VyOS-as-1941** config that reproduces your OSPF backbone + `default-information originate`, so the GNS3 topology routes end-to-end without Cisco.

---

## Sources (verified 2026-07-20)
- MikroTik CHR download + license tiers — MikroTik documentation & downloads
- FortiGate-VM permanent trial — Fortinet Document Library
- Cisco CML-Personal / EULA (images are CML-only) — Cisco + independent legal summaries
- GNS3 3.0 / GNS3 VM v0.15.0 — GNS3.com & GNS3 GitHub releases
