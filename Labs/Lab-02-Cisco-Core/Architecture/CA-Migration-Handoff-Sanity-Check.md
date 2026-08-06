---
Title: Sanity-Check — Lab CA Migration Handoff (Pi01 → dedicated CA VM)
Reviewer: Claude (Cowork), read-only reconciliation against the live repo
Date: 2026-07-20
Source of truth: Atlas-Engineering-Repository (files as staged 2026-07-20)
Scope: A paperwork/planning review only. No key transfer, signing, or push was performed — Hard Rule #1 ("not from a cloud session") is respected. This is a map to check before you execute on your own machines; it is not a substitute for the runbooks.
---

# Sanity-Check — CA Migration Handoff

## Verdict in one line

The **mechanics** of the plan (encrypted-archive move, preserve `index.txt`/serials/`0600`, repoint `openssl.cnf`, test-sign, decommission) are sound and faithful to runbook `049`. The **framing** is not: as written, the plan contradicts the repo's target design in three fundamental ways, and it undercounts the one issue most likely to bite you (`CM-0032`). Reconcile the framing before you build anything.

The handoff's own instruction — *"the design may already exist; reconcile, don't reinvent"* — is exactly right, and reconciling is what turns up the problems below.

---

## A. The big one: which CA are you actually building? (three things have been merged into one)

The handoff treats "migrate Pi01's CA to a new VM on VLAN 10 and keep it as the live trust anchor" as a single, settled task. The repo describes **three different things**, and the handoff has blended them and then pointed them at the wrong device page.

| # | Concept | Repo source | Where it lives | Keys | Trusted by the lab? |
|---|---|---|---|---|---|
| 1 | **Greenfield Lab-02 CA** — the real future trust anchor | `Lab-02-Offline-Root-CA-Build-Design.md`, `CA01-VAULT01-PKI/Build-Checklist.md` | **VLAN 20** (Tier-0 carve `10.20.0.2–.9`) | **New** keys; offline air-gapped Root; online Intermediate on CA01; revocation (CRL DP + AIA) **from cert #1** | Yes — eventually |
| 2 | **Pi01 CA migration + DR drill** — a throwaway practice exercise | `CA-Migration-and-DR-Lab.md` | **VLAN 70 (Testing, isolated)** | The **existing** Pi01 keys, migrated as-is | **No** — "nothing production is at stake" |
| 3 | **The handoff's plan** | this handoff only | **VLAN 10 (Management)** | Existing Pi01 keys, as-is, "no reissue, trust unchanged" | Yes (implied by "cut over") |

The two design docs are explicit and mutually consistent:

- `CA-Migration-and-DR-Lab.md` — status **"a documented lab exercise… nothing production is at stake."** Its rationale: *"You're retiring that CA for the greenfield one anyway, so it's the perfect practice subject: a real CA with real key material and nothing to lose."* Its target is an **isolated VM on VLAN 70**, and its Part 3 is a DR Game Day (`ADR-0011`).
- `Lab-02-Offline-Root-CA-Build-Design.md` — **"A greenfield PKI, built clean. This is *not* a migration of the live Pi01 CA — that stays frozen with Lab-01."** New root, offline from day one, revocation designed in.
- `CA01-VAULT01-PKI/Build-Checklist.md` (the device the handoff calls "the target CA device") — says CA01 is the **online Intermediate on VLAN 20**, built by generating a **new** Intermediate key + CSR and signing it on an **air-gapped Root** (*"the Root key never comes to CA01"*), with **VAULT01 stood up first**. Lifting Pi01's existing root **and** intermediate keys onto this one box is the opposite of what its own checklist says to do.

**So the plan points at CA01's page but describes an action CA01's page forbids.** That is the reconciliation failure, and it is the thing to resolve first.

### What to decide (this gates everything else)

