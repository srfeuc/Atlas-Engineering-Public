---
Title: CA / PKI Recovery Objectives — RPO & RTO (proposed)
Path (suggested): 07-Backup-and-Recovery/  — candidate seed for the referenced-but-missing POL-0005
Status: PROPOSED — targets are a risk-appetite decision; ratify or adjust the numbers, then this becomes the standard the DR drill measures against.
Author: drafted with Claude (Cowork), reconciled against 049 / CA-Migration-and-DR-Lab / ADR-0009 / CM-0032
Date: 2026-07-20
Scope: The lab CA/PKI (Root + Intermediate key material, the issuance database, and the passphrases that open the keys). The coupled Vaultwarden/paper passphrase path is in scope because the CA cannot be recovered without it (049's circular dependency). Pi-hole / FreeRADIUS / other Pi01 services are OUT of scope here — noted as a follow-on tier.
---

# CA / PKI Recovery Objectives — RPO & RTO

## 0. Why a CA needs its own RPO/RTO definition

A CA is not a continuously-changing service. Its recoverable state lives in a handful of files that change **only on discrete events**:

| Artifact | Changes when | Frequency |
|---|---|---|
| Root key, Root cert | key generated / rotated | ~never (Root 10y) |
| Intermediate key, cert, `ca-chain.crt` | key generated / rotated | rare (Intermediate 5y) |
| `index.txt`, `serial`, `crlnumber`, `newcerts/` | **every issue / revoke** | per issuance |
| `openssl.cnf` | config change (e.g. the `copy_extensions` fix) | rare |
| Key passphrases (vault + paper) | rotation | rare, event-driven |

Two consequences follow, and they drive every number below:

1. **RPO must be event-based, not clock-based.** Between issuances the CA is static, so "how many hours of data could I lose" is the wrong question. The right one is *"was every issuance captured in a backup before the host died?"* A cert issued after the last backup returns from restore as an **orphan with no `index.txt` row** — unrevocable and invisible to compromise detection. That is precisely the `CM-0032` state (FGT01's live cert absent from `index.txt`), reached by accident. An RPO breach reaches it on purpose.

2. **RTO tolerance is high, but gated by dependencies.** While the CA is down, **every already-issued certificate keeps validating** — the Root cert in device trust stores is unchanged, so TLS everywhere in the lab keeps working. Only *new issuance and revocation* are blocked. (And revocation is currently non-functional anyway — no CDP/CRL served, per `ADR-0009`/`CM-0032` — so the revocation half of RTO is moot until that's fixed.) So the CA can be down for hours with near-zero blast radius. What actually determines whether you hit your RTO is not rebuild speed — it's whether the **backup is reachable** and the **passphrase survived**.

---

## 1. RPO — Recovery Point Objective (proposed)

**Headline target: zero lost issuances.** Every event that mutates the CA database or keys triggers an immediate backup, so the newest archive always reflects the newest issuance. A time backstop covers the static periods.

| Tier | Artifact | RPO target | How it's met |
|---|---|---|---|
| **1 — Issuance DB** | `index.txt`, `serial`, `crlnumber`, `newcerts/` | 🔴 **0 un-backed-up mutating events** | Re-run the `049` backup **immediately after any issue / revoke** — before the session ends. This is the binding target. |
| **2 — Key material** | Root & Intermediate keys, certs, chain, `openssl.cnf` | Since last key/config change (effectively any recent archive) | Re-backup on every key rotation or `openssl.cnf` change (`049` already mandates this). Between changes, any archive is current for this tier. |
| **3 — Passphrases** | Root / Intermediate / archive passphrases | 0 un-captured rotations | Vault entry **and** paper updated at rotation. Paper gives passphrase-recovery an RPO independent of any electronic backup. |
| **Backstop (all tiers)** | whole tree | **≤ 6 months staleness** during no-issuance periods | `049`'s "at minimum every 6 months" — also covers unpowered flash-media bit-rot. |

**Restated as one sentence for POL-0005:** *The CA backup is taken immediately after every issuance, revocation, key rotation, or config change, and at least every six months regardless — so the recovery point is never behind the CA's live issuance history.*

**Why tier 1 is the strict one:** the failure it prevents is not "lost work," it's a **security-control breach**. `ADR-0009` accepted the possibly-compromised-Intermediate risk *specifically* on the promise that `index.txt` is "the only way to detect an unauthorised issuance." An issuance that never reached a backup is invisible to that control after a restore — you'd have manufactured a fresh `CM-0032` blind spot as your recovery baseline.

---

## 2. RTO — Recovery Time Objective (proposed, by scenario)

RTO is measured **from "host declared dead" to "CA issuing again"** (chain verifies on a freshly-signed cert). A fuller DR pass also restores revoke + CRL; capture both.

| # | Scenario | Precondition | Proposed RTO | Reality today |
|---|---|---|---|---|
| **S1** | CA host lost; on-site backup + paper intact | The clean restore — this is the drill | **≤ 2 hours** to operable | Achievable. Measure the actual number in the drill. |
| **S2** | Site loss (host **and** on-site copy gone — fire/theft/flood); only the off-site copy survives | Off-site **media** copy exists | **≤ 1 business day** (retrieval + restore) | 🔴 **UNMET — currently ∞.** The off-site copy of the *media* does not exist (`049` Phase 5 open; Roadmap Critical Risk #1: "both copies in the same room"). Until Phase 5 is done, S2 is unrecoverable. |
| **S3** | Passphrase lost (vault gone with the host) | Paper passphrase survived off-site | Collapses into S1/S2 timing | ✅ Paper exists — two copies, one off-site (`049` Phase 6, operator-confirmed). If paper **and** vault were both lost → **∞ (unrecoverable)**; that's why the paper-off-site copy is load-bearing. |

**The honest headline:** S1's RTO is a stopwatch exercise you can pass this week. S2's RTO is **infinite until `049` Phase 5 is closed**, because there is no second location to recover *from*. No amount of restore-speed practice changes that — it's a missing artifact, not a slow procedure. If you set one recovery objective and act on it, make it *"close Phase 5,"* because it converts S2 from impossible to a one-day restore.

**Downtime-tolerance note (justifies the generous targets):** because existing certs keep validating while the CA is down, a multi-hour CA outage in this lab has near-zero operational impact. The 2-hour S1 target is set by *"how long does a careful, verified restore take"* (interview-credible), not by urgency. Don't let a tight-sounding RTO push you into skipping the read-back verifications — an unverified fast restore is the `049`/`016` "a command that exited 0 is not a confirmed change" trap.

---

## 3. What actually threatens these objectives (the dependency chain)

RTO/RPO for a CA are almost never blown by the OpenSSL steps. From `049`'s recorded experience, the real risks are:

- 🔴 **The circular dependency** — key → passphrase → Vaultwarden → runs on the host that died. Broken only by **paper** (dependency-free). Keeps S3 finite.
- 🔴 **Off-site media gap (Phase 5)** — the single event the whole exercise exists to survive (losing the room) is still unsurvivable. Directly sets S2 = ∞.
- **Passphrase typeability** — the `049` ASCII-only standard (a `£`/`&`/`!` breaks the paste/shell at the one moment you need it, on unfamiliar recovery hardware). A perfect backup + an untypeable passphrase = missed RTO.
- **Backup completeness** — a key without `index.txt`/`serial` restores a directory, not a CA (`CA-Migration-and-DR-Lab` Part 1). RPO is meaningless if the captured point is incomplete.
- **A target host to restore onto** — S1/S2 assume you have hardware/VM ready. For the drill that's the VLAN-70 box (VM 104); for a real event, note where the replacement comes from.

---

## 4. Drill measurement worksheet (capture ACHIEVED values)

Run this during the VLAN-70 DR pass. Record wall-clock timestamps; RTO is arithmetic on them.

**RTO stopwatch — record each:**

| Mark | Event | Time |
|---|---|---|
| T0 | Host declared dead (start clock) | |
| T1 | Encrypted archive in hand on the target (off-site retrieval simulated) | |
| T2 | Decrypted (paper passphrase) + extracted, checksum verified | |
| T3 | Layout recreated, `openssl.cnf` repointed, perms fixed (`0600`) | |
| T4 | **Test cert issued; `openssl verify` against chain → OK** | |
| T5 | Test cert revoked; CRL regenerated + published | |

- **RTO (issuing again) = T4 − T0** ← the headline number, and the interview answer.
- **RTO (full DR: issue+revoke+CRL) = T5 − T0.**
- Note where the clock stalled (retrieval? passphrase paste? perms?) — that's your next improvement target.

**RPO achieved — record:**

- Newest row date in the restored `index.txt` (`sudo tail index.txt`) vs. the simulated failure moment. The gap = your data-loss window for this recovery point.
- For the drill (restoring the existing `E:\` archive): RPO achieved = **age of that archive** = time since the last CA change it captured. Since `049`'s archive predates nothing new (Lab-01 frozen), expect ~0 lost issuances — but confirm by counting rows against deployed certs.

**Fidelity checks (prove it's the *same* CA, per the migration lab):**

- Restored CA cert fingerprint **==** original (`openssl x509 -noout -fingerprint -sha256`).
- `index.txt` reconciles with deployed certs — expect this to **surface `CM-0032`** (the 2 orphans + stale pihole leaf `IP:10.0.0.5`); reconcile on the copy as the teaching step (do **not** edit frozen Pi01).
- Capture a screenshot of the restored CA issuing a cert (portfolio evidence, per the lab's Portfolio note).

---

## 5. Open items this exposes

1. 🔴 **Close `049` Phase 5** (off-site media copy). Converts S2 RTO from ∞ to ≤ 1 day. Highest-leverage single action.
2. **Write `POL-0005`** — it's referenced by `CA-Migration-and-DR-Lab`, `Lab-02-Offline-Root-CA-Build-Design`, `CA01-VAULT01-Build-Checklist` (×2) and more, but appears not to exist. These RPO/RTO targets are its natural core. *(Confirm it isn't hiding in `07-Backup-and-Recovery/` — the bridge dropped before I could list that folder.)*
3. **Ratify the numbers.** 2h / 1-day / event-driven-RPO are proposals sized to a home lab. Adjust to your risk appetite, then they're the standard the drill scores against.
4. **Decide the Vaultwarden master-password recovery path** (`049`'s still-open ADR question) — it gates whether the *rest* of the vault (beyond the CA passphrases now on paper) is recoverable at all.

---

## Appendix — the same objectives, applied later to greenfield CA01

When you build the real CA01 (the offline-Root design), these transfer with two upgrades: the **Root** key is air-gapped so its RTO/RPO is a *physical* retrieval of a LUKS USB (and the "both copies in one room" risk is closed by design), and **revocation works from cert #1**, so the revoke-half of RTO stops being moot — a real CRL regeneration/publish time becomes a number worth targeting.
