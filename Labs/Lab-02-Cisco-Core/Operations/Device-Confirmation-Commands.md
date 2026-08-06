---
Title: Device-Confirmation Commands — grounding the doc-audit fixes (POL-0001)
Path: Labs/Lab-02-Cisco-Core/Operations
Status: 🟢 Handout — run these, paste the read-backs, and the remaining audit fixes get made from evidence (not assumption). Companion to `Doc-Conflict-Audit-2026-07-24.md` + `Foundation-Doc-Conflict-Audit-2026-07-24.md`.
Version: 1.0
Date: 2026-07-24
---

# Device-Confirmation Commands (for the doc-audit fixes)

Several audit fixes depend on **live device state I can't see from here**. Per `POL-0001` (verify by device status; a `[x]` needs a command + its output), run the block for each item, paste the read-back, and I'll finalize the matching doc edit from what's actually true. **Read the *status*, not the config file.**

> ✅ **Already applied (device-verified, no confirmation needed):** the native-VLAN-10→999 fix in `Master-Build-Order` (SW01 both trunks native 999 + PVE01 `vmbr0.10`, verified 2026-07-24) and the `ADR-0029` FreeRADIUS→NPS decision. Everything below is what's *still* gated on evidence.

---

## 1. AD OU structure — grounds **H1** (303 OU tree says `Computers`/`Users`)

**On a DC or PAW (PowerShell, RSAT):**
```powershell
Get-ADOrganizationalUnit -Filter * | Select-Object Name,DistinguishedName | Sort-Object DistinguishedName
```
- **Confirms:** the real top-level OU names and the built tree.
- **Authoritative expectation:** top level is **`Devices`** and **`Employees`** (NOT `Computers`/`Users` — those collide with the built-in containers, `8305`; `OU-Design-and-Build.md`).
- **Fix once confirmed:** rewrite the `303` OU tree (and its `Computers\…`/`Users\…` GPO-table paths) to the real built structure, and point it at `OU-Design-and-Build.md` as the source.

## 2. DC state — grounds **M10** (303/304: "DC not promoted", "DC01 on VLAN 10 untagged")

