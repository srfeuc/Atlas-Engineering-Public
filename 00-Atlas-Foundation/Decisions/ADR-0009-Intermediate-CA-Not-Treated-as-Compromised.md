---
Title: ADR-0009 — Intermediate CA Not Treated as Compromised
Path: Atlas Foundation/Decisions
---

# ADR-0009 — Intermediate CA Not Treated as Compromised

| Item | Value |
|---|---|
| Status | **Proposed** |
| Governing Policy | POL-0009 (+POL-0002) |
| Scope | **Global** — estate-wide principle (applies across labs) |
| Date | 2026-07-13 |
| Supersedes | — |
| Related | `CM-0010`, `043` Part 9, `049`, `031`, `ADR-0003` |

## Context

Between **2026-07-12 ~22:12** and **2026-07-13 ~14:00** — roughly **fifteen hours** — the Intermediate CA private key and the passphrase that opens it were **both present on the admin workstation.**

### How the convergence happened

| Step | What | Source |
|---|---|---|
| 1 | `043` Part 9 backed up both CA keys before re-encrypting them, creating `root-ca.key.bak-2026-07-12` and `intermediate-ca.key.bak-2026-07-12` — **wrapped in the old passphrase.** | `043` Part 9 step 1 |
| 2 | **The procedure had no destroy step.** Both files stayed in the CA's private directories. | `CM-0010` |
| 3 | `pi01-full-backup-2026-07-12.tar.gz` archived `/etc/ssl/lab-ca` **whole** — capturing all four key files — and was moved to `E:\` **on the workstation.** | `029` line 139; `tar -tzf`, confirmed |
| 4 | The old passphrase was in **a plaintext file on that same workstation's desktop** — the exposure that started `043` in the first place. | `043` Part 9 step 6 |

**Key material and the passphrase that opens it, on one machine, for fifteen hours.** Neither `043` nor any subsequent document noticed.

### Separately

The **new** Root CA passphrase was pasted into a chat session log on 2026-07-13. **No key file accompanied it**, and it was rotated the same hour (`CM-0010`). A passphrase without the key it wraps is inert.

### Resolved

All four exposed key copies destroyed. Both passphrases rotated. Plaintext passphrase file destroyed. Tarball destroyed. **See `CM-0010` and `049` v2.0.**

> 🔴 **None of that undoes the fifteen hours.** Rotating a passphrase changes the wrapper on the live key. **It does not un-expose a copy that already existed.** If the pre-rotation `.bak` was read during that window, the Intermediate CA private key is in someone else's hands and no rotation performed since touches that fact.
>
> **That is the question this ADR exists to answer, and it has been deferred twice.**

## What Is and Is Not at Stake

**Device certificates were never exposed.** Their private keys are unencrypted by design (`031` — services must start unattended) but they never left Pi01, were never backed up to the workstation, and appear in no chat log.

**So "rotate the device keys" is not an option.** It is wrong under both branches:

- If the Intermediate is **sound**, device keys were never exposed and rotating them achieves nothing.
- If the Intermediate is **compromised**, new device keys signed by that same Intermediate protect nothing — the attacker mints their own.

**The only question is the Intermediate itself.**

## Threat Model

**Who could have read those files?**

Anyone with access to the admin workstation between 2026-07-12 22:12 and 2026-07-13 14:00.

| Factor | Assessment |
|---|---|
| **Exposure surface** | A single-user Windows workstation on a home network, behind FGT01. Not internet-exposed. Not shared. |
| **Realistic vector** | Malware on the workstation exfiltrating files. Non-zero — it is a general-purpose machine that browses the internet. |
| **Evidence of intrusion** | **None.** |
| 🔴 **Ability to detect intrusion** | **None.** Book 5 does not exist. VLAN 40 is empty. SW01 points SNMP at a server that does not exist. **"No evidence of compromise" here means "we cannot see," not "we looked."** That distinction is the honest core of this decision. |
| **Attacker payoff** | **A lab.** The Intermediate signs certificates trusted by four devices and one browser. It protects nothing of monetary value, guards no production system, and is not publicly trusted. |
| **Window** | ~15 hours, now closed. |

**The realistic risk is low, and the realistic payoff to an attacker is near zero. But the reason we can say "low" is judgment, not observation — because there is nothing to observe with.**

## 🔴 CONFIRMED: This CA Cannot Revoke Anything

**Evidence Status: `Verified` — 2026-07-13. `grep -r crlDistributionPoints` across the entire repository returns ZERO occurrences.**

`031` creates `crl/` directories, maintains `crlnumber` files, and documents `openssl ca -gencrl` in its rollback section. **But no issued certificate carries a CRL Distribution Point extension, and no CRL is served over HTTP.**

**No client is ever told where to look. So no client ever looks.**

### It has already happened

**`MC-0002` revoked the broken MikroTik certificate — serial `1000`, the one with the empty SAN.**

**That revocation reached nothing.** Serial `1000` is marked revoked in `index.txt` and remains **fully trusted by every device and browser holding the Root CA.** Anyone holding that certificate and its key could still present it today.

> **A revocation nobody checks is a filing action, not a security control.**

Verify on any issued certificate:

```bash
openssl x509 -in /etc/ssl/lab-ca/issued/mikrotik/mikrotik.crt -noout -text \
  | grep -A2 "X509v3 CRL Distribution Points"
