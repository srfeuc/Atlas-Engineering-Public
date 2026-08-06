# Microsoft Architecture Reference — Windows Infrastructure & Identity

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

## How to Use This Document

This is a research/reference compilation, not an Atlas Build Guide. Every link below is Microsoft's own documentation (Microsoft Learn, Azure Architecture Center, or Azure docs) — no third-party tutorials except where explicitly noted for extra context. Use this to plan Phase 3 (Windows Infrastructure) and Phase 4 (Identity) from the Atlas Roadmap, then build actual Atlas Build Guides once each piece is live-validated, same as every other pack.

Nothing here has been built or tested yet except what's already live: **DC01 is a promoted domain controller** (Windows Server 2025 eval, cloned from the `TPL-WIN2025` golden image — now **`10.20.0.2`, VLAN 20, promoted `atlas.lab`, device-verified 2026-07-21**), **DC02** is a promoted replica (🟡 operator-reported 2026-07-28, `repadmin`/`dcdiag` read-back pending), and the **golden image lineage (100 → 9000 → 101)** is confirmed real. *(The earlier "DC01 on VLAN 10 untagged / not yet promoted" wording was stale — 07-24 audit M10.)*

---

## Recommended Build Order

Based on real dependencies, not the roadmap's original ordering — each step needs the one before it:

1. **AD DS** on DC01 — first forest, first domain controller. Everything else depends on this existing.
2. **DNS** — almost always installed alongside AD DS in the same wizard; becomes the domain's authoritative DNS.
3. **DHCP** — needs AD DS to authorize the server (rogue DHCP protection).
4. **Group Policy** — needs AD DS; this is where OU structure, password policy, and baseline hardening get defined.
5. **AD CS (two-tier PKI)** — needs AD DS for an Enterprise CA. This is where the open design question below matters most.
6. **Certificate templates & autoenrollment** — needs AD CS live first.
7. **NPS** — can be stood up any time after AD DS exists; benefits from AD CS being live first if using certificate-based RADIUS (EAP-TLS/PEAP) instead of password-based.
8. **Windows Admin Center** — install on a **non-DC** management server or workstation once there's something worth centrally managing (explicitly unsupported on domain controllers — see below).

---

## Open Design Question: Does AD CS Replace or Coexist with the Existing OpenSSL Lab CA?

You already have a working, live-validated two-tier CA (root + intermediate) on Pi01, issuing certs to Pi-hole (in active use), MikroTik, and FortiGate (issued, not yet installed). Microsoft's own two-tier AD CS pattern below is architecturally identical — offline root, online issuing CA — just built with Windows tooling instead of OpenSSL.

Two real options, not a foregone conclusion:

- **Option A — Coexist.** OpenSSL Lab CA keeps serving non-Windows lab infrastructure (Pi-hole, MikroTik, FortiGate, SW01 if it ever needs TLS). AD CS serves only domain-joined Windows resources, since that's where AD CS earns its keep anyway (autoenrollment, NPS integration, smart cards later — none of that works for non-domain devices regardless).
- **Option B — Replace.** Stand up AD CS as the one lab-wide CA, reissue MikroTik/Pi-hole/FortiGate certs from it instead. More "enterprise realistic" in the sense that most real shops run one PKI, not two — but throws away validated, working infrastructure to rebuild something that already works.

Recommendation for what it's worth: **Option A.** Two CAs for two different trust domains (Windows-integrated vs. everything else) is a legitimate pattern, and it avoids re-touching Pi01 infrastructure that's already correctly documented and working. Worth an ADR either way, per the Atlas Roadmap's own suggestion — this is exactly the kind of decision that doc format exists for.

---

## Active Directory Domain Services (AD DS)

**What it does:** The directory itself — forest, domain, domain controllers, the object store everything else (DNS integration, GPO, certificate templates, NPS user lookups) depends on.

**How it fits:** Done — DC01 is a **promoted** domain controller (`10.20.0.2`, VLAN 20, device-verified 2026-07-21) and **DC02** is a promoted replica (🟡 operator-reported 2026-07-28, read-back pending). This section is the reference for what that promotion required.

