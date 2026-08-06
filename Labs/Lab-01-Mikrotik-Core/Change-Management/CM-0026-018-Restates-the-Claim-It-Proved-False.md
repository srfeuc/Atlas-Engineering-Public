# CM-0026 — `018` v3.0 Disproves a Claim, Then Restates It as Fact 21 Lines Later

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Change-Management

| Item | Value |
|---|---|
| Status | **Draft** |
| Risk | 🔴 **HIGH — this is the document that defines the control protecting the repository.** *(No live device change.)* |
| Affected systems | **Documentation.** `018-Atlas-Documentation-Standards.md`. |
| Date raised | 2026-07-14 |
| Evidence Status | **`Verified`** — read directly from `018` v3.0 as committed |
| Related | `CM-0014`, `CM-0021`, `CM-0004`, `ADR-0010`, `016` lesson 4, `051-Book-1-Audit-Report.md` (findings G1–G3) |

> 🔴 **`018` is the page `ADR-0010` gates publication on.** If someone reads it and builds the control it names, **they build the control that provably failed.**

---

## 🔴 Finding 1 — `018` calls a sentence FALSE, then prints it as fact

**Line 45–49 — the v3.0 correction block:**

> *"**v2.0 of this page said:** 🔴 *'**Pre-commit secret scan — THIS is the control.** It reads **content**, not filenames, and it **fails the commit**. **Nothing else in this list would have stopped `ac2182f`.**'*"*
>
> *"*'`.gitignore` — denylists **extensions**… **A backstop, not a control.**'*"*
>
> 🔴 **"BOTH SENTENCES ARE FALSE. Tested 2026-07-14 against the exact file and the exact leaked value."**

**Line 69–70 — twenty-one lines below, in the table titled *"The control is mechanical, or it does not exist"*:**

| Line | Text, verbatim |
|---|---|
| **69** | *"`.gitignore` — Denylists **extensions**… **A backstop, not a control.**"* |
| 🔴 **70** | 🔴 *"**Pre-commit secret scan** — **This is the control.** It reads **content**, not filenames, and it **fails the commit.** **Nothing else in this list would have stopped `ac2182f`.**"* |

🔴 **Both sentences the page declares FALSE are reprinted, word for word, as the page's own recommendation.**

**And the test result they contradict is in the same document:**

| Control | Would it have stopped the real leak? |
|---|---|
| **Gitleaks — default (content) ruleset** | 🔴 **NO.** Scanned all 25 bytes. **"no leaks found."** Committed cleanly. |
| **A NAME-based rule (`*passphrase*`)** | ✅ **YES.** Blocked immediately. |

> 🔴 **The content scanner is NOT "the control." It is the control that FAILED.**
> 🔴 **`.gitignore`'s name-based rule is NOT "a backstop." It is the ONLY thing that worked.**
>
> **A bare high-entropy passphrase has no shape** — no `AKIA`, no `-----BEGIN`, no `key = value`. **Nothing for a pattern matcher to match. The filename was the only signal, and it was screaming.**

## 🔴🔴 Finding 2 — this is the THIRD occurrence of the same defect, and it is now a pattern

| Document | The correction added | The error left standing | Result |
|---|---|---|---|
| **`026` §12** (`CM-0021`) | `mac-winbox = RECOVERY` at line 41 | `mac-winbox = none` at line 47 | 🔴 **Last write wins. A rebuild has no recovery path.** |
| 🔴 **`018` v3.0** (this record) | *"BOTH SENTENCES ARE FALSE"* at line 49 | Both sentences, verbatim, at lines 69–70 | 🔴 **A reader implements the control that failed.** |
| **`021`** (audit **B3**) | *"Interfaces — Disabled"* block, `Verified` | Prose: *"left at factory defaults **rather than disabled**"* | 🔴 One document, two opposite answers. |

> 🔴 **THE PATTERN, NAMED:**
>
> **A correction is APPENDED. The thing it corrects is not DELETED. The document then contains both, and the reader gets whichever one they reach first — or, on a device, whichever one runs last.**

**Why it keeps happening:** appending is safe-feeling and additive. **Deleting requires you to be sure.** And the `[chg ]` line-count delta **goes up**, which reads as a plausible edit — the exact shape `tools/README.md` teaches you *not* to worry about.

> **`016` lesson 12: every safety net that worked was one that failed loudly.** **This one is silent by construction:** a document that contains both the truth and the error looks, at a glance, more thorough than one that contains only the truth.

## 🔴 Finding 3 — `018` has two Change Log tables

```
grep -c "^| Version | Changes |" 018-Atlas-Documentation-Standards.md   →   2
```

