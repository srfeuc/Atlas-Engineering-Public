---
Title: Atlas Security Awareness Program (handbook + phishing-campaign runbook)
Path: 00-Atlas-Foundation/Security-Program
Status: Draft — the training/awareness program that operationalizes the AUP. Covers Security+ SY0-701 5.6.
Version: 1.0
Date: 2026-07-20
Framework: CIS Controls v8 14 · NIST CSF 2.0 PR.AT · Security+ 5.6
---

# Atlas Security Awareness Program

The human layer — the one an infrastructure lab never touches, and the one `301` is purpose-built for. Atlas Industrial has 156 people, most of whom **don't sit at a desk, don't have email, and share a login** — so a one-size training deck fails on contact. This program tailors awareness to the actual workforce and gives you a runnable phishing exercise.

## 1. Audiences (train to the workforce you actually have)

| Audience (`301`) | Reality | What they need |
|---|---|---|
| **Corporate desk staff** (~95: Finance, HR, Sales-inside, Marketing, CS, Eng, IT) | Email + web, the phishing target | Full program: phishing, data handling, password/MFA, reporting |
| **Field reps** (12 Sales) | Laptops, VPN, roaming, hybrid/remote | Device security (BitLocker, VPN, public Wi-Fi), lost-device reporting, remote-work opsec |
| **Shop floor** (45 Production) | Shared kiosks, **no email**, line-stops-are-incidents | In-person/poster + shift briefings: tailgating/badges, USB, "report to your lead," physical security |
| **Warehouse** (15) | Handheld scanners, ruggedized | Device handling, don't plug unknown hardware, report loss |
| **Executives** (5) | High-value targets; demand exceptions | Whaling/BEC, why the PSO exists, exception-with-a-record |
| **Contractors** (6) | Temporary, expiring accounts | Scoped AUP briefing at onboarding; access ends on the date |
| **IT / privileged** (8) | Tier 0/1/2 | Insider-threat, credential hygiene, no Tier-0-on-workstation (`ADR-0021`) |

## 2. Core topics (Security+ 5.6, mapped to Atlas)

- **Phishing** — recognizing (urgency, mismatched sender/URL, unexpected attachment, payment/credential asks); the Exec BEC/whaling angle; and **how to report** (one channel, one click). Responding to *reported* suspicious messages: triage → contain → warn others.
- **Anomalous behavior** — risky (sharing a password, disabling AV), unexpected (a login at 3am, a kiosk used off-shift), unintentional (emailing a Restricted file to a personal address). Tie to Book-5 monitoring once it exists.
- **Password & MFA hygiene** — length over complexity (the `049` ASCII-length lesson generalizes), no reuse, a password manager, MFA everywhere it's offered. The Executive who wants a carve-out gets the *why*, not an exemption.
- **Removable media & cables** — no unknown USB, no "found" cables/devices, no Restricted data on media without approval (the USB-drop and malicious-cable vectors; echoes `POL-0002`).
- **Social engineering** — pretexting, tailgating (badge doors — Facilities' domain), vishing, the "IT needs your password" call. Verify out-of-band.
- **Insider threat** — the accidental (svc-scanner over-access) and the intentional; how to report a concern; that shared kiosks mean *the log names eight people* (why individual accountability matters).
- **Operational security** — clean desk, screen lock, don't discuss Restricted data in public, shoulder-surfing.
- **Hybrid/remote** — home Wi-Fi, VPN always-on, physical laptop security, no family use of a work device.
- **Data classification in practice** — what Restricted/Confidential/Internal (`305`) means for *"can I email this / put it on a USB / take it home."*

## 3. Delivery & cadence

- **Initial** — at onboarding, before access is granted; AUP acknowledged (attestation recorded, `POL-0001`). Contractors get the scoped version.
- **Recurring** — annual refresh for all; **quarterly** phishing simulation (below); shift-briefing micro-topics for the shop floor (no email → in person).
- **Just-in-time** — after an incident or a failed phishing test, a short targeted nudge (not punishment).
- **Formats** — desk staff: short modules; shop floor/warehouse: posters + 5-minute shift briefings + a laminated "report it" card by each kiosk; execs: a focused BEC briefing.

## 4. Reporting & metrics

- **One reporting path**, frictionless: a "Report Phish" button (or, for the shop floor, "tell your line lead, who tells IT"). Measure **report rate**, not just click rate — a workforce that *reports* is the goal.
- Track: click rate, report rate, time-to-report, repeat-clickers (coach, don't shame), AUP acknowledgement %, training completion %. These are your **compliance-monitoring** evidence too (`POL-0001` / Domain 5.4).

---

## 5. Phishing-campaign runbook (a runnable exercise)

**Goal:** measure and improve recognition + reporting, safely, with no blame.

1. **Authorize & scope.** Written approval (you, as Security). Scope: which audiences, how many, what pretext. 🔴 **Rules of engagement** — no credential capture stored, no real payloads, a clear "this was a test" landing page, an opt-out for anyone in a sensitive moment. (This RoE discipline is the same one you'll write for the SPAN/IDS pentest — Domain 5.3.)
2. **Design the lure** to the audience: Finance → a fake invoice/ACH-change (BEC); HR → a "W-2/benefits" link; Sales field reps → a "VPN password expiring" page; Execs → a CEO-to-CFO wire request; shop floor → *skip email* (use a dropped-USB or tailgating test instead — they have no inbox).
3. **Baseline first.** Run once before heavy training to get a true starting click/report rate.
4. **Send in waves**, off a synced clock (so timestamps correlate — the `CM-0030` lesson applies to *any* logging).
5. **Land safely.** Clickers hit a friendly "you clicked a simulation — here's the tell you missed" page. Capture *that they clicked*, not their credentials.
6. **Measure** click rate, report rate, time-to-report, by audience. The reporters are your win.
7. **Coach, don't punish.** Repeat-clickers get a short targeted module. Publicly celebrate reporters. A punitive program teaches people to hide clicks — the opposite of what you want.
8. **Feed it back** into the next cycle and into detection (a real phish that got reported is a Book-5/IR detection signal).

**Portfolio note:** "designed and ran a phishing simulation program with rules of engagement, no-blame coaching, and report-rate as the primary metric" is a strong Security+/SOC talking point — and it's pure paper, no lab hardware.

## Related

`POL-0010` (Acceptable Use — the rules this teaches) · `POL-0002` (media/secrets) · `305` (data classification) · `301` (the workforce) · `ADR-0021` (tiering / insider) · `POL-0001` (attestation & metrics) · the IR playbook (responding to reported phish).
