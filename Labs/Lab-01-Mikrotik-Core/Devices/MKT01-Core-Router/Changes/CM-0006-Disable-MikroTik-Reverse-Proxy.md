# CM-0006 — Disable MikroTik reverse-proxy Service

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: MKT01 - Role: Core Router

| Item | Value |
|---|---|
| Status | **Closed** |
| Risk | Low — service confirmed unrestricted and unused, no dependent config |
| Affected systems | MKT01 |
| Date raised | 2026-07-12 |
| **Date closed** | **2026-07-13 — verified on the live device** |
| Evidence Status | **`Verified`** — `/ip service print` |

> **This record sat at `Status: Draft` while the work was already done.** Same defect as `CM-0004`. **In a rebuild, a Draft record gets skipped.**

## Purpose

Disable the `reverse-proxy` service on MKT01, found enabled with **no source-address restriction** (`address=""`) and **no certificate bound** during live validation.

## Verification — 2026-07-13

**A doubt was raised that `reverse-proxy` might not be a `/ip service` object at all** — that the record was describing `/ip proxy` badly, and its premise was wrong.

**It was not. The record was accurate.** `/ip service print` on RouterOS 7.23.1:

```
Flags: D - DYNAMIC; X - DISABLED, I - INVALID; c - CONNECTION
 #     NAME           PORT  PROTO  ADDRESS       CERTIFICATE            VRF
 0  X  ftp              21  tcp                                         main
 1  X  telnet           23  tcp                                         main
 2  X  www              80  tcp                                         main
 4  X  reverse-proxy   443  tcp                  none                   main
 5     www-ssl         443  tcp    10.0.0.0/24   mikrotik-bundle.crt_0  main
                                   10.10.0.0/24
 6     ssh            2222  tcp    10.0.0.0/24                          main
                                   10.10.0.0/24
 8     winbox         8291  tcp    10.0.0.0/24                          main
                                   10.10.0.0/24
10  X  api            8728  tcp                                         main
11  X  api-ssl        8729  tcp                  none                   main
```

**`X` = disabled.** `reverse-proxy` is a real `/ip service` object, it had exactly the empty `ADDRESS` and `CERTIFICATE: none` the record described, and **it is disabled. Closed.**

*(Note: `/ip proxy print` shows `enabled: no` for the **web proxy** — a different object entirely, with no `address` or `certificate` fields. It does not answer this record.)*

## Bonus — the service table is properly hardened

Confirmed in the same output, unasked:

- **`ftp`, `telnet`, `www`, `api`, `api-ssl` all disabled**
- **`www-ssl`** — certificate `mikrotik-bundle.crt_0` bound, restricted to `10.0.0.0/24` and `10.10.0.0/24` → **`CM-0007` is confirmed executed on the device**
- **`ssh` (2222) and `winbox` (8291)** — both address-restricted to the management and recovery subnets

## Closeout

- [x] `reverse-proxy` disabled — verified on device
- [x] Record premise confirmed correct — it **is** a `/ip service` object
- [x] **Closed**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Raised 2026-07-12. |
| 1.1 | **Draft → Closed 2026-07-13.** Verified via `/ip service print`. A doubt that `reverse-proxy` was not a `/ip service` object was **checked and disproven** — the record was accurate. |
