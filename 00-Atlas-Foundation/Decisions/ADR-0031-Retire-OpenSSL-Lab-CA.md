# ADR-0031 — Retire the OpenSSL Lab CA: One Unified PKI on AD CS

| Item | Value |
|---|---|
| Status | **Accepted** (operator, 2026-07-28). **Reverses `ADR-0003`.** |
| Governing Policy | POL-0007 |
| Scope | **Lab-02-Cisco-Core** |
| Date | 2026-07-28 |
| Supersedes | **`ADR-0003`** (AD CS + OpenSSL *coexist*). This reverses that decision: the non-domain devices fold onto AD CS and the OpenSSL Lab CA is retired. |
| Related | `ADR-0027` (two-tier AD CS — **explicitly asks for this ADR** "with the reissue cost stated up front"), `ADR-0009` (revocation-is-a-hard-gate + reissue/reinstall cost + key⁄passphrase custody), `ADR-0028` (FGT01 → AD CS/ICA01 already), `ADR-0021` (tiered identity / Vaultwarden adjacency). Captures Review-Flag-Register **A3** (and revises **C3**). |
| Evidence Status | **Decision** (operator, 2026-07-28). Every migration and decommission step below is **`Target`** until executed and device-confirmed via the **D5 migrate-and-test lab** (`POL-0001`). **No OpenSSL trust is removed from any device until its AD CS replacement is proven.** |

## Context

`ADR-0003` chose **coexistence**: a working two-tier **OpenSSL Lab CA** (originating on Pi01, `Labs/Lab-01-Mikrotik-Core/…/Lab-CA`) issues to the **non-domain** devices — **Pi-hole (in active use), MikroTik, FortiGate** — while **AD CS** serves domain-joined Windows machines. The Lab-02 plan carried the OpenSSL intermediate forward as a planned host, **CA01**, paired with **VAULT01** (Vaultwarden) in the `CA01-VAULT01-PKI` build checklist (Target Design — **not yet built**).

Since then the ground shifted:

- **AD CS is being built the Microsoft way** (`ADR-0027`: offline root **RCA01** + enterprise issuing **ICA01** `10.20.0.4`), with an HTTP CRL/AIA endpoint on SRV01 (`pki.atlas.lab`) and revocation as a hard gate.
- **FGT01 already moved to AD CS** (`ADR-0028`): its authoritative PKI relationship is **ICA01**, not the OpenSSL CA (it still physically holds an old OpenSSL cert — historical, 07-24 audit **L4**).
- `ADR-0027` explicitly carved this out as a **separate decision**: *"'Redo the CA the Microsoft way' … does not, by itself, retire the OpenSSL CA. Folding the non-domain devices onto AD CS is a separate, deliberate `ADR-0003` reversal … raise it as its own ADR with the reissue cost stated up front."* This is that ADR.

The operator has made the call: **consolidate on one PKI (AD CS) and retire the OpenSSL Lab CA.**

## Decision

**Retire the OpenSSL Lab CA. All certificates — domain and non-domain — come from AD CS (ICA01). The planned CA01-VAULT01 host is decommissioned; Vaultwarden survives as an independent service.**

1. **Non-domain devices fold onto AD CS.** **Pi-hole, MikroTik (MKT01), and FortiGate (FGT01)** are reissued their certificates from **ICA01** and made to **trust the AD CS chain** (install the **RCA01** offline-root cert — and the ICA01 intermediate — as a trust anchor on each non-domain device). Domain-joined machines already autoenroll from ICA01 via GPO.
2. **The OpenSSL Lab CA is retired** — the live Lab-01 Pi01 OpenSSL CA is decommissioned once every relying device is migrated and verified, and the **planned Lab-02 CA01 (OpenSSL intermediate) is struck — it is not built.**
3. **CA01-VAULT01 is decommissioned as a combined host.** With no OpenSSL CA to build, the "CA + secrets-vault on one box" construct dissolves. **Vaultwarden survives as an independent service** — it relocates to its own surviving host (**relocation target = open follow-on, its own tracked change**), obtains its TLS cert from **AD CS (ICA01)** instead of a self-signed/OpenSSL cert, and **retains its `ADR-0009` secrets-custody role** (holding the RCA01/CA backup passphrases, DSRM, and break-glass credentials — the built-in Administrator break-glass already lives there).
4. **Migrate-and-test before retiring (D5).** Nothing is torn out first: each device is cut to AD CS and **verified working** — including a **real revocation test** (the `ADR-0009` gate: issue → revoke → publish CRL → device refuses) — through the **D5 migrate-and-test lab**, *then* the OpenSSL CA is decommissioned and its keys destroyed per the `ADR-0009` destroy-step rule.

One trust anchor, one enrollment/revocation story, one CRL to keep alive.

## Cost, stated up front (per `ADR-0027` / `ADR-0009`)

Reversing `ADR-0003` is **not** free — `ADR-0009` documents the reissue-and-reinstall cost for all relying devices, and it is accepted deliberately here:

