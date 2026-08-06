---
Title: Lab-02 Master Build Order — SUPERSEDED
Path: Labs/Lab-02-Cisco-Core/Architecture
Status: 🔴 SUPERSEDED (2026-07-29, `ADR-0043` / register E2). The single estate build-order owner is now `../Operations/Build-Order-and-Dependencies.md`. Do not edit here.
Version: 1.7
Date: 2026-07-29
---

# Lab-02 — Master Build Order — 🔴 SUPERSEDED

> **This doc is retired.** The estate build order — the phases, the 🔴 gates, the five principles, and the dependency cheat-sheet — now live in **one owner**:
>
> ### → [`../Operations/Build-Order-and-Dependencies.md`](../Operations/Build-Order-and-Dependencies.md)
>
> (`ADR-0043` / register **E2** — the "full merge" that ends the three-order-docs drift.) The per-device *how* moved into each device's **gated Build-Guide** (`ADR-0043`).

## Why
Three docs carried the build sequence — this, `Master-Implementation-Checklist.md`, and `Build-Progress-Tracker.md` — and drifted apart. That is the exact failure this cleanup unwinds. There is now **one** owner of the order (`POL-0008`); this file's v1.6 content was absorbed there and remains in git history.

## Where things went
- **Order + gates + dependency map** → `../Operations/Build-Order-and-Dependencies.md`
- **Per-device steps (the how)** → each `Devices/<host>/Build-Guide` (or `Build-Guide/`)
- **Live status / execution log** → `../Build-Progress-Tracker.md`
- **Where we are** → `../SESSION-HANDOFF.md`
- **Design (why / where services land)** → `Atlas-Service-Architecture.md`

## Change Log
| Version | Changes |
|---|---|
| 1.7 | 2026-07-29. 🔴 **SUPERSEDED** by `Operations/Build-Order-and-Dependencies.md` (`ADR-0043` / E2 full merge). Phases 0–11 + the five principles + the dependency cheat-sheet absorbed into the new single owner; per-device steps → the gated Build-Guides. Full prior content (v1.6) in git history. |