- **(a) Practice migration + DR drill of the retired CA.** Then the repo already has the design: build the target on **VLAN 70** (isolated), and VM 104 — the existing VLAN-70 box — is actually the *right* subject, not the throwaway the handoff dismisses. Nothing in the lab trusts it; "no reissue / trust unchanged" is irrelevant because it isn't a trust anchor. This is the lowest-risk reading and matches `CA-Migration-and-DR-Lab.md` verbatim.
- **(b) A real production cutover** making the migrated Pi01 CA the live trust anchor on a new dedicated VM. This is what the handoff's Phase 5 ("cut over, no reissue, every existing cert stays valid") actually describes — but it conflicts with the greenfield design and with `ADR-0009` (below), it re-entrenches the broken revocation the greenfield design exists to kill, and per the Lab-02 addressing plan it would live on **VLAN 20 (Tier-0)**, not VLAN 10.
- **(c) Build the greenfield CA01** per the target design. Then this is **not a migration at all** — new keys, offline root, VAULT01-first, VLAN 20 — and most of the handoff's phased plan doesn't apply.

My read: the repo clearly intends **(c)** as the destination and **(a)** as the learning exercise along the way. The handoff looks like **(b)** wearing (a)'s clothes and (c)'s address label. Confirm which one you actually want before standing up a host.

---

## B. VLAN and addressing: the handoff is quoting the *frozen* lab

The handoff sets "CA VM home: VLAN 10 (Management)," picks a static in `.10–.49`, and says to avoid `.100 iDRAC` and `.254 FGT01`. Every one of those numbers comes from **Lab-01 (FROZEN)**, not the active Lab-02 build:

- **VLAN placement.** Both Lab-02 CA design docs put the CA in **VLAN 20** (the Tier-0 Identity carve, `10.20.0.2–.9`, per `IP-Addressing-Plan-VLSM.md` and `ADR-0021`), *not* VLAN 10. The migration *practice* doc puts the throwaway on **VLAN 70**. VLAN 10 (Management) matches **neither** Lab-02 design.
- **Subnet size.** Lab-01's `007-IP-Addressing-Strategy` uses `10.<vlan>.0.0/24` with a `.10–.49` server range and hosts at `.100`/`.254`. Lab-02's authoritative `IP-Addressing-Plan-VLSM` re-sizes **VLAN 10 to `/27` (`10.10.0.0/27`, usable `.1–.30`)**. In a `/27`, the handoff's avoid-list addresses **`.100` and `.254` don't exist** — they're outside the block. If you're building in Lab-02, the whole addressing paragraph is from the wrong plan.
- **DAI / `STATIC-HOSTS`.** The instinct is correct — a static-ARP-ACL VLAN silently drops an un-registered host (the "Host Unreachable by Design" trap). But the `STATIC-HOSTS` ACL the handoff names is the **VLAN 10** control. If the CA lands on VLAN 20 or VLAN 70 per the target design, verify *that* VLAN's ARP-inspection posture against the Lab-02 `SW01-Access-Switch/Build-Checklist.md` rather than assuming VLAN 10's ACL applies. (I did not verify VLAN 20/70's DAI config in this pass — flag it, don't assume.)

Net: pin the VLAN decision in **A** first, then take the address from `IP-Addressing-Plan-VLSM.md` (the one authoritative plan, `POL-0008`), not from the frozen Lab-01 standard.

---

## C. "Carry the revocation gap forward, fix is out of scope" fights the target design

The handoff lists the dead revocation (no CDP on issued certs, no CRL served) as a known issue that *"rides along… migrating as-is preserves this gap (its fix is Target-Design work, out of scope for this move)."*

That's internally consistent **only for reading (a)** — a throwaway practice CA that nothing trusts. For readings (b)/(c) it's a direct conflict:

- The greenfield design's entire reason to exist is *"revocation is designed in from certificate #1, not retrofitted,"* explicitly to fix the `ADR-0009` *"revocation that reaches nothing"* defect. Migrating the broken CA into a **trusted** role reintroduces the exact defect the target design was written to eliminate.
- `ADR-0009`'s decision is to **replace the Intermediate at the 2027 renewal** (i.e. go greenfield), *not* to migrate it into a new trusted home. And one of its hard reversal triggers is *"the lab is ever exposed to an untrusted network, or hosts anything of real value."* Promoting the CA to a permanent Management-VLAN trust anchor is the kind of change `ADR-0009` says should re-open the decision.

