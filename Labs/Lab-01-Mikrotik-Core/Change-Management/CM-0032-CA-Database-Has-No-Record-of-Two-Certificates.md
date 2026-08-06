# CM-0032 — The CA Database Has No Record of Two Certificates It Signed. And `032` Rebuilds Pi-hole From a Stale File.

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Change-Management

| Item | Value |
|---|---|
| Status | **Draft** |
| Risk | 🔴 **HIGH.** *(Not because a certificate is exposed. Because `index.txt` is `ADR-0009`'s ONLY compromise-detection control — and it is 40% blind.)* |
| Affected systems | Pi01 — Lab CA (`index.txt`, `issued/pihole/`), Pi-hole. **`032`, `035`, `042`, `048` (documentation).** |
| Date raised | 2026-07-14 |
| Evidence Status | **`Verified`** — live device output, Pi01, 2026-07-14 |
| Related | `ADR-0009`, `MC-0002`, `CM-0008`, `CM-0027`, `031`, `032`, `048`, `051` |

> **Raised because the operator asked whether a stale certificate SAN was a security problem. It is not — and looking for the answer found something that is.**

---

## The device output

```
dnsadmin@pihole:~ $ sudo cat /etc/ssl/lab-ca/intermediate/index.txt
R  270713004002Z  260713010943Z  1000  unknown  /...CN=mikrotik.lab      <- revoked
V  270713011017Z                 1001  unknown  /...CN=mikrotik.lab
V  270713015133Z                 1002  unknown  /...CN=vault.lab
V  270713042055Z                 1003  unknown  /...CN=pihole.lab
```

**Four rows. Now count the certificates this CA has actually signed and that devices actually trust:**

| # | Certificate | Serial | In `index.txt`? |
|---|---|---|---|
| 1 | `mikrotik.lab` (broken, empty SAN) | `1000` | ✅ **R** (revoked) |
| 2 | `mikrotik.lab` (current, live on `www-ssl`) | `1001` | ✅ **V** |
| 3 | `vault.lab` (live on nginx:8443) | `1002` | ✅ **V** |
| 4 | `pihole.lab` (live in `tls.pem`) | `1003` | ✅ **V** |
| 🔴 **5** | 🔴 **`pihole.lab` — the ORIGINAL** | `740BE5A81FB4906F1A2E749CD8343E450125D9EA` | 🔴 **ABSENT** |
| 🔴 **6** | 🔴 **`fortigate.lab` — LIVE ON FGT01 RIGHT NOW** | *(not in `index.txt` at all)* | 🔴 **ABSENT** |

```
dnsadmin@pihole:~ $ sudo openssl x509 -in /etc/ssl/lab-ca/issued/pihole/pihole.crt -noout -serial -subject -dates
serial=740BE5A81FB4906F1A2E749CD8343E450125D9EA        <- a 20-byte RANDOM serial. Not 1000-1003.
subject=C=US, ST=California, L=Redding, O=Home Lab, CN=pihole.lab
notBefore=Jun 12 21:02:52 2026 GMT
notAfter=Jun 12 21:02:52 2027 GMT
```

```
dnsadmin@pihole:~ $ ls -la /etc/ssl/lab-ca/issued/pihole/
-rw-r--r-- 1 root root  263 Jun 12 17:02 pihole.ext        <- 🔴 THE TELL
```

## 🔴 Root cause — `-extfile` signs a certificate and does NOT write to `index.txt`

**`029` and `031` v0.6 already told us, and nobody followed the thread:**

> *"FortiGate's predates the `copy_extensions` fix and was **correct anyway** — it was built via **`-extfile`**, which supplies extensions at signing time and **bypasses `copy_extensions` entirely.**"*

**`-extfile` is a flag for `openssl x509 -req`. `openssl x509 -req` is not `openssl ca`.**

| | `openssl ca` | 🔴 **`openssl x509 -req -extfile`** |
|---|---|---|
| Signs a certificate | ✅ | ✅ |
| **Writes to `index.txt`** | ✅ | 🔴 **NO** |
| Consumes a serial from `serial` | ✅ (`1000`, `1001`…) | 🔴 **NO** — generates a random 20-byte serial |
| Writes to `newcerts/` | ✅ | 🔴 **NO** |
| Can be revoked | ✅ (*bookkeeping only — no CDP*) | 🔴 **NOT EVEN BOOKKEEPING.** `openssl ca -revoke` fails: *the CA has no record of it.* |

**The `pihole.ext` file and the random serial are the fingerprints.** **Both the original Pi-hole certificate and FGT01's were signed with `x509 -req -extfile`, during the original CA build, before `031` existed.**

---

## 🔴🔴 THE FINDING — `index.txt` is `ADR-0009`'s only control, and it is 40% blind

**`ADR-0009` — the decision that ACCEPTED the risk of a possibly-compromised Intermediate CA — rests on this, verbatim:**

> 🔴 *"**`index.txt` becomes a control, not just a file.** It is the CA's record of every certificate ever issued. 🔴 **It is now the ONLY way to detect an unauthorised issuance.** It is in the backup (`049`), and **it should be checked against deployed certificates periodically.**"*

**And its own Review Trigger:**

> 🔴 *"**A certificate appears that this CA did not knowingly issue** → **reverse this decision immediately and replace the Intermediate as an emergency.** **Check `index.txt` against what is deployed.**"*

> 🔴 **RUN THAT CHECK TODAY AND IT FIRES.**
>
> **FGT01 is serving a certificate that `index.txt` has no record of.** **Under `ADR-0009`'s literal trigger, that is an emergency Intermediate replacement.**
>
> 🔴 **IT IS NOT ONE. The certificate is legitimate — we know exactly where it came from.** **But the control cannot tell the difference, and that is the entire problem.**

**`ADR-0009` also establishes this CA CANNOT REVOKE** (no `crlDistributionPoints`, no CRL served — `031` v0.7). **So:**

| Layer | State |
|---|---|
| **Revocation reaches clients** | 🔴 **NO** — no CDP. `MC-0002` revoked serial `1000`; it is **still trusted by every device today.** |
| **Revocation is at least recorded** | 🔴 **NO — for these two.** `openssl ca -revoke` cannot revoke a certificate the CA has no row for. |
| **Detection of an unauthorised issuance** | 🔴 **DEGRADED.** The control's baseline is missing 2 of 6 known-good certificates. **A real rogue certificate is indistinguishable from these two.** |

> 🔴 **A compromise-detection control whose baseline is wrong does not fail safe. It fails LOUD and WRONG — it cries wolf on two legitimate certificates, and the operator learns to ignore it.**
>
> **`ADR-0009` accepted a real risk on the strength of this control. The control does not work. `ADR-0009` must be told.**

---

## 🔴 Finding 2 — `032` rebuilds Pi-hole from the STALE file

**The live service is CORRECT:**

```
sudo openssl x509 -in /etc/pihole/tls.pem -noout -serial -dates
serial=1003
notBefore=Jul 13 04:20:55 2026 GMT

openssl s_client -connect 10.10.0.5:443 | openssl x509 -noout -text | grep -A1 SAN
    DNS:pihole.lab, DNS:pi.hole, IP Address:10.10.0.5      🟢 CORRECT

sudo grep -c "BEGIN CERTIFICATE"  /etc/pihole/tls.pem   -> 3   🟢
sudo grep -c "BEGIN.*PRIVATE KEY" /etc/pihole/tls.pem   -> 1   🟢
```

🟢 **`031` v0.6's *"Certificate SANs Verified — CLOSED"* table is TRUE.** **That verification was real and it was done on the wire.**

🔴 **And the SOURCE FILE it rebuilds from is stale:**

```
/etc/ssl/lab-ca/issued/pihole/pihole.crt
  serial 740BE5...  (Jun 12)   SAN: DNS:pihole.lab, DNS:pi.hole, IP Address:10.0.0.5   🔴 PRE-VLAN
```

**`032` Step 7 builds `tls.pem` from EXACTLY that file:**

```bash
sudo sh -c 'cat /etc/ssl/lab-ca/issued/pihole/pihole.crt \
    /etc/ssl/lab-ca/intermediate/certs/ca-chain.crt \
    /etc/ssl/lab-ca/issued/pihole/pihole.key \
    > /etc/pihole/tls.pem'
```

**`048` Phase 3.5 restores `/etc/ssl/lab-ca` whole — stale file included — then rebuilds Pi-hole from `032`.**

> 🔴 **A REBUILD SERVES THE WRONG CERTIFICATE.** `IP:10.0.0.5` on a host at `10.10.0.5`. **Browser name-mismatch on the lab's DNS server, during a rebuild, with no DNS.** **This is the exact `CM-0008` / `MC-0002` incident, pre-loaded into the rebuild path.**
>
> 🔴 **The serial-`1003` certificate was NEVER written back to `issued/pihole/`.** It exists only in `intermediate/newcerts/` and inside `tls.pem`. **The `issued/` tree — the tree the guides read from — does not know it exists.**

## 🔴🔴 THE PATTERN — P2, in its purest form yet

> **The verification checked THE WIRE. The rebuild uses THE FILE. Nobody checked the file.**

**`031` v0.6, `029`, `MC-0002` and `NETWORK-PACK-MANIFEST` all record: *"SANs verified directly on the live-served connection."*** **All four are TRUE.**

**And all four verified the one artefact a rebuild does not use.**

> **This is `051`'s P2 — *the correction reaches the document that DESCRIBES the work and misses the one that DOES it* — applied to ARTEFACTS instead of documents.**
>
> **The wire is what you check. The file is what you rebuild from. They were never compared.**

## 🟢 What is NOT wrong — stated so nobody over-corrects

| | |
|---|---|
| **`copy_extensions`** | 🟢 **`[ CA_default ]`, line 4.** Correct section. *(The auditor suspected an `MC-0002` repeat — `[ ca ]` instead of `[ CA_default ]`. **The device disproved it. Recorded, not hidden.**)* |
| **All four live-served certificates** | 🟢 **CORRECT.** Pi-hole `1003`, MikroTik `1001`, Vaultwarden `1002`, FGT01 `fortigate-bundle`. |
| **FGT01 / MikroTik / Vaultwarden `issued/` files** | 🟢 **CORRECT SANs.** **Only Pi-hole's source file is stale.** |
| **CA private keys** | 🟢 **`049` Phase 0.2 PASSES** — exactly one `.key` per private dir, `0600`, **no `.bak` files.** `CM-0010` holds. |
| **Is the stale cert a security exposure?** | 🟢 **Effectively no.** **A certificate without its private key is inert** — it is a public document. The key is `0600 root`. **The operator's decision to defer was defensible and is upheld.** |

---

## Implementation

### 🔴 Step 1 — Write the current Pi-hole certificate back into `issued/`

**Do NOT reissue. The certificate is correct. It just is not where the guides look.**

```bash
# Find serial 1003 in newcerts/ and confirm it is what tls.pem serves
sudo openssl x509 -in /etc/ssl/lab-ca/intermediate/newcerts/1003.pem -noout -serial -text | grep -A1 "Subject Alternative Name"
# EXPECT: serial=1003, SAN: DNS:pihole.lab, DNS:pi.hole, IP Address:10.10.0.5

# Back up the stale one before overwriting. Then replace.
sudo cp /etc/ssl/lab-ca/issued/pihole/pihole.crt /etc/ssl/lab-ca/issued/pihole/pihole.crt.stale-2026-06-12
sudo cp /etc/ssl/lab-ca/intermediate/newcerts/1003.pem /etc/ssl/lab-ca/issued/pihole/pihole.crt

# Rebuild the bundle from the CORRECTED file
sudo sh -c 'cat /etc/ssl/lab-ca/issued/pihole/pihole.crt \
    /etc/ssl/lab-ca/intermediate/certs/ca-chain.crt \
    > /etc/ssl/lab-ca/issued/pihole/pihole-bundle.crt'

# 🔴 READ IT BACK. A clean cp proves nothing.
sudo openssl x509 -in /etc/ssl/lab-ca/issued/pihole/pihole.crt -noout -serial -text | grep -A1 "Subject Alternative Name"
# EXPECT: serial=1003 ... IP Address:10.10.0.5
sudo grep -c "BEGIN CERTIFICATE" /etc/ssl/lab-ca/issued/pihole/pihole-bundle.crt   # EXPECT 3
```

> 🔴 **DO NOT touch `/etc/pihole/tls.pem`. It is already correct and Pi-hole is serving from it.** **This step fixes the SOURCE, not the service.** **Nothing restarts. Nothing goes down.**

🔴 **THEN destroy the `.stale-2026-06-12` backup** once the read-back passes. **`CM-0010`: *"a key backup is a rollback with an expiry measured in minutes."* Same rule for a stale certificate — it is a trap, not an archive.**

### 🔴 Step 2 — Reconstruct `index.txt`. **This is the important one.**

**Two certificates are missing from the CA's only detection control.**

```bash
# The two orphans:
sudo openssl x509 -in /etc/ssl/lab-ca/issued/pihole/pihole.crt.stale-2026-06-12 -noout -serial -subject -dates
sudo openssl x509 -in /etc/ssl/lab-ca/issued/fortigate/fortigate.crt      -noout -serial -subject -dates
```

**Then append a row to `index.txt` for each, in OpenSSL's tab-separated format:**

```
<V|E|R>	<notAfter YYMMDDHHMMSSZ>	<revocation date or empty>	<serial hex>	unknown	<subject DN>
```

- **FGT01's certificate → `V` (valid).** **It is live and legitimate.**
- **Pi-hole's original → `E` (expired) or `R` (revoked).** 🟡 **It is superseded, not compromised.** **Operator's call — but it MUST have a row, or the control stays blind.**

> 🔴 **HAND-EDITING `index.txt` IS DANGEROUS.** **Back it up first (`cp index.txt index.txt.bak-$(date +%F)`), and `openssl ca -status <serial>` after every change.** **A malformed `index.txt` breaks the CA's ability to issue anything.**
>
> 🔴 **DESTROY the `.bak` the moment the CA is proven working.** **`CM-0010`: three `.bak` files from one date is a habit, not an accident.**

**Validate:**
```bash
sudo openssl ca -config /etc/ssl/lab-ca/intermediate/openssl.cnf -status 1003
sudo openssl ca -config /etc/ssl/lab-ca/intermediate/openssl.cnf -status <fgt01-serial>
# BOTH must return a status. "Not present in database" = the control is still blind.
```

### 🔴 Step 3 — Tell `ADR-0009`. It accepted a real risk on a control that does not work.

**`ADR-0009` must be amended, not silently patched:**

> 🔴 **`index.txt` was incomplete when `ADR-0009` was written.** **The Intermediate-CA risk was accepted on the strength of a detection control with a 2-of-6 blind spot.**
>
> **The decision — *do not treat the Intermediate as compromised* — is still defensible: the payoff to an attacker is a home lab, and there is still no evidence of intrusion.** **But the REASONING must be corrected**, because `ADR-0009` explicitly says: *"the honest reason this risk is acceptable is that the payoff is low — **not** that the lab is clean, because **the lab cannot currently tell whether it is clean**."*
>
> 🔴 **It could tell even less than it thought.**

**And its periodic check must become a real, written procedure** — see Step 4.

### 🔴 Step 4 — The check that would have caught this. Add it to `015`.

```bash
# For every device, compare the WIRE against the DATABASE.
for d in 10.10.0.5 10.10.0.1 10.10.0.254; do
  s=$(openssl s_client -connect $d:443 </dev/null 2>/dev/null | openssl x509 -noout -serial | cut -d= -f2)
  echo "=== $d  serial=$s"
  sudo openssl ca -config /etc/ssl/lab-ca/intermediate/openssl.cnf -status "$s" 2>&1 | tail -1
done
```

> 🔴 **"Not present in database" on a LIVE certificate is `ADR-0009`'s emergency trigger.** **Today it fires on FGT01, legitimately-but-wrongly. After Step 2, it will only fire on something real.**

**And the artefact check `032`, `035` and `048` all need:**

```bash
# 🔴 The WIRE and the FILE must agree. Verifying one proves nothing about the other.
diff <(openssl s_client -connect <ip>:443 </dev/null 2>/dev/null | openssl x509 -noout -text | grep -A1 "Subject Alternative Name") \
     <(sudo openssl x509 -in /etc/ssl/lab-ca/issued/<dev>/<dev>.crt -noout -text | grep -A1 "Subject Alternative Name")
# EXPECT: no output. Any output means a rebuild will serve a different certificate than production.
```

---

## Reconciliation — all document types (`ADR-0019`)

| Document | Outcome | Detail |
|---|---|---|
| 🔴 **`032`** (Build Guide) | **MUST UPDATE** | 🔴 **Step 7 rebuilds `tls.pem` from `issued/pihole/pihole.crt`.** **Add the wire-vs-file check BEFORE the `cat`.** **Handled with `CM-0027`.** |
| 🔴 **`035`** (Runbook) | **MUST UPDATE** | 🔴 **`CM-0027` already rewrites it.** **Add: after `openssl ca`, WRITE THE CERTIFICATE INTO `issued/<dev>/` — the guides read from there, and `newcerts/` is not that.** |
| 🔴 **`042`** (Guide) | **MUST UPDATE** | **`CM-0027` rewrites Step 5 (revocation).** **Add: a certificate signed with `x509 -req -extfile` CANNOT be revoked — the CA has no row for it.** |
| 🔴 **`031`** (Build Guide) | **MUST UPDATE** | 🟢 It correctly uses `openssl ca`. 🔴 **But it never says WHY, and never warns that `x509 -req -extfile` bypasses the database.** **Two certificates in this lab were signed that way.** |
| 🔴 **`048`** (Runbook) | **MUST UPDATE** | Phase 3.5 restores `/etc/ssl/lab-ca` whole — **including a stale certificate.** **Add: verify the wire matches the file after restore.** **`CM-0025`.** |
| 🔴 **`ADR-0009`** | 🔴 **MUST AMEND — this record's most important output** | **The Intermediate-CA risk was accepted on a control with a 2-of-6 blind spot.** **The decision stands; the reasoning does not.** |
| 🔴 **`015`** (Validation) | **MUST UPDATE** | **Add the wire-vs-database and wire-vs-file checks as standing validation.** |
| 🔴 **`029`** (Build Record) | **MUST UPDATE** | Record `index.txt`'s real contents and the two orphans. **`029` calls `index.txt` part of the backup — it never says what is in it.** |
| **`016`** | 🔴 **MUST UPDATE** | 🔴 **New lesson: VERIFYING THE WIRE PROVES NOTHING ABOUT THE FILE YOU REBUILD FROM.** *(See "The lesson" below.)* |
| **`MC-0002`, `CM-0008`** | **ANNOTATE** | Both closed with *"verify Pi-hole's and FortiGate's SANs"* as follow-up. **The follow-up was done — on the wire — and it was the wrong artefact.** *(Status-hygiene pass.)* |

---

## The lesson — for `016`

> 🔴 **VERIFYING THE WIRE PROVES NOTHING ABOUT THE FILE YOU REBUILD FROM.**

**Four documents recorded — truthfully — that Pi-hole's certificate SAN was *"verified directly on the live-served connection."*** **All four were right.**

**And the file the rebuild reads from carried a pre-VLAN address the whole time.**

> **`016` lesson 1 says a command completing without an error is not a confirmed change — so read the state back.**
> **`016` lesson 4 says a test that cannot fail proves nothing.**
> 🔴 **This adds: reading the state back off the RUNNING SERVICE tells you nothing about the ARTEFACT THE REBUILD USES.** **They are two different objects. Check both.**

**And the second, sharper one:**

> 🔴 **A control is only as good as its baseline.** **`ADR-0009` made `index.txt` the lab's sole compromise-detection control — and nobody ever ran `cat index.txt` and counted the rows against the certificates in service.** **One command. Four rows. Six certificates.**

---

## Closeout

- [ ] Step 1 — serial `1003` written into `issued/pihole/pihole.crt`; bundle rebuilt; **read back**
- [ ] Stale `.crt` backup **destroyed** after the read-back passes (`CM-0010`'s rule)
- [ ] 🔴 **Step 2 — `index.txt` reconstructed.** **Both orphans have rows.** `openssl ca -status` returns a status for **every live certificate**
- [ ] 🔴 **Step 3 — `ADR-0009` AMENDED.** Its control had a 2-of-6 blind spot when the risk was accepted.
- [ ] 🔴 **Step 4 — the wire-vs-database and wire-vs-file checks added to `015`**
- [ ] `032`, `035`, `042`, `031`, `048` reconciled — **`CM-0025` / `CM-0027`**
- [ ] `029` records `index.txt`'s real contents
- [ ] 🔴 **`016` updated** with both lessons — **BLOCKS CLOSURE**
- [ ] Closed

> 🔴 **Does NOT move to `Closed` while any box is unticked.**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Raised 2026-07-14 by the Book 1 audit (`ADR-0019`), from a device pass on Pi01. 🔴 **`index.txt` holds FOUR rows. This CA has signed SIX certificates that devices trust.** **FGT01's — live right now — and Pi-hole's original were signed with `openssl x509 -req -extfile`, which does NOT write to the database.** 🔴 **`ADR-0009` accepted the Intermediate-CA compromise risk explicitly on the strength of `index.txt` as *"the ONLY way to detect an unauthorised issuance"* — and its own Review Trigger fires TODAY on a legitimate certificate.** 🔴 **Separately: `issued/pihole/pihole.crt` still carries the pre-VLAN SAN `IP:10.0.0.5`, and `032` Step 7 rebuilds `tls.pem` from exactly that file — so a rebuild serves the wrong certificate on the lab's DNS server.** 🟢 **The live services are all correct; `copy_extensions` is in `[ CA_default ]`; `049` Phase 0.2 passes with no `.bak` key files.** **The stale SAN is NOT a security exposure — a certificate without its key is inert, and the operator's decision to defer it is upheld.** |
