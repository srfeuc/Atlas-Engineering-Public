<#
.SYNOPSIS
    Places the verified 051 Tier-3 reconciliation batch into the Atlas repo.

.DESCRIPTION
    Nine corrected documents. Seven go through Tools\Place-AtlasFiles.ps1 (the
    normal path). TWO are README.md files — the Change-Management index and the
    Book 1 landing page. Place-AtlasFiles.ps1 REFUSES README.md by design (it is
    a per-directory name it cannot resolve), and one [FAIL] aborts the WHOLE
    batch — so the READMEs must not go through the tool. This script feeds the
    seven to the tool and hand-places the two READMEs to their exact paths, the
    way PLACEMENT-CHEATSHEET.md prescribes.

    Then it enforces the step everyone skips: it Select-String-verifies a phrase
    that only exists in the NEW version of every one of the nine files, and
    REFUSES TO COMMIT if any verify misses. A tool saying "done" and git saying
    "committed" prove nothing about the file's contents. This does.

    Nothing is destroyed: the tool backs up every overwrite to
    99-Archive\replaced\<timestamp>\, and the two hand-placed READMEs are backed
    up here the same way before they are overwritten.

.PARAMETER BatchZip
    Path to atlas-tier3-batch-2026-07-15.zip (e.g. in your Downloads folder).

.PARAMETER Repo
    Repo root. Defaults to C:\Users\Seth\Atlas\Atlas-Engineering-Repository.

.PARAMETER Apply
    Actually place files. Without it this is a dry run and writes nothing.

.PARAMETER Commit
    After a CLEAN verify, commit. Implies -Apply. Will not commit if any verify misses.

.PARAMETER Push
    After a successful commit, push. Implies -Commit.

.EXAMPLE
    # 1. Dry run — writes nothing, shows the plan and the README previews:
    .\Place-Tier3-Batch.ps1 -BatchZip C:\Users\Seth\Downloads\atlas-tier3-batch-2026-07-15.zip

.EXAMPLE
    # 2. Place + verify, stage but don't commit (review the diff yourself):
    .\Place-Tier3-Batch.ps1 -BatchZip C:\Users\Seth\Downloads\atlas-tier3-batch-2026-07-15.zip -Apply

.EXAMPLE
    # 3. Place + verify + commit + push in one go:
    .\Place-Tier3-Batch.ps1 -BatchZip C:\Users\Seth\Downloads\atlas-tier3-batch-2026-07-15.zip -Push

.NOTES
    This script was downloaded, so it carries Mark of the Web. Before running:
        Unblock-File .\Place-Tier3-Batch.ps1
    Do NOT change the execution policy. Unblock-File fixes the one file.

    Sanity-check the script itself before running (silence = it parses):
        [void][ScriptBlock]::Create((Get-Content .\Place-Tier3-Batch.ps1 -Raw))
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $BatchZip,

    [string] $Repo = 'C:\Users\Seth\Atlas\Atlas-Engineering-Repository',

    [switch] $Apply,
    [switch] $Commit,
    [switch] $Push
)

$ErrorActionPreference = 'Stop'
if ($Push)   { $Commit = $true }
if ($Commit) { $Apply  = $true }

function Head ($t) { Write-Host ""; Write-Host $t -ForegroundColor Cyan; Write-Host ('-' * $t.Length) -ForegroundColor DarkCyan }
function Ok   ($t) { Write-Host "  [ ok ] $t" -ForegroundColor Green }
function Info ($t) { Write-Host "  $t" -ForegroundColor Gray }
function Bad  ($t) { Write-Host "  [FAIL] $t" -ForegroundColor Red }

