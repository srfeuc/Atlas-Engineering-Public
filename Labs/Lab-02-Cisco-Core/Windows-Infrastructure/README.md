---
Title: Book 3 — Windows Infrastructure
Path: Labs/Lab-02-Cisco-Core/Windows-Infrastructure
Status: 📋 Planned — not yet started (waits on the Network book freeze, per the Charter sequencing rule).
Version: 0.1
Date: 2026-08-02
---

# Book 3 — Windows Infrastructure

## Status

Planned. Not yet started — do not begin until Network (Book 1) is frozen, per the Charter's sequencing rule. This page exists now so the plan has a home; execution waits its turn.

## Target Reader Test

The completed book must allow an engineer to:

- promote DC01 and DC02, and explain why a single-DC design isn't a credible answer for a 150-person company;
- design and build an OU tree that supports delegation and Group Policy targeting, not just an org-chart mirror;
- create and justify a group strategy (AGDLP) and a service-account strategy (gMSA-first);
- stand up DNS, DHCP, file services/DFS, and WSUS, and explain what each depends on and what depends on it;
- build a Group Policy baseline including Windows LAPS;
- onboard and offboard a user end-to-end, including the access-revocation and retention-period parts, not just account creation.

## What This Book Covers

Pulled from the Windows Environment Roadmap (`00-Atlas-Foundation/Windows-Environment-Roadmap.md`) — see that document for full detail, rationale, and sourcing. Summary:

1. **Company definition** — Atlas as a ~100-150 person company, department breakdown, headcount. Needed before OU design means anything.
2. **Forest and domain design** — single forest, single domain. The rationale (not multi-domain) matters more than the conclusion; document it as a real decision, not a default.
3. **OU structure** — role-based, not department-mirrored. This is the most common real-world mistake and worth getting right on purpose.
4. **Groups and service accounts** — AGDLP pattern; gMSA as the default for any service that supports it, with the KDS root key prerequisite called out explicitly since it has a real propagation delay.
5. **Group Policy baseline** — password/lockout policy, workstation and server security baselines, Windows LAPS, executive exception handling done as a documented decision rather than a silent carve-out.
6. **Core services build order** — AD DS → KDS root key → OU skeleton → DNS/DHCP → base GPOs → groups → user population → file services/DFS. Order matters; each step assumes the one before it exists.
7. **Windows Server roles needed** — see `00-Atlas-Foundation/VM-and-Services-Inventory.md` for the concrete VM list, sized against PVE01's actual hardware capacity.

## Explicitly Out of Scope for This Book

- Tiered administration model in depth — that's Book 4 (Identity and PKI), even though it's introduced here conceptually.
- AD CS / PKI — Book 4.
- Anything Azure/hybrid — belongs with whichever future book takes on cloud extension, not bolted on here.

## Dependencies

- PVE01 (Book 2) must support the VM roster in the VM and Services Inventory.
- DC01 already exists as a VM (Book 2's golden-image lineage) but has never been promoted — this book is where that actually happens.

## Source Notes

This book's plan is derived from real research (Microsoft Learn documentation, current AD design best practices) done in the same session that produced the Windows Environment Roadmap — not from assumption. See that document's citations for specifics.
