---
Title: ADR-0027 — AD CS Two-Tier PKI, Built the Microsoft-Recommended Way
Path: Atlas Foundation/Decisions
---

# ADR-0027 — AD CS Two-Tier PKI, Built the Microsoft-Recommended Way

| Item | Value |
|---|---|
| Status | **Proposed — 2026-07-22** (operator accepts by moving to `Accepted`) |
| Governing Policy | POL-0007 |
| Scope | **Lab-02-Cisco-Core** |
| Date | 2026-07-22 |
| Version | **1.2** (Microsoft-conformance correction — see Change Log) |
| Related | `ADR-0003` (AD CS vs OpenSSL Lab CA — coexist), `ADR-0009` (Intermediate CA / the CRL-is-decorative lesson), `ADR-0021` (AD as the tiered identity backbone), `ADR-0004` (NPS vs FreeRADIUS), `ADR-0020` (NTP/PDCe), `ADR-0007` (`atlas.lab`) |
| Evidence Status | **`Target Design`** — nothing built yet; the AD CS hosts (`RCA01`/`ICA01`) are not yet created. The reconciliation of prior ADRs/design docs is `Verified` against those documents. |
| Supersedes | Nothing. **Refines** `ADR-0003`'s "Book 4 AD CS" into a concrete build; does **not** reverse its coexist decision. |
| Reconciles | `Devices/CA01-VAULT01-PKI/Build-Checklist.md` (CA01 = the **OpenSSL** intermediate, not AD CS), `Windows-Infrastructure/303-Windows-Design-Standards.md` §7 (AD CS = build step 9), `304-Microsoft-Architecture-Reference.md` (the MS AD CS sources) |

> **This ADR exists because the operator asked to "redo the CA the Microsoft way with Windows Server — the build needs to match what Microsoft recommends," and to stand AD CS up now rather than deferring it to a later book. `ADR-0003` already reserved a Windows-native AD CS for domain machines; this ADR turns that reserved decision into a specific, Microsoft-aligned two-tier design and pulls it forward in the roadmap.**

## Context

Three prior decisions bound this one and must not drift:

- **`ADR-0003` (Accepted):** the lab runs **two CAs on one boundary — domain membership.** A live two-tier **OpenSSL Lab CA on Pi01** already issues certs to the **non-domain** gear (Pi-hole, MikroTik, **FortiGate** — `CM-0005`). AD CS is scoped to **domain-joined Windows** resources, where it earns its keep (autoenrollment, NPS, LDAPS for the DCs, future smart cards).
- **`ADR-0009`:** the OpenSSL CA shipped **revocation that reaches nothing** — no `crlDistributionPoints` on any issued cert, no CRL served over HTTP. "A revocation nobody checks is a filing action, not a security control." **Building AD CS "the Microsoft way" means not repeating that defect.**
- **`ADR-0021`:** AD is the **tiered identity backbone**; **Tier 0 = identity itself — Domain Controllers, AD CS, the tools that administer them.** A credential from a higher tier never authenticates to a lower tier.

The immediate driver is the FGT01 Pass-2 "give the FortiGate an AD-backed admin account" work and the broader device-auth wave (LDAPS for the DCs and the service estate; NPS/802.1X later) — **all of which want a real server-auth certificate on the Domain Controllers**, which today they do not have. Rather than issue a throwaway DC cert, the operator chose to build the domain PKI properly, now.

## Decision

**Stand up AD CS now as the Windows-domain PKI, as a Microsoft-recommended two-tier hierarchy, with working HTTP revocation, under the Tier-0 discipline of `ADR-0021`.**

### 1. Two-tier hierarchy (offline root + online issuing)

| Tier | Host | Role | Posture |
|---|---|---|---|
| **Root** | **`RCA01`** (new VM — **workgroup, NOT domain-joined**; Server Core is ideal, minimal footprint) | **Standalone Root CA** | **Offline** — powered off except to sign the issuing-CA cert and re-publish its CRL on schedule. Tier 0. |
| **Issuing** | **`ICA01`** (new **domain-joined member server** — **NOT a DC, and NOT CA01**) | **Enterprise Subordinate (Issuing) CA** | Online, autoenrollment + template issuance. Computer object lands in `OU=Servers,OU=Devices`. Tier 0. Administered from the PAW. |

