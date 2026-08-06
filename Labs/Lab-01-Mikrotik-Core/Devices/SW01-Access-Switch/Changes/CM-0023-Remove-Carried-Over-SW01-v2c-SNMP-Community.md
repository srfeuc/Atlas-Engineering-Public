# CM-0023 — Remove the Carried-Over v2c `homelab` SNMP Community from SW01

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: SW01 - Role: Access Switch. **Finding raised in Lab-01; remediated during the Lab-02 SW01 rebuild** (`Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md` Step 8). This record was **referenced across the estate but never written** — backfilled 2026-08-02 to close the dangling reference.

| Item | Value |
|---|---|
| Status | 🟡 **Implemented — reconciliation open.** Removed during the Lab-02 SW01 rebuild; device-reported absent 2026-07-21. **Operator to confirm with a live `show snmp community` read-back, then Close.** |
| Risk | 🟡 **Medium** — a live cleartext v2c RO community is a real credential (`ADR-0010` publication gate: "no live credential anywhere in the working tree"). Mitigated: RO only, and the trap host `10.40.0.52` does not exist. |
| Affected systems | **SW01** (Cisco Catalyst 2960X) — SNMP. |
| Silo(s) / boundary crossed | **Network → Security** (a network device's credential is a security-owned control; `ADR-0018`). |
| Date raised | 2026-07-14 (Book-1 audit, `ADR-0019`) |
| Evidence Status | 🟡 **Operator/device-reported** — the Lab-02 SW01 Build-Guide (Step 8) and Troubleshooting both record *"Confirmed absent in the 2026-07-21 live config."* Not independently re-read in this docs-only session; a final `show snmp community` read-back closes it (`POL-0001`). |
| Related | `ADR-0010` (publication preconditions — the "no live credential" gate) · `POL-0002` (secrets) · `ADR-0020` (time — SNMP telemetry rides the same MON01 path) · `ADR-0032` (SPAN/monitoring → MON01) · `CM-0022` (SW01 build-guide regression) · `016-Network-Lessons-Learned.md` · `051-Book-1-Audit-Report.md` · Lab-02 `Devices/SW01-Access-Switch/Build-Guide.md` §Step 8 + `Troubleshooting.md` |
| Found by | The Book-1 audit, running `show run | include snmp-server` on SW01 |

---

## 🔴 The finding

The Book-1 audit found a **live, cleartext SNMPv2c read-only community** on SW01, carried over from the original Lab-01 configuration:

```
SW01# show run | include snmp-server
snmp-server community homelab RO
snmp-server host 10.40.0.52 version 2c homelab
```

🔴 **`homelab` is a live credential.** SNMPv2c community strings travel in cleartext, and this one was named directly in the Charter with an order to rotate it. Two problems compound it:

- The community grants **read access to the device's SNMP MIB** to anyone who can reach UDP 161 and knows the string — and the string is `homelab`, guessable and now also written in the repository.
- The configured **trap host `10.40.0.52` does not exist** (no MON01 yet), so the community bought nothing operationally while remaining a live exposure.

## Purpose

Remove the carried-over v2c `homelab` community (and its dead trap-host line) from SW01, and record that removal formally so the estate's many `CM-0023` references resolve to a real change record. Re-introduce SNMP only as **SNMPv3 (auth + priv)** pointed at MON01 when MON01 exists (Phase 6, `ADR-0032`).

## Reason

`ADR-0010` gates publication of this repository on precondition #4: **"No live credential, key, token, or passphrase exists anywhere in the working tree."** A live v2c community is exactly that. It also violates `POL-0002` (no cleartext secret in a device config we treat as source) and the Charter's explicit instruction to rotate this string. v2c cannot be made safe (cleartext by design), so the fix is removal + a move to v3, not a new v2c string.

## Prerequisites

- Console or SSH access to SW01 on the `Vlan10` management SVI (`10.10.0.2`).
- Confirmation that no current collector depends on the `homelab` community (none does — the trap host does not exist).

## Backup

- `show run` captured to the SW01 build record before the change (the pre-change SNMP lines are preserved in this record above).

## Implementation

Executed as part of the Lab-02 SW01 rebuild (Build-Guide Step 8):

```
configure terminal
 no snmp-server community homelab RO
 no snmp-server host 10.40.0.52 version 2c homelab
end
write memory
```

> **Do not replace it with another v2c community.** SNMP returns only as **SNMPv3 (auth + priv)** to MON01 in Phase 6 (`ADR-0032`). The old `homelab` string is treated as **burned** and must never be re-added.

## Validation

**Read the resulting state back.** A command that returned no error is not a confirmed change.

```
SW01# show snmp community
<expected: no output / no 'homelab' community>

SW01# show run | include snmp-server
<expected: no 'community homelab', no 'host 10.40.0.52 ... 2c'>
```

🟡 Device-reported absent 2026-07-21 (Lab-02 SW01 Build-Guide Step 8, Troubleshooting §"`homelab` v2c SNMP community present"). **Operator: paste the two read-backs above to move this record to Closed.**

## Rollback

None desired — this is a removal of an unwanted credential. If SNMP monitoring is needed before Phase 6, configure **SNMPv3**, never the v2c community.

## Documentation updates

- [x] Lab-02 SW01 Build-Guide references this record (Step 8).
- [x] Lab-02 SW01 Troubleshooting references this record (incident section).
- [x] Lab-01 Change-Management ledger index row added.
- [ ] Build Record updated with the confirming read-back (on operator close).
- [ ] Revision History updated.

## Guide Reconciliation — required, not conditional

> **Does any guide now contain an instruction that would recreate this problem, or a claim that this change disproves?**

| Guide | Outcome | Detail |
|---|---|---|
| Lab-02 `SW01/Build-Guide.md` | Reviewed — correct | Step 8 already *removes* the community and warns "never re-add the old v2c `homelab` community." No change needed. |
| Lab-02 `SW01/Troubleshooting.md` | Reviewed — correct | Documents the removal and the "SNMPv3 only" resolution. No change needed. |
| Lab-01 `027-`/`SW01/Build-Guide.md` | Frozen (`ADR-0022`) — historical | Records the string as it was found live at freeze; preserved as history (`ADR-0012`). The string is now dead. |

## Closeout

- [x] Implemented (removed during the Lab-02 rebuild)
- [ ] Validated — resulting state read back, not inferred (operator to paste `show snmp community`)
- [ ] Build Record updated
- [x] Guide reconciliation answered in writing above
- [ ] Closed

> 🔴 **Does not move to `Closed` until the `show snmp community` read-back is pasted above.** Until then the correct status is **Implemented — reconciliation open** (`POL-0001`).

---

*Backfilled 2026-08-02 to close the dangling `CM-0023` reference found during the pre-publication secret sweep. The `homelab` string still appears in frozen Lab-01 records and in the Charter/`POL-0001`/Documentation-Style docs that name it as the string ordered rotated — those are historical/teaching references to a now-dead string and are preserved per `ADR-0012`; they are not live credentials.*
