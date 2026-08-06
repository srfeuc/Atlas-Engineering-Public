---
Title: Windows Environment Build Roadmap
Path: Labs/Lab-02-Cisco-Core/Windows-Infrastructure
---

# Windows Environment — 12-Week Build Roadmap

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Evidence Status | Target Design |
| Version | 1.0 |
| Assumes | ~15 hrs/week on this + ~5 hrs/week CCNA |
| Host | PVE01 — 62 GiB RAM, 16 vCPU, 793 GB local-lvm |
| Maps to | AZ-802, and the day-one skillset of an MSP engineer |

---

## Three Things to Get Right Before Week 1

### 1. The licence clocks are real, and they will bite you

| Product | Clock | What to do |
|---|---|---|
| **Windows Server 2025 Eval** | **180 days** | Rearmable ~3× (`slmgr /rearm`). Roughly 2 years total. Note the install date **in the Build Record.** |
| **Windows 11 Enterprise Eval** | **90 days** | Shorter than you think. Build the client *when you need it*, not early. |
| **SQL Server Developer Edition** | **None — free, forever, full features** | **Use this, not Express and not Eval.** Express caps at 10 GB and has no SQL Agent. Developer Edition is the full Enterprise product, free for non-production. Most people don't know this. |

**Put the eval expiry dates in the Build Record on day one.** An environment that silently expires in month six is exactly the kind of thing this project exists to prevent.

### 2. Enable nested virtualisation on PVE01 now

You need it for Hyper-V (Phase 6), and Hyper-V is **on the AZ-802 exam** while Proxmox is not.

```bash
# On PVE01
cat /sys/module/kvm_intel/parameters/nested     # want: Y
echo "options kvm-intel nested=Y" | sudo tee /etc/modprobe.d/kvm-intel.conf
# reboot, then on the VM: set CPU type to 'host'
```

Do it now, while a reboot is cheap.

### 3. Capacity check

| VM | RAM | Disk | Purpose |
|---|---|---|---|
| DC01 | 4 GB | 60 GB | AD DS, DNS |
| DC02 | 4 GB | 60 GB | Replication partner |
| SQL01 | 8 GB | 100 GB | AtlasHR, AtlasERP |
| FS01 | 4 GB | 100 GB | DFS, FSRM, Storage Spaces |
| WS01 | 4 GB | 60 GB | Windows Admin Center, Azure Arc |
| CL01 | 4 GB | 60 GB | Windows 11 client |
| HV01 / HV02 | 8 GB ea. | 80 GB ea. | Nested Hyper-V cluster |
| **Total** | **~44 GB** | **~600 GB** | **You have 62 GB / 793 GB.** Comfortable. |

Tight on disk, not on RAM. Thin-provisioned LVM helps. **Snapshot before every phase.**

---

## Phase 0 — Clear the Decks (Week 1, ~8 hrs)

Do not start building on an unfinished foundation. This is short.

- [ ] **Freeze Book 1.** It's nearly done. Stop polishing it.
- [ ] **Renumber Book 2** (`001`–`014` → `101`–`114`). It collides with Book 1 and will keep breaking tooling.
- [ ] **Delete the two committed `.zip` files** and add `*.zip` to `.gitignore`.
- [ ] Enable nested virt, reboot PVE01.
- [ ] Snapshot the `TPL-WIN2025` template.

**Deliverable:** a clean repo you can build on without tripping over.

---

## Phase 1 — Core Directory (Weeks 1–2, ~25 hrs)

The foundation everything else assumes.

### Build

1. **Promote DC01.** It already exists as VM 101, never promoted. Domain: **`atlas.lab`** (per ADR-0007 — the suffix decision you already made).
2. **Create the KDS root key immediately.**
   ```powershell
   Add-KdsRootKey -EffectiveImmediately
   ```
   > **Do this on day one.** In production it needs **10 hours** to propagate before gMSA works. In a single-DC lab `-EffectiveImmediately` bypasses it — **but do it anyway, and understand why the delay exists.** It's a classic exam and interview question, and nothing blocks you like discovering it in week 6.
