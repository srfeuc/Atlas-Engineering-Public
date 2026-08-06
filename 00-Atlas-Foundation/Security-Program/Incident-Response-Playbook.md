---
Title: Atlas Incident Response Playbook
Path: 00-Atlas-Foundation/Security-Program
Status: Draft — the operational procedure under POL-0009 (Incident Response). You run it; it ends with a written record and a lesson.
Version: 1.0
Date: 2026-07-20
Framework: NIST SP 800-61 phases · CIS Control 17 · Security+ SY0-701 4.8
---

# Atlas Incident Response Playbook

The lifecycle, made concrete for Atlas — a one-operator shop wearing all five silo hats (`ADR-0018`), on a fictional 156-person manufacturer (`301`/`305`). Each phase names *what to do*, *the Atlas-specific trap*, and *the evidence to capture*. Worked examples are real Atlas incidents.

## Roles (for one operator wearing hats)

| IR role | Atlas silo hat | Does |
|---|---|---|
| Incident Commander | whoever declares | Owns the timeline, decides containment, calls closure |
| Investigator | Security / the affected silo | Gathers evidence, root-cause |
| Scribe | Security | The write-up *as it happens* — timestamps from a synced clock |
| Comms | (n/a solo; the 301 org would notify Exec/Legal/insurer) | Records who was told and when |

> Even solo, **write the timeline as you go**. Memory is Rank 6 (Charter Rule 13). The scribe hat is not optional.

---

## Phase 1 — Preparation (before anything happens)

- Know your **crown jewels** (`305` data classification: CA keys/`NTDS.dit` = Restricted; AtlasERP/`AtlasHR`/CAD = Confidential) and where they live.
- Know your **detection surface** — and its holes. 🔴 Atlas's honest state (`ADR-0009`): *"no evidence of compromise" means "we cannot see," not "we looked."* Book 5 (Wazuh/LibreNMS) isn't built; `index.txt` is the CA's only detection control and was 2-of-6 blind (`CM-0032`); SW01's clock never synced (`CM-0030`) so its logs can't be correlated. **Fix detection gaps in peacetime — they're what you'll wish you had mid-incident.**
- Have the **recovery path proven**: off-site restore-tested backups (`POL-0005`), and the MKT01 console cable (`ADR-0016`) so response can't lock you out of the box that gates the interior.
- Keep this playbook + contacts reachable **offline** (the `048` lesson: your credentials live on the host you may be responding to).

## Phase 2 — Detection & Declaration

- **Sources:** a control firing (once Wazuh exists), a reconciliation finding (`CM-0032`-style: `index.txt` vs. deployed certs; the `301` SQL "gap report" — AD accounts with no HR row), an `EAST-WEST-DENIED`/`INPUT-DENIED` log spike, a device behaving oddly (the **reboot-loop**: PVE01 rebooting ~every 30 min), or a user report ("I clicked a link").
- **Declare it.** Start the timeline, assign a tracking ID (reuse the CM/incident numbering), note the trigger and the first observation *with evidence*.
- 🔴 **Prove the positive before trusting a negative** (`015`): a quiet log or a failed exploit may mean the control isn't working, not that you're clean (the `CM-0012` cipher-0 trap).

## Phase 3 — Analysis (scope & root cause)

- **Scope it** using `305`'s classification and the tier model: what data class, which zone, is Tier 0 (identity/CA) involved? Blast radius, not just the first host.
- **Read state off the device**, don't guess (Rule 13). The reboot-loop root cause — a **scheduled task on the admin workstation (`10.10.0.50`) SSHing into PVE01 running `reboot`** — was found by reading the task, not theorizing.
- **Distinguish exposure from compromise** (`ADR-0009`): a passphrase in a chat log with no key is inert; a key + its passphrase on one box for 15 hours is real. Rotation changes the wrapper; it does **not** un-expose a copy that already existed.
- Capture evidence **before** you change anything: snapshot the VM, export the config, `tar` the tree, copy the logs off-box. You can't analyze what you wiped.

## Phase 4 — Containment (stop the bleeding, keep the evidence)