```powershell
Get-ADDomainController -Filter * | Select-Object Name,IPv4Address,IsGlobalCatalog,OperatingSystem
Get-ADDomain | Select-Object DNSRoot,NetBIOSName,PDCEmulator,DomainMode
repadmin /replsummary
```
- **Confirms:** DC01/DC02 exist, their IPs, GC role, and replication health.
- **Authoritative expectation:** **DC01 = `10.20.0.2` (VLAN 20), promoted**; **DC02 = `10.20.0.3`, replica/GC**; `repadmin` → **0 failures**. *(DC02 promotion was "in progress" at the last handoff — this confirms whether it's done.)*
- **Fix once confirmed:** update `304` ("DC01 currently on VLAN 10 untagged" → `10.20.0.2` VLAN 20, promoted) and `303` ("promote it (still pending)" → done; DC02 status).

## 3. AD CS / ICA01 + RCA01 — grounds **M1/M5/M6** (PKI "open question", CA01-not-ICA01, single-Intermediate)

```powershell
# reachability + domain membership of the issuing CA:
Test-NetConnection 10.20.0.4 -Port 443    # or: ping 10.20.0.4
Get-ADComputer ICA01 -ErrorAction SilentlyContinue | Select Name,DNSHostName
```
```
:: on ICA01 (if the CA role is installed):
certutil -cainfo
:: go/no-go for the whole PKI (from a domain box):
pkiview.msc
```
- **Confirms:** whether **ICA01** (issuing CA, `10.20.0.4`) is online and whether the **CA role is actually installed** yet (the RCA01 offline-root ceremony is the gate — it may not be built).
- **Authoritative expectation:** design = two-tier **AD CS** — offline **RCA01** root + enterprise **ICA01** issuing (`10.20.0.4`) — for the domain; separate **OpenSSL CA01** for non-domain (`ADR-0027`/`ADR-0003`). Whether they're *built* is what this confirms.
- **Fix once confirmed:** correct the PKI rows in `VM-and-Services-Inventory`, `Atlas-Service-Architecture`, `Lab-02-Device-Role-Assignments`, `304` to **ICA01 + RCA01** (marking built vs planned honestly).

## 4. FreeRADIUS — grounds **ADR-0029 decommission** (+ M7/M9)

```bash
# on Pi01 (and, if it exists, SRV01):
systemctl status freeradius 2>/dev/null || systemctl status freeradius3 2>/dev/null
dpkg -l | grep -i freeradius
ss -ulnp | grep -E ':1812|:1813'      # RADIUS auth/acct ports
```
- **Confirms:** whether a FreeRADIUS instance is actually running anywhere, so it can be decommissioned and its shared secrets rotated (`ADR-0029`).
- **Authoritative expectation:** per `ADR-0029` it should be **removed** / not running. If it *is* running (e.g. carried over from Lab-01 Pi01), stop + purge it and rotate any device RADIUS secrets that pointed at it.
- **Fix once confirmed:** drop FreeRADIUS from `SRV01/Build-Guide.md`, `SRV01/Build-Checklist.md`, `POL-0013`, `Atlas-Service-Architecture`, `Lab-02-Device-Role-Assignments`.

## 5. DHCP — grounds **M8** (VM-inventory/Device-Role say DHCP on the DC)

```powershell
Get-Service DhcpServer -ErrorAction SilentlyContinue    # on DC01/DC02
Get-DhcpServerv4Scope -ErrorAction SilentlyContinue
```
- **Confirms:** whether any DHCP scope is authorized/running on the DCs.
- **Authoritative expectation:** **no DHCP on the DCs** — DHCP = **Kea on SRV01** (+ MKT01 relay), infra static (`IP-Addressing-Plan-VLSM`, `Master-Build-Order` Phase 5). Likely nothing runs DHCP yet.
- **Fix once confirmed:** change the DHCP row in `VM-and-Services-Inventory` + `Lab-02-Device-Role-Assignments` to **Kea/SRV01 (planned)**.

## 6. SRV01 / MON01 build state — grounds **M9/M11** (SRV01 roles; MON01 at `.20/.30/.10`)

```powershell
Test-NetConnection 10.20.0.10 -Port 22     # SRV01 (Ubuntu services)
Test-NetConnection 10.40.0.10 -Port 22     # MON01
```
- **Confirms:** whether SRV01 / MON01 are built yet (SRV01 was mid-build; MON01 planned).
- **Authoritative expectation:** **SRV01 = `10.20.0.10`** (nginx CRL host `pki.atlas.lab` + Kea DHCP + Oxidized + rsyslog — **no FreeRADIUS** per `ADR-0029`, NTP is on **Pi01** not SRV01); **MON01 = a single host `10.40.0.10`** (not `.20/.30`).
- **Fix once confirmed:** correct the SRV01 role rows (drop NTP/NPS/FreeRADIUS, add nginx-CRL/Kea) and collapse MON01's `.20/.30/.10` to `10.40.0.10` in `Atlas-Service-Architecture` + `Lab-02-Device-Role-Assignments`.

---

## What I've already changed (2026-07-24, device-verified or your decision)
- `Architecture/Master-Build-Order.md` — PVE01 trunk **native 10 → 999** + the VM-placement lesson marked **resolved**; Pass-2 auth updated to **NPS (no FreeRADIUS)** + FGT01 **LDAPS resolved**.
- `00-Atlas-Foundation/Decisions/ADR-0029-…` — **new**, records the FreeRADIUS→NPS decision.
- `Windows-Infrastructure/303-Windows-Design-Standards.md` — fixed the garbled **"`atlas.lab` … NOT `atlas.lab`"** domain line (M14).

## Everything else stays flagged
The rest of the audit findings (the VM-inventory / service-architecture / role-assignment / 304 rows, the OU tree, DC/PKI state) are **not** changed yet — they hinge on the confirmations above. Run the blocks, paste the read-backs, and I'll make each fix from evidence.

## Change Log
| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-07-24 | Created — the `show`/PowerShell commands that ground the remaining doc-audit fixes in live device state (`POL-0001`): OU structure (H1), DC state (M10), AD CS/ICA01/RCA01 (M1/M5/M6), FreeRADIUS presence (ADR-0029/M7/M9), DHCP host (M8), SRV01/MON01 build state (M9/M11). Records the three fixes already applied (Master native-999, ADR-0029, 303 domain line). |