The `v3.0` row sits in an **orphan table** below a section called *"The rule this page now teaches about itself."* The `## Change Log` heading is 40 lines above it, holding `v1.0` and `v2.0`. **A reader who scrolls to the Change Log never sees v3.0.**

## 🔴 Finding 4 — `CM-0004` required a note in `037`. It was never written.

**`CM-0004`, closeout, verbatim:**

> *"**`037-FGT01-Troubleshooting-Guide.md` should carry a 'FortiOS CLI is not a Linux shell' note.** The next person to type `grep -E` on that box loses the same ten minutes."*

```
grep -ci "grep -E|not a Linux shell|FortiOS grep" 037-FGT01-Troubleshooting-Guide.md   →   0
```

🔴 **`037` contains no such note.** **`CM-0004` is `Closed`.**

*(`037` is otherwise good — Feature Visibility, the leaf-vs-bundle trap, the silently unbound `admin-server-cert`, the VDOM lockout, and it correctly opens with `get` vs `show`.)*

---

## Implementation — documentation only

### Edit 1 — 🔴 `018` line 69–70: REPLACE the table rows. Do not append.

**Delete both rows and replace with:**

| Control | What it actually does |
|---|---|
| **This page** | States the rule. **Stops nothing.** *(It was in force during `ac2182f`.)* |
| 🔴 **A NAME-based rule** — `.gitignore` + a `gitleaks` `path` rule (`*passphrase*`, `*secret*`, `*credential*`, `*.key`, `*.pem`, `.env`) | 🔴 **THIS IS THE CONTROL THAT WOULD HAVE STOPPED `ac2182f`. Proven by test, 2026-07-14.** The filename was the only signal, and it was screaming. **`.gitleaks.toml` now carries it.** |
| 🔴 **Content scanner** — `gitleaks` default ruleset | 🔴 **THIS IS THE CONTROL THAT FAILED.** It scanned all 25 bytes of `Archive passphrase.txt` and reported **"no leaks found."** **A bare high-entropy passphrase has no shape** — no prefix, no delimiter, no `key = value`. **Nothing to match.** **Necessary. Nowhere near sufficient.** |
| `tools/New-Atlas-Commit.ps1` | Puts the scan on the path actually used. 🔴 **`CM-0020`: the hook does not survive a `git clone`. The control exists on ONE machine.** |

> 🔴 **BOTH ARE REQUIRED. NEITHER IS SUFFICIENT.**
>
> **Content catches shaped secrets — AWS keys, PEM blocks, tokens. Names catch shapeless ones — a passphrase, a password, a seed phrase.** **The leak that actually happened was shapeless.**

### Edit 2 — `018`: merge the orphan Change Log

One `## Change Log` table, one heading, `v1.0` → `v2.0` → `v3.0`, at the foot of the document.

### Edit 3 — `018` Working Rules: correct the secrets line

> 🔴 **Never include passwords, API tokens, private keys, or reusable secrets.** **This rule was published, in force, and violated by the very commit that shipped the runbook forbidding it.** **The rule is not the control. See below.**

### Edit 4 — `037`: add the note `CM-0004` asked for

**New section:**

> ## 🔴 FortiOS CLI Is Not a Linux Shell
>
> **`grep` on FortiOS is a cut-down implementation.**
>
> | You typed | What happens |
> |---|---|
> | `grep -E "a\|b"` | 🔴 **No `-E`. No alternation.** Fails or returns nothing — **and returning nothing looks like an answer.** |
> | `grep -A5 "set status"` | 🟡 **Truncates.** `set status` sits *below* `set distance` in the block. |
> | ✅ `grep -f "set status down"` | ✅ **`-f` prints the containing config block and marks the match.** **This is the one that works.** |
>
> **`CM-0004` burned ten minutes on this.** Three commands ran cleanly and printed plausible output before one answered the question:
>
> - `get system interface physical` — **wrong question.** Reports *link and IP* state, not *administrative* status. **A disabled interface and an interface with no address look identical.**
> - `grep -A5` — truncated.
> - `grep -E` — **not supported.**
>
> 🔴 **Each ran cleanly. Each printed plausible output. None answered the question.**
>
> > **`016` lesson 1 has a twin: a command completing without an error, *on the wrong question*, is not evidence either.**
>
> **The command that works:**
> ```
> show full-configuration system interface | grep -f "set status down"
> ```

---

## Validation

```powershell
# The false claim must appear ONCE - as a QUOTE inside the correction block.
# If it appears TWICE, the recommendation table still carries it. Expect ONE hit:
(Select-String -Path .\Labs/Lab-01-Mikrotik-Core\Operations\018-Atlas-Documentation-Standards.md `
               -Pattern "Nothing else in this list would have stopped").Count