| Resource | What it covers |
|---|---|
| [Active Directory Domain Services overview](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview) | Core concepts — directory, global catalog, replication |
| [AD DS Design and Planning](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/ad-ds-design-and-planning) | Forest/domain planning strategy |
| [Install Active Directory Domain Services](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/install-active-directory-domain-services--level-100-) | Actual install steps — PowerShell and Server Manager, forest creation |
| [AD DS Deployment](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/ad-ds-deployment) | Deployment hub page, links to every deeper topic |
| [Introduction to AD DS (Training)](https://learn.microsoft.com/en-us/training/modules/introduction-to-ad-ds/) | Free Microsoft Learn training module — forests, domains, OUs, users, groups |
| [Deploy and manage AD DS domain controllers (Training)](https://learn.microsoft.com/en-us/training/modules/deploy-manage-active-directory-domain-services-domain-controllers/) | Training module specifically on DC deployment/migration |

---

## DNS

**What it does:** Name resolution for the domain — SRV records for locating DCs/Kerberos/LDAP, forward/reverse zones, integration with DHCP for dynamic updates.

**How it fits:** This is the service that eventually replaces the current interim DNS design (`1.1.1.1`/`8.8.8.8` direct, per the Network Source of Truth's "Known Deviations" table) with `Windows Server AD DNS → Pi-hole → 1.1.1.1`, matching what's already documented as the target state.

| Resource | What it covers |
|---|---|
| [Domain Name System (DNS) in Windows and Windows Server](https://learn.microsoft.com/en-us/windows-server/networking/dns/dns-overview) | Overview, AD integration, hybrid scenarios |
| [Install and Configure DNS Server on Windows Server](https://learn.microsoft.com/en-us/windows-server/networking/dns/quickstart-install-configure-dns-server) | Quickstart — role install, zones, forwarders |
| [Implement Windows Server DNS (Training)](https://learn.microsoft.com/en-us/training/modules/implement-windows-server-dns/) | Free training module |

Note: DNS installs automatically as an option during the AD DS promotion wizard — you likely won't run this as a fully separate step.

---

## DHCP

**What it does:** Automatic IP assignment. Currently nothing on the network runs DHCP except the MikroTik hint in old planning docs — everything today is static.

**How it fits:** Matches the SOT's target state exactly (`DHCP: Windows Server` / current: `Not deployed`). This is also what would have let DC01 actually get an address if it had been left on VLAN 20 during the earlier session's test — no DHCP scope existed there yet.

| Resource | What it covers |
|---|---|
| [What is DHCP Server in Windows Server?](https://learn.microsoft.com/en-us/windows-server/networking/technologies/dhcp/dhcp-top) | Overview, features (failover, IPAM integration, DNS integration) |
| [Install and configure DHCP Server on Windows Server](https://learn.microsoft.com/en-us/windows-server/networking/technologies/dhcp/quickstart-install-configure-dhcp-server) | Quickstart — install, authorize, create a scope |
| [Deploy and manage DHCP (Training)](https://learn.microsoft.com/en-us/training/modules/deploy-manage-dynamic-host-configuration-protocol/) | Free training module |
| [DHCP failover in Windows Server](https://learn.microsoft.com/en-us/windows-server/networking/technologies/dhcp/dhcp-failover) | Relevant once/if a second DC exists — redundant DHCP without a second physical scope |

---

## Group Policy

**What it does:** Centralized configuration and security baseline enforcement for every domain-joined computer and user — this is also how certificate autoenrollment gets turned on later.

**How it fits:** This is where an OU structure gets designed (the Atlas Roadmap doc doesn't currently define one) and where the eventual SSH-style hardening baseline for Windows machines gets enforced instead of being done by hand per-machine, unlike the manual Linux hardening checklist used on Pi01.

| Resource | What it covers |
|---|---|
| [Group Policy overview for Windows Server](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/group-policy/group-policy-overview) | GPOs, containers vs. templates, OU-level application |
| [Group Policy processing for Windows](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/group-policy/group-policy-processing) | Precedence, inheritance, loopback processing — needed before designing OU structure |
| [Group Policy Management Console](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/group-policy/group-policy-management-console) | GPMC usage — creating, linking, editing GPOs |
| [Implement Group Policy Objects (Training)](https://learn.microsoft.com/en-us/training/modules/implement-group-policy-objects/) | Free training module |

---

## Active Directory Certificate Services (AD CS) — Two-Tier PKI

**What it does:** Windows-native PKI — offline root CA + online enterprise issuing CA, same architecture pattern as the existing OpenSSL Lab CA. See the open design question above before building this.

**How it fits:** Directly parallels `031-Pi01-Lab-CA-Build-Guide.md`. Whichever option (coexist/replace) gets chosen, the two-tier pattern itself is identical to what's already running.

| Resource | What it covers |
|---|---|
| [Active Directory Certificate Services overview](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/) *(hub page, see PKI design considerations below for the real content)* | AD CS role overview |
| [PKI design considerations using AD CS](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/pki-design-considerations) | **Start here** — how many CAs, hierarchy depth, HSM considerations, CDP/CRL planning |
| [What is the Certification Authority Role Service?](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/certification-authority-role) | Enterprise vs. standalone CA, root vs. subordinate |
| [Test Lab Guide: Deploying an AD CS Two-Tier PKI Hierarchy](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/hh831348(v=ws.11)) | Microsoft's own official step-by-step two-tier lab guide — offline root, online enterprise subordinate, CDP/AIA configuration. Written for Server 2012 R2 but the architecture and steps are still current; cross-check specific PowerShell cmdlet syntax against current docs. |
| [Configure the Certificate Enrollment Policy Web Service](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/configure-certificate-enrollment-policy-web-service) | For enrolling non-domain-joined or off-network devices — relevant if Option A (coexist) needs Windows certs issued to something outside the domain |

---

## Certificate Templates & Autoenrollment

**What it does:** Lets domain-joined computers/users automatically receive and renew certificates with zero manual `certreq` steps — the Windows-native equivalent of the manual OpenSSL cert-issuance process currently used for Pi01/MikroTik/FortiGate.

**How it fits:** This is what would issue NPS its server certificate automatically once AD CS exists, and is the mechanism referenced by the Roadmap's Phase 4 "Auto Enrollment" and "Certificate Templates" line items.

| Resource | What it covers |
|---|---|
| [Configure Certificate Auto-Enrollment for Network Policy Server](https://learn.microsoft.com/en-us/windows-server/networking/core-network-guide/cncg/server-certs/configure-server-certificate-auto-enrollment) | Current, Server 2025-applicable — GPO-based autoenrollment specifically for NPS |
| [Configure the Server Certificate Template for Network Remote Access](https://learn.microsoft.com/en-us/windows-server/networking/core-network-guide/cncg/server-certs/configure-server-certificate-template-remote-access-network-policy-server) | Duplicating/configuring the "RAS and IAS Server" template used by NPS |

---

## Network Policy Server (NPS) — Windows RADIUS

**What it does:** Microsoft's RADIUS server/proxy implementation — the direct Windows-world equivalent of the FreeRADIUS instance already running on Pi01.

**How it fits:** This is a genuine architectural decision, not just "add another service." FreeRADIUS on Pi01 already authenticates MKT01 and FGT01 admin logins. Standing up NPS raises the same coexist-vs-replace question as AD CS: does NPS take over network device AAA once AD DS exists (letting it authenticate against real domain accounts instead of a static FreeRADIUS `users` file), or does FreeRADIUS stay as-is since it already works and isn't tied to AD? The FreeRADIUS Build Guide (`033`) already flags this exact question under its own Lessons Learned section — worth resolving both at once, as one ADR, not two.

| Resource | What it covers |
|---|---|
| [Network Policy Server (NPS) overview](https://learn.microsoft.com/en-us/windows-server/networking/technologies/nps/nps-top) | RADIUS server vs. proxy modes, feature overview |
| [Plan NPS as a RADIUS server](https://learn.microsoft.com/en-us/windows-server/networking/technologies/nps/nps-plan-server) | Planning steps — domain membership, VSAs, EAP/PEAP decision |
| [Install Network Policy Server](https://learn.microsoft.com/en-us/windows-server/networking/technologies/nps/nps-manage-install) | Role install — PowerShell or wizard. Notes default ports: 1812/1813/1645/1646 |
| [Configure RADIUS Clients](https://learn.microsoft.com/en-us/windows-server/networking/technologies/nps/nps-radius-clients-configure) | Adding MKT01/FGT01-equivalent NAS entries — directly comparable to FreeRADIUS's `clients.conf` |
| [Configure Network Policies](https://learn.microsoft.com/en-us/windows-server/networking/technologies/nps/nps-np-configure) | Policy-based authorization rules |
| [Network Policy Server Best Practices](https://learn.microsoft.com/en-us/windows-server/networking/technologies/nps/nps-best-practices) | Includes: `Export-NpsConfiguration` contains **unencrypted RADIUS shared secrets** — same handling caution already applied to the FreeRADIUS secrets this session |
| [Deploy Network Policy Server](https://learn.microsoft.com/en-us/windows-server/networking/technologies/nps/nps-deploy) | Deployment hub — links to 802.1X, VPN-specific guides |

---

## Windows Admin Center

**What it does:** Modern browser-based single-pane-of-glass management for Windows Server — replaces a lot of individual MMC snap-ins (Server Manager, Device Manager, Hyper-V Manager) with one web UI. Free.

**How it fits:** Useful once there's more than one Windows Server to manage day-to-day, but has one hard constraint worth flagging now, before it becomes a wasted install:

> **Installing Windows Admin Center on a domain controller is not supported.** It needs its own separate server or workstation.

DC01 is currently the only Windows machine in the lab, so there's nowhere to legitimately install WAC yet — this becomes relevant once a second, non-DC Windows Server or management VM exists (e.g. a future member server, or even just an admin workstation).

| Resource | What it covers |
|---|---|
| [Windows Admin Center overview](https://learn.microsoft.com/en-us/windows-server/manage/windows-admin-center/overview) | What it replaces, hybrid Azure integration |
| [What is Windows Admin Center](https://learn.microsoft.com/en-us/windows-server/manage/windows-admin-center/understand/what-is) | Deeper feature breakdown, Azure Arc integration |
| [Install Windows Admin Center](https://learn.microsoft.com/en-us/windows-server/manage/windows-admin-center/deploy/install) | Install steps — gateway vs. desktop mode, TLS cert requirement |
| [What type of installation is right for you](https://learn.microsoft.com/en-us/windows-server/manage/windows-admin-center/plan/installation-options) | Explicitly states the domain-controller limitation above |

---

## Azure Extension Options

You said you're open to paying for Azure VMs if needed — here's what that would actually unlock, roughly ordered from "genuinely useful for the lab" to "impressive but probably not necessary yet."

### 1. Site-to-site VPN — connect the home lab to an Azure VNet

Would let Azure-hosted resources (a second DC, a DR target, whatever) sit on the same logical network as the home lab, instead of being an island.

| Resource | What it covers |
|---|---|
| [About Azure VPN Gateway](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpngateways) | Service overview, connection types |
| [Tutorial: Create S2S VPN connection (Azure portal)](https://learn.microsoft.com/en-us/azure/vpn-gateway/tutorial-site-to-site-portal) | Actual walkthrough |
| [Azure VPN Gateway topologies and design](https://learn.microsoft.com/en-us/azure/vpn-gateway/design) | S2S vs. P2S vs. VNet-to-VNet — which pattern fits |

**Relevant to your specific hardware:** a site-to-site connection needs a VPN device on the home-lab side with a public IP. **MikroTik RouterOS supports IPsec site-to-site VPN natively** — MKT01 could plausibly serve as that device without adding any new hardware, though this needs its own research pass on the RouterOS IPsec configuration specifically before treating it as confirmed compatible with Azure's expected parameters.

### 2. A second domain controller in Azure (real hybrid AD)

The most "enterprise realistic" option on this list, and where AZ-800/801 study value is highest, given the certs you're pursuing.

| Resource | What it covers |
|---|---|
| [Deploy AD DS in an Azure Virtual Network (Architecture Center)](https://learn.microsoft.com/en-us/azure/architecture/example-scenario/identity/adds-extend-domain) | Reference architecture — subnet design, disk layout for NTDS.dit, Bastion for admin access instead of a jump box |
| [Install Active Directory Domain Services on an Azure VM](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/virtual-dc/adds-on-azure-vm) | Actual deployment walkthrough — new forest or replica DC |
| [Deploy and manage Azure IaaS AD DS domain controllers (Training)](https://learn.microsoft.com/en-us/training/modules/deploy-manage-azure-iaas-active-directory-domain-controllers-azure/) | Free training module, matches AZ-800/801 material directly |
| [Hybrid identity with AD and Microsoft Entra ID (Cloud Adoption Framework)](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/identity-access-active-directory-hybrid-identity) | Bigger-picture design guidance — Entra Connect vs. Cloud Sync, when to deploy DCs vs. use Entra Domain Services |

Real cost driver here isn't the VM (a small B-series VM is cheap) — it's the **VPN Gateway**, which runs continuously and is priced hourly regardless of use. Worth checking current Azure pricing before committing, since that's the actual recurring cost, not the DC itself.

### 3. Azure Bastion — secure admin access without exposing RDP

If a DC or any other management-plane VM ends up in Azure, this replaces "open RDP to the internet" with a managed jump-host pattern — directly relevant given your own Atlas security posture (SSH key-only, no exposed management ports) already applied everywhere else in this lab.

| Resource | What it covers |
|---|---|
| [What is Azure Bastion?](https://learn.microsoft.com/en-us/azure/bastion/bastion-overview) | Overview, SKU tiers (Developer SKU is low-cost/zero-config, worth checking for lab use) |
| [Connect to a Windows VM using RDP - Azure Bastion](https://learn.microsoft.com/en-us/azure/bastion/bastion-connect-vm-rdp-windows) | Actual connection walkthrough |

### 4. Microsoft Entra Domain Services (managed alternative — mentioned for completeness, not recommended yet)

A PaaS-managed AD-compatible domain Microsoft runs for you — no domain controller VMs to patch or maintain. Mentioned here mainly to rule it out: it removes exactly the kind of hands-on DC administration that's the actual point of this phase of the lab for certification study. Real self-managed AD DS (option 2 above) is the better fit for what you're building toward.

---

## What This Document Deliberately Leaves Out

Per the Atlas Roadmap's own scope boundary (Networking/Windows/PKI/Proxmox/Labs/Monitoring don't belong in Atlas Foundation) — this document is scoped to Phase 3/4 (Windows Infrastructure, Identity) only. Not covered here: Phase 5 (Monitoring), Phase 6 (Security baselines/Defender), Phase 7 (Backup/Recovery), or Phase 8 (certification labs) — those get their own research pass when their turn comes up in the roadmap.

## Related Atlas Pages

- Atlas Roadmap (`00-Atlas-Foundation/Roadmap/Atlas-Roadmap.md`) — Phase 3/4 definitions this document expands on
- Pi01 Lab CA Build Guide (`031-Pi01-Lab-CA-Build-Guide.md`) — the existing PKI this plan needs to reconcile against
- Pi01 FreeRADIUS Build Guide (`033-Pi01-FreeRADIUS-Build-Guide.md`) — the existing RADIUS this plan needs to reconcile against
- Network Source of Truth (`006-Network-Source-of-Truth.md`) — "Known Deviations" table already defines DNS/DHCP/NTP target state as "Windows Server," which this document is the plan for