So "out of scope" is fine if this is a drill. If it's a real cutover, the revocation gap isn't a footnote you carry forward — it's the thing the target design says you must not carry forward.

---

## D. `CM-0032` is undercounted — and there's a stale-file landmine the plan will copy

The handoff says: *"One cert `not in database` on the intermediate (CM-0032). Reconcile during/after the move."* Reading `CM-0032` directly, two things are worse than that sentence implies:

1. **It's two orphans, not one.** `index.txt` has 4 rows (serials 1000–1003) but the CA has signed **six** certs that devices trust. Missing from the database:
   - Pi-hole's **original** cert (random serial `740BE5…`), and
   - **FGT01's `fortigate.lab` cert — live on FGT01 right now**, not in `index.txt` at all.
   
   Both were signed with `openssl x509 -req -extfile`, which signs but **does not write to `index.txt`, consumes no serial, and cannot later be revoked** (`openssl ca -revoke` fails — no row). Since `index.txt` is `ADR-0009`'s *only* compromise-detection control, it's ~40% blind. That's the real content of `CM-0032`, and "one cert" undersells it.

2. **The `issued/pihole/pihole.crt` source file is stale — and migrating "as-is" copies the stale file.** The **wire** serves the correct cert (serial `1003`, `SAN … IP:10.10.0.5`). But the **file** in `issued/pihole/` is the pre-VLAN original: serial `740BE5…`, `SAN … IP:10.0.0.5` (old `10.0.0.x` address). Serial `1003` was never written back to `issued/`; it lives only in `intermediate/newcerts/1003.pem` and inside the live `tls.pem`.

   Why this matters for the migration specifically: your Phase 4 verification is *"`openssl verify … <leaf>` → OK."* The **stale** leaf will verify **OK** against the chain — so that check passes while silently carrying a cert with the wrong IP SAN. Any later rebuild on the new host from the migrated `issued/` tree then serves `IP:10.0.0.5` on a host at `10.10.0.5` — a name/-address mismatch on your DNS box, exactly the `CM-0008`/`MC-0002` incident, pre-loaded into the new environment.

**Fix the source before you back up, not "during/after."** `CM-0032` gives the procedure:
- **Step 1** — copy `newcerts/1003.pem` over `issued/pihole/pihole.crt`, rebuild the bundle, read it back (expect serial `1003`, `IP:10.10.0.5`), then destroy the `.stale` backup. Do **not** touch the live `tls.pem`.
- **Step 2** — reconstruct `index.txt` so both orphans have a row (FGT01 → `V`; old Pi-hole → `E`/`R`, your call), backing up `index.txt` first and running `openssl ca -status <serial>` after each edit. Hand-editing `index.txt` can break issuance, so this is careful work — but doing it **on Pi01 before the archive** means you migrate a *correct, complete* database instead of migrating the blind spot into the new host.

Doing D before Phase 2 also satisfies the handoff's own Hard Rule *"Preserve serials and `index.txt`"* in the way that actually helps — you preserve a *reconciled* database, not a 2-of-6-blind one.

---

## E. Watch for stray `.bak` files riding along in the tree

Runbook `049` (Phase 0.3 / Phase 4.3) documents that the CA tree has repeatedly accumulated `.bak` files that must not travel:

- Two exposed `*-ca.key.bak-2026-07-12` key copies (destroyed — `CM-0010`), and
- an **`openssl.cnf.bak-2026-07-12`** — the **pre-fix config without `copy_extensions`**. `049` explicitly warns someone could restore the wrong file and *"silently reintroduce the SAN defect."*

Your Phase 4 says "fix `openssl.cnf` paths." Add to that: **before archiving, `ls` the tree and confirm exactly one `0600` `.key` per private dir and no stray `.cnf.bak`/`.key.bak`** (`049` Phase 0.3), and after the move confirm the Intermediate `openssl.cnf` you repoint is the **live** one with `copy_extensions = copy` in `[ CA_default ]` (verified correct in `CM-0032`), not a stray. A whole-tree "as-is" copy will otherwise carry these traps into the new host.

---

## F. What the plan gets right (so it's not all red)