3. **OU skeleton — role-based, not departmental.** Justify it in writing against the two problems from the Company Profile: Sales splits across two machine policies; Finance and HR share one password policy.
4. **DNS** — forwarders to Pi-hole (10.10.0.5), reverse lookup zone, then update the DHCP/client chain.
5. **DC02.** Promote. **Then break replication on purpose** and fix it with `repadmin /showrepl`, `dcdiag`.
6. **Sites and Services.** Even with one site — configure it, so you know what it does.

### Deliverables
- Working two-DC domain
- An **ADR** justifying role-based OUs, with the Sales/Finance evidence
- A Build Record with the eval expiry dates in it

### AZ-802 coverage
AD DS deployment, FSMO, replication, DNS. **~30% of the exam.**

---

## Phase 2 — The HR Pipeline (Weeks 2–3, ~30 hrs)

**This is the phase that separates you from every other home lab.** It reinforces SQL, teaches real provisioning, and produces the best portfolio artifact in the build.

### Build

1. **SQL01** — Windows Server + **SQL Server Developer Edition** (free, full-featured).
2. **`AtlasHR` database.** Schema from the Company Profile. `ManagerID` self-referencing FK — that's your org hierarchy.
3. **Populate 156 employees, *including the mess*:**
   - 12 Reeves acquisition users (`SourceSystem = 'ReevesLegacy'`, wrong naming convention)
   - 5 ghosts (`TerminationDate` in the past, `IsActive = 1`)
   - 6 contractors with expiry dates
   - The name bombs: `O'Brien`, `Papadopoulos-Georgiou`, two `John Smith`s, `José Ramírez`
4. **Write the provisioning script.** SQL → `New-ADUser` → **write `sAMAccountName` back to SQL.**
5. **Let it break.** It *will* break on the apostrophe and on the 20-character `sAMAccountName` limit. **That's the exercise.** Fix it, and document what broke.

### The SQL you'll actually write
- **Recursive CTE** — full reporting chain to the CEO
- **Termination reconciliation** — `TerminationDate < GETDATE() AND IsActive = 1`
- **Collision detection** — duplicate `first.last`, and your tiebreak rule
- **The 20-char pre-flight** — catch it *before* `New-ADUser` fails
- **The gap report** — AD accounts with no SQL row. **These are the ones nobody can explain.**

### Deliverables
- `New-AtlasUsersFromHR.ps1`, in the repo, with the failure modes documented
- A populated 156-user domain
- A written answer to: *"How do you know AD matches your system of record?"*

### Why it matters
That gap report is a genuine interview answer, and almost nobody has one.

---

## Phase 3 — The Client, and Real GPO (Weeks 3–4, ~25 hrs)

> **The mistake everyone makes: building DCs and no clients.** Then GPO is "applied" but never *experienced*. LAPS is "deployed" but never *retrieved*. Onboarding is a script nobody ever logged into.

### Build

1. **CL01 — Windows 11 Enterprise Eval**, domain-joined. *(90-day clock — build it now that you need it.)*
2. **GPO baseline** — security baseline, screen lock, drive mapping, folder redirection.
3. **PSO for Finance + HR** — stricter than the domain default. Prove it applies to both and not to Sales.
4. **The executive exception.** Someone will demand a carve-out. **Document it as a decision (an ADR), not a silent change.** That's the actual lesson.
5. **Windows LAPS** — deploy, then **retrieve a password as a Tier 2 account and watch it fail.**
6. **Kiosk GPO** for the shop-floor accounts — no Control Panel, no USB, auto-logon, forced reboot at shift end.

### Deliverables
- A client that visibly behaves differently depending on which OU it's in
- LAPS proven working *and* proven correctly restricted

---

## Phase 4 — Core Services (Weeks 4–6, ~35 hrs)

### Build

