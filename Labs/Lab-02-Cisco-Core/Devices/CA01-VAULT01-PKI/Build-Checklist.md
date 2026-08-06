---
Title: CA01 / VAULT01 Build Checklist (PKI + Secrets)
Path: Labs/Lab-02-Cisco-Core/Devices/CA01-VAULT01-PKI
Status: 🔴 SUPERSEDED by `ADR-0031` (2026-07-28) — the OpenSSL CA (CA01) is retired/not built; the CA01-VAULT01 joint host is decommissioned; Vaultwarden survives standalone. See the banner. **#22 audit (2026-07-30): quarantined with pointers to the live homes (RCA01/ICA01 · BKP01/Vaultwarden).**
Version: 1.2
---

# CA01 / VAULT01 — Build Checklist (Issuing CA + Secrets Vault)

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

> **Roles:** **CA01** = the online **Intermediate** issuing CA (OpenSSL, non‑domain; AD CS handles domain‑joined machines per `ADR-0003`). **VAULT01** = Vaultwarden, **off Pi01**. Both **Tier 0‑adjacent** (`ADR-0021`) — VLAN 20, in/near the Tier‑0 block. Debian VMs on PVE01.
>
> 🔴 **The CA ceremony itself is in [`Lab-02-Offline-Root-CA-Build-Design.md`](../../Architecture/Lab-02-Offline-Root-CA-Build-Design.md)** — offline Root, CRL from cert #1. This doc is the **host/service** build around it.
>
> 🔴 **SUPERSEDED (2026-07-28, `ADR-0031`).** The OpenSSL Lab CA is **retired** — there is **no CA01 to build**; the estate's only PKI is **AD CS** (`ICA01` issuing + offline `RCA01`). The **CA01-VAULT01 joint host is decommissioned entirely.** **Vaultwarden survives** as an independent service — reached via its **web console**, **relocated off this host**, with a **cert from AD CS (ICA01)** instead of a self-signed/OpenSSL cert — keeping its `ADR-0009` secrets-custody role (the RCA01/CA backup passphrases, DSRM, break-glass). The **CA01 (OpenSSL Intermediate)** steps below are **struck** (historical only). Vaultwarden's own build moves to its standalone doc/host — relocation target is an open follow-on (register **A3a**).
>
> 🗄️ **#22 audit (2026-07-30) — quarantined; the live homes now exist (`ADR-0012` quarantine-not-delete, `POL-0008`).** This folder is **retained as history only — nothing to build here.** Where its content lives now: the estate PKI → **[`../RCA01-ICA01-ADCS/`](../RCA01-ICA01-ADCS/)** (offline `RCA01` + issuing `ICA01`, AD CS two-tier); **Vaultwarden** → **[`../BKP01-Backup/Roles/Vaultwarden/`](../BKP01-Backup/)** (standalone on BKP01, cert from ICA01 — the `A3a` relocation target, now landed). This folder carries **no Services map / connections diagram** by design (decommissioned, not a live device).

## Order matters
- [ ] 🔴 **VAULT01 first** — it holds the CA passphrases. Don't generate CA keys with nowhere safe to put the passphrase (`POL-0002`; the Pi01/`ADR-0009` lesson).

## VAULT01 — Vaultwarden
- [ ] Debian VM, CIS‑Debian hardened; VLAN 20.
- [ ] Install Vaultwarden behind **nginx with HTTPS** (self‑signed to start → replace with a CA01 cert once issued).
- [ ] 🔴 **Back up the vault DB** to BKP01 + off‑site, **encrypted** — it holds every secret (`POL-0005`/`POL-0002`).
- [ ] Later: **LDAPS auth to AD** (Phase 5) so it's one identity.
- **Verify:** HTTPS reachable; a test secret stores/retrieves; the DB backup restores.

## ~~CA01 — online Intermediate (OpenSSL)~~ — STRUCK (`ADR-0031`; not built)
- [ ] Debian VM, CIS‑Debian hardened; VLAN 20 / Tier‑0 adjacency; the tightest MKT01 policy reaches it (matrix Identity micro‑zone).
- [ ] Follow the **offline‑Root design**: generate the Intermediate **key + CSR on CA01**, sign it on the **air‑gapped Root** (the Root key never comes to CA01), install the returned cert.
- [ ] 🔴 **Every issued cert carries `crlDistributionPoints` + AIA** (the `ADR-0009` fix); serve the CRL over HTTP (SRV01/Pi‑hole nginx).
- [ ] Passphrase → **VAULT01**, never on disk in cleartext or in git.
- **Verify:** chain validates; a **test revocation actually rejects** (issue → revoke → publish CRL → client refuses); `index.txt` reconciles with deployed certs.

## AD CS (domain side, `ADR-0003`)
- [ ] For **domain‑joined** machines, AD CS Issuing CA (with the identity track) — kept **separate from DC01/DC02** (Tier‑0 isolation, VM Inventory). Autoenrollment via GPO. Same offline‑root pattern in Microsoft tooling.

## Failure modes
- 🔴 **Generating CA keys before VAULT01 exists** — nowhere safe for the passphrase (the Pi01 convergence, `ADR-0009`).
- 🔴 **Revocation that reaches nothing** — CRL DP missing from issued certs (the exact `ADR-0009`/`MC-0002` defect). Bake it in; test a real revocation.
- 🔴 **Root key ever on CA01 or the network** — sign on the air‑gapped host only.
- 🔴 **Vault DB unbacked / backup unencrypted** — every secret at risk.
- **AD CS drifting to non‑domain issuance** — that's OpenSSL's job (`ADR-0003`).

## Change Log
| Version | Changes |
|---|---|
| 1.1 | 2026-07-28. **Superseded by `ADR-0031`** (cascade from Master-Build-Order v1.6). Added the SUPERSEDED banner: OpenSSL CA retired, **CA01 not built**, the **CA01-VAULT01 joint host decommissioned**; the CA01 (OpenSSL Intermediate) section struck. **Vaultwarden survives standalone** (web console, relocated off this host, AD CS cert, retains its `ADR-0009` secrets-custody role) → its own doc/host, relocation target open (register A3a). |
| 1.0 | 2026-07-17. Host/service build checklist for VAULT01 (Vaultwarden, off Pi01, first) and CA01 (online OpenSSL Intermediate) — the CA ceremony itself deferring to `Lab-02-Offline-Root-CA-Build-Design.md`. Covers CIS-Debian hardening, HTTPS/LDAPS, encrypted vault backup, the `crlDistributionPoints`-from-cert-#1 requirement, the AD CS domain-side split (`ADR-0003`), and the order-matters gate (vault before keys) plus the `ADR-0009` failure modes. |