- **Move-don't-decrypt.** Phase 2/3's "keys stay AES-256-encrypted, the archive is an outer `gpg` wrapper, never decrypt in transit" matches `049` exactly (`tar` → `gpg --symmetric --cipher-algo AES256`), and the "verify the archive opens" step is the whole point of `049` Phase 4.
- **Preserve `index.txt`/serial/`crlnumber`, never regenerate.** Correct and load-bearing — `CA-Migration-and-DR-Lab.md` Part 1 and `049` both hammer that a key without the database is not a CA, and regenerating `serial` causes collisions.
- **Preserve `0600` + ownership** via `tar -p --numeric-owner`. Exactly `049`'s Phase 3.3 (and its glossary explains why `-p`/`--numeric-owner`/`sudo` are non-optional).
- **Test-sign a throwaway CSR to confirm `copy_extensions` still lands a SAN.** Good — and note it uses `openssl ca` (the DB-writing path), which is the correct method; `CM-0032` shows the whole orphan problem came from using `x509 -req -extfile` instead.
- **Decommission per `ADR-0009` mindset** — don't leave a second live signing copy without a documented reason. Correct; that's the missing-destroy-step lesson.
- **Hard Rules** (no secrets on screen/in repo, gitleaks + second-human read, ASCII passphrase handling) — all consistent with `POL-0002` and `049`'s ASCII-passphrase standard.

---

## G. Phase-by-phase margin notes

1. **Stand up target VM** — *first settle A (which CA / which VLAN).* If (a): VLAN 70, and VM 104 is the natural subject. If (b)/(c): VLAN 20 Tier-0, address from `IP-Addressing-Plan-VLSM`. The DAI step is right in spirit but VLAN-specific (see B).
2. **Back up per `049`** — **do D (reconcile `index.txt` + write serial 1003 back to `issued/`) and E (`ls` for stray `.bak`) BEFORE the archive**, so you back up a correct tree. Also note `049`'s SSH is on **port 2222**; `049` archives more than the CA tree (vault, `clients.conf`, etc.) — you only need `/etc/ssl/lab-ca` for a CA-only move.
3. **Transfer over SSH within the VLAN** — fine; preserve perms on extract (`tar -xzpf`), and if the target is VLAN 70 (isolated), the transfer path/routing differs from VLAN 10.
4. **Verify on new VM** — good steps, but `openssl verify <leaf>` on the **stale** pihole leaf will pass while hiding the wrong SAN (D). Add the **wire-vs-file** SAN diff from `CM-0032` Step 4, and confirm `openssl ca -status` returns a status for **every** live serial (i.e. the orphans now have rows).
5. **Cut over / "no reissue, trust unchanged"** — only meaningful for reading (b). For (a) nothing trusts it; for (c) it's new trust. Don't assert "no device reissue required" until A is decided — under (c) the greenfield design *does* eventually reissue/replace the Intermediate (`ADR-0009`, 2027).
6. **Decommission Pi01 CA** — sound; follow `049`/`CM-0010` "shred, don't `rm`" and the "destroy the rollback only after the replacement verifies" ordering.
7. **Document** — add: **amend `ADR-0009`** (its detection control had the 2-of-6 blind spot when the risk was accepted — `CM-0032` Step 3), and reconcile `035`/`042`/`048` for the `x509 -req -extfile` / write-to-`issued/` lessons, not just the host-rename.

---

## Bottom line

Green-light the mechanics; red-light the framing until you answer **A**. Concretely, before any host is built:

1. Decide **(a) DR drill / (b) real cutover / (c) build greenfield CA01** — this sets VLAN, addressing, and whether "no reissue" even means anything.
2. Take the VLAN/address from `IP-Addressing-Plan-VLSM.md`, not the frozen Lab-01 standard.
3. Do the `CM-0032` reconciliation **on Pi01 before the backup** (write serial 1003 into `issued/pihole/`; give both orphans an `index.txt` row) so you migrate a complete database and a correct pihole leaf.
4. `ls` the tree for stray `.bak`/`.cnf.bak` before archiving; repoint only the live `openssl.cnf`.
5. Keep every key move, signature, and push on your own machines — none of it from a cloud session.