1. **DHCP on DC01/DC02 with failover** (load-balance mode). **Explicit AZ-802 content.**
2. **FS01** — file services:
   - **DFS Namespaces + Replication**
   - **FSRM** — quotas, file screens (block `.mp3` on the finance share, watch someone complain)
   - **Storage Spaces** — a mirrored virtual disk from spare vdisks
3. **Shares mapped by GPO**, per the role-based OU model.
4. **WSUS** *or* — better — skip straight to **Azure Update Manager** in Phase 7. WSUS is legacy; Update Manager is what the exam now tests.

### AZ-802 coverage
Storage and file services (~15–20%), networking/DHCP (~15%).

---

## Phase 5 — Tiering, gMSA, and the Cleanup (Weeks 6–7, ~30 hrs)

The security phase. Also the most MSP-relevant one.

### Build

1. **Tier 0 / 1 / 2 model.** Eight IT staff → 20+ accounts.
2. **AGDLP** groups, properly. Not "everyone in Domain Admins because it was quicker."
3. **gMSA** for `svc-sqlengine` and `svc-atlaserp`. *(KDS key from Phase 1 has now propagated — this is why you did it first.)*
4. **Prove Tier 2 cannot touch Tier 0.** Not assert. **Log in and fail, and screenshot the failure.**

### The Reeves Cleanup — do this as a real project

Twelve users in `CN=Users`, wrong naming convention, `Description` fields saying `TEMP - fix later`, and **three with Domain Admins granted "temporarily" 18 months ago by someone who has since left.**

- Write the PowerShell to **find the three rogue Domain Admins**
- Decide: rename to the Atlas convention (breaking profiles) or grandfather them (breaking your convention). **Write the ADR.**
- Do it as a **Change Record** — backup, rollback, validation.

> **This is what every MSP inherits on day one, from every client.** It's the single most transferable thing in this build.

### Offboarding SOP
Take one of the five ghosts and offboard them properly — disable, strip groups except an audit group, move to a Disabled OU, revoke certificates, document retention. **Write it as an SOP a colleague could follow without you.**

---

## Phase 6 — Hyper-V and High Availability (Weeks 7–9, ~35 hrs)

**Hyper-V is on the exam. Proxmox is not.** Run it nested.

### Build

1. **HV01 + HV02** — Windows Server VMs on Proxmox, CPU type `host`, Hyper-V role installed.
2. **Failover Clustering** across the two.
3. **Storage Spaces Direct** *or* **Storage Replica** — pick one, understand both.
4. **Live Migration** between nodes.
5. Nest a small VM inside HV01 and migrate it. *(Yes, that's a VM in a VM in a VM. It works, and it's a good story.)*

### Why bother, when you already know Proxmox?

The **concepts transfer directly** — you've already done templates, snapshots, VM lifecycle in Book 2. What doesn't transfer is the *Hyper-V-specific* vocabulary the exam tests: checkpoints vs snapshots, Generation 1 vs 2, dynamic memory, VM Connect.

And in an interview: *"I run Proxmox in production and know Hyper-V for the exam"* is a **better** answer than pretending. It shows you chose deliberately.

### AZ-802 coverage
VMs and containers, HA, disaster recovery. **This is the whole AZ-801 half your current lab plan is missing.**

---

## Phase 7 — Azure and Hybrid (Weeks 9–11, ~35 hrs)

**This is where AZ-802 lives now.** Budget: **$10–30/month, with discipline.**

### Build, in cost order (cheapest first)

| Step | Cost | Notes |
|---|---|---|
| **Azure account + budget alert** | $0 | **Set the alert first.** This is the lesson. |
| **Entra ID (free tier)** | $0 | |
| **Entra Connect** — hybrid identity | $0 | Sync `atlas.lab` → Entra. Password hash sync. |
| **Azure Arc** — onboard FS01, WS01, SQL01 | **$0** for the agent | Now your on-prem servers appear in the portal |
| **Azure Monitor + VM Insights** | ~$2–5/mo | Pay per GB ingested. Keep it small. |
| **Azure Update Manager** | ~$5/server/mo | Patch on-prem servers *from Azure*. Replaces WSUS. |
| **Azure Files + File Sync** | ~$2–5/mo | Tier the DFS share to Azure. Real hybrid storage. |
| **Defender for Cloud** (free tier) | $0 | Recommendations only |
| **Site-to-site VPN** — MikroTik → Azure VNet | **~$1/day** | **BURST ONLY. Build it, prove it, tear it down.** |