```

**Expect nothing.**

### What this does to the decision

**It removes the cheap option.** "Treat the Intermediate as compromised" cannot mean *revoke it* — revoking it changes a file on Pi01 and changes nothing anywhere else.

**The only real remedy is physical:** build a new Intermediate, reissue all four certificates, and **remove the old Intermediate object from every device.** There is no partial measure, no gradual rollout, and no way to invalidate the old Intermediate remotely.

**That raises the cost of Alternative 1 substantially — and it is a fact, not a projection.** It is stated here so it is not discovered mid-remediation.

### A separate open item, independent of compromise

**This CA has no working revocation capability at all.** That is a gap in its own right and it will bite the moment any certificate needs to be pulled for any reason — a lost laptop, a decommissioned device, a leaked key.

**Either fix it** (add `crlDistributionPoints` to `[ server_cert ]`, serve the CRL over HTTP from Pi-hole's nginx, reissue), **or state plainly in `031` that revocation is not available and the only remedy is replacement.** What must not continue is a CA that *appears* to support revocation and does not — which is the same defect class as `033` teaching a deleted credential, and Pi-hole serving a factory certificate while three documents claimed otherwise.

## Alternatives Considered

### 1. Treat as compromised — replace the Intermediate now

Generate a new Intermediate key and CSR, sign with the Root, reissue all four device certificates, reinstall on each device, remove the old Intermediate objects.

**Cost:** This is `MC-0001` + `MC-0002` territory. Each of those consumed a full session and surfaced novel failures — a hidden Feature Visibility menu, a silently unbound `admin-server-cert`, an empty SAN after a clean sign, a duplicate serial, WinBox permission errors, RouterOS renaming objects on import. **Four devices, realistically a full session, probably two.**

**Benefit:** Eliminates a risk assessed as low, against an attacker whose payoff is a home lab.

> **One thing that does *not* cost anything:** the Root CA certificate is unchanged, so **no trust store needs re-importing.** That is the entire point of the two-tier design in `031`, and it works. But the reissue-and-reinstall work is unavoidable.

**Rejected — for now.** The cost is real and immediate; the risk is speculative and small.

### 2. Accept the risk permanently — do nothing, never revisit

**Rejected.** It converts a judgment call into an unexamined assumption, which is precisely how the `.bak` files survived fifteen hours. **An accepted risk with no review trigger is not an accepted risk. It is a forgotten one.**

### 3. Accept the risk, with a scheduled replacement and hard triggers — **Chosen**

**All four device certificates expire mid-2027** (FGT01 `2027-06-20`, Pi-hole `2027-07-13`). **They must all be reissued then anyway.**

**Replace the Intermediate at that renewal, as part of work already scheduled.** Same outcome, same devices touched, **one session instead of two** — and performed calmly rather than as an emergency.

## Decision

**The Intermediate CA is NOT treated as compromised.**

**It will be replaced at the 2027 certificate renewal cycle**, when all four device certificates are being reissued regardless.

**This decision is reversed immediately, and the Intermediate replaced as an emergency, if any of the following occur:**

| Trigger | Why |
|---|---|
| 🔴 **Any evidence of workstation compromise** — malware, unexplained access, unexpected outbound traffic | The convergence was on that machine. Evidence there is evidence here. |
| 🔴 **A certificate appears that this CA did not knowingly issue** | Direct proof. Check `index.txt` against what is deployed. |
| 🔴 **The lab is ever exposed to an untrusted network, or hosts anything of real value** | The payoff calculation above is the whole basis of this decision. **If the payoff changes, the decision changes.** |
| 🔴 **Book 5 goes live and shows anything anomalous in the 2026-07-12/13 window** | The one chance to convert "we cannot see" into "we looked." |

## Consequences

- **The lab carries a small, known, documented risk for approximately eleven months.** Known and documented is the point — it is written here rather than living in someone's memory.
- **`index.txt` becomes a control, not just a file.** It is the CA's record of every certificate ever issued. **It is now the only way to detect an unauthorised issuance.** It is in the backup (`049`), and it should be checked against deployed certificates periodically.
- **Book 5 (Monitoring) is promoted in importance by this decision.** The honest reason this risk is acceptable is that the payoff is low — *not* that the lab is clean, because **the lab cannot currently tell whether it is clean.** Book 5 is what would let a future version of this ADR be based on observation instead of inference.
- **A CRL with no distribution point should be either fixed or acknowledged as decorative.** Right now the lab has revocation machinery that nothing consults. See open items.

## Review Trigger

- **Automatically, at the 2027 certificate renewal** — this is when the replacement happens.
- **Immediately, on any trigger in the Decision table.**
- **On any change to what the lab hosts or what it is connected to.**

## Note

**The exposure was not created by a mistake. It was created by a procedure with a missing step.**

`043` Part 9 said *"Backed up both key files first."* It never said *"and then destroyed them."* The files it created were not forgotten through carelessness — **they were never anyone's job to remove, because no line of any document made them so.**

**The remedy is not "be more careful." It is a closeout.** `031` v0.5 now carries the destruction rule and the pre-archive `ls`. `049` carries both. **The Charter does not yet.**

> **Three `.bak` files from a single date, none removed, is a habit — not three accidents.**
