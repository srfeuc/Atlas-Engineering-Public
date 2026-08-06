---
Title: Pi01 — Automation (scripts + how-tos)
Path: Labs/Lab-02-Cisco-Core/Devices/Pi01-DNS-NTP/Automation
Status: 📋 Designed stub (`ADR-0048`). Authored *after* the manual first pass — automate what you've learned by hand (Learning Rule). 🟡 until each artifact runs idempotently.
Version: 0.1
Date: 2026-07-30
---

# Pi01 — Automation (`ADR-0048`)

> **The rule (`ADR-0048`).** This folder holds Pi01's automation **slice** — how-tos + device-specific scripts — authored **after** the manual first pass, never as a shortcut past the learning (you build Pi-hole + chrony by hand once so you learn DNS/NTP service admin; *then* you make the rebuild repeatable). Because the box is a disposable SD-card Pi (`ADR-0009`), "rebuild as code" is the real payoff — a lost SD should mean a re-image, not a re-learn. Runnable shared code = the estate capability (`Operations/Automation/` + self-hosted git, Backlog #19). 🟡 until idempotent (`ADR-0041`).

## Planned automation (designed, phased — `ADR-0048` tooling ladder)

| Task | Tool | What it automates | What it does NOT automate (hand-learned first) |
|---|---|---|---|
| **Base image + harden** | cloud-init / Ansible | Raspberry Pi OS provisioning, named admin, SSH-keys-only, host firewall (53/123/22), VLAN-10 static identity | The *first* manual harden pass (Linux/Security+ skill) |
| **chrony config** | Ansible (config as code) | Install chrony, mask timesyncd, render the `ADR-0020` upstream + `allow` scopes, assert `chronyc tracking` synced | Deciding the NTP hierarchy placement (the time-authority design) |
| **Pi-hole config** | Ansible + Pi-hole `--teleporter` / v6 config | Install Pi-hole, upstream resolvers, `dnsmasq.d` local records, `atlas.lab` conditional-forward, blocklists | 🔴 **The DNS-policy / forwarder design judgment** — the boundary (`ADR-0003`/`ADR-0007`), what to filter, what to forward |
| **Rebuild-from-SD** | cloud-init image + config tar | Reproduce the whole reduced box identically after an SD failure | Confirming the migrations OFF stayed off (`ADR-0009`) |

## How this fits the estate
- **Phase alignment:** Roadmap **automation-onboarding**, after the manual DNS+NTP build is proven. Estate sequencing: `../../Operations/Build-Order-and-Dependencies.md` (`ADR-0048`).
- **Secrets:** any bind/API creds come from the vault at run time — **never committed** (`POL-0002`).
- **Cert anchor:** cloud-init/Ansible (CCNP ENAUTO-adjacent); Pi-hole/chrony service admin (Linux).

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-30 | Created as the designed `Automation/` stub for Pi01 (`ADR-0048`) — planned cloud-init/Ansible base+harden, chrony config-as-code (mask timesyncd, assert sync), Pi-hole config (v6 `dnsmasq.d` records + `atlas.lab` conditional-forward), and rebuild-from-SD, each with its "does NOT automate" boundary — with the **DNS-policy/forwarder design judgment** explicitly left hand-owned. Filled after the manual build. |
