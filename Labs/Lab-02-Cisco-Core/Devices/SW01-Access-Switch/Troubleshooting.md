---
Title: SW01 Troubleshooting Guide
Path: Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch
---

# SW01 Troubleshooting Guide

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** - Host: SW01 - Role: L2 Access/Distribution Switch (Cisco Catalyst 2960X, IOS 15.2)

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Living |
| Version | 1.0 |
| Applies To | SW01 |
| Last Updated | 2026-07-21 |

## Purpose

Every entry below is a **real incident on SW01** with the root cause and the verified fix. For build steps see `Build-Guide.md`; the cross-device timeline lives in `Build-Progress-Tracker.md` — this page is the SW01-specific detail.

## Before You Start

- [ ] **Read STATUS, not `show run`** (`POL-0001` R-A1) — `show ip dhcp snooping`, `show ip arp inspection statistics`, `show ntp status`, `show interfaces trunk`. Config output can look right while the live state is wrong.
- [ ] **The 2960X is 802.1Q-only** — never `switchport trunk encapsulation dot1q` (it errors).
- [ ] **DAI is enabled on VLANs 20–90** (OFF on VLAN 10). Any static host on 20–90 depends on its **uplink being DAI-trusted** — the MKT01 (`Gi1/0/1`) and PVE01 (`Gi1/0/4`) trunks are trusted for this reason. A "host can't reach its gateway" with no other cause → check DAI first.
- [ ] **Old IOS SSH offers only SHA1 algorithms** — a modern client needs legacy-algorithm flags (see the SSH incidents).

## Diagnostic Approach

```text
Reachability   — can the host ARP-resolve its gateway? (DAI drops? show ip arp inspection statistics)
Trust model    — is the uplink/trunk trusted for DAI + DHCP snooping? (show ip arp inspection interfaces)
Negotiation    — SSH: which layer failed — KEX, host key, cipher, or MAC? (read the exact "Their offer:" line)
Live state     — read STATUS, not show run
```

---

## Incident: SSH from a modern client fails — "no matching key exchange method found"

**Symptom:** `ssh ciscoadmin@10.10.0.2` →
```
Unable to negotiate with 10.10.0.2 port 22: no matching key exchange method found.
Their offer: diffie-hellman-group-exchange-sha1,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1
```
After adding the KEX flag it moves to the next layer: `no matching host key type found. Their offer: ssh-rsa`, then `no matching MAC found. Their offer: hmac-sha1,hmac-sha1-96`.

**Wrong assumption to avoid:** it is **not** the RSA key size. A 4096-bit host key is fine — algorithm negotiation happens *before* host-key auth. This is not a key problem.

**Root cause:** the 2960X's IOS SSH server only offers **legacy SHA1** algorithms (KEX `diffie-hellman-group14-sha1` and older, host key `ssh-rsa`, MAC `hmac-sha1`). Modern OpenSSH (Windows 10/11) disables all of these by default, so negotiation fails one layer at a time: **KEX → host key → cipher → MAC.**

**Resolution — client-side (get in now):** re-enable the legacy algorithms with `+`:
```
ssh -o KexAlgorithms=+diffie-hellman-group14-sha1 -o HostKeyAlgorithms=+ssh-rsa -o MACs=+hmac-sha1 ciscoadmin@10.10.0.2
```
**Permanent — per-host, no flags:** add to `%USERPROFILE%\.ssh\config`:
```
Host sw01 10.10.0.2
    HostName 10.10.0.2
    KexAlgorithms +diffie-hellman-group14-sha1
    HostKeyAlgorithms +ssh-rsa
    MACs +hmac-sha1
```
**Better — server-side (if the image supports it):** on SW01, `ip ssh server algorithm kex ?` / `... mac ?`. If SHA2 variants are listed (`diffie-hellman-group14-sha256`, `hmac-sha2-256`), configure them and modern clients connect with **no** flags. If only SHA1 is offered, the image is the limit — client-side config or an IOS upgrade.

**Verify fix:** the connection completes and prompts for the `ciscoadmin` password. *(device-verified 2026-07-21)*

**Lesson:** prefer `diffie-hellman-group14-sha1` over `diffie-hellman-group1-sha1` (avoid group1). Read the exact `Their offer:` line each time — it tells you which layer to fix next.

---

## Incident: SSH "REMOTE HOST IDENTIFICATION HAS CHANGED!" after regenerating the switch key

**Symptom:**
```
@ WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED! @
...
Host key verification failed.
Offending RSA key in C:\Users\Seth/.ssh/known_hosts:5
```

**Root cause:** you changed the switch's host key (e.g. `crypto key generate rsa` to regenerate as 4096-bit). OpenSSH still has the **old** key cached in `known_hosts` and blocks the connection under strict checking as a man-in-the-middle guard. **Expected** when *you* regenerated the key.

**Resolution:** remove the stale entry, reconnect, accept the new key (`yes`):
```
ssh-keygen -R 10.10.0.2
ssh -o KexAlgorithms=+diffie-hellman-group14-sha1 -o HostKeyAlgorithms=+ssh-rsa -o MACs=+hmac-sha1 ciscoadmin@10.10.0.2
```

**Verify fix:** connects; the new fingerprint is stored. *(device-verified 2026-07-21)*

**Guard:** if you did **not** change the key, do not blindly clear it — verify the fingerprint out-of-band with `show crypto key mypubkey rsa` on the switch before trusting it. A changed key you didn't cause is exactly what the warning is for.