### The VPN Gateway is the budget killer

A Basic VPN Gateway runs **~$27/month if left on.** That's your entire budget.

**So don't leave it on.** Build it on a Saturday, prove the tunnel, run a domain-joined VM in Azure across it, tear it down Sunday. **Document the build *and* the teardown as a repeatable procedure.**

> **That teardown discipline *is* the MSP skill.** Clients get billed for what you leave running. An engineer who spins up a gateway and forgets it is the engineer who costs the company money. Make it a documented step, not an afterthought.

### Deliverables
- On-prem servers visible and patchable from the Azure portal
- Hybrid identity working
- A **site-to-site VPN build/teardown runbook** with real costs in it
- A budget alert that has actually fired at least once

---

## Phase 8 — Disaster Recovery (Weeks 11–12, ~25 hrs)

The phase everyone skips, and the one that gets you hired.

### Break things on purpose

1. **AD Recycle Bin** — enable, delete a user, restore them.
2. **Authoritative restore from DSRM** — actually do it. Once. It's terrifying the first time and routine the second.
3. **FSMO transfer *and* seize.** Transfer is the easy path. **Seize is what you do when DC01 is on fire and never coming back** — and that's the one they ask about.
4. **Break replication deliberately.** Firewall a DC off, let it go stale past the tombstone lifetime, then deal with the consequences.
5. **Storage Migration Service** — migrate FS01's shares to a new server. AZ-802 tests migration.
6. **Restore a VM from backup.** *Any* backup. **You currently have none of any kind, anywhere.**

### Deliverable
A **DR runbook** that a colleague could execute at 3am without calling you. That is the actual test of everything you've built.

---

## What You'll Have at the End

| Artifact | Why it matters |
|---|---|
| A 156-user AD domain provisioned from SQL | Almost nobody has this |
| An HR-to-AD sync with a reconciliation gap report | A real interview answer |
| A documented rogue-Domain-Admin cleanup | Exactly what MSPs inherit |
| Hyper-V failover cluster, nested | AZ-802's whole second half |
| On-prem servers Arc-managed from Azure | The "hybrid" the cert is named for |
| A DR runbook you have actually executed | The thing that separates admins from engineers |
| A site-to-site VPN with **costs and a teardown** | MSP cost discipline |

**And roughly 80% of AZ-802.** The remaining 20% is reading.

---

## The Rules That Keep This Honest

1. **Snapshot before every phase.** You now have the discipline for this.
2. **Every phase produces a Build Record** — not just a Build Guide. *What actually happened*, including what broke.
3. **Charter Rule 15 applies.** If a change invalidates a guide, fix the guide before you close the change.
4. **Every failure is a portfolio asset.** The broken script, the failed restore, the VPN that cost $40 because you forgot it — **document all of it.** That is the difference between this and a tutorial.

---

## Related Pages

- `Labs/Lab-02-Cisco-Core/Windows-Infrastructure/001-Atlas-Company-Profile.md` — the company this serves
- `00-Atlas-Foundation/Windows-Environment-Roadmap.md`
- `08-Labs/README.md` — Sections 1, 2 and 4 all become real once this is built
- `00-Atlas-Foundation/Decisions/ADR-0007-Adopt-atlas-lab-Domain-Suffix.md`

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Initial 12-week roadmap. Sequenced so each phase unblocks the next: KDS key in Phase 1 because gMSA in Phase 5 needs it propagated; the client in Phase 3 because GPO isn't real without one; Azure last because it costs money and everything else is free. |