# One Change Log table only. Expect 1:
(Select-String -Path .\Labs/Lab-01-Mikrotik-Core\Operations\018-Atlas-Documentation-Standards.md `
               -Pattern "^\| Version \| Changes \|").Count

# The name-based rule must now be named as THE control. Expect at least one hit:
Select-String -Path .\Labs/Lab-01-Mikrotik-Core\Operations\018-Atlas-Documentation-Standards.md `
              -Pattern "CONTROL THAT WOULD HAVE STOPPED"

# 037 must now carry the FortiOS grep note. Expect at least one hit:
Select-String -Path .\Labs/Lab-01-Mikrotik-Core\Operations\037-FGT01-Troubleshooting-Guide.md `
              -Pattern "FortiOS CLI Is Not a Linux Shell"
```

> 🔴 **Note the shape of the first check. It counts occurrences — it does not merely confirm presence.** **That is the check that would have caught `026` §12, and it is the check this record exists to teach.**

## Rollback

`git checkout -- 00-Atlas-Foundation/Atlas-Documentation-Standards.md Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/Troubleshooting.md`

---

## Reconciliation — all document types

| Document | Outcome | Detail |
|---|---|---|
| 🔴 **`018`** | **Updated** | Edits 1–3. |
| 🔴 **`037`** | **Updated** | Edit 4 — `CM-0004`'s unfulfilled row, finally written. |
| **`.gitleaks.toml`** | **Reviewed — no change needed** | 🟢 **It already carries the name-based rule** (`atlas-secret-filename`), with an allowlist for `.md`. **The config is correct. The document describing it is not.** |
| **`.gitignore`** | **Reviewed — no change needed** | 🟢 Already carries the `CM-0014` name-based backstops. |
| 🔴 **`016`** | **MUST UPDATE** | **Add the pattern (Finding 2) as a new lesson.** Three occurrences is not a coincidence. |
| **`CM-0004`** | 🔴 **ANNOTATE** | Its `037` action item is finally done. **Record that it closed with the row unfulfilled.** *(Deferred to the status-hygiene pass.)* |
| **`tools/New-Atlas-Commit.ps1`, `tools/README.md`** | 🔴 **NOT YET REVIEWED** | `CM-0014` marked both 🔴 **Must update** and closed. **Outside Book 1 — hand to the Tools pass.** |

---

## The lesson — for `016`

> 🔴 **A correction that is APPENDED without DELETING the thing it corrects leaves a document that contains both.**
>
> **The reader gets whichever they reach first. A device gets whichever runs last.**

**Three occurrences, all found in one audit:**

1. **`026` §12** — the fix at line 41, the bug at line 47. **The bug wins.**
2. **`018` v3.0** — *"BOTH SENTENCES ARE FALSE"* at line 49, both sentences at lines 69–70. **The bug is the recommendation.**
3. **`021`** — the disabled-interfaces block, and a prose paragraph saying they were *"left at factory defaults rather than disabled."*

**In every case the author knew the truth, wrote the truth, and did not delete the lie.**

> **Verify a correction by counting how many times the OLD text appears, not by confirming the NEW text is present.** A `Select-String` hit on the fix proves the fix landed. **It proves nothing about whether the thing it replaced is still sitting twenty lines below it.**

---

## Closeout

- [ ] Edit 1 — `018` control table **REPLACED** (not appended)
- [ ] Edit 2 — `018` Change Log merged into one table
- [ ] Edit 3 — `018` Working Rules secrets line annotated
- [ ] Edit 4 — `037` FortiOS-grep note written (`CM-0004`'s row)
- [ ] Validated — **the false sentence appears exactly ONCE, inside the correction block, as a quote**
- [ ] 🔴 **`016` updated with the append-don't-delete pattern** — **blocks closure**
- [ ] 🔴 **`tools/New-Atlas-Commit.ps1` / `tools/README.md` reviewed** (`CM-0014`'s open row) — **blocks closure**
- [ ] Closed

> 🔴 **Does NOT move to `Closed` while any box is unticked.**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Raised 2026-07-14 by the Book 1 audit (`ADR-0019`), findings G1–G3. 🔴 **`018` v3.0 quotes two sentences, declares "BOTH SENTENCES ARE FALSE," and then reprints both verbatim as its own recommendation 21 lines later.** A reader building the control `018` names builds **the content scanner that provably failed** — while `018`'s own test table shows the **name-based rule** is what caught it. 🔴 **Third occurrence of the same defect** (`026` §12, `018` v3.0, `021`): **the correction is appended and the error is not deleted.** 🔴 **`CM-0004` required a "FortiOS CLI is not a Linux shell" note in `037` and closed without it.** |
