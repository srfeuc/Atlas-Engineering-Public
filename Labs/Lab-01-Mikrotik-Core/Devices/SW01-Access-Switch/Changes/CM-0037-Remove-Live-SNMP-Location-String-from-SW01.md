# CM-0037 — Remove the Live SNMP Location String from SW01

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: SW01 - Role: Access Switch

| Item | Value |
|---|---|
| Status | **Open — raised 2026-07-16** |
| Risk | Low — `snmp-server location` is descriptive; removing it has no operational effect |
| Affected systems | SW01 |
| Date raised | 2026-07-16 |
| Evidence Status | **`Verified`** — live `show run`, SW01, 2026-07-16 |
| Related | `027` §17, `057` row 8, `ADR-0010` (publication), `CM-0023` (SNMP community rotation — separate), `029` (`L=Redding` precedent) |
| Found by | The SW01 reconcile-to-live pass (`056`) |

## Purpose

Remove `snmp-server location Home-Lab-California` from SW01 — a real-world location disclosure sitting live in the config on a repository `ADR-0010` intends to publish.

## Reason

The reconcile pass found the string **still live** on the device:

```
snmp-server location Home-Lab-California
```

`027` §17 states it *"was removed"* — the **guide** was corrected, the **device** never was. This is the same class of leak as `L=Redding` in the certificate subjects (`029`). It is **distinct from** the SNMP community rotation (`CM-0023`): this record covers the location string only, which needs no rotation — just deletion.

## Prerequisites

None.

## Backup

```text
show run | include snmp-server location
```

## Implementation

```text
configure terminal
no snmp-server location
end
write memory
```

## Validation

```text
show run | include snmp-server location
show snmp
```

Expect: the `include` returns **nothing**, and `show snmp` shows the **Location field blank**.

> 🔴 **"Empty output is not a pass" (Rule 13) — so do not rely on the empty `include` alone.** Confirm the removal by reading the **`show snmp`** Location line and seeing it blank. An empty `include` could equally mean you mistyped the filter.

## Rollback

Re-adding a location disclosure is the defect, not a desirable rollback. If a location is genuinely required, use a **non-identifying** label:

```text
configure terminal
snmp-server location <non-identifying-label>
end
write memory
```

## Documentation updates

- [ ] `027-SW01-Build-Guide.md` §17 — note flips to "removed — device-verified"
- [ ] `057-SW01-Considerations-and-Risks.md` row 8 — closed
- [ ] Revision History

## Guide Reconciliation — required, not conditional

| Guide | Outcome | Detail |
|---|---|---|
| `027-SW01-Build-Guide.md` | To update on close | §17's note currently reads "must be removed — still live"; flip to "removed, device-verified". |
| `023-SW01-Build-Record.md` | Reviewed — no change needed | The SNMP row names the community (redact-after-rotation, `CM-0023`); the location string is not recorded there. |

## Closeout

- [ ] Implemented
- [ ] Validated — `show snmp` Location read back blank, not inferred from an empty `include`
- [ ] `027` / `057` reconciled
- [ ] Considered bundling with `CM-0023` (SNMP hardening) before publication
- [ ] Closed

> 🔴 **Does NOT move to `Closed` while any box is unticked.**