> 🔴 **Host-naming correction (v1.1):** an earlier draft put the issuing CA on **CA01**. That is wrong — **`CA01` is the OpenSSL Debian intermediate** of the *non-domain* PKI (`Devices/CA01-VAULT01-PKI/Build-Checklist.md`; `ADR-0003`), not an AD CS host. AD CS is a **separate Windows pair, `RCA01` + `ICA01`.** (`RCA01`/`ICA01` = Root CA / Issuing CA — proposed to match the `<ROLE><NN>` convention in `303`, which doesn't yet name them; the operator confirms or renames.)

- The **root never issues leaf certificates** — it signs exactly one thing, the issuing CA's certificate. This is the entire point of the two tiers: the trust anchor stays offline and its compromise surface is near-zero, while the online issuing CA does the day-to-day work and can be rebuilt without re-establishing trust everywhere (the `ADR-0009` §Alternative-1 payoff — root cert unchanged ⇒ no trust-store re-import).
- The issuing CA is **NOT co-located on a DC** (Microsoft-recommended role separation; keeps DC and CA blast radii distinct).
- **The two PKIs stay independent (`ADR-0003` coexist):** OpenSSL = Pi01 offline root → **CA01** intermediate → non-domain gear (FGT/MKT/Pi-hole); AD CS = **RCA01** offline root → **ICA01** issuing → domain machines. Two trust anchors, one boundary — domain membership.
- **Capacity note (`302`):** PVE01 is disk-tight. `RCA01` Server Core, normally powered off (~2 GB / 40 GB); `ICA01` modest (~4 GB / 60 GB). Snapshot both before the ceremony.

### 2. Revocation must actually work (the `ADR-0009` correction — non-negotiable)

- **CDP and AIA are published over HTTP** (a simple web path, e.g. `http://pki.atlas.lab/pki/…`) and **reachable by every relying party** before any leaf certificate is issued.
- Every issued certificate carries a **CRL Distribution Point** and an **Authority Information Access** URL that resolve. The root's CRL (long-dated, republished on schedule) and the issuing CA's CRL + delta are both served.
- **Acceptance gate:** `pkiview.msc` shows all CDP/AIA/CRL locations **OK**, and revoking a test certificate is *observed to be honoured by a relying party*. Revocation is proven, not assumed. This gate is what `ADR-0009` says the OpenSSL CA never had.

### 3. Crypto & validity baseline (Microsoft-aligned)

Per Microsoft's CAPolicy.inf guidance, tuned up for a PKI meant to last:

| Parameter | Root CA | Issuing CA |
|---|---|---|
| Key | **RSA 4096** | **RSA 4096** (2048 acceptable) |
| Hash | **SHA-256** | **SHA-256** |
| Validity | **~20 years** | **~10 years** |
| CRL period | long (e.g. **26 weeks**), manual republish | base **1 week** + delta **1 day** |
| `LoadDefaultTemplates` | `0` (root) / n/a | issuing installs templates deliberately, not the default grab-bag |
| `AlternateSignatureAlgorithm` | **0** — 🔴 the **one intentional deviation** from Microsoft's sample (which uses `1`). See below. |

**Conformance correction (audited 2026-07-22 against the official Test Lab Guide `hh831348`, the CAPolicy.inf page, and the [PKI design considerations](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/pki-design-considerations) page).** An earlier draft of this ADR called 4096/20-year a "deliberate deviation upward from Microsoft." **That was inaccurate and is corrected:**

- **20-year root — matches `hh831348` exactly.** Not a deviation.
- **RSA 4096 — is Microsoft's own value on the PKI design considerations page** (the `hh831348` lab shows 2048). The stronger of two Microsoft-documented options; not a deviation.
- **SHA-256 — a required modernization, not drift.** `hh831348` predates the SHA1 deprecation and shows SHA1; Microsoft's *current* guidance is SHA-256. Following the dated lab verbatim would be wrong.
- **`AlternateSignatureAlgorithm=0` — the single genuine, intentional deviation** (Microsoft's sample uses `1`, enabling RSASSA-PSS). Chosen deliberately: PSS is validated unreliably by non-Windows relying parties — the **FortiGate** (`ADR-0028`) and later MikroTik — and a certificate a device can't validate is a *security* failure (it pressures an operator into disabling validation). `0` (PKCS#1 v1.5) is universally interoperable, making it the **more secure choice for this estate's mixed relying parties**. This is the only place the build is not byte-for-byte Microsoft's sample, and it is documented on purpose.

So: the build is conformant with Microsoft's *current* recommended two-tier PKI; the only conscious deviation is `AlternateSignatureAlgorithm=0`, justified above.

### 4. Scope stays on the `ADR-0003` boundary — for now

- **AD CS serves domain-joined machines:** DC **LDAPS / Kerberos-Authentication** certs (autoenrolled), member-server certs, NPS server cert, future 802.1X and smart-card/WHfB.
- **The Pi01 OpenSSL Lab CA keeps the non-domain gear** (FortiGate, MikroTik, Pi-hole) exactly as `ADR-0003` decided. The FortiGate does **not** get a cert *from* AD CS; if the FGT later validates the DC over LDAPS it simply **trusts the AD CS root** (importing a trust anchor ≠ being issued a cert — no `ADR-0003` reversal).
- **"Redo the CA the Microsoft way" = build AD CS properly. It does not, by itself, retire the OpenSSL CA.** Folding the non-domain devices onto AD CS (a single unified PKI) is a **separate, deliberate `ADR-0003` reversal** carrying the reissue-and-reinstall cost `ADR-0009` documents for all four devices — see Review Trigger. Not done silently as a side effect of this build.

### 5. AD CS is Tier 0, and it is an attack surface

- Both CA hosts are **Tier 0** (`ADR-0021`): administered only from the **PAW**, in the protected segment, with no lower-tier credential ever used on them.
- **AD CS is a known privilege-escalation surface (ESC1–ESC8).** The build hardens templates from the start: no "supply subject/SAN in the request" on authentication templates, enrollment permissions scoped (no broad `Authenticated Users` enroll on powerful templates), manager-approval where appropriate, **CA auditing on**, and **role separation** for CA administration. This is part of "the Microsoft way," not a later pass.

## Alternatives Considered

**A — Single-tier Enterprise Root CA (root = issuing, one box).** Common in labs and simpler. **Rejected** — the operator explicitly asked for the Microsoft-recommended build, and Microsoft's recommendation is the offline-root two-tier. A single-tier CA also means a compromise of the one online CA compromises the trust anchor itself, with no clean recovery.

**B — Interim/self-signed DC LDAPS cert now, AD CS later.** Rejected by the operator (previous decision) — keeps a throwaway on the books and defers the real work.

**C — Reuse the Pi01 OpenSSL CA to issue the DC cert.** Rejected — crosses the `ADR-0003` domain/non-domain boundary and issues a domain-critical cert from the CA `ADR-0009` flagged as having no working revocation.

**D — Replace the OpenSSL CA outright, single unified AD CS PKI.** Not chosen here. It is the plausible end-state of "the Microsoft way," but it is a **reversal of `ADR-0003`** with real reissue cost (`ADR-0009` Alternative 1) and belongs in its own decision, not folded into stand-up.

## Consequences

- **The PKI work is pulled forward** from "Book 4 / Phase 8" to sit **before the AD-backed device-auth wave** — the DC LDAPS cert it produces is the prerequisite for LDAPS (service estate) and for any AD-backed admin auth. `Master-Build-Order.md` and the Build-Progress-Tracker are re-sequenced accordingly.
- **Two new Windows VMs are needed:** `RCA01` (workgroup, offline, Tier-0 asset — not a domain object) and `ICA01` (domain-joined member server → `OU=Servers,OU=Devices`). **CA01 is NOT reused** (it's the OpenSSL intermediate). The Build-Progress-Tracker's "CA01 = online issuing CA (cloned from golden image)" row contradicts the CA01-VAULT01 checklist and is corrected in the tracker re-sequence.
- **AD gains PKI containers** automatically in the configuration partition; **no OU redesign** — the tiered structure absorbs it.
- **AD CS is now production-critical and Tier 0** ⇒ it inherits the `ADR-0021` obligation: a **tested recovery/backup path** (CA key backup + a documented restore) before anything depends on it. Offline-root private-key handling follows the `ADR-0009` discipline (no key + passphrase converging on one host; a destroy step in every backup procedure).
- **The FGT Pass-2 auth-path question (`ADR-0004`: RADIUS-backed vs direct LDAPS) is now unblocked but still open** — settled in a follow-up once the CA is up. Both options consume this PKI.

## Review Trigger

- **Before folding any non-domain device (FGT/MKT/Pi-hole) onto AD CS** — that is an `ADR-0003` reversal; raise it as its own ADR with the reissue cost stated up front.
- **When the issuing CA or DC LDAPS cert is first issued** — run the §2 revocation acceptance gate; do not skip it.
- **Before adding a second issuing CA or any cross-forest trust** — re-affirm scope (`ADR-0021` sprawl guard).
- **If AD CS ever issues to anything internet-exposed or of real value** — the `ADR-0009` payoff calculus changes.

## Sources (Microsoft-recommended build)

- Microsoft Learn — [PKI design considerations using AD CS](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/pki-design-considerations) (the `304` "start here")
- Microsoft Learn — [Prepare the CAPolicy.inf File](https://learn.microsoft.com/en-us/windows-server/networking/core-network-guide/cncg/server-certs/prepare-the-capolicy-inf-file)
- Microsoft Learn — [Test Lab Guide: Deploying an AD CS Two-Tier PKI Hierarchy](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/hh831348(v=ws.11)) (the official step-by-step `304` cites; cross-check cmdlet syntax against current docs)
- Microsoft Community Hub — [Step by Step: 2-Tier PKI Lab](https://techcommunity.microsoft.com/blog/microsoft-security-blog/step-by-step-2-tier-pki-lab/4413982)
- Microsoft Community Hub — [Secure Configuration and Hardening of Active Directory Certificate Services](https://techcommunity.microsoft.com/blog/coreinfrastructureandsecurityblog/secure-configuration-and-hardening-of-active-directory-certificate-services/4463240)
- Internal — `304-Microsoft-Architecture-Reference.md` (AD CS §), `303-Windows-Design-Standards.md` §7, `Devices/CA01-VAULT01-PKI/Build-Checklist.md`

## Change Log

| Version | Changes |
|---|---|
| 1.2 | 2026-07-22. **Microsoft-conformance correction** (audited against `hh831348` + CAPolicy + pki-design pages, POL-0001). Corrected §3's inaccurate "deliberate deviation upward" framing: 20-yr root **matches the TLG exactly**, RSA 4096 **is Microsoft's pki-design-page value**, SHA-256 is a **required modernization** over the TLG's dated SHA1 — none are deviations. The **only** intentional deviation is `AlternateSignatureAlgorithm=0` (vs the sample's `1`/PSS), chosen for non-Windows relying-party security (FortiOS/`ADR-0028`) and now documented as such. |
| 1.1 | 2026-07-22. **Host-assignment correction** after reading `Devices/CA01-VAULT01-PKI/Build-Checklist.md` + `303`/`304`: the AD CS issuing CA is **NOT CA01** (CA01 = the OpenSSL Debian intermediate of the non-domain PKI). AD CS is a **separate Windows pair, `RCA01` (offline root) + `ICA01` (issuing member server)**. Clarified the two coexisting two-tier PKIs, added capacity/Server-Core guidance, `OU=Servers,OU=Devices` placement, flagged the tracker's contradictory CA01 row for correction, and added the MS PKI-design-considerations + Test Lab Guide sources. |
| 1.0 | Proposed 2026-07-22. Stand up AD CS **now** as a Microsoft-recommended **two-tier** PKI (offline standalone RootCA01 + Enterprise Issuing CA on CA01, not on a DC), with **working HTTP CDP/AIA revocation** (the `ADR-0009` correction, gated on `pkiview` + an observed revocation), RSA-4096/SHA-256 root ~20yr / issuing ~10yr, templates hardened against ESC1–ESC8 from the start, both CA hosts **Tier 0** per `ADR-0021`. Scope held on the `ADR-0003` domain/non-domain boundary (AD CS = domain machines; OpenSSL Lab CA keeps FGT/MKT/Pi-hole); unifying onto AD CS reserved as an explicit future `ADR-0003` reversal. Pulls PKI forward ahead of the device-auth wave. |
