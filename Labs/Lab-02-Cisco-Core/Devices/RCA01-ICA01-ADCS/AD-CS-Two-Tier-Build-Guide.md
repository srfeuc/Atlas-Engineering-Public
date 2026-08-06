---
Title: AD CS Two-Tier PKI — Build Guide (RCA01 offline root + ICA01 issuing)
Path: Labs/Lab-02-Cisco-Core/Devices/RCA01-ICA01-ADCS
Status: 🟡 Target Design — authored, NOT executed. Runs per POL-0001 (verify on the device; evidence = command + output). Microsoft-conformance audited 2026-07-22 (see the conformance table before the Change Log). A4a build-time NPS cert + non-domain enrollment (`ADR-0031`) added 2026-07-28.
Version: 0.3
---

# AD CS Two-Tier PKI — Build Guide

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** — Hosts: **RCA01** (offline standalone Root CA) + **ICA01** (Enterprise Issuing/Subordinate CA) — Role: **the estate's unified PKI** (`ADR-0027` + `ADR-0031`). 🔴 **`ADR-0031` retired the OpenSSL Lab CA and reversed `ADR-0003`'s coexistence** — the non-domain gear (Pi-hole, MKT01, FGT01) now folds onto AD CS too (**Part 3B**), rather than a separate OpenSSL CA (Pi01 root → CA01, struck).

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | 🟡 **Target Design — not built.** Nothing here is device-verified yet. Every `[ ]` becomes `[x]` only with a command + its output (`POL-0001` R-A1). Microsoft-conformance audited 2026-07-22. |
| Version | 0.3 |
| Applies To | **RCA01** (Windows Server 2025, **workgroup**, offline) + **ICA01** (Windows Server 2025, **domain-joined member server**, `atlas.lab`) |
| Governs | `ADR-0027` (two-tier, Microsoft-recommended, working revocation, Tier 0); `ADR-0031` (retire OpenSSL → non-domain devices fold onto AD CS, Part 3B); `ADR-0029` (the NPS server cert, §3.5). Reconciles `Devices/CA01-VAULT01-PKI/Build-Checklist.md` (superseded), `303-Windows-Design-Standards.md` §7, `304-Microsoft-Architecture-Reference.md` |
| Reference | Microsoft — [PKI design considerations](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/pki-design-considerations) · [CAPolicy.inf](https://learn.microsoft.com/en-us/windows-server/networking/core-network-guide/cncg/server-certs/prepare-the-capolicy-inf-file) · [Two-Tier PKI Test Lab Guide](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/hh831348(v=ws.11)) |
| Governing Policy | `POL-0007` (hardening), `POL-0001` (evidence), `POL-0002` (secrets → Vaultwarden) |

> 🔴 **Break-glass / recovery-first (`Operations/Device-Hardening-Standard.md`, Part A).** The PKI's trust anchor is **RCA01's private key** — if it is lost, the whole hierarchy is rebuilt and every trust store re-imported. Before any ceremony: **snapshot both VMs**, and **back up each CA's private key** (Part 5) *before* it signs anything. RCA01 is administered only from its own console (it is never on the network); ICA01 is Tier 0 — administer it **only from PAW01**, never with a lower-tier credential (`ADR-0021`). **Do not install the CA role until the host is named its final name (§0.3).**

> 🔴 **The one rule this build exists to get right (`ADR-0009`).** The OpenSSL CA shipped revocation that reached nothing — no CRL Distribution Point on issued certs, no CRL served. *"A revocation nobody checks is a filing action, not a security control."* **This build is not done until a test certificate is revoked and a relying party is *observed* to reject it (Part 4).** That gate is mandatory, not optional.

---

## Part 0 — Prerequisites & host prep (do this first)

### 0.1 The two hosts

| Host | Domain state | Role | Normally |
|---|---|---|---|
| **RCA01** | **Workgroup** (never domain-joined) | Standalone Root CA | **Powered OFF** — on only for the initial ceremony and scheduled CRL re-publish |
| **ICA01** | **Domain-joined** member server (`atlas.lab`) → `OU=Servers,OU=Devices` | Enterprise Subordinate (Issuing) CA | Online |

- **ICA01 may be the repurposed Windows golden-image clone** (the VM currently labelled "CA01" in the tracker). Reuse is fine — it's the right OS. **Rename it to `ICA01` first (§0.3).** The name **CA01** then stays reserved for the Debian OpenSSL intermediate per its own checklist.
- **RCA01 is a new, minimal VM** — Server Core is ideal (~2 GB / 40 GB). Two-tier means two machines; the root cannot share ICA01.
- Neither CA goes on **DC01/DC02** (Microsoft role separation — keep DC and CA blast radii apart).

### 0.2 Capacity & snapshots (`302` says PVE01 is disk-tight)

- [ ] Confirm free space on `local-lvm` before cloning (`302`: ~600 GB used of 793 GB). RCA01 Server Core keeps the footprint small.
- [ ] **Snapshot both VMs** at a clean, patched, pre-CA-role state (`218-…` naming). This is the rollback for a botched ceremony.

### 0.3 🔴 Rename BEFORE the AD CS role (permanent-name gotcha)

**A CA's name is baked into its certificate, database, and every issued cert. Renaming after the role is installed = rebuild.** So, in order:

- [ ] **RCA01:** set the computer name to `RCA01` → reboot → *then* install AD CS. (Workgroup; never domain-join.)
- [ ] **ICA01:** rename the clone to `ICA01` → reboot → **domain-join** `atlas.lab` → move the computer object to `OU=Servers,OU=Devices` → *then* install AD CS.
- [ ] Decide the **CA common names** now (they need not equal the hostnames, and also can't change later). Suggested: root CA CN = `Atlas Root CA`, issuing CA CN = `Atlas Issuing CA`. Record the choice here before building.

### 0.4 Time

- [ ] **ICA01** takes time from the domain (PDCe → external, `ADR-0020`) — verify `w32tm /query /source` is the DC, not CMOS.
- [ ] **RCA01 is offline**, so its clock drifts. **Set it correctly before the ceremony** — a wrong clock backdates/futuredates the root cert and the sub-CA cert. Re-check each time RCA01 is powered on.

### 0.5 The HTTP CDP/AIA endpoint (decide the URL now — revocation depends on it)

- [ ] Choose one **HTTP path that every relying party can reach**, e.g. `http://pki.atlas.lab/pki/`. Add the `pki.atlas.lab` DNS record (CNAME/A) in AD DNS.
- [ ] Host it on a real web server that stays up — **SRV01** (planned) or the existing **Pi-hole/SRV nginx** (the same box the OpenSSL CRL is meant to serve from). It does **not** go on RCA01 (offline) and preferably not on a DC.
- [ ] This URL goes into **both** CAs' CDP/AIA (§1.4, §2.6). Getting it wrong is the exact `ADR-0009` defect — so it is verified in Part 4, not assumed.

---

## Part 1 — RCA01: the offline Standalone Root CA

> The root signs **exactly one thing** — ICA01's certificate — then goes back in its box. It never issues leaf certs and is never on the network.

### 1.1 Build & isolate

- [ ] New VM, Windows Server 2025 (Server Core ideal), **workgroup**, name `RCA01` (§0.3). Patch it once, then keep it **off the network** (remove/disconnect the vNIC after patching, or never connect it).
- [ ] Snapshot `rca01-preCA`.

### 1.2 CAPolicy.inf (root) — place in `C:\Windows\CAPolicy.inf` *before* installing the role

Grounded in Microsoft's [CAPolicy.inf guidance](https://learn.microsoft.com/en-us/windows-server/networking/core-network-guide/cncg/server-certs/prepare-the-capolicy-inf-file), tuned per `ADR-0027`:

```ini
[Version]
Signature="$Windows NT$"

[Certsrv_Server]
RenewalKeyLength=4096
RenewalValidityPeriod=Years
RenewalValidityPeriodUnits=20
CRLPeriod=Weeks
CRLPeriodUnits=26
CRLDeltaPeriod=Days
CRLDeltaPeriodUnits=0
LoadDefaultTemplates=0
AlternateSignatureAlgorithm=0
```

- `RenewalKeyLength=4096` / 20-year root. ✅ **Microsoft-conformant** (audited 2026-07-22 against the official Test Lab Guide `hh831348`): the **20-year root matches the TLG exactly**, and **RSA 4096 is Microsoft's own value on the [PKI design considerations](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/pki-design-considerations) page** (`hh831348` shows 2048; 4096 is the stronger of two Microsoft-documented options — *not* a deviation).
- `CRLPeriodUnits=26` weeks + `CRLDeltaPeriodUnits=0` — **both match the TLG root exactly** (offline root: base CRL only, manually re-published ~every 26 weeks; no deltas).
- `AlternateSignatureAlgorithm=0` — 🔴 **the one intentional deviation from Microsoft's sample (which uses `1`), documented on purpose (`ADR-0027` §3).** `1` enables RSASSA-PSS padding, which non-Windows relying parties (FortiOS/`ADR-0028`, later MikroTik) validate unreliably — and a cert those devices can't validate is a *security* problem (it pressures someone into turning validation off). `0` (PKCS#1 v1.5) is universally interoperable, so it is the **more secure choice for this estate's mixed relying parties.**
- **Hash = SHA-256** (set at install, §1.3) — a deliberate modernization: `hh831348` predates the SHA1 deprecation and shows SHA1; **Microsoft's current guidance is SHA-256**, so following the old lab verbatim would be wrong here. Keep SHA-256.

📸 *Screenshot the file in Notepad before install.*

### 1.3 Install the role (GUI-primary)

Server Manager → **Add Roles and Features** → **Active Directory Certificate Services** → role service **Certification Authority** only → after install, the yellow flag → **Configure Active Directory Certificate Services**:

- [ ] Credentials: local admin.
- [ ] Role service: **Certification Authority**.
- [ ] Setup type: **Standalone CA** (a standalone root — it is *not* domain-joined, so Enterprise is not offered).
- [ ] CA type: **Root CA**.
- [ ] Private key: **Create a new private key**.
- [ ] Cryptography: provider `RSA#Microsoft Software Key Storage Provider`, **key length 4096**, hash **SHA-256**.
- [ ] CA name (Common Name): **`Atlas Root CA`** (§0.3 — permanent).
- [ ] Validity period: **20 years**.
- [ ] Finish → the CA service starts.

📸 *Capture the Cryptography page (4096 / SHA-256) and the final summary.*

> *(Server Core / PowerShell equivalent, optional:)*
> ```powershell
> Install-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools
> Install-AdcsCertificationAuthority -CAType StandaloneRootCA -CACommonName "Atlas Root CA" `
>   -KeyLength 4096 -HashAlgorithmName SHA256 -ValidityPeriod Years -ValidityPeriodUnits 20
> ```

### 1.4 Post-install registry: HTTP-only CDP/AIA + validity for the sub-CA cert

> **GUI-primary path (matches your preference):** do the CDP/AIA edits in the *Certification Authority* console → right-click the CA → Properties → *Extensions* tab. For an **offline root**, set the published locations to **HTTP + the local CertEnroll file only** (remove LDAP and any location that won't resolve for an offline root): CDP checks "Include in the CDP extension of issued certificates" + "Include in CRLs"; AIA checks "Include in the AIA extension of issued certificates."

> ✅ **The `certutil` strings below are now the *verified* Test Lab Guide (`hh831348`) values, adapted to `http://pki.atlas.lab/pki/`** (audited 2026-07-22 — previously these were flagged "verify the magic numbers"; they're now grounded, not guessed). Variable codes: `%1`=ServerDNSName, `%3`=CaName, `%4`=CertificateName suffix, `%8`=CRLNameSuffix. Still capture the `-getreg` read-back (below) as evidence — a wrong CDP is the whole `ADR-0009` failure.

```powershell
:: Root CA — CDP (local file + HTTP) and AIA (HTTP), per hh831348:
certutil -setreg CA\CRLPublicationURLs "1:C:\Windows\system32\CertSrv\CertEnroll\%3%8.crl\n2:http://pki.atlas.lab/pki/%3%8.crl"
certutil -setreg CA\CACertPublicationURLs "2:http://pki.atlas.lab/pki/%1_%3%4.crt"
:: CRL overlap (TLG):
certutil -setreg CA\CRLOverlapPeriodUnits 12
certutil -setreg CA\CRLOverlapPeriod "Hours"
:: Validity of the cert the root issues to ICA01 = 10 years (TLG):
certutil -setreg CA\ValidityPeriodUnits 10
certutil -setreg CA\ValidityPeriod "Years"
:: So directory-relative variables resolve even though the root is offline:
certutil -setreg CA\DSConfigDN "CN=Configuration,DC=atlas,DC=lab"
net stop certsvc && net start certsvc
certutil -CRL
```

- [ ] After the restart, **publish a fresh CRL**: CA console → *Revoked Certificates* → right-click → **Publish** (or the `certutil -CRL` above).

**Evidence (`POL-0001`):** `certutil -getreg CA\CRLPublicationURLs`, `certutil -getreg CA\CACertPublicationURLs`, `certutil -getreg CA\ValidityPeriodUnits` — capture the output and confirm it matches the strings above.

### 1.5 Export the root cert + CRL (to sneakernet to ICA01)

- [ ] From `C:\Windows\System32\CertSrv\CertEnroll\` copy **`Atlas Root CA.crt`** (or `RCA01_Atlas Root CA.crt`) and **`Atlas Root CA.crl`** to removable media / an ISO. These go to ICA01 (§2.2) and to the HTTP `/pki/` path (§2.7).
- [ ] 🔴 **Back up the root private key now (Part 5) before it signs anything**, and snapshot `rca01-postCA`.

---

## Part 2 — ICA01: the Enterprise Issuing (Subordinate) CA

### 2.1 Host

- [ ] `ICA01` renamed (§0.3), **domain-joined** `atlas.lab`, computer object in `OU=Servers,OU=Devices`.
- [ ] Logged in **from PAW01** as a Tier-0 admin (`t0-seth`); Server baseline GPO applies (it's under `Devices\Servers`).

### 2.2 Trust the root across the forest (before installing the sub CA)

From ICA01 (elevated), using the files from §1.5:

- [ ] Publish the root **into AD** (so every domain member trusts it automatically):
  - `certutil -dspublish -f "Atlas Root CA.crt" RootCA`
  - `certutil -dspublish -f "Atlas Root CA.crl"`
- [ ] Add it to the **local** machine trust + the enterprise stores so the sub-CA install can chain:
  - `certutil -addstore -f Root "Atlas Root CA.crt"`
- [ ] Force a policy refresh (`gpupdate /force`) and confirm the root appears under *Trusted Root Certification Authorities* on a domain member.

**Evidence:** `certutil -viewstore -enterprise Root` (or `-store Root`) shows **Atlas Root CA**.

### 2.3 CAPolicy.inf (issuing) — `C:\Windows\CAPolicy.inf` before the role

```ini
[Version]
Signature="$Windows NT$"

[Certsrv_Server]
RenewalKeyLength=4096
RenewalValidityPeriod=Years
RenewalValidityPeriodUnits=10
LoadDefaultTemplates=0
AlternateSignatureAlgorithm=0
```

- `LoadDefaultTemplates=0` — **do not auto-publish the default template grab-bag**; templates are added deliberately in Part 3 (an ESC-hardening measure).

### 2.4 Install the role → generate a request

Add Roles → **AD CS** → **Certification Authority** → Configure:

- [ ] Setup type: **Enterprise CA** (offered because it's domain-joined; needs Enterprise Admins / a Tier-0 account).
- [ ] CA type: **Subordinate CA**.
- [ ] Private key: **Create a new private key**; RSA **4096**, **SHA-256**.
- [ ] CA name: **`Atlas Issuing CA`** (permanent).
- [ ] "Request a certificate from a parent CA" → **Save a request to file** (RCA01 is offline, so there's no online parent to send to). This writes `C:\*.req`.
- [ ] Finish — the CA is installed but **stopped/pending** until its cert is issued.

📸 *Capture the "save request to file" page and the request path.*

### 2.5 Sign the request on the offline root (sneakernet)

- [ ] Copy the `.req` to RCA01. On RCA01, CA console → right-click the CA → **All Tasks → Submit new request** → select the `.req`.
- [ ] Under *Pending Requests*, right-click the new request → **All Tasks → Issue**.
- [ ] Under *Issued Certificates*, open it → **Details → Copy to File** → export as **PKCS#7 (.p7b), include the chain** → `ICA01.p7b`.
- [ ] Sneakernet `ICA01.p7b` (and, if not already carried, the root `.crt`/`.crl`) back to ICA01.

### 2.6 Install the sub-CA cert + configure CDP/AIA, then start

- [ ] On ICA01, CA console → right-click the CA → **All Tasks → Install CA Certificate** → select `ICA01.p7b`.
- [ ] **Extensions** tab (GUI-primary): set CDP = local CertEnroll + **LDAP** (the default AD location) + **HTTP**; AIA = LDAP + **HTTP**. Tick "Include in … of issued certificates" on the HTTP + LDAP entries.
- [ ] ✅ **Verified `hh831348` strings for the *issuing* CA (audited 2026-07-22), adapted to `pki.atlas.lab`.** The LDAP CDP/AIA entries are the CA-console defaults — leave them; the commands below set the file + HTTP entries and the CRL periods:

```powershell
:: Issuing CA — CDP (local + HTTP) and AIA (HTTP + local file share), per hh831348:
certutil -setreg CA\CRLPublicationURLs "1:C:\Windows\system32\CertSrv\CertEnroll\%3%8.crl\n2:http://pki.atlas.lab/pki/%3%8.crl"
certutil -setreg CA\CACertPublicationURLs "2:http://pki.atlas.lab/pki/%1_%3%4.crt"
:: CRL cadence — base 1 week + delta 1 day (TLG uses 2-week base; 1 week is a deliberate, security-positive tightening — fresher revocation):
certutil -setreg CA\CRLPeriodUnits 1
certutil -setreg CA\CRLPeriod "Weeks"
certutil -setreg CA\CRLDeltaPeriodUnits 1
certutil -setreg CA\CRLDeltaPeriod "Days"
certutil -setreg CA\CRLOverlapPeriodUnits 12
certutil -setreg CA\CRLOverlapPeriod "Hours"
net stop certsvc && net start certsvc
certutil -CRL
```

- [ ] **Start the CA service.** In the console the CA node should show green/running.

**Evidence:** `certutil -getreg CA\CRLPublicationURLs` + `…CACertPublicationURLs`; CA console shows the sub-CA cert chaining to *Atlas Root CA*.

### 2.7 Publish CRLs + root cert to the HTTP endpoint

- [ ] Copy the **root** `.crt` + `.crl` (from §1.5) and the **issuing** CA's `.crt` + base/delta `.crl` (from ICA01's `CertEnroll\`) into the web root serving `http://pki.atlas.lab/pki/`.
- [ ] Set a reminder/task to re-copy the **root CRL every ~26 weeks** (offline root — manual) and confirm the issuing CA auto-publishes its CRL there.

---

## Part 3 — Templates, ESC hardening, and the DC LDAPS cert

### 3.1 Harden before you publish anything (ESC1–ESC8, `ADR-0027`)

- [ ] **CA auditing on:** CA → Properties → *Auditing* → enable all events; ensure "Audit object access" is on via GPO. Evidence via the Security event log.
- [ ] **No "supply in the request" on authentication templates** — never let the enrollee choose the subject/SAN on a template with an auth EKU (the ESC1 hole). Use only build-from-AD templates for auth.
- [ ] **Scope enrollment** — don't leave broad `Authenticated Users` *Enroll* on powerful templates; grant Enroll to specific groups.
- [ ] **Manager approval** on any sensitive template.
- [ ] **Role separation** — CA Administrator vs Certificate Manager as distinct Tier-0 duties where practical.

### 3.2 Publish the DC template + turn on autoenrollment

The DC LDAPS/KDC cert is the deliverable that unblocks the device-auth wave.

- [ ] CA console → **Certificate Templates → Manage** → use the **Kerberos Authentication** template (supersedes *Domain Controller* / *DC Authentication*; provides Server Authentication + KDC + the DC FQDN in the SAN). Optionally duplicate it to `Atlas-KerberosAuth` to control validity/permissions, and set it to **supersede** the older DC templates.
- [ ] Back in the CA console → **Certificate Templates → New → Certificate Template to Issue** → select **Kerberos Authentication** (or your duplicate).
- [ ] **Autoenrollment GPO:** GPMC → a GPO linked to the **Domain Controllers** OU → *Computer Config → Policies → Windows Settings → Security Settings → Public Key Policies* → **Certificate Services Client – Auto-Enrollment** = Enabled, tick *Renew expired / update / remove revoked* **and** *Update certificates that use certificate templates*.

### 3.3 Enrol & verify on the DCs

- [ ] On DC01 (and DC02): `gpupdate /force` then `certutil -pulse` to trigger autoenrollment.
- [ ] Verify the DC now holds a machine cert with **Server Authentication** (and KDC) EKU, subject/SAN = the DC FQDN, chaining to **Atlas Root CA**:
  - `certutil -store My` (capture the issued cert + its EKUs + issuer)

### 3.4 🎯 Verify LDAPS (636) — the unblock

- [ ] From PAW01: **`ldp.exe`** → *Connection → Connect* → server `dc01.atlas.lab`, port **636**, tick **SSL** → a successful bind (RootDSE returns) proves LDAPS is live on a trusted cert.
- [ ] Repeat for DC02.

**Evidence:** the `ldp.exe` success banner / RootDSE output. This is what the service-estate LDAPS and any AD-backed device auth were waiting on.

### 3.5 NPS server cert (build-time — `ADR-0029`)

The RADIUS server **`NPS01`** needs a server certificate for **PEAP/EAP-TLS**. Under `ADR-0029` (D7) this is a **build-time** item, no longer deferred (it was "later" here under the old `ADR-0004`).

- [ ] Publish the **RAS and IAS Server** template on ICA01 (CA console → *Certificate Templates → New → Certificate Template to Issue*). Optionally duplicate it (`Atlas-RAS-IAS`) to control validity/permissions; scope **Enroll** to `NPS01` (or a group holding it) — *not* broad `Authenticated Users` (ESC hygiene, §3.1).
- [ ] On `NPS01`: `gpupdate /force` then `certutil -pulse` to autoenrol; verify `certutil -store My` holds a **Server-Authentication** cert whose subject/SAN = `nps01.atlas.lab`, chaining to **Atlas Root CA**.
- [ ] Password RADIUS (PAP/MS-CHAPv2) works **without** this cert; **cert-based PEAP/EAP-TLS waits on it.** See `Devices/NPS01-Network-Policy-Server/Build-Guide.md` (the RADIUS role that consumes this cert).

---

## Part 3B — Non-domain enrollment & root-trust distribution (`ADR-0031`)

> 🔴 **`ADR-0031` reversed `ADR-0003`.** The non-domain devices — **Pi-hole, MKT01, FGT01** — now get their certificates from **ICA01** and trust the AD CS chain, instead of the retired OpenSSL Lab CA. They **can't autoenrol** (not domain-joined), so enrollment is **manual per device**, and each must be handed the **RCA01 root** (+ the ICA01 intermediate) as a trust anchor **by hand** — no GPO reaches them. **Migrate-and-test before retiring (D5, `ADR-0031`):** no device's OpenSSL trust is removed until its AD CS cert is proven *and* the revocation gate (Part 4) passes on that device. Pi-hole is in active use on its current cert — plan for the brief TLS interruption on cutover.

### 3B.1 Distribute the trust anchor (every non-domain device)

- [ ] Carry the **`Atlas Root CA.crt`** (§1.5) and the **ICA01 issuing cert** to each device and install both into its trust store:
  - **Pi-hole / Linux:** copy root + intermediate to `/usr/local/share/ca-certificates/` → `update-ca-certificates`; verify with `openssl verify -CAfile`.
  - **FGT01 (FortiOS):** *System → Certificates → Import → CA Certificate* — import root + intermediate (GUI-primary; `ADR-0028` already points FGT01's admin LDAPS at ICA01).
  - **MKT01 (RouterOS):** `/certificate import` the root + intermediate PEM; verify `/certificate print` shows them trusted (`T` flag), read state back with `print detail` (`MC-0001`/`016`).
- [ ] Confirm the chain on each device: **Atlas Root CA** trusted + the ICA01 intermediate present.

### 3B.2 Issue each device a cert from ICA01 (manual CSR)

- [ ] On the device, generate a key + **CSR** with the device FQDN as subject/SAN — FGT01: GUI *Generate*; MKT01: `/certificate add … create-certificate-request`; Pi-hole: `openssl req`.
- [ ] Submit the CSR to **ICA01** — CA console *All Tasks → Submit new request*, **or** `certreq -submit -config "ICA01\Atlas Issuing CA" <device>.req` → *Issue* → export the signed cert **with chain**.
- [ ] Install the signed cert back on the device and bind it to its service (Pi-hole web/TLS; FGT01 admin/LDAPS relying cert per `ADR-0028`; MKT01 service cert). Read the binding back (`get`/`print detail`, not `show`).
- [ ] 🔴 **Prove revocation on the device (per-device `ADR-0009` gate):** issue a throwaway cert → **revoke** it → **publish the CRL** → confirm the device fetches `http://pki.atlas.lab/pki/` and **rejects** the revoked cert. Only *then* retire that device's OpenSSL trust (D5). If revocation can't be made to reach a given device, its OpenSSL trust **stays** until it can (`ADR-0031` review trigger).

📸 *Capture each device's trust store showing **Atlas Root CA**, and its newly-issued cert chaining to it.*

---

## Part 4 — 🔴 The revocation acceptance gate (mandatory — the `ADR-0009` correction)

**Do not mark this PKI "done" until both pass:**

- [ ] **`pkiview.msc`** (Enterprise PKI) shows **every CDP, AIA, and CRL location for both CAs = OK** (no red). Screenshot it.
- [ ] **Prove a revocation is honoured:** issue a throwaway test cert from ICA01 → **revoke** it (CA console → *Issued Certificates* → Revoke) → **publish the CRL** → on a relying party, validate the cert and confirm it is **rejected as revoked** (e.g. `certutil -verify -urlfetch <testcert>.cer` shows the revocation reached; or a browser/service refuses it). Capture the output.

If revocation does **not** reach, the CDP/AIA (§1.4/§2.6/§2.7) is wrong — fix it before issuing anything real. This is the exact gate the OpenSSL CA never had.

---

## Part 5 — Recovery, backup & break-glass

- [ ] 🔴 **Back up each CA's private key + database** — CA console → *All Tasks → Back up CA* (or `certutil -backupkey` / `Backup-CARoleService`) → protect with a strong password → store the backup **encrypted on BKP01** + off-site.
  - **Passwords → VAULT01/Vaultwarden** (`POL-0002`), **never** on disk in cleartext or in git.
  - 🔴 **`ADR-0009` discipline:** the key backup and the password that opens it must **not** converge on one host, and **every backup procedure has a destroy step** for interim copies. That convergence is exactly what bit the OpenSSL CA.
- [ ] **RCA01 stays powered off** between the initial ceremony and scheduled CRL re-publishes. Its snapshot + key backup are the trust-anchor recovery.
- [ ] **ICA01** — snapshot after go-live; the CA DB + key backup is the rebuild path (root cert unchanged ⇒ no trust-store re-import, the two-tier payoff).
- [ ] Document a one-page **restore drill** (later: a Game Day, `ADR-0021`'s "prove the recovery" bar).

---

## Deferred / later

- **Certificate templates for member servers / web (LDAPS for the service estate — NetBox, Grafana, Proxmox, Vaultwarden per `ADR-0021`)** — once the DC cert path is proven.
- ~~**NPS server cert** (RAS and IAS Server template) — when NPS is stood up~~ → ✅ **now build-time, see §3.5** (`ADR-0029` D7 reclassified this deferred → build-time; the old `ADR-0004` framing is superseded).
- **Autoenrollment for member servers / (later) users, smart-card/WHfB** — Windows-domain devices (non-domain gear is handled manually in **Part 3B** per `ADR-0031`).
- ~~**Any non-domain device onto AD CS** — that's an `ADR-0003` reversal; raise its own ADR first.~~ → ✅ **decided: `ADR-0031`** reverses `ADR-0003`; the enrollment + trust-distribution steps are now **Part 3B** above (build-time; migrate-and-test per D5).

## Related

- `ADR-0027` (this build's decision) · `ADR-0031` (retire OpenSSL → non-domain folds onto AD CS, Part 3B) · `ADR-0003` (the coexistence this reverses) · `ADR-0009` (the CRL lesson) · `ADR-0021` (Tier 0 / tiered backbone) · `ADR-0029` (NPS/RADIUS — the §3.5 server cert) · `ADR-0028` (FGT01 LDAPS relying party)
- `Devices/CA01-VAULT01-PKI/Build-Checklist.md` (the OpenSSL side; CA01 ≠ this) · `Architecture/Lab-02-Offline-Root-CA-Build-Design.md` (the OpenSSL ceremony — the sneakernet/offline-root pattern mirrored here)
- `Windows-Infrastructure/303-Windows-Design-Standards.md` §7 (build order) · `304-Microsoft-Architecture-Reference.md` (AD CS §, MS sources)
- `Operations/Device-Hardening-Standard.md` (recovery-first) · `Devices/DC-Domain-Controllers/*` (the DCs that autoenrol) · `PAW01-Tier0-Admin/Build-Guide.md` (where this is administered from)

## Microsoft conformance (audited 2026-07-22, POL-0001)

This build was verified step-by-step against Microsoft's official sources. It follows Microsoft's two-tier method faithfully; **most parameters match the Test Lab Guide `hh831348` exactly** (20-yr root, 26-wk root CRL, no root delta, `LoadDefaultTemplates=0`, sub-cert `ValidityPeriodUnits=10`, `DSConfigDN`, `-dspublish` of the root, HTTP CDP/AIA, request→offline-sign→install, sub base+delta CRL, `CRLOverlapPeriod` 12h).

Differences, each characterized honestly:

| Parameter | This build | Microsoft | Verdict |
|---|---|---|---|
| Root/issuing key | RSA 4096 | `hh831348` = 2048; **pki-design page = 4096** | ✅ Not a deviation — the stronger Microsoft-documented option |
| Root validity | 20 years | `hh831348` = 20 years | ✅ Exact match |
| Hash | SHA-256 | `hh831348` = SHA1 (dated) | ✅ Correct modernization — current MS guidance is SHA-256; keep it |
| `AlternateSignatureAlgorithm` | `0` | sample = `1` (PSS) | 🔴 **The one intentional deviation** — `0` for non-Windows relying-party (FortiOS/`ADR-0028`) interop = the more secure real-world outcome. Documented. |
| Issuing base CRL | 1 week | `hh831348` = 2 weeks | Minor, security-positive (fresher revocation) — documented |
| `[PolicyStatementExtension]` CPS block | omitted | present in samples | Optional; not a conformance issue |

**Sources (verified live 2026-07-22):** Microsoft Learn — [Two-Tier PKI Test Lab Guide `hh831348`](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/hh831348(v=ws.11)) · [Prepare the CAPolicy.inf File](https://learn.microsoft.com/en-us/windows-server/networking/core-network-guide/cncg/server-certs/prepare-the-capolicy-inf-file) · [PKI design considerations](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/pki-design-considerations). 🔴 Could not retrieve the newer [techcommunity 2-tier lab](https://techcommunity.microsoft.com/blog/microsoft-security-blog/step-by-step-2-tier-pki-lab/4413982) (fetch returned metadata only) — open it directly to cross-check if desired.

## Change Log

| Version | Changes |
|---|---|
| 0.3 | 2026-07-28. **Phase-2 reconciliation A4a.** (1) Promoted the **NPS server cert** from *Deferred* to **build-time §3.5** (RAS-and-IAS-Server template from ICA01, enrol on `NPS01`) per `ADR-0029` D7 — the old `ADR-0004` "later" framing is superseded. (2) Added **Part 3B — non-domain enrollment & root-trust distribution** (`ADR-0031`, which reverses `ADR-0003`): Pi-hole/MKT01/FGT01 install the RCA01 root (+ICA01) as a trust anchor by hand and get a cert from ICA01 via manual CSR, with the per-device `ADR-0009` revocation gate and migrate-and-test-before-retire (D5). (3) Updated the provenance line, Governs, Deferred bullets, and Related list from the `ADR-0003` coexistence framing to the `ADR-0031` unified-PKI framing. No change to the RCA01/ICA01 ceremony (Parts 1–2) or the conformance audit. |
| 0.2 | 2026-07-22. **Microsoft-conformance audit** (POL-0001) against `hh831348` + CAPolicy + pki-design pages: added the conformance table + Sources; **replaced the hedged "verify the magic numbers" `certutil` CDP/AIA blocks (§1.4, §2.6) with the verified TLG strings** adapted to `pki.atlas.lab`; documented `AlternateSignatureAlgorithm=0` as the single intentional deviation (chosen for FortiOS/non-Windows relying-party security, `ADR-0028`); noted 4096/20yr as Microsoft-documented (not a deviation, correcting the earlier framing) and SHA-256 as a required modernization over the TLG's SHA1. |
| 0.1 | 2026-07-22. Authored (not executed). Two-tier AD CS build per `ADR-0027`: Part 0 prereqs (the **rename-before-role** gotcha; ICA01 = the repurposed golden-image clone, RCA01 = new offline Server Core root; capacity; the HTTP CDP endpoint), Part 1 offline **RCA01** (CAPolicy.inf, standalone-root install RSA-4096/SHA-256/20yr, HTTP-only CDP/AIA, export), Part 2 **ICA01** enterprise subordinate (publish root to AD, CAPolicy.inf, request→offline-sign→install, CDP/AIA + CRL periods, HTTP publish), Part 3 ESC hardening + Kerberos-Auth template + autoenrollment + **LDAPS(636) verify**, Part 4 the **mandatory revocation acceptance gate** (`pkiview` all-OK + an observed revocation — the `ADR-0009` correction), Part 5 key/DB backup with the `ADR-0009` convergence/destroy discipline. GUI-primary; `certutil` shown for reference with a 🔴 "verify the flag numbers against the MS Test Lab Guide" caveat. |
