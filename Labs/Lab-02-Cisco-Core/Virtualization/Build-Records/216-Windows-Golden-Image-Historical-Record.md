---
Title: Windows Server 2025 Golden Image Historical Record
Document Type: Build Record
Verification Status: Partially verified — updated from recovered build session transcript
---

# Windows Server 2025 Golden Image Historical Record

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

## Confirmed outcomes

- A Windows Server 2025 build VM was created.
- The original build VM is retained as VMID 100, `WIN2025-BUILD-ARCHIVE`.
- QEMU Guest Agent is enabled in the template and was confirmed **Running** during the build.
- VirtIO media is attached.
- The image uses OVMF, Q35, EFI, Secure Boot keys, and TPM 2.0.
- The generalized image was converted to VMID 9000, `TPL-WIN2025`.
- DC01 was cloned or created from the template as VMID 101 — **and separately confirmed via Proxmox `qmclone` task log evidence** (see Reference/Verified Facts, live-session addendum): the real chain is 100 → 9000 → 101.
- **Edition: Windows Server 2025 Standard, Evaluation license.** Confirmed via captured `systeminfo`/`Get-ComputerInfo` output. `WindowsProductName: Windows Server 2025 Standard Evaluation`, `OsBuildNumber: 26100`.
- **Original install date: 6/29/2026.**
- **Update level at time of capture: 3 hotfixes** — `KB5066131`, `KB5073379`, `KB5072725`. This was captured mid-build, not necessarily the final level at Sysprep — see Not Yet Verified below.
- **Hostname at time of capture: `WIN-QBDOACQH9LR`** (Windows-assigned default) — had **not yet** been renamed to `WIN2025-BUILD` at that point in the build.
- **Domain: WORKGROUP** — confirms no premature domain join, consistent with the Build Guide's "do not join the domain" instruction.
- **VirtIO drivers actually installed and confirmed running: VirtIO Balloon Driver and VirtIO Serial Driver only.** Confirmed via a direct driver/service audit in the recovered session (both drivers and both corresponding services — VirtIO Balloon Service, VirtIO Serial Service — verified running).
- **VirtIO storage and network drivers were never installed.** This is now a confirmed fact, not an inference — the audit above only found Balloon and Serial. Consistent with and now explains why the final template uses an IDE system disk and an E1000 NIC rather than VirtIO SCSI/net.
- **Virtualization-based security: Not enabled** at time of capture (`systeminfo` output).
- NIC hardware confirmed as `Intel(R) PRO/1000 MT Network Connection` (E1000 emulated) at time of capture.

## Historical actions believed to have been completed

These match the resulting template but still need confirmation from the archive VM or Windows logs:

- Windows updated to the final level used at Sysprep (only a mid-build snapshot of 3 hotfixes is confirmed — not necessarily the final count).
- Base configuration completed (Power Plan, Server Manager at Logon, IE Enhanced Security Configuration, Remote Management, Windows Firewall review — these were planned as the next steps in the recovered session but their outcomes were not captured before the transcript ends).
- Sysprep executed with Generalize and Shutdown.
- VM converted to template.

## Not yet verified from Windows

- **Sysprep was not confirmed completed anywhere in the recovered transcript.** The last progress checklist in that session still shows Sysprep as an open item, not a completed one. Treat the exact Sysprep invocation (unattend.xml vs. manual GUI steps) as still unknown.
- **Whether a Windows local account named `seth-admin` (or similar) was ever created.** A separate historical Build Record titled "Seth-Admin Account" was referenced by name earlier in the same recovered session as if it documented completed work, but no account-creation command or evidence for it appears anywhere in that transcript. This should be treated as an open question, not assumed either way, until confirmed independently (e.g., from the archive VM's local account list, offline).
- Exact final Windows Defender and firewall state after the "Windows Firewall review" step (planned but outcome not captured).
- Exact final installed driver versions.
- Exact OOBE choices.
- Exact base applications, if any.

## Open item — IP address overlap, needs checking, not assuming

At the time the `systeminfo` snapshot above was captured, the build VM's IP address was `10.10.0.50`. That is the same address later documented elsewhere (Network pack) as the admin workstation / FreeRADIUS `laptop` client address. This may be nothing — the build VM likely didn't hold that address permanently — but it has not been independently confirmed there was no real overlap. Worth a quick check once DC01 or any other Windows VM is assigned a permanent static address in that range.

## Open item — Evaluation license runway

Since the confirmed edition is Windows Server 2025 Standard **Evaluation**, and evaluation licenses have a limited activation window (commonly ~180 days) before the server begins periodic forced shutdowns, this needs an operational check, not just a documentation note: run `slmgr /dlv` on DC01 to determine remaining evaluation time before this becomes an outage rather than a paperwork item.

## Verification plan

Boot the archive VM only through a controlled change because starting a Sysprepped source or archive may alter its historical state.

Prefer offline or non-invasive evidence:

- VM configuration;
- mounted disk inspection;
- Windows event logs;
- Sysprep Panther logs;
- installed driver inventory;
- QEMU Guest Agent service state.

