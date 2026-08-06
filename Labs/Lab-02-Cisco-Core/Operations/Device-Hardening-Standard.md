---
Title: Device Hardening Standard — Recovery-First Order + Pass-1 Checklist (LIVING)
Path: Labs/Lab-02-Cisco-Core/Operations
Status: 🟢 LIVING STANDARD (v0.1). The **device-agnostic** hardening pattern every Lab-02 device follows. Per-device *commands* live in each device's Build/Hardening guide + `CIS-Hardening-<device>` doc; **this is the shared order + checklist they all execute** (POL-0008 — one source for the pattern, don't re-derive it per box). Modeled on the **FGT01 tiered guides** (the exemplar). Applies to network devices now and **service devices (Pi01/SRV01/MON01/…) as their build guides are written.**
Version: 0.1
Date: 2026-07-22
---

# Device Hardening Standard — Recovery-First Order + Pass-1 Checklist

## Why this exists
Hardening a device's **management plane is exactly what can lock you out of it.** The #1 self-inflicted outage in this build is scoping or removing management access with no proven recovery path (MKT01's power-cut lockout; FGT01's local-in-severs-break-glass warning). FGT01's guides already encode the fix — *"prove the break-glass FIRST."* This standard makes that the rule for **every** device, and pairs it with a device-agnostic **Pass-1 checklist** so every box hardens the same way.

> **Scope:** this is **Pass 1** — self-contained hardening that needs no other services. **Pass 2** (AD-LDAPS / RADIUS / PKI cert-auth admin) is separate and comes after the DC/CA (`Master-Build-Order` §2.5). This standard is executed *by* each device's hardening guide, which supplies the device-specific syntax; it does not replace `CIS-Hardening-<device>` (the control mapping / *why*).

---

## Part A — Recovery-first order (the break-glass discipline)
🔴 **The invariant:** **prove your break-glass BEFORE you touch the management plane; do the access-removing steps LAST; re-verify recovery after.**