- **Short-term:** isolate without destroying. Options Atlas actually has — disable an SW01 access port; move a host to VLAN 70 (Testing, isolated); an MKT01 `EAST-WEST-DENIED` block; disable an AD account; pull the bridgeLocal/mgmt path. Prefer **isolation over power-off** (power-off loses volatile evidence and, on the shop floor, *stops the line* — in OT, availability outranks confidentiality, `305` Part 2).
- 🔴 **Containment crosses silos** — disabling a firewall path or an identity is a Security/Network/Identity action; record it (`ADR-0018`).
- **Don't lock yourself out.** A containment rule on MKT01 with no tested console is the `ADR-0023` lockout risk — console first.

## Phase 5 — Eradication (remove the cause)

- Remove the mechanism, not just the symptom: delete the malicious scheduled task; **destroy every exposed copy** of a secret (the `ADR-0009` missing-destroy-step lesson — `shred`, not `rm`, `POL-0002`); revoke and reissue a compromised cert (and note Atlas's revocation reaches nothing until the CDP fix — `CM-0032`, so eradication may mean *replace the Intermediate*, not "revoke").
- Rotate affected credentials — **and** assess whether rotation is sufficient or the key/account must be rebuilt (`ADR-0009` branch logic).

## Phase 6 — Recovery (return to known-good, verified)

- Restore from a **restore-tested** backup (`POL-0005`) — capture the RTO. Rebuild vs. restore is a decision (`048`): restore is fast and keeps trust; rebuild is the post-compromise clean-room.
- **Verify before declaring recovered** — read the state back off the wire *and* the file (`CM-0032`: the wire can be right while the source file is stale). Confirm the crown jewel is actually serving correctly.
- Watch for recurrence for a defined window before closing.

## Phase 7 — Post-incident (the deliverable)

- **Root cause in one honest sentence**, plus timeline with evidence.
- 🔴 **A lesson that reaches the doc that DOES the work** (`016` R2, change-process step 11): `ADR-0009`'s remedy was a destroy step added to `049` and `POL-0002` — *not* "be more careful." Name the file(s) changed.
- **Prevention + detection follow-ups:** what control would have caught this sooner? (Most Atlas incidents point back to the same gap: *we couldn't see.* File the Book-5/monitoring backlog item.)
- **Reversal/escalation triggers** for any accepted residual risk (`ADR-0009` table).
- In the `301` org: note who Comms would have notified — Exec, Legal, the **cyber-insurer** (the attestation questionnaire in `305` obliges timely notification; late notice can void a claim).

---

## Worked examples (real Atlas incidents through the lifecycle)

| Incident | Detect | Analyze | Contain/Eradicate | Lesson (doc changed) |
|---|---|---|---|---|
| **CA key convergence** (`ADR-0009`) | Reconciliation found key+passphrase on one workstation 15h | Exposure vs. compromise; blast radius = the Intermediate | Destroy exposed `.bak` copies; rotate; scheduled Intermediate replacement w/ triggers | Destroy step → `049`, `POL-0002` |
| **Committed passphrase** (`CM-0014`) | gitleaks / audit | Archive passphrase in a commit | Rotate, re-encrypt, destroy old, blast-radius note | gitleaks CI portable; `POL-0002` |
| **Blind detection control** (`CM-0032`) | `index.txt` vs. deployed certs | 2 of 6 certs unrecorded; control 40% blind | Reconstruct `index.txt`; amend `ADR-0009` | wire-vs-file + wire-vs-DB checks → `015` |
| **Reboot-loop** | PVE01 rebooting ~30-min cadence | Scheduled task on `10.10.0.50` SSH→PVE01 `reboot` | Disable the task; verify | (open) — a monitoring/detection gap |
| **Counterfeit console cables** | Three adapters failed | Counterfeit Prolific PL2303 (supply chain) | Genuine FTDI (`Console-Recovery-Cable` note) | Supply-chain lesson; vendor due diligence |

## Tabletop drills (Game Days — `ADR-0011`)

Run one unannounced-ish scenario per quarter, restore/contain on VLAN 70, capture the RTO: *phished shop-floor kiosk* (shared `PROD-LINE3` — who did it? the non-repudiation finding), *a Reeves temp Domain Admin credential abused*, *the `svc-scanner` account (2018 password) used for lateral movement*, *ransomware on FS01* (test `POL-0005` restore). Each drill is a portfolio write-up and a detection-gap finder.

## Related

`POL-0009` (Incident Response policy) · `POL-0002` / `POL-0005` / `POL-0001` · `ADR-0009` / `CM-0014` / `CM-0032` · `305` (classification, OT availability) · `301` (the users/accounts in the scenarios) · `ADR-0011` (Game Days).