# ---- the content-verify map: a phrase that exists ONLY in the corrected file ----
# Relative path (repo-rooted, backslashes) -> distinctive new-version phrase.
$verify = [ordered]@{
    '01-Enterprise-Network\Architecture\001-Enterprise-Network-Overview.md' = 'must not be treated as disposable'
    '01-Enterprise-Network\Build-Records\021-FGT01-Build-Record.md'         = 'the scoped address objects do not exist on the device'
    '01-Enterprise-Network\Build-Records\023-SW01-Build-Record.md'          = 'last copy still showing the old label'
    '01-Enterprise-Network\Build-Records\024-PVE01-Network-Build-Record.md' = '16 logical CPUs'
    '01-Enterprise-Network\Build-Records\029-Pi01-Build-Record.md'          = 'atlas-pi01-2026-07-14.tar.gz.gpg'
    '01-Enterprise-Network\Operations\020-Network-Revision-History.md'      = 'Populated 2026-07-14'
    '01-Enterprise-Network\Operations\Build-Order-and-Dependencies.md'      = 'AD CS does NOT replace the OpenSSL Lab CA'
    '01-Enterprise-Network\Change-Management\README.md'                     = 'its stated next-free number was still six behind reality'
    '01-Enterprise-Network\README.md'                                       = '76 Markdown documents'
}

# README.md files are placed by hand (the tool refuses them). Everything else
# goes through the tool.
$ReadmeRel = @(
    '01-Enterprise-Network\Change-Management\README.md'
    '01-Enterprise-Network\README.md'
)

# --------------------------------------------------------------- preflight ----

if (-not (Test-Path -LiteralPath $BatchZip)) { throw "Batch zip not found: $BatchZip" }
$Repo = (Resolve-Path $Repo).Path
$tool = Join-Path $Repo 'Tools\Place-AtlasFiles.ps1'
if (-not (Test-Path -LiteralPath $tool)) { throw "Place-AtlasFiles.ps1 not found at $tool" }

Head "Repository"
Info $Repo

Push-Location $Repo
try {
    $dirty = @(git status --porcelain 2>$null)
    if ($dirty.Count -gt 0) {
        Head "Working tree is not clean"
        $dirty | Select-Object -First 15 | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkYellow }
        Bad "Commit or stash first. This script (and the tool) refuse a dirty tree on purpose."
        exit 1
    }
    Ok "Working tree clean"
} finally { Pop-Location }

# --------------------------------------------------------------- unpack -------

$work = Join-Path ([IO.Path]::GetTempPath()) ("tier3-" + [guid]::NewGuid().ToString('N').Substring(0,8))
New-Item -ItemType Directory -Path $work | Out-Null

