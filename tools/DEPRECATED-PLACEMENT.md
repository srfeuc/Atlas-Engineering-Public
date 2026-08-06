# Deprecated — the flat-numbering placement tooling

The placement scripts in this folder were built for the **old flat structure**, where documents were global-numbered (`026-…`, `047-…`) and filed into type folders (`Build-Guides/`, `Operations/`, …). That structure no longer exists — as of the **2026-07-16 restructure**, files live by **path** under `Labs/<lab>/Devices/<device>/` and `00-Atlas-Foundation/`.

## Retired — do not use

- `Place-AtlasFiles.ps1`
- `Place-Tier3-Batch.ps1`
- `PLACE-INSTRUCTIONS.md`
- `PLACEMENT-CHEATSHEET.md`
- `What-a-Batch-Is.md`

They assume the old numbered layout and will **mis-file** into folders that no longer carry meaning. In the new tree there is nothing to "place": you write a file at its correct path, or `git mv` an existing one to a new one. Keep the `Select-String`-before-commit verification habit — that discipline outlived the tooling.

## Not deprecated

The recon scripts (`scripts/*-recon.*`) read **live device state** and are still current. They stay.

---

*These files are left in place rather than deleted so history and the placement-log stay intact. `git rm` them whenever you want them gone.*
