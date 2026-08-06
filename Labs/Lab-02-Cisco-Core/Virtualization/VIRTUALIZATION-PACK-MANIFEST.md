# Pack Manifest — Enterprise Virtualization

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

## Status

**Draft assembled. Not frozen.** ~17 Build Guides (renumbered to the **`2xx`** series — Freeze #1 below, resolved), **5 Build Records**, 1 Reference. Freeze #1, #2 **and** #3 now resolved (`ADR-0034` + `#21`). **The `2xx` R410-era guides were reconciled to the device-verified Build-Records in the #22 audit (2026-07-30)** — stale pre-07-24 networking corrected, guides wired to their authoritative records, 🟡 read-backs called out (see Change Log v1.5). Remaining before freeze: the on-device 🟡 read-backs (RAID/virtual-disk; ACL/root/TFA) + formal Evidence-Status blocks (Freeze #4) + the Confluence manual redirect.

> 🚪 **Front doors (`#21`).** The hypervisors now have device page-sets — `../../Devices/PVE01-Hypervisor/` (built; points here) + `../../Devices/PVE02-Hypervisor/` (target-state; the `221` runbook is its home procedure). **The `Devices/` folders are the front door; this pack's Build-Records + Build-Guides stay the deep build-record/procedure home they link into** (`POL-0008`, `ADR-0034`).

Book 2 is **stronger than the Roadmap gave it credit for** — it was listed as 0% while containing 18 documents. It was also the **only source in the entire project that recorded PVE01's RAM correctly** (62 GiB usable, 64 GB physical, upgraded 2026-07-11, DIMM slot B1 faulty), while a `.docx` claiming *"confirmed directly from the running system via SSH"* and a Confluence Build Record both said 32 GB.

Its `Reference/217-Verified-Facts-and-Reconciliation-Notes.md` independently caught the 32-vs-16 logical-CPU error, the `10.10.0.254` address collision with FGT01, and the Proxmox version drift — **unprompted.**

## Pages

- [x] **Build Guides** — **`201`–`214`** (R410 prep → Proxmox install → post-install → networking → storage → auth → Windows Server 2025 VM → install → VirtIO → base config → Sysprep → template → clone → DC01 deploy) + **`220`** (Ubuntu golden image + its `.sh`) + the **GNS3-Lab-Simulation** guide. *(Renumbered from the old `001`–`014` to the `2xx` series — see Blocking Freeze #1, now resolved.)* **+ `221`** — PVE02/EQR6 bring-up & VM-migration runbook (📋 target-state; the `#21` companion).
- [x] **Build Records (5)** — PVE01 Current State (`215`); Windows Golden Image Historical Record (`216`); **PVE01-Networking** (authoritative PVE01-networking home, `ADR-0034`); **PVE01-Storage** (new `#21`); **PVE01-Authentication** (new `#21`). *(Plus `PVE01-Diagnostics` — the `ADR-0032` show-battery.)*
- [x] **Reference (1)** — Verified Facts and Reconciliation Notes.
- [x] **VIRTUALIZATION-PACK-MANIFEST** — this page.
- [x] **Device front-doors (`#21`)** — `../../Devices/PVE01-Hypervisor/` (built, points here) + `../../Devices/PVE02-Hypervisor/` (target-state; `221` is its home procedure). The `Devices/` folders are the front door; this pack stays the deep home (`POL-0008`).
- [ ] Confluence publication and review.

## Quality Assessment (2026-07-13)

Scanned against every defect class found in Book 1. **Book 2 is clean:**

| Defect class | Book 1 | Book 2 |
|---|---|---|
| Placeholder passwords in guides | Found (SW01, MKT01) | **None** |
| `cat \| sudo tee` silent-truncation pattern | Found in 3 guides | **None** |
| Stale credentials instructed | Found (`testing`/`password`) | **None** |
| Instructions targeting inert config files | Found (`custom.list`) | **None** |
| Honest, granular status lines | Added retrospectively | **Already present** |

Book 2's status lines were already doing what Charter Rule 14 later formalised:

> `Status | Outcome confirmed; exact historical invocation not independently verified`
> `Status | Verified — confirmed against a recovered build session driver audit`

**This is evidence that the process works.** Book 2 was written after Book 1's lessons and is measurably better.

---

## Blocking Freeze

### 1. Numbering collides with Book 1 — ✅ RESOLVED (2026-07-28)

~~Book 2's guides are numbered `001`–`014`. Book 1 uses `001`–`020`. There are now two `001-`, two `004-`, two `007-`, and so on.~~

✅ **Resolved:** the Lab-02 Virtualization guides were renumbered to the **`2xx` series** — `201`–`214` (+ `220` Ubuntu golden image, + the GNS3 guide). Nothing now collides with Book 1's `0xx`, and the placement tool's numeric-neighbour logic is unambiguous. *(The original recommendation was `101`–`114`; the estate chose the book-scoped `2xx` prefix instead — same effect.)*

### 2. PVE01's networking has three authoritative homes — ✅ RESOLVED (2026-07-28, `ADR-0034`)

The same facts (`vmbr0`, VLAN-aware bridge, `10.10.0.10`, native VLAN 10 on Gi1/0/4, the VLAN-20 tagging failure) are documented in:

- `Labs/Lab-01-Mikrotik-Core/Devices/PVE01-Hypervisor/Build-Guide-Network.md`
- `Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides/204-Proxmox-Networking.md` — *which claims it "matches live `/etc/network/interfaces` exactly"*
- A Confluence page in the `Atlas 2.0` space

~~**No ownership decision was ever made.**~~ ✅ **Decided (`ADR-0034`, operator 2026-07-28):** the single authoritative home is **`Build-Records/PVE01-Networking.md`** (this book). `204-Proxmox-Networking` stays the build *procedure* and points to it; the two **frozen Lab-01** homes (`Build-Record-Network`, `Build-Guide-Network`) become **pointers** (they held the stale pre-07-24 `/24`/native-10 design); the **Confluence** page needs a **manual redirect** (out of repo scope). Live owner sits in the active book — a frozen doc can't be the live owner (`ADR-0022`).

~~**Decide:** does PVE01's *network* configuration belong to the Network book or the Virtualization book?~~ ✅ **Virtualization book owns it** (`ADR-0034`); the others link. This blocker is cleared for both books.

### 3. Build Records are thin — ✅ RESOLVED (2026-07-30, `#21`)

~~14 guides, 2 records — a 7:1 ratio, mostly aspiration.~~ The three named-missing records now exist (the `#21` sweep), closing the last freeze-blocking gap. Guides describe *target state*; records describe *verified reality*:

- [x] Storage Build Record — ✅ **`Build-Records/PVE01-Storage.md`** created (`#21`): `local` ~94 GB (dir) / `local-lvm` ~793 GB (LVM-thin) + 8 GiB swap, device-verified 07-16; RAID/virtual-disk detail 🟡 still to read back.
- [x] Networking Build Record — ✅ **`Build-Records/PVE01-Networking.md`** created (`ADR-0034`)
- [x] Authentication Build Record — ✅ **`Build-Records/PVE01-Authentication.md`** created (`#21`): `root@pam` (recovery) + `seth-admin@pve` (named admin), device-verified 07-16; ACL-least-privilege + root policy 🟡 to read back.

### 4. Evidence Status blocks

Per Charter Rule 14. Book 2's status lines are already close; formalise them.

---

## Known Deviations

| Item | Status |
|---|---|
| ~~DC01 exists (VMID 101) but has **never been promoted**~~ → ✅ **DC01 promoted `atlas.lab`** (device-verified; DC02 replica operator-reported 2026-07-28, read-back pending) | Windows infrastructure is now well underway (AD DS, GPO, AD CS in build). The earlier "not started" note is stale. |
| GUI Shell (noVNC) broken — VNC to `localhost:5900` refused | Non-critical; SSH is a full substitute. Diagnostic commands recorded. |
| CMOS battery still physically dead | BIOS re-enable holds while the host stays on continuous power. **Physical replacement outstanding.** |
| No-subscription patch will be reverted by `apt upgrade` | Needs a post-update hook or manual re-application. |
| iDRAC not hardened | Factory default credentials never changed. **Real gap.** |
| **No backups of any VM, ever** | Proxmox Backup Server is planned and unbuilt. See Book 7. |

## Next Action

1. ~~Resolve the numbering collision~~ → ✅ **done** (renumbered to `201`–`214` / `220`).
2. ~~**Decide who owns PVE01's networking.**~~ → ✅ **done** (`ADR-0034` — Virtualization Build-Record owns it). Residual: **manually redirect the Confluence copy**.
3. ~~Add the three missing Build Records.~~ → ✅ **done** (`#21` — Storage + Authentication created; Networking already existed). Residual: the 🟡 read-backs inside each (RAID/virtual-disk detail; ACL review).
4. Add Evidence Status blocks.
5. Publish, review, reconcile, **freeze**.

## Change Log

| Version | Changes |
|---|---|
| 1.5 | 2026-07-30 (**#22**). **The `2xx` R410-era guides reconciled to the device-verified Build-Records (the deferred #22 item).** `202-Install-Proxmox-VE` + `201-R410-Preparation`: the stale pre-07-24 networking (`/24`, untagged-native-10) corrected to the current tagged `vmbr0.10` `/27` (SW01 `Gi1/0/4` native 999) design, pointing to `PVE01-Networking.md` (`ADR-0034`); `205-Storage` + `206-Authentication`: wired to their authoritative `PVE01-Storage`/`PVE01-Authentication` Build-Records (`POL-0008`) with the 🟡 read-backs (RAID/virtual-disk; ACL/root/TFA) called out (Freeze #4 Evidence-Status pointers); `203` Build-Record reference specified; `215-Current-State`'s stale `/24`-untagged networking table annotated as superseded (→ `PVE01-Networking.md`); `205` `pvsm`→`pvesm` typo fixed. Guides were otherwise already clean (per the 2026-07-13 defect scan). No live device commands run — the remaining 🟡 items need on-device read-backs. |
| 1.4 | 2026-07-30 (`#21`). **PVE01/PVE02 as `Devices/` + Freeze #3 closed.** The hypervisors gained `../../Devices/PVE01-Hypervisor/` (built; points here) + `../../Devices/PVE02-Hypervisor/` (target-state; the `221` runbook is its home) page-sets — the `Devices/` folders are the **front door**, this pack stays the **deep build-record/procedure home** they link into (`POL-0008`, `ADR-0034`). Added **`Build-Records/PVE01-Storage.md`** + **`Build-Records/PVE01-Authentication.md`** → **Freeze #3 (thin Build Records) RESOLVED**; Build-Records 3→5. The `2xx` guides stay flagged as R410-era carry-over for the **#22** clean rewrite. Residuals: the 🟡 read-backs in the new records + the Confluence manual redirect (`ADR-0034`, out of repo scope). |
| 1.3 | 2026-07-30. Added **`221-PVE02-EQR6-Bring-Up-and-VM-Migration`** — the 📋 target-state migration runbook (operator ask; the `#21` companion). Grounded in `ADR-0036` v1.2 placement + `Build-Records/PVE01-Networking` (`ADR-0034`) + the SW01 page-set for the switch side; the clean device-verified PVE02 Build-Guides/Records come from the fresh install. Guides ~16→~17. |
| 1.2 | 2026-07-28. **Freeze Blocker #2 RESOLVED (`ADR-0034`).** PVE01 networking now has one authoritative home — the new **`Build-Records/PVE01-Networking.md`** (Virtualization book); `204` stays the procedure + points to it; the frozen Lab-01 `Build-Record-Network`/`Build-Guide-Network` become pointers; Confluence needs a manual redirect. Build-Records count 2→3; Freeze #3's "Networking Build Record" item closed. Both freeze blockers (#1 numbering, #2 ownership) now resolved. |
| 1.1 | 2026-07-28. **C7 staleness reconciliation (docs-only).** Marked **Blocking Freeze #1 (numbering) RESOLVED** — Lab-02 Virtualization guides were renumbered to the **`2xx` series** (`201`–`214`, `220`), so nothing collides with Book 1's `0xx`; updated Status + Pages to match (added the `220` Ubuntu golden-image guide + GNS3). Updated **Known Deviations**: DC01 (VMID 101) **is now promoted** (device-verified; DC02 read-back pending). Flagged **Blocking Freeze #2 (PVE01 networking = 3 homes) as STILL OPEN** — the Network-book-vs-Virtualization-book ownership decision is the one remaining freeze blocker and needs an operator call (register C7). No guide content changed. |
| 1.0 | Initial manifest, 2026-07-13. Created during the Book 1 close-out, after a full defect scan found Book 2 clean — contradicting the working assumption that it would carry Book 1's defects. |
