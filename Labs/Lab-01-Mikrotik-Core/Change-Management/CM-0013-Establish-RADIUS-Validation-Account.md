# CM-0013 — Establish a Permanent RADIUS Validation Account

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Change-Management

| Item | Value |
|---|---|
| Status | **Closed — implemented and verified 2026-07-13.** Guide reconciliation (`033`, `015`) completed 2026-07-15. |
| Risk | Low |
| Affected systems | Pi01 (FreeRADIUS) |
| Date raised / executed | 2026-07-13 |
| Evidence Status | **`Verified`** — `radtest` returned `Access-Accept` |

> **Raised because `CM-0009` could not be validated.** The change removed two firewall rules that *nominally* carried FGT01→Pi01 RADIUS. The only way to disprove the analysis was to authenticate — **and no RADIUS credential existed to do it with.**

## Reason — RADIUS was untestable, and had been for a day

`043` Part 10 tested RADIUS using **`testing` / `password`**. That account was then **deliberately deleted** — correctly, because the moment RADIUS started working it became a **live admin login on every network device**, and `033`'s checklist still listed creating it as a *passing test*.

**Nothing replaced it.**

**Consequence:** from that deletion until 2026-07-13, the lab had a RADIUS deployment it **could not authenticate against.**

| What could be tested | What could not |
|---|---|
| FGT01 "Test Connectivity" — a packet reaches Pi01 and gets a reply | **Whether authentication actually works** |
| MKT01 `use-radius: yes` | Whether the shared secret is correct |
| FreeRADIUS starts cleanly | Whether the `users` file parses and the auth chain completes |

**Those are different failures.** A wrong shared secret or a broken `users` file passes Test Connectivity and fails every real login. **Every RADIUS change since `043` has been unvalidatable, and nobody noticed** — because "the service is running" looked like "the service works."

## Implementation

`/etc/freeradius/3.0/users`:

```text
radtest-verify   Cleartext-Password := "<generated in Vaultwarden>"
```

```bash
sudo systemctl restart freeradius
radtest radtest-verify '<password>' 127.0.0.1 0 '<localhost secret from clients.conf>'
```

## Validation — 2026-07-13

```text
Received Access-Accept Id 5 from 127.0.0.1:1812 to 127.0.0.1:49574 length 38
        Message-Authenticator = 0x… (redacted — per-packet HMAC, not a reusable credential; removed per ADR-0010 / gitleaks)
```

**`Access-Accept`.** The shared secret is correct, the `users` file parses, and the authentication chain completes end to end. **First proven RADIUS authentication since the `testing` account was deleted.**

## 🔴 Rules for this account — it is NOT `testing`/`password` reborn

| Rule | Why |
|---|---|
| **Name it deliberately** — `radtest-verify`, not `test`/`admin`/`user` | A generic name invites reuse. This account has one job. |
| **Password generated in Vaultwarden. Never a dictionary word.** | `testing`/`password` was guessable, and became an admin login the moment RADIUS worked. |
| **Never grant it device privileges.** Validation only. | The entire failure of `testing`/`password` was that a *test* credential became a *production* one by accident. |
| **It lives in Vaultwarden, and it is documented here.** | An undocumented account is indistinguishable from a backdoor. |

> **The lesson from `033` is not "don't create test accounts."** It is **"a test account that can log into production devices is not a test account."** This one exists precisely so nobody is ever tempted to recreate the old one *"just to check RADIUS is up."*

## Guide Reconciliation — Charter Rule 15

| Guide | Outcome | Detail |
|---|---|---|
| `033-Pi01-FreeRADIUS-Build-Guide.md` | ✅ **Updated (v1.2, 2026-07-15)** | Added the permanent **`radtest-verify`** standing validation account as the mandatory final validation step, with the rules above. Step 3's test account is ephemeral and removed at build time; without this replacement the build had no way to validate RADIUS at all. |
| `015-Network-Validation-Guide.md` | ✅ **Updated (v2.1, 2026-07-15)** | Added a **Pi01 — RADIUS** check: `radtest` against the standing `radtest-verify` account, `Access-Accept` as the only pass. |
| `CM-0009` | **Reviewed** | This record is what allowed `CM-0009` to close with a real end-to-end proof rather than a reachability probe. |

## Closeout

- [x] Account created, password generated in Vaultwarden
- [x] `radtest` returns **`Access-Accept`** — verified
- [x] Account has **no** device privileges
- [x] `033` and `015` reconciled — **done 2026-07-15** (`033` v1.2 gained the standing `radtest-verify` step; `015` v2.1 gained the Pi01 RADIUS check)
- [x] **Closed**

## Note

**This record exists because a security fix created a blind spot.**

Deleting `testing`/`password` was unambiguously correct. **But the deletion had no closeout** — nothing asked *"and how do we test RADIUS now?"* So a control was secured and simultaneously made unverifiable, and it stayed that way until a change record needed to prove itself.

**Same shape as `043` Part 9's `.bak` files:** a correct action with a missing follow-up step. **The fix is not "be more careful." It is a closeout that asks what the change broke.**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Raised and closed 2026-07-13. Created `radtest-verify` after discovering RADIUS had been **unauthenticatable** since `043` deleted `testing`/`password` with no replacement. `Access-Accept` verified. Enabled `CM-0009` to close with a real end-to-end auth rather than a reachability probe. |
| 1.1 | 2026-07-15 — `033`/`015` guide reconciliation (see above). **Redacted the RADIUS `Message-Authenticator` hex** from the Validation output — a per-packet HMAC, not a reusable credential, but a high-entropy value that does not belong in the tree (`ADR-0010`) and that the `gitleaks` pre-commit hook correctly refused. The `Access-Accept` proof is retained. |
