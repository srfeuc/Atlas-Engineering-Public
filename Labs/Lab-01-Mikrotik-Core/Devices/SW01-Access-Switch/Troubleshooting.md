---
Title: SW01 Troubleshooting Guide
Path: Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch
---

# SW01 Troubleshooting Guide

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: SW01 - Role: Access Switch

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Draft |
| Version | 1.1 |
| Applies To | SW01 |
| Last Updated | 2026-07-16 |

## Purpose

Every entry below is a real incident, recovered from an archived prior session covering SW01's original build. For build steps, see `Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Build-Guide.md`.

## Before You Start

- [ ] Never set a placeholder password (like `YourStrongEnablePassword`) and plan to change it later — see the Enable Password entry below for exactly why that's dangerous, not just untidy.
- [ ] Confirm you're using the right `show` command for this specific switch model before concluding a feature is broken — see the `show vlan` entry below.
- [ ] If a VLAN 10 device is unreachable while its switch port is up, suspect `STATIC-HOSTS` before you suspect the device — see the silent-DAI-drop entry below.

## Diagnostic Approach

```text
Console/Access — baud rate, enable password
Port identification — physical port naming vs. logical naming
Command syntax — model-specific command differences
```

---

## Incident: Enable Secret Placeholder Caused a Real Lockout

**Symptom:** Locked out of privileged EXEC mode during initial build.

**Root cause:** setting `enable secret YourStrongEnablePassword` as a literal placeholder value, intending to change it later — and then actually being locked out by it, because it was never actually a placeholder from the switch's perspective, it was a real configured secret from the moment it was set.

**Resolution/prevention:** never set a password value that looks like a placeholder — generate and use the real value immediately, even during initial scratch configuration. If already locked out, this requires the platform's password-recovery procedure (typically a boot-time console break sequence), which is disruptive enough to be worth preventing entirely rather than resolving after the fact.

---

## Incident: `show vlan` Returns "Unrecognized Command"

**Symptom:** `show vlan` fails on this switch even though it's a standard-looking IOS command.

**Root cause:** this model (Catalyst 2960X) requires `show vlan brief` — plain `show vlan` alone isn't valid on this platform, despite working on other Cisco switches.

**Resolution:** use `show vlan brief` on this specific hardware.

---

## Incident: SFP Ports Not Where Expected

**Symptom:** Following a generic guide's port numbering for SFP uplinks (e.g., assuming `Gi1/1/1-4`) doesn't match physical reality.

**Root cause:** on this specific model, SFP ports are `Gi1/0/49-52`, not a separate `Gi1/1/x` numbering block some other Catalyst models use. An assumption carried over from a different switch (the original SG300, in this case).

**Resolution:** confirm actual port numbering with `show interfaces status` or physical inspection before assuming a numbering scheme from a different model.

---

## Incident: Console Access Fails at Default Baud Rate

**Symptom:** Console cable connected, terminal shows garbage or nothing at the assumed default baud rate.

**Root cause:** this switch uses 9600 baud, not 115200 — an assumption carried over from the older SG300 hardware it replaced.

**Resolution:** set the terminal program to 9600 baud for this hardware specifically.

---

## Incident: Proxmox Uplink Port Behavior Confusing Relative to MikroTik Trunk

**Symptom:** Significant troubleshooting time spent on why PVE01's uplink (Gi1/0/4) behaves differently than MKT01's trunk (Gi1/0/1).

**Root cause — not a fault, but an undocumented design decision:** Gi1/0/4 (Proxmox) uses **native VLAN 10**, while Gi1/0/1 (MikroTik trunk) uses **native VLAN 999** (the deliberately-unused catch-all). These are two different, both-correct designs serving different purposes — PVE01's host management traffic is untagged by design (see the PVE01 Troubleshooting Guide's VLAN entry), while MKT01's trunk deliberately has no untagged traffic at all. Without knowing this was intentional, the difference looks like an inconsistency to debug rather than two deliberate choices.

**Resolution:** no fix needed — this is documented, correct behavior. Included here specifically because it cost real troubleshooting time before being understood as intentional rather than a bug.

---

---

## Incident: A VLAN 10 Device Is Unreachable but Its Port Is Up (Silent DAI Drop)

**Symptom:** a static-IP host on VLAN 10 (Pi01, FGT01 mgmt, PVE01, the admin workstation, the iDRAC) is unreachable — no ping, no SSH — yet its switch port shows `connected` and the device itself is healthy.

**Root cause:** Dynamic ARP Inspection is enforced on VLAN 10 with the `STATIC-HOSTS` ARP ACL, and **`DHCP Permits: 0` — there is no DHCP-snooping fallback.** A host whose IP/MAC is not in `STATIC-HOSTS` has its ARP **dropped, full stop.** No error, no warning — it simply looks like a dead device.

**Resolution:** `show arp access-list` — confirm the host's IP/MAC is one of the five entries; `show ip arp inspection` shows the VLAN 10 `ACL Drops` counter climbing if it's being dropped. If missing, add it (read the MAC off the device directly — **never guess**) per `027` §16. This exact omission (Pi01 absent) produced a false *"Pi01 is unreachable"* mystery that survived three handoffs (`016` lesson 6, `CM-0022`).

---

## Incident: Timestamps Are Wrong / Logs Won't Correlate (Clock Never Synced)

**Symptom:** log entries carry a frozen or nonsensical time; SW01's events can't be lined up against any other device.

**Root cause:** SW01's clock has **never synchronised.** `show ntp status` returns `Clock is unsynchronized, stratum 16, never updated`; it is pointed at `10.10.0.5` (Pi01), which serves no NTP (`show ntp associations` → `.INIT.`, `reach 0`). A `ntp server …` config line is not a working clock.

**Resolution:** this is a known open finding, not a quick fix — `CM-0030`, with the time-source decision recorded in `ADR-0020` (external-pool interim; AD PDC-emulator as the target). Do **not** build log correlation (Book 5) on this switch until `show ntp status` reads `Clock is synchronized`.

---

## Incident: SSH to SW01 Fails with "no matching key exchange method"

**Symptom:** `ssh cisco@10.10.0.2` from a modern client fails immediately — `no matching key exchange method found` or `no matching host key type`.

**Root cause:** IOS 15.2 on the 2960X offers only deprecated SSH algorithms; current OpenSSH refuses them by default. Not a fault on the switch.

**Resolution:** connect with the legacy flags (or an `ssh sw01` alias) — see `027` §3:

```text
ssh -oKexAlgorithms=+diffie-hellman-group14-sha1 -oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa -oMACs=+hmac-sha1 cisco@10.10.0.2
```

---

## Quick Reference — Common Commands

| Task | Command |
|---|---|
| Show VLAN info on this model | `show vlan brief` (not `show vlan`) |
| Confirm actual port layout | `show interfaces status` |
| Console baud rate for this hardware | 9600, not 115200 |
| Confirm a VLAN 10 host is allowed by DAI | `show arp access-list` ; `show ip arp inspection` (VLAN 10 ACL Drops) |
| Check the clock actually synced | `show ntp status` — must read `Clock is synchronized`, not `stratum 16` |
| SSH from a modern client | legacy flags / `ssh sw01` alias — see `027` §3 |

## Escalation

1. Check `023-SW01-Build-Record.md` against live state.
2. Check `006-Network-Source-of-Truth.md` for the current port assignment table before assuming a port's purpose.

## Related Pages

- `Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Build-Guide.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Build-Record.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/PVE01-Hypervisor/Troubleshooting.md` — the native VLAN 10 vs. 999 design decision explained from PVE01's side