---

## Incident: A host on VLAN 20–90 can't reach its gateway (no internet, no RDP)

**Symptom:** a newly-attached host — e.g. **DC01**, static `10.20.0.2` on VLAN 20 via the PVE01 trunk — can't ping its gateway `10.20.0.1`; nothing in or out, even though the IP/mask/gateway and the Proxmox VLAN tag are all correct.

**Root cause:** **DAI is on for VLANs 20–90**. The host reaches SW01 over the **PVE01 trunk `Gi1/0/4`, which is DAI-untrusted**, and a statically-addressed host has **no DHCP-snooping binding** and isn't in a static ARP ACL → its ARP is dropped, so it never resolves the gateway MAC.

**Diagnostic:**
```
show ip arp inspection statistics vlan 20   # Dropped counter climbs while the host pings the gateway
show ip arp inspection interfaces           # Gi1/0/4 shows Untrusted
```

**Resolution:** trust the hypervisor uplink (you can't reliably snoop VM DHCP across a trunk; static VMs have no lease to snoop):
```
conf t
interface GigabitEthernet1/0/4
 ip arp inspection trust
end
copy running-config startup-config
```

**Verify fix:** host reaches the gateway (and the internet); `show ip arp inspection interfaces` shows `Gi1/0/4` Trusted; the Dropped counter stops climbing. *(device-verified 2026-07-21 — this is what unblocked DC01.)*

**Forward note:** add `ip dhcp snooping trust` on `Gi1/0/4` too once a VM starts serving DHCP (Kea/DC), or snooping drops its offers.

---

## Incident: A static VLAN-10 host's ARP is dropped (STATIC-HOSTS filter)

**Symptom:** a static host on VLAN 10 can't reach the gateway.

**Root cause:** `ip arp inspection filter STATIC-HOSTS vlan 10` validates ARP against a **hand-typed** IP+MAC list; any host not listed (and with no DHCP-snooping binding) has its ARP dropped.

**Resolution:** interim — add the host's MAC to `arp access-list STATIC-HOSTS`. Proper fix — **regenerate `STATIC-HOSTS` from NetBox** (Phase 3), don't hand-type. DAI on VLAN 10 is currently **OFF** for this reason (VLAN 10 removed from `ip arp inspection vlan`).

**Verify fix:** `show ip arp inspection statistics vlan 10` — no drops for the host.

---

## Incident: SPAN session captures nothing

**Symptom:** the IDS on `Gi1/0/5` receives no mirrored traffic.

**Root cause:** `monitor session 1` had a **destination but no source**.

**Resolution:**
```
monitor session 1 source interface Gi1/0/1        # the MKT01 trunk
monitor session 1 destination interface Gi1/0/5
```

**Verify fix:** `show monitor session 1` shows both source and destination; **and confirm the IDS host actually receives frames** (a SPAN built but never plugged in is telemetry you never use).

---

## Incident: `switchport trunk encapsulation dot1q` rejected

**Symptom:** `% Invalid input detected` on `switchport trunk encapsulation dot1q`.

**Root cause:** the 2960X is **802.1Q-only**; the encapsulation command doesn't exist (and isn't needed — dot1q is the default).

**Resolution:** omit the line entirely.

---

## Incident: `homelab` v2c SNMP community present (carried from Lab-01)

**Symptom:** a legacy `homelab` SNMPv2c community was live in the config, carried from Lab-01 ([`CM-0023`](../../../Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Changes/CM-0023-Remove-Carried-Over-SW01-v2c-SNMP-Community.md)).

**Root cause:** carried over from the Lab-01 configuration.

**Resolution:**
```
no snmp-server community homelab RO
no snmp-server host 10.40.0.52 version 2c homelab
```
SNMPv3 (auth+priv) → MON01 in Phase 6; never re-add a v2c community. *(Confirmed absent in the 2026-07-21 live config.)*

---

## Quick Reference — Common Commands

| Task | Command |
|---|---|
| SSH in from a modern client | `ssh -o KexAlgorithms=+diffie-hellman-group14-sha1 -o HostKeyAlgorithms=+ssh-rsa -o MACs=+hmac-sha1 ciscoadmin@10.10.0.2` |
| Clear a stale host key after regenerating it | `ssh-keygen -R 10.10.0.2` |
| See DAI drops on a VLAN | `show ip arp inspection statistics vlan <n>` |
| See which ports are DAI-trusted | `show ip arp inspection interfaces` |
| Confirm DHCP snooping state | `show ip dhcp snooping` |
| Confirm NTP is actually synced | `show ntp status` (not `show run`) |
| Confirm trunk VLANs / native | `show interfaces trunk` |
| Show the switch's SSH host key fingerprint | `show crypto key mypubkey rsa` |

## Escalation

1. Capture the exact error (`Their offer:` line for SSH; the `show ip arp inspection statistics` deltas for DAI) before changing anything.
2. Check `Build-Guide.md` (current v0.5) against live state.
3. Cross-reference the `Build-Progress-Tracker.md` troubleshooting log for the cross-device context.

## Related Pages

- `Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md`
- `Labs/Lab-02-Cisco-Core/Build-Progress-Tracker.md` (cross-device timeline)
- `Labs/Lab-02-Cisco-Core/Devices/MKT01-East-West-Firewall/Build-Guide.md` (the trunk's other end)
- `Labs/Lab-02-Cisco-Core/Architecture/IP-Addressing-Plan-VLSM.md`