The order for hardening any device:
0. **Back up + export** the running config first (to `E:\` / Oxidized-git per `Device-Backup-Runbook.md`). A lockout is only recoverable if a known-good config exists.
1. **🔴 Prove the break-glass / out-of-band path** — get an *actual login* over it, not "the cable is plugged in." This is the **gate**: nothing sharp (step 3) proceeds until it works.
2. **Lockout-safe steps** (any order) — named admin + disable the default admin (log in as the named one first), disable unused services, remove v2c SNMP, strong crypto, NTP, input/local-in protection *(with the break-glass exempted)*.
3. **🔴 Access-removing steps LAST** — scope management to the source subnet, and remove fallback paths (MAC-server, extra `allowaccess`, the default admin). Only after step 1 is proven.
4. **🔴 Re-verify recovery** — after the lockdown, confirm the break-glass **still works** (FGT01's local-in policy must *exempt* it and be tested; a scoped MikroTik must still answer on the console). Recovery you haven't tested *after* hardening is a guess.

### Per-device break-glass mechanism
Keep **exactly one documented break-glass per device**; never PKI-ify it; store its secret in **Vaultwarden** (`POL-0002`), never the repo.

| Device | Break-glass path | Serial | Notes |
|---|---|---|---|
| **MKT01** (MikroTik RB1100AHx4) | Serial console + a documented local admin; **MAC-WinBox** is the interim net *until* console proven | **115200 8N1** | ✅ console login proven 07-22; `ether2` `192.168.88.1` was the interim path |
| **SW01 / 1941** (Cisco) | Serial console + `enable`/local admin | **9600 8N1** | confirm baud on the box |
| **FGT01** (FortiGate) | Local `fortigateadmin` + `192.168.1.99`/`internal3-7` trusthost + console; **the local-in policy MUST exempt it** | **9600 8N1** | `CM-0033`/`ADR-0016` |
| **VMs** (DC / PAW / service on PVE01) | **Proxmox noVNC/SPICE console** (out-of-band, network-independent) + the built-in/local admin | — | the console is the break-glass; e.g. DC01 mask-fix recovery, Win11 Audit-Mode |

🔎 The mechanism differs, the **discipline is identical**: an OOB path that survives whatever you do to the network/mgmt plane, proven before you harden.

---

## Part B — Pass-1 service-hardening checklist (device-agnostic)
Self-contained hardening — no AD/PKI dependency (that's Pass 2). Run it in the recovery-first order above. **Per-device syntax → each device's guide.** Evidence rule (`POL-0001` R-A1): a `[x]` needs a **command + its output** (a `detail`/`status` read-back), not a config line.

- [ ] **Named admin created; default admin disabled/removed** — *after* you've logged in as the named account and confirmed it works.
- [ ] **Admin secrets in Vaultwarden** (`POL-0002`); strong passwords; MFA where the platform supports it without a CA (e.g. FortiToken).
- [ ] **Management services scoped to the mgmt source subnet** (not all VLANs / not `0.0.0.0/0`). 🔴 Include the subnet you're *actually* managing from, or you lock yourself out (this is a step-3 / access-removing action).
- [ ] **Unused management services disabled** — telnet, non-TLS http, ftp, api, neighbor-discovery/UPnP/proxy/socks/bandwidth-test, etc. Verify with a **detail** read-back (summary output hides scope/dynamic rows — the MKT01 `016` misread).
- [ ] **v2c SNMP removed**; SNMP off until **SNMPv3 (auth+priv) → MON01** (Phase 6). Never leave a cleartext community (the `homelab`/`CM-0023` lesson — and verify it's actually present before "fixing" it; POL-0001).
- [ ] **Strong crypto / TLS only** — disable weak ciphers, SSHv1, TLS < 1.2; strong-crypto on where offered.
- [ ] **Unused interfaces disabled**; every kept-up port documented with a reason (`POL-0007`). 🔴 Never disable your current recovery port.
- [ ] **Management-plane input protection** — only mgmt-zone sources reach the device's own services (input / local-in default-deny), **break-glass exempted and tested**.
- [ ] **NTP client synced** — verify by the runtime clock/status, not the config line (the `045` false-tick).
- [ ] **Encrypted config backup after each change** (`Device-Backup-Runbook.md`); for FortiGate, record the `private-data-encryption` key offline or the backup can't be restored.
- [ ] *(Phase 6, deferred)* logging → **MON01**; SNMPv3 → MON01. Not blocking Pass-1.

---

## The guide structure every device follows (the FGT01 model)
Each device's build docs split by domain, with a **hardening guide** that executes *this* standard + the device's `CIS-Hardening-<device>` control mapping:
- an **Index** (`Build-Guide-Index.md`) when a device has multiple guides — the tiered set + which are runnable-now vs blocked (e.g. FGT01 Guide-3 gated on a FortiGuard bundle);
- **Guide-1 Networking**, **Guide-2 Hardening** *(this standard + device syntax + the break-glass gate)*, **Guide-3+** (security profiles / services);
- a **`CIS-Hardening-<device>.md`** doc — the control mapping / *why* (this standard is the *how-order*, not the control catalog).

**Current state:**
- **FGT01** — the exemplar: `Build-Guide-Index` + `Build-Guide-1-Networking` + `Build-Guide-2-Hardening` (break-glass gate front-and-centre) + `CIS-Hardening-FGT01`.
- **MKT01** — hardening currently lives as **Stage 1** in its `Build-Guide` (reworked 07-22 into the recovery-first order + Pass-1 steps). *Optional future parity:* split it into its own `Build-Guide-2-Hardening` like FGT01.
- **SW01 / 1941** — CIS passes reference this standard; a dedicated hardening guide/section to follow.
- **Service devices** (Pi01, SRV01, MON01, NETBOX01, BKP01, CA01) — get their build guides *"eventually"*; when written, they inherit this standard (recovery path = the **Proxmox console** for the VMs).

## Related
`Device-Backup-Runbook.md` · `Validation-and-Adversarial-Testing.md` · each device's `Build-Guide*` + `CIS-Hardening-*` · `FGT01/Build-Guide-Index.md` + `Build-Guide-2-Hardening.md` (the exemplar) · `Master-Build-Order.md` §2.5 (Pass 1 / Pass 2) · `ADR-0016` (console recovery) · `POL-0001` (evidence) · `POL-0002` (secrets) · `POL-0007` (unused interfaces).

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-22 | Created — the shared device-hardening standard, extracted from the FGT01 pattern and generalized to every device (Seth: "the MikroTik and all other devices need this … recovery + the Pass-1 checklist"). Part A = recovery-first break-glass order + per-device break-glass table (MikroTik/Cisco console, FGT local admin+trusthost, VM Proxmox console). Part B = device-agnostic Pass-1 checklist (named admin/disable default, scope mgmt to source, disable unused services, kill v2c SNMP, strong crypto, unused interfaces, input protection, NTP, encrypted backup), under the POL-0001 evidence rule. Documents the FGT01 tiered-guide structure as the model all devices (incl. future service devices) follow. |
