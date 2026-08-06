# CM-0020 — The Pre-Commit Secret Scanner Does Not Survive a `git clone`

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Change-Management

| Item | Value |
|---|---|
| Status | **Open** |
| Risk | 🔴 **The control that `CM-0014` closes on exists on exactly ONE machine.** |
| Date raised | 2026-07-14 |
| Evidence Status | **`Verified`** — by structure. `.git/hooks/` is not tracked by Git. |
| Related | `CM-0014`, `018` v3.0 |
| Blocks | Nothing. **Book 1 is frozen.** |

## The problem

**`.git/hooks/pre-commit` is NOT version-controlled and is NOT pushed.**

**`.gitleaks.toml` IS committed** — the *rules* travel. **The hook that invokes them does not.**

| Machine | `.gitleaks.toml` | Hook | Protected? |
|---|---|---|---|
| The workstation where `CM-0014` was closed | ✅ | ✅ | ✅ |
| **Any other machine** | ✅ | 🔴 **NO** | 🔴 **NO** |
| **Any future `git clone`** | ✅ | 🔴 **NO** | 🔴 **NO** |

**Discovered when the operator opened the session from a second computer.**

> 🔴 **A control that silently ceases to exist on `git clone` is not a control.**
>
> **No error. No warning. The commit just goes through.** **`016` lesson 12: a control that fails silently is not a control** — and this one fails silently **by disappearing**.

## 🔴 And it is worse than it looks

**`CM-0014` was closed on the strength of *"the scanner is installed and proven."*** **It is proven on ONE machine.** **The record is true and the protection is local.** Those are not the same thing, and the record must say so.

## Remediation

**Track the hook in the repo and install it with a script.**

1. Commit `Tools/hooks/pre-commit` **into the repository**.
2. Add `Tools/Install-AtlasHooks.ps1` — copies it into `.git/hooks/`, and **verifies `gitleaks` is on PATH.**
3. **Run it after every clone.** Document it in `018` and in the README as **step 1 of setting up a workstation.**
4. **Alternative:** `git config core.hooksPath Tools/hooks` — a **single command**, and the path *is* tracked. **Still requires running once per clone. Nothing makes hooks automatic — that is a deliberate Git security property, not a bug.**
5. 🔴 **PROVE it on the second machine.** Stage `Archive passphrase.txt` with a dummy value. **It must be BLOCKED.** *(`018` v3.0: a control you have not watched refuse something is a hope.)*

## Closeout

- [ ] `Tools/hooks/pre-commit` committed
- [ ] `Tools/Install-AtlasHooks.ps1` written **and run**
- [ ] 🔴 **Blocked-commit test PASSES on a second machine**
- [ ] `018` documents hook installation as a workstation setup step
- [ ] Closed

## Note

**`CM-0014` spent a night establishing that a control must be tested, not assumed.** **Then it closed on a control installed in one directory on one laptop.**

> **The lesson does not stop applying just because you have learned it.**
