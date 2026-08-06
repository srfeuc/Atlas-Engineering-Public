---
Title: FGT01 Considerations and Risks
Path: Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall
---

# FGT01 Considerations and Risks

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: FGT01 - Role: Perimeter Firewall

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Draft |
| Version | 0.1 |
| Applies To | FGT01 (10.10.0.254, FortiGate-60E — perimeter firewall) |
| Last Reviewed | 2026-07-16 |

## Purpose

What could bite you on FGT01 — design risks, weak spots, unverified assumptions — each with a way to check it. Read before you trust, rebuild, or harden this device. Complements `037` (Troubleshooting) and `047` (CIS).

## How to read this

- 🟩 **Recommendation** — best practice to adopt.
- 🟨 **Hole** — unverified assumption / weak spot; run the check to settle it.
- 🟥 **Device-gated** — confirmed issue needing a live device read/write (usually a change record).

**Verify, don't assume** — run the command; don't trust the status column (Rule 13). Use `get`, not `show`.

## Considerations & Risks

| # | Consideration / Risk | Type | How to verify | Current status | Ref |
|---|---|---|---|---|---|
| 1 | **UTM provides nothing.** Signature DBs are 8–11 years stale (Virus 2018, IPS/APP 2015), no licence, no profiles applied to policy 1. | 🟥 Device-gated | `get system status` (DB dates) ; `show firewall policy 1` (no `utm-status`) | **Confirmed 2026-07-16.** The "good branch" — nothing pretends to protect. **Settle it: formally accept (ADR) or licence.** `047` §4's "possibly not applied" is not an answer. | Roadmap Risk #2, `047`, `CM-0033` |
| 2 | **`dmz` is admin-UP at factory `10.10.10.1/24`**, no purpose, in no policy. VLAN 80 is the real DMZ (MKT01 `10.80.0.1`). One typo from overlapping VLAN 10. | 🟨 Hole | `get system interface` → `dmz status: up` | **Confirmed up 2026-07-16.** CM‑0033 recommended disabling; **not done.** Disable (`010` policy) or document + reserve `10.10.10.0/24` in `007`. | `CM-0033` F2, `010` |
| 3 | **`internal3‑7` are FGT01's only IP recovery path** (`192.168.1.99`, plug a laptop into internal3‑7 / static `192.168.1.10`). Admin-enabled, dormant. | 🟩 Recommendation | `get system interface` → internal3‑7 `up`; `internal` group holds `192.168.1.99` | 🟢 **Intact 2026-07-16.** 🔴 **DO NOT disable** — a hardening pass that shuts these removes the recovery path. | `CM-0033` F1, `003`, `048` |
| 4 | **NTP config is untidy though the clock works.** Global `set interface "fortilink"` (down) is a pointless binding; `server-mode enable` offers to serve time. Sync happens via wan1 (per-server `auto`). | 🟨 Hole | `show full-configuration system ntp` ; `diagnose sys ntp status` (synced) | 🟢 **Clock synced (stratum 2) 2026-07-16.** Cleanup: `unset interface`, decide `server-mode`. **CM‑0033's "clock broken" was wrong.** | `CM-0033` F3, `CM-0030` |
| 5 | **FGT01's cert is an `-extfile` orphan.** Serial `740BE5…D9F2` — random hex, **not in the CA `index.txt`**. Cannot be revoked; invisible to ADR‑0009's only detection control (its Review Trigger fires on it). | 🟥 Device-gated | On Pi01: `sudo openssl ca -config …/intermediate/openssl.cnf -status 740BE5…D9F2` → "not in database" | **Confirmed 2026-07-16** (Pi01 B9 loop). Fixed by CM‑0032's `index.txt` reconstruction. | `CM-0032`, `ADR-0009` |
| 6 | **Revocation is decorative CA-wide** — no CDP, no CRL served. A compromised FGT01 cert can't be revoked to any client. | 🟥 Device-gated | On Pi01: `grep -rc crlDistributionPoints /etc/ssl/lab-ca/` → 0 | Confirmed. Home-lab-acceptable per `ADR-0009`; know it before relying on it. | `031` v0.7, `042`, `ADR-0009` |
| 7 | **DNS-over-TLS validates against `Fortinet_Factory`, not the Lab CA.** FGT01 resolves via 1.1.1.1/8.8.8.8 over DoT (not Pi‑hole). | 🟨 Hole | `get system dns` → `ssl-certificate: Fortinet_Factory` | Confirmed; recorded nowhere but here. Benign; note it. | `CM-0033`, `021` |
| 8 | **`modem` carries an encrypted PPPoE credential** on a disabled, undocumented-until-021 interface — it rides in every config backup. | 🟨 Hole | `021` "Interfaces — Disabled" note (do **not** paste the `ENC` line) | Factory noise, but a credential in every backup. | `021`, `CM-0004` |
| 9 | **Tunnel interfaces `naf.root`/`l2t.root`/`ssl.root` are up** (FortiOS internals) and recorded in no build doc. | 🟩 Recommendation | `get system interface` → the three `type tunnel` up | Benign; add to `021` for completeness. | `CM-0033` |

## Open holes — summary (most consequential first)

1. **UTM (row 1)** — decide: accept-with-an-ADR or licence. Right now protection is zero and a checklist half-says otherwise.
2. **`dmz` still up (row 2)** — disable or document; it's a factory L3 interface on the perimeter firewall.
3. **Cert orphan (row 5)** — resolved by CM‑0032's Pi01-side `index.txt` work.
4. **NTP cleanup (row 4)** — cosmetic; the clock is fine, the config isn't tidy.

## For the next build (Device Role Plan / Service Architecture)

- **Decide UTM up front:** licence it and apply profiles, or don't deploy the menus at all — never leave stale DBs that imply protection.
- **Document break-glass paths in the Build Record**, not just the topology doc — an undocumented recovery port is one hardening pass from deletion.
- **Disable every factory interface you don't use** (`dmz`, spare ports) *and* record the ones you keep enabled and why.
- **One real NTP server, pointed-at explicitly, proven with `diagnose`** — not inferred from config.
- **Sign device certs with `openssl ca`** so they land in `index.txt` and can be revoked/detected.
- **Keep firewall policy scoping tied to a redundancy trigger** (`ADR-0005`) — don't narrow `srcaddr` until there's a second path.

## Revision history

| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-16 | Created from the 2026-07-16 live FGT01 verification run. Confirms `021`; records the real open holes; **corrects CM‑0033's NTP finding** (clock syncs). |

## Related pages

- **Verification Procedure: `058-FGT01-Verification-Procedure.md`**
- 🔵 **Firewall architecture — north‑south vs east‑west, enterprise practice, verification method: `00-Atlas-Foundation/Atlas-Firewall-Architecture.md`.** FGT01 is Atlas's **north‑south** perimeter firewall; the east‑west role becomes MKT01's job in Book 11.
- Build Record: `021` · Build Guide: `025` · Troubleshooting: `037` · CIS: `047`
- Change records: `CM-0033`, `CM-0032`, `CM-0004`, `MC-0001`, `ADR-0005`, `ADR-0009`