- **Reissue + reinstall a cert on every non-domain device** (Pi-hole, MKT01, FGT01), and **distribute the AD CS root (RCA01) as a trust anchor** to each — non-domain devices don't get it via GPO, so this is manual per device. The **AD CS build guide currently lacks these non-domain enrollment/trust steps** — that's a required guide addition (register **A3 → Phase 2 / build-time**).
- **Pi-hole is in active use** on its current OpenSSL cert — highest-care migration; plan for the brief TLS interruption on cutover.
- **Revocation must actually work first.** AD CS's HTTP CRL/AIA (`pki.atlas.lab` on SRV01) is a **hard gate** — the 07-24 audit's retracted "revocation non-functional" note is *accurate today* (no CRL is served yet). No non-domain device is cut over until the AD CS revocation gate passes.
- **Secrets custody continuity:** Vaultwarden must be stood up on its new host and its DB restored **before** any CA passphrase handling, preserving the `ADR-0009` rule (key and passphrase never converge; every backup has a destroy step).

## Alternatives Considered

- **Keep coexistence (`ADR-0003` as-is).** Rejected — two CAs, two CRLs, two enrollment stories; the OpenSSL chain is the one with the `ADR-0009` scars (missing CDP, unrevocable off-book certs, RADIUS never device-tested). FGT01 has already left it. Consolidating removes a whole fragile trust domain.
- **Retire OpenSSL but rename/keep the CA01-VAULT01 host** (the earlier register **C3** assumption — "Vaultwarden survives *in place*"). Rejected by the operator in favor of **decommissioning the combined host entirely** and relocating Vaultwarden to its own home. (This ADR therefore **revises C3**.)
- **Rip out OpenSSL now, migrate after.** Rejected — violates D5 and `ADR-0009`; you don't remove working trust before its replacement is proven, especially with Pi-hole live.

## Consequences

- **`ADR-0003` gets a superseded/reversed banner** pointing here.
- **A new open follow-on:** **where Vaultwarden relocates** (surviving host + AD CS cert + DB restore + `ADR-0009` custody) — tracked, not decided here (register **new ripple**, was **C3**).
- **Docs to reconcile (each its own tracked change, `POL-0003`):**
  - `Devices/CA01-VAULT01-PKI/Build-Checklist` — **strike the CA01 (OpenSSL) build**; split out **VAULT01/Vaultwarden** to its own doc/host with an AD CS cert; the "VAULT01-first because it holds the CA passphrase" ordering still holds *for the AD CS offline-root backup passphrase*, but the OpenSSL-intermediate build it was gating is gone.
  - **AD CS build guide** (`RCA01-ICA01-ADCS/AD-CS-Two-Tier-Build-Guide`) — **add the non-domain enrollment + root-trust-distribution steps** it currently lacks (Pi-hole/MKT01/FGT01 request a cert from ICA01 + install the RCA01 trust anchor). Register **A3**.
  - **PKI-narrative preamble (07-24 M1–M5, L3, L4)** — its reconciliation direction **reverses**: authoritative PKI = **"two-tier AD CS only (OpenSSL retired)"**, *not* "AD CS + OpenSSL coexist." The M6 ICA01-vs-CA01 conflation simplifies — only **ICA01** exists.
  - `Lab-02-Device-Role-Assignments` / `Atlas-Service-Architecture` / `VM-and-Services-Inventory` — remove **CA01** as a host/role; Vaultwarden becomes its own row on its new host.
  - **Lab-01 Pi01 Lab-CA** guide + the `CM-0005` (FGT) / `CM-0007` (MikroTik) OpenSSL-cert-install change records → mark **historical/retired** once migration completes.
- **Feeds the D5 lab:** the migrate-and-test lab (`CA-Migration-and-DR-Lab`, `CA-Migration-Handoff-Sanity-Check`, `CA-PKI-Recovery-Objectives-RPO-RTO`, the new `Device-Confirmation-Commands`) executes this reversal and doubles as the Academy AAA+PKI module.

## Review Trigger

- If a genuine need reappears for a CA that AD CS cannot serve (a device that can't trust/enroll from AD CS, or a hard offline/non-Windows requirement) → re-open; that is a new decision, not a silent return to coexistence.
- If the AD CS revocation gate cannot be made to work on a given non-domain device, **that device's OpenSSL trust stays until it can** — retirement is per-device on proof, never a flag-day.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-28. Accepted. **Reverses `ADR-0003`** (the coexistence decision `ADR-0027` flagged for its own ADR). Retire the OpenSSL Lab CA; **fold Pi-hole/MKT01/FGT01 onto AD CS (ICA01)** with the RCA01 root distributed as a trust anchor per device; **decommission the planned CA01-VAULT01 host entirely** (CA01/OpenSSL struck — never built); **Vaultwarden survives independently**, relocates to its own host (target = open follow-on), gets an AD CS cert, and keeps its `ADR-0009` secrets-custody role. **Migrate-and-test before retiring (D5)** with a real revocation test; nothing removed until its AD CS replacement is proven and the revocation gate passes. States the `ADR-0009` reissue/reinstall cost up front. Revises register **C3** (host decommissioned, not renamed) and captures **A3** (AD-CS guide needs the non-domain enrollment/trust steps). |
