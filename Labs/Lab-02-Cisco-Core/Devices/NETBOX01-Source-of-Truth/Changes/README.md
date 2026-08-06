# NETBOX01 — Changes ledger

> One file per **post-build** change: `CM-####-Short-Kebab-Title.md`, `####` continuing the estate's CM sequence. Record the change (what, why, evidence) here first, **then** update `../Build-Record.md` — **never silently edit the record** (`ADR-0037` workflow, `POL-0001`).

Empty until NETBOX01's service is built and its first change lands. A likely early entry: **the empty-diff proof** — when the NetBox-generated SW01 `STATIC-HOSTS`/DAI ACL first diffs empty against the live device (the moment "source of truth" stops being aspirational — see `../Considerations.md`). Later: the **self-signed → ICA01 cert** swap (Phase 8) and the **LDAPS-to-AD auth** enablement.
