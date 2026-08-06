# CM-0005 — Install Lab CA Certificate on FGT01

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: FGT01 - Role: Perimeter Firewall

| Item | Value |
|---|---|
| Status | **SUPERSEDED by MC-0001** |
| Risk | Low |
| Affected systems | FGT01 |
| Superseded | 2026-07-13 |

> ## This change was never executed as written. Do not close it — it did not happen.
>
> **The work was done under `MC-0001-FGT01-Lab-CA-Certificate-Installation.md`**, which escalated to a *Major Change* because the task turned out to be far more involved than this record anticipated.
>
> Marking this **Closed** would assert it was executed as planned. It was not. **`Superseded` is the accurate status.**

## Why it escalated to MC-0001

This record's Implementation section is three GUI clicks and a `set admin-server-cert`. **The live work was none of those things:**

1. **`System > Certificates` did not appear in the GUI at all.** Looked like a licensing restriction. It was a **hidden-by-default Feature Visibility setting** — nothing in this record anticipated it.
2. Certificate imported and bound — **browser still showed `ERR_CERT_AUTHORITY_INVALID`.** Only the *leaf* was being served, with no chain. Importing the intermediate as a separate "CA Certificate" object **did nothing** — that only affects what FortiGate *trusts*, not what it *presents*.
3. Real fix: build a **bundle** (leaf + intermediate chain concatenated) and import *that* as the Local Certificate.
4. Chain then confirmed correct via `openssl s_client` — and the browser **still** showed the old certificate.
5. **`get system global | grep admin-server-cert`** revealed the binding had **silently never changed.** Still pointing at the factory `Fortinet_GUI_Server`, despite the `set` command in this record's Implementation section returning success.

> **Point 5 is the reason this record is dangerous if closed.** Its Implementation says `set admin-server-cert "FortiGate-Lab-CA"`. **That command ran, returned no error, and did not take effect.**
>
> This is the origin of Charter Rule 13's corollary: **a command that returns no error is not a confirmed change.**
>
> Use **`get`**, not `show`. `show` only prints non-default values — it would have shown you nothing and told you nothing.

## Current live state

Certificate confirmed serving on the wire: `issuer=CN=Home Lab Intermediate CA`.

**Still open and NOT closed by MC-0001:** FGT01's certificate SAN was never independently verified against the CA-wide `copy_extensions` defect. See `031-Pi01-Lab-CA-Build-Guide.md`.

```bash
openssl s_client -connect 10.10.0.254:443 </dev/null 2>/dev/null \
  | openssl x509 -noout -issuer -text | grep -A1 "Subject Alternative Name"
```

**Check `issuer` too** — that is what caught Pi-hole serving a factory certificate while every document claimed otherwise.

## Closeout

- [x] **Superseded by MC-0001** — see that record for what was actually done
- [ ] ~~Implemented~~ — not as written
- [ ] ~~Closed~~ — **do not close. Closing implies execution.**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Raised 2026-07-12. |
| 1.1 | **Status Draft → Superseded.** The certificate is live, but it was installed under MC-0001, not under this plan. Left as `Draft`, this record looked like outstanding work. Closed, it would have falsely asserted its own three-step plan was what happened — hiding the Feature Visibility trap, the leaf-vs-bundle problem, and the silently unbound `admin-server-cert`. All three are the actual lessons. |