try {
    $expand   = Join-Path $work 'batch'
    $toolSrc  = Join-Path $work 'tool-src'   # seven files, READMEs removed
    Expand-Archive -LiteralPath $BatchZip -DestinationPath $expand -Force
    Copy-Item -LiteralPath $expand -Destination $toolSrc -Recurse -Force

    # Strip the READMEs out of the tool source so the tool never sees them.
    Get-ChildItem -Path $toolSrc -Recurse -File -Filter 'README.md' |
        ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force }

    $incoming = Get-ChildItem -Path $expand -Recurse -File -Filter *.md
    $nToolFiles = @(Get-ChildItem -Path $toolSrc -Recurse -File -Filter *.md).Count
    if ($incoming.Count -ne 9) { throw "Expected 9 .md files in the batch, found $($incoming.Count)." }
    if ($nToolFiles -ne 7)     { throw "Expected 7 tool-placeable files after removing READMEs, found $nToolFiles." }

    # ------------------------------------------------------- tool dry run -----
    Head "Tool dry run (7 documents)"
    & $tool -Source $toolSrc -Repo $Repo
    if ($LASTEXITCODE -ne 0) { Bad "Tool dry run did not resolve cleanly (exit $LASTEXITCODE). Nothing written."; exit $LASTEXITCODE }

    # ----------------------------------------------- README hand-placements ---
    Head "README.md hand-placements (2 — the tool refuses these by design)"
    foreach ($rel in $ReadmeRel) {
        $src = Join-Path $expand $rel
        $dst = Join-Path $Repo   $rel
        if (-not (Test-Path -LiteralPath $src)) { throw "Missing from batch: $rel" }
        $old = if (Test-Path -LiteralPath $dst) { (Get-Content -LiteralPath $dst).Count } else { 0 }
        $new = (Get-Content -LiteralPath $src).Count
        $phraseHit = @(Select-String -LiteralPath $src -SimpleMatch -Pattern $verify[$rel]).Count -gt 0
        $tag = if ($old -eq 0) { "[ new]" } else { "[chg ] OVERWRITE $old -> $new lines" }
        Write-Host "  $tag  .\$rel" -ForegroundColor Yellow
        if (-not $phraseHit) { Bad "incoming $rel does NOT contain its verify phrase — wrong file? Aborting."; exit 3 }
    }

    if (-not $Apply) {
        Head "Dry run"
        Info "Nothing written. Re-run with -Apply to place, or -Push to place, verify, commit and push."
        exit 0
    }

    # ------------------------------------------------------------- apply ------
    Head "Applying — 7 via the tool"
    & $tool -Source $toolSrc -Repo $Repo -Apply
    if ($LASTEXITCODE -ne 0) { Bad "Tool apply failed (exit $LASTEXITCODE). Inspect the tree; nothing here has been committed."; exit $LASTEXITCODE }

    Head "Applying — 2 READMEs by hand (with backup)"
    $stamp  = Get-Date -Format 'yyyy-MM-dd-HHmmss'
    $backup = Join-Path $Repo "99-Archive\replaced\$stamp"
    foreach ($rel in $ReadmeRel) {
        $src = Join-Path $expand $rel
        $dst = Join-Path $Repo   $rel
        if (Test-Path -LiteralPath $dst) {
            $bak = Join-Path $backup $rel
            New-Item -ItemType Directory -Path (Split-Path $bak -Parent) -Force | Out-Null
            Copy-Item -LiteralPath $dst -Destination $bak -Force
        }
        Copy-Item -LiteralPath $src -Destination $dst -Force
        Write-Host "  [chg ] .\$rel  (previous -> 99-Archive\replaced\$stamp)" -ForegroundColor Yellow
    }

    Push-Location $Repo
    try { git add -A | Out-Null } finally { Pop-Location }

    # -------------------------------------------------- VERIFY (the gate) -----
    Head "Content verification — Select-String, every file (Step 4)"
    $misses = 0
    foreach ($rel in $verify.Keys) {
        $dst = Join-Path $Repo $rel
        $hit = @(Select-String -LiteralPath $dst -SimpleMatch -Pattern $verify[$rel]).Count -gt 0
        if ($hit) { Ok "$rel" }
        else      { Bad "$rel  — phrase NOT found: '$($verify[$rel])'"; $misses++ }
    }

    if ($misses -gt 0) {
        Head "STOP — $misses file(s) failed verification"
        Info "Nothing has been committed. The files are placed and staged, but do not trust them."
        Info "Undo everything since the last commit with:  git checkout -- ."
        Info "Then investigate before re-running."
        exit 4
    }
    Ok "All 9 files verified."

    # ------------------------------------------------------------ commit ------
    if (-not $Commit) {
        Head "Staged, not committed"
        Info "Review the diff, then commit yourself:"
        Info "    git diff --cached"
        Info "    git commit -m `"...`"  ;  git push"
        exit 0
    }

    $msg = "051 Tier 3 reconciliation batch: correct 5 false-Verified docs (001/021/023/024/029), " +
           "rebuild CM index (next=CM-0034), populate 020, fix Build-Order + Book 1 README. " +
           "R1 count-checks clear; device-gated items flagged not resolved."
    Push-Location $Repo
    try {
        git commit -m $msg | Out-Null
        Ok "Committed."
        Write-Host "      $msg" -ForegroundColor DarkGray
        if ($Push) {
            git push
            Ok "Pushed."
        } else {
            Head "Not pushed"
            Info "Push when ready:  git push"
        }
    } finally { Pop-Location }

} finally {
    Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
}
