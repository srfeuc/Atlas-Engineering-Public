---
Title: Contributing — Adding & Moving Docs in the New Structure
Path: 00-Atlas-Foundation/Documentation
Status: Authoritative — this is the one "where does a doc go?" reference (placement). What a device folder *contains* is governed by [`Atlas-Documentation-Standard.md`](./Atlas-Documentation-Standard.md) (v1.7). See [`00-Atlas-Foundation/README.md`](../README.md) for the index.
---

# Contributing — Adding & Moving Docs

This is the **authoritative** placement doc for Atlas. It replaces the retired flat-numbering placement tooling (`tools/DEPRECATED-PLACEMENT.md`) **and** the earlier structure proposals (`Atlas-Repository-Restructure-Proposal.md`, `Atlas-Repository-Structure-and-Navigation.md`, now archived). Since the 2026-07-16 restructure — refined 2026-07-23 — files live **by path** under the Capitalized `00-Atlas-Foundation/` scheme. There is nothing to "place" — you write a file where it belongs, or `git mv` an existing one.

## Where things live

| Kind of doc | Home |
|---|---|
| Charter, the `Contributing`/doc-standards references, cross-lab architecture | `00-Atlas-Foundation/` (root) |
| Governance — the framework, the pack workflow, the change-management process | `00-Atlas-Foundation/Governance/` |
| Security program — compliance, incident response, awareness, third-party risk | `00-Atlas-Foundation/Security-Program/` |
| Roadmap family — the phase list (authoritative), advanced scenarios, next-lab brief, improvement backlog | `00-Atlas-Foundation/Roadmap/` |
| The company scenario (who Atlas is) | `00-Atlas-Foundation/Company-Profile/` |
| A standing rule | `00-Atlas-Foundation/Policies/POL-####-…md` |
| A concrete standard a policy requires | `00-Atlas-Foundation/Standards/STD-####-…md` |
| A point-in-time decision | `00-Atlas-Foundation/Decisions/ADR-####-…md` |
| A reusable skeleton | `00-Atlas-Foundation/Templates/` |
| Learning & certification material | [`Atlas-Academy/`](../../Atlas-Academy/) |
| Anything about one device, one lab | `Labs/<lab>/Devices/<DEVICE-Role>/` |
| A cross-device runbook for a lab | `Labs/<lab>/Operations/` |
| A change record | device-specific → `Labs/<lab>/Devices/<device>/Changes/`; cross-device → `Labs/<lab>/Change-Management/` |

## What goes *inside* a device folder

This doc owns **where a doc lives**. What a `Devices/<DEVICE-Role>/` folder **contains** — and the shape of each doc — is governed by **[`Atlas-Documentation-Standard.md`](./Atlas-Documentation-Standard.md)** (currently **v1.7**). Don't restate its rules here; the current standard per-device page-set is:

- **`README.md`** — the front-door: identity table, *Role this era*, a **Connections map** with a Mermaid diagram whose **edges are labelled with protocol/port** (Standard v1.6), a **Services map** table — *Service · Purpose · Consumed-by + port · Depends-on · Status* (Standard **v1.7**) — and a Documents index. (README has **no** YAML frontmatter; every other doc does + a foot Change Log.)
- **`Roadmap.md`** · **`Build-Guide.md`** (or a `Build-Guide/` spine for phased builds) · **`Build-Checklist.md`** · **`Build-Record.md`** · **`Considerations.md`** · **`Diagnostics.md`** · **`Troubleshooting.md`**.
- **`Roles/<service>/`** on a multi-service host (per-service Build-Checklists) · **`Automation/`** (the [`ADR-0048`](../Decisions/ADR-0048-Automation-and-IaC-Model.md) automation doc-type) · **`Changes/`** (the `CM-####` ledger).

Author **in build order** (checklist-first). Networking/security devices copy the folder *shape* but rewrite content to their real domain (ports/VLANs/routing/`show`-commands) per the replication prompt's **§5 networking variant** ([`Operations/Device-Page-Set-Replication-Prompt.md`](../../Labs/Lab-02-Cisco-Core/Operations/Device-Page-Set-Replication-Prompt.md)) — no Windows/SMB/AGDLP carry-over. The Standard is the authority on **element content**; this file stays the authority on **placement**.

## Naming

- **Inside a device folder, use descriptive names, not numbers:** `Build-Guide.md`, `Build-Record.md`, `Troubleshooting.md`, `CIS-Hardening.md`, `Verification.md`, `Considerations.md`.
- **Change records keep their numbers** (`CM-####`, `MC-####`) — they are a chronological ledger. **Numbering resets per lab.**
- `POL-####` and `ADR-####` keep global numbers.

## Every lab doc gets

1. Frontmatter with `Title:` and `Path:` (`Path:` = the doc's folder path, so git tree == Confluence tree).
2. A provenance banner under the H1:
   `> **Lab-01 - Mikrotik-Core (FROZEN …)** - Host: <device> - Role: <role>`
   so a page viewed alone still says which era and role it belongs to.

## To add a doc

1. Create it at the correct path (create the folder if needed — `git` tracks files, not folders, so the folder appears when the file lands).
2. Add the frontmatter + provenance banner.
3. Reference other docs by their **new path**, not by old number.

## To move a doc

Use `git mv` — **never** delete-and-recreate. History must follow every file (`git log --follow` must keep working). `git mv` does **not** create the destination directory; `mkdir` it (or `New-Item -Force`) first.

## Before you commit

- `Select-String` the file to confirm it's really there (a batch that never applied is a change that never happened).
- Fix any cross-references you broke, then `git grep` the old form to confirm it returns **0** outside `99-Archive`.
- `gitleaks` must pass; endings stay **LF** per `.gitattributes`. CI (`.github/workflows/atlas-checks.yml`) enforces all three.
