<#
.SYNOPSIS
    Places incoming Atlas documentation files into the correct repository paths.

.DESCRIPTION
    Replaces the `Expand-Archive -Force` pattern, which silently overwrote files,
    relied on a hand-maintained map that went stale, and quarantined unmatched
    files into _unmapped_review/ where they were forgotten.

    Three principles:

      1. THE MAP IS LEARNED, NOT MAINTAINED.
         Destinations are derived by scanning the repo. Every file already in the
         repo tells you where its kind of file belongs. A derived map cannot drift
         from the thing it describes.

      2. IT REFUSES TO GUESS.
         If placement is ambiguous, the script FAILS and tells you why. It does not
         quarantine. A quarantine directory is a failure that looks like a success.

      3. IT NEVER DESTROYS.
         Any overwrite is backed up first and logged. Dry run is the default.

.PARAMETER Source
    A .zip file or a folder containing the incoming documents.

.PARAMETER Apply
    Actually write. Without this, the script reports what it WOULD do and exits.
    There is no -DryRun switch: dry run IS the default.

.PARAMETER Commit
    After a successful -Apply, stage and commit. Implies -Apply.

.PARAMETER AllowDirty
    Proceed even if the working tree has uncommitted changes. Off by default.

.EXAMPLE
    .\Place-AtlasFiles.ps1 -Source ~\Downloads\batch.zip
    # Dry run. Writes nothing.

.EXAMPLE
    .\Place-AtlasFiles.ps1 -Source ~\Downloads\batch.zip -Apply

.NOTES
    v2 (2026-07-13) -- numeric inference is now BOOK-AWARE.

    v1 treated document numbers as one flat sequence across the whole repo. Once
    Book 3 adopted 301+, nothing existed between 048 and 301, so:

      * a new 049- was REFUSED  (its upper neighbour, 301, lives in Book 3)
      * a new 401- would have been FILED INTO BOOK 3 -- silently -- because 302
        was its nearest lower number and no rule said books were different things

    The refusal was loud. The misfiling would not have been. See CM-0010 and the
    2026-07-13 session handoff.

    Sanity-check any edit to this file before running it:

        [void][ScriptBlock]::Create((Get-Content .\Place-AtlasFiles.ps1 -Raw))

    Silence means it parses. An error names the line.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $Source,

    [string] $Repo,

    [switch] $Apply,
    [switch] $Commit,
    [switch] $AllowDirty
)

$ErrorActionPreference = 'Stop'
if ($Commit) { $Apply = $true }

# ---------------------------------------------------------------- settings ----

# Directories that must NEVER teach the map.
#
# Backups and quarantines contain COPIES of real files. If they leak into the map,
# the tool will try to place new work INTO a backup -- destroying the very safety
# net it just created -- and numeric neighbours will appear to contradict each
# other. Found the hard way, 2026-07-13.
$ExcludeDirs = @(
    '\\\.git\\'
    '\\99-Archive\\'
    '\\90-Source-Evidence\\'
    '\\_unmapped_review\\'
)

# Files that legitimately exist once per directory. One README per pack is correct
# design, not a violation of 'one authoritative home'.
$PerDirectory = @('README.md', 'PACK-MANIFEST.md')

# ---------------------------------------------------------------- helpers ----

function Write-Head ($t) { Write-Host ""; Write-Host $t -ForegroundColor Cyan; Write-Host ('-' * $t.Length) -ForegroundColor DarkCyan }
function Write-Ok   ($t) { Write-Host "  [ ok ] $t" -ForegroundColor Green }
function Write-New  ($t) { Write-Host "  [ new] $t" -ForegroundColor Green }
function Write-Chg  ($t) { Write-Host "  [chg ] $t" -ForegroundColor Yellow }
function Write-Same ($t) { Write-Host "  [same] $t" -ForegroundColor DarkGray }
function Write-Warn ($t) { Write-Host "  [warn] $t" -ForegroundColor Yellow }
function Write-Bad  ($t) { Write-Host "  [FAIL] $t" -ForegroundColor Red }

function Get-FileHashStr ($path) {
    if (-not (Test-Path -LiteralPath $path)) { return $null }
    (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
}

function Test-Excluded ($fullPath) {
    foreach ($pattern in $ExcludeDirs) {
        if ($fullPath -match $pattern) { return $true }
    }
    return $false
}

# Book N numbers its documents in the N-hundreds. Book 3 = 301+, Book 4 = 401+.
# Book 1 is legacy and uses 001-099, which floors to 0.
function Get-Book ($n) { [math]::Floor([int]$n / 100) }

# --------------------------------------------------------------- find repo ----

if (-not $Repo) {
    $d = (Get-Location).Path
    while ($d -and -not (Test-Path (Join-Path $d '.git'))) {
        $d = Split-Path $d -Parent
    }
    if (-not $d) { throw "No git repository found. Pass -Repo explicitly." }
    $Repo = $d
}
$Repo = (Resolve-Path $Repo).Path
Write-Head "Repository"
Write-Host "  $Repo"

# --------------------------------------------------------- git cleanliness ----

Push-Location $Repo
try {
    $dirty = @(git status --porcelain 2>$null)
} finally {
    Pop-Location
}

if ($dirty.Count -gt 0) {
    Write-Head "Working tree is not clean"
    $dirty | Select-Object -First 15 | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkYellow }
    if ($dirty.Count -gt 15) { Write-Host "  ... and $($dirty.Count - 15) more" -ForegroundColor DarkYellow }
    Write-Host ""
    if (-not $AllowDirty) {
        Write-Bad "Refusing to place files onto an uncommitted tree."
        Write-Host ""
        Write-Host "  If this script writes now, you will not be able to tell what it changed" -ForegroundColor Gray
        Write-Host "  from what you already had. Commit or stash first, or pass -AllowDirty." -ForegroundColor Gray
        exit 1
    }
    Write-Host "  -AllowDirty set. Continuing." -ForegroundColor DarkYellow
}

# ----------------------------------------------------------- stage source ----

$stage = Join-Path ([IO.Path]::GetTempPath()) ("atlas-place-" + [guid]::NewGuid().ToString('N').Substring(0,8))
New-Item -ItemType Directory -Path $stage | Out-Null

try {
    if ($Source -match '\.zip$') {
        Expand-Archive -LiteralPath $Source -DestinationPath $stage -Force
    } else {
        Copy-Item -LiteralPath $Source -Destination $stage -Recurse -Force
    }

    $incoming = Get-ChildItem -Path $stage -Recurse -File |
        Where-Object { $_.FullName -notmatch '__MACOSX' -and $_.Name -ne '.DS_Store' }

    if (-not $incoming) { throw "No files found in $Source" }

    # ------------------------------------------------------- learn the map ----

    $repoFiles = Get-ChildItem -Path $Repo -Recurse -File -Filter *.md |
        Where-Object { -not (Test-Excluded $_.FullName) }

    $byName = @{}
    $dupes  = @{}
    foreach ($f in $repoFiles) {
        if ($PerDirectory -contains $f.Name) { continue }
        if ($byName.ContainsKey($f.Name)) {
            if (-not $dupes.ContainsKey($f.Name)) { $dupes[$f.Name] = @($byName[$f.Name]) }
            $dupes[$f.Name] += $f.FullName
        } else {
            $byName[$f.Name] = $f.FullName
        }
    }

    if ($dupes.Count -gt 0) {
        Write-Head "Duplicate filenames already in the repo"
        Write-Host "  These have more than one home. That breaks 'one authoritative home'." -ForegroundColor Yellow
        foreach ($k in $dupes.Keys) {
            Write-Host "  $k" -ForegroundColor Yellow
            foreach ($p in $dupes[$k]) { Write-Host "      $($p.Replace($Repo,'.'))" -ForegroundColor DarkYellow }
        }
    }

    # ------------------------------------------------------ numbered docs ----
    #
    # Each number maps to a LIST of directories, not one.
    #
    # v1 used last-write-wins, which quietly hid a real collision: Book 1 uses
    # 001-048 and Book 2 still uses 001-014. A number owned by two books cannot
    # teach the map anything, and pretending otherwise means guessing. Collect
    # them all, then refuse to learn from any number that is not unique.

    $numDirs = @{}
    foreach ($f in $repoFiles) {
        if ($f.Name -match '^(\d{3})-') {
            $n = [int]$Matches[1]
            if (-not $numDirs.ContainsKey($n)) { $numDirs[$n] = @() }
            $dir = Split-Path $f.FullName -Parent
            if ($numDirs[$n] -notcontains $dir) { $numDirs[$n] += $dir }
        }
    }

    # A number is only usable as a landmark if every file bearing it lives in one
    # directory. Anything else is contested ground.
    $numDir     = @{}
    $contested  = @{}
    foreach ($n in $numDirs.Keys) {
        if ($numDirs[$n].Count -eq 1) { $numDir[$n] = $numDirs[$n][0] }
        else                          { $contested[$n] = $numDirs[$n] }
    }

    if ($contested.Count -gt 0) {
        Write-Head "Contested document numbers"
        Write-Host "  These numbers exist in more than one folder, so they cannot place anything." -ForegroundColor Yellow
        Write-Host "  Usually this means a book has not been renumbered into its own hundreds." -ForegroundColor DarkGray
        foreach ($n in ($contested.Keys | Sort-Object)) {
            Write-Warn ("{0:d3}" -f $n)
            foreach ($d in $contested[$n]) { Write-Host "         $($d.Replace($Repo,'.'))" -ForegroundColor DarkYellow }
        }
    }

    function Resolve-ByPrefix ($regex) {
        $hit = $repoFiles | Where-Object { $_.Name -match $regex } | Select-Object -First 1
        if ($hit) { return (Split-Path $hit.FullName -Parent) }
        return $null
    }

    # ------------------------------------------------------------- resolve ----

    $plan = @()

    foreach ($f in $incoming) {

        $name = $f.Name
        $note = @()

        # Strip browser/zip collision suffixes: Foo_1.md, Foo (1).md
        if ($name -match '^(?<base>.+?)(?:_\d+| \(\d+\))(?<ext>\.md)$') {
            $name = $Matches['base'] + $Matches['ext']
            $note += "collision suffix stripped from '$($f.Name)'"
        }

        $dest   = $null
        $reason = $null

        # 1. Exact filename already in the repo -> back where it came from.
        if ($byName.ContainsKey($name) -and -not $dupes.ContainsKey($name)) {
            $dest   = Join-Path (Split-Path $byName[$name] -Parent) $name
            $reason = "existing file"
        }

        # 2. Numbered doc -> infer from its neighbours WITHIN THE SAME BOOK.
        #
        #    A neighbour in a different book is not a neighbour. Filtering inside
        #    the Where-Object means cross-book numbers never enter the candidate
        #    list at all, so every branch below is safe by construction.
        elseif ($name -match '^(\d{3})-') {
            $n    = [int]$Matches[1]
            $book = Get-Book $n

            $lo = ($numDir.Keys |
                   Where-Object { $_ -lt $n -and (Get-Book $_) -eq $book } |
                   Sort-Object -Descending | Select-Object -First 1)

            $hi = ($numDir.Keys |
                   Where-Object { $_ -gt $n -and (Get-Book $_) -eq $book } |
                   Sort-Object | Select-Object -First 1)

            if ($contested.ContainsKey($n)) {
                $reason = "AMBIGUOUS: $('{0:d3}' -f $n) is already used by more than one book. " +
                          "Renumber before placing."
            }
            elseif ($null -ne $lo -and $null -ne $hi -and $numDir[$lo] -eq $numDir[$hi]) {
                $dest   = Join-Path $numDir[$lo] $name
                $reason = "between $('{0:d3}' -f $lo) and $('{0:d3}' -f $hi), both in the same folder"
            }
            elseif ($null -ne $lo -and $null -eq $hi) {
                $dest   = Join-Path $numDir[$lo] $name
                $reason = "extends the sequence after $('{0:d3}' -f $lo)"
            }
            elseif ($null -eq $lo -and $null -ne $hi) {
                $dest   = Join-Path $numDir[$hi] $name
                $reason = "precedes $('{0:d3}' -f $hi) in the same book"
            }
            elseif ($null -eq $lo -and $null -eq $hi) {
                $reason = "AMBIGUOUS: no other Book $book document exists. " +
                          "The first numbered file in a book must be placed by hand."
            }
            else {
                $a = $numDir[$lo].Replace($Repo, '.')
                $b = $numDir[$hi].Replace($Repo, '.')
                $reason = "AMBIGUOUS: $('{0:d3}' -f $lo) lives in $a but $('{0:d3}' -f $hi) lives in $b"
            }
        }

        # 3. Known families.
        elseif ($name -match '^ADR-\d{4}-')     { $d = Resolve-ByPrefix '^ADR-\d{4}-';     if ($d) { $dest = Join-Path $d $name; $reason = "ADR" } }
        elseif ($name -match '^(CM|MC)-\d{4}-') { $d = Resolve-ByPrefix '^(CM|MC)-\d{4}-'; if ($d) { $dest = Join-Path $d $name; $reason = "change record" } }
        elseif ($name -match '-Template\.md$')  { $d = Resolve-ByPrefix '-Template\.md$';  if ($d) { $dest = Join-Path $d $name; $reason = "template" } }

        # 4. README / PACK-MANIFEST are per-directory. The name alone can't place them.
        if (($PerDirectory -contains $name) -and -not $dest) {
            $reason = "AMBIGUOUS: '$name' exists in several packs. Place it by hand."
        }

        if (-not $dest -and -not $reason) {
            $reason = "AMBIGUOUS: no rule matches this filename, and nothing like it is in the repo."
        }

        $plan += [pscustomobject]@{
            SourcePath = $f.FullName
            Name       = $name
            Dest       = $dest
            Reason     = $reason
            Notes      = $note
        }
    }

    # -------------------------------------------------------------- report ----

    $unresolved = @($plan | Where-Object { -not $_.Dest })

    Write-Head "Placement plan  ($($plan.Count) file$(if($plan.Count -ne 1){'s'}))"

    foreach ($p in ($plan | Where-Object Dest | Sort-Object Dest)) {
        $rel = $p.Dest.Replace($Repo, '.')
        $existing = Get-FileHashStr $p.Dest
        $incomingHash = (Get-FileHash -LiteralPath $p.SourcePath -Algorithm SHA256).Hash

        if (-not $existing) {
            $p | Add-Member Action 'new' -Force
            Write-New "$rel"
        }
        elseif ($existing -eq $incomingHash) {
            $p | Add-Member Action 'same' -Force
            Write-Same "$rel  (identical, will skip)"
        }
        else {
            $p | Add-Member Action 'overwrite' -Force
            $old = (Get-Content -LiteralPath $p.Dest).Count
            $new = (Get-Content -LiteralPath $p.SourcePath).Count
            Write-Chg "$rel  (OVERWRITE: $old lines -> $new lines)"
        }
        foreach ($n in $p.Notes) { Write-Host "         note: $n" -ForegroundColor DarkYellow }
        Write-Host "         why:  $($p.Reason)" -ForegroundColor DarkGray
    }

    if ($unresolved.Count -gt 0) {
        Write-Head "Could not place $($unresolved.Count) file$(if($unresolved.Count -ne 1){'s'})"
        foreach ($p in $unresolved) {
            Write-Bad $p.Name
            Write-Host "         $($p.Reason)" -ForegroundColor DarkGray
        }
        Write-Host ""
        Write-Host "  Nothing has been written. These are NOT being quarantined." -ForegroundColor Gray
        Write-Host "  Fix the names, or place these by hand, then re-run." -ForegroundColor Gray
        exit 2
    }

    # --------------------------------------------------------------- apply ----

    if (-not $Apply) {
        Write-Head "Dry run"
        Write-Host "  Nothing written. Re-run with -Apply to place these files."
        exit 0
    }

    $stamp   = Get-Date -Format 'yyyy-MM-dd-HHmmss'
    $backup  = Join-Path $Repo "99-Archive\replaced\$stamp"
    $written = 0; $replaced = 0; $skipped = 0

    Write-Head "Applying"

    foreach ($p in ($plan | Where-Object Dest)) {
        switch ($p.Action) {
            'same' { $skipped++ }

            'overwrite' {
                $rel = $p.Dest.Substring($Repo.Length).TrimStart('\')
                $bak = Join-Path $backup $rel
                New-Item -ItemType Directory -Path (Split-Path $bak -Parent) -Force | Out-Null
                Copy-Item -LiteralPath $p.Dest -Destination $bak -Force
                Copy-Item -LiteralPath $p.SourcePath -Destination $p.Dest -Force
                Write-Chg "$rel  (previous version -> 99-Archive\replaced\$stamp)"
                $replaced++
            }

            'new' {
                New-Item -ItemType Directory -Path (Split-Path $p.Dest -Parent) -Force | Out-Null
                Copy-Item -LiteralPath $p.SourcePath -Destination $p.Dest -Force
                Write-New $p.Dest.Replace($Repo, '.')
                $written++
            }
        }
    }

    # ----------------------------------------------------------------- log ----

    $logPath = Join-Path $Repo '99-Archive\placement-log.md'
    New-Item -ItemType Directory -Path (Split-Path $logPath -Parent) -Force | Out-Null
    if (-not (Test-Path $logPath)) {
        "# Placement Log`n`nEvery file this tool has written, and what it replaced.`n" | Set-Content $logPath -Encoding utf8
    }

    $log  = @()
    $log += ""
    $log += "## $stamp"
    $log += ""
    $log += "Source: ``$Source``"
    $log += ""
    $log += "| Action | File | Backup |"
    $log += "|---|---|---|"
    foreach ($p in ($plan | Where-Object { $_.Dest -and $_.Action -ne 'same' })) {
        $rel = $p.Dest.Substring($Repo.Length).TrimStart('\')
        $b   = if ($p.Action -eq 'overwrite') { "``99-Archive/replaced/$stamp/$($rel -replace '\\','/')``" } else { '-' }
        $log += "| $($p.Action) | ``$($rel -replace '\\','/')`` | $b |"
    }
    $log -join "`n" | Add-Content $logPath -Encoding utf8

    Write-Head "Done"
    Write-Host "  $written new, $replaced replaced, $skipped unchanged"
    if ($replaced -gt 0) { Write-Host "  Replaced files backed up to 99-Archive\replaced\$stamp" -ForegroundColor DarkGray }

    # ----------------------------------------------------------- git stage ----

    Push-Location $Repo
    try {
        git add -A | Out-Null
        Write-Head "git status"
        git status --short

        if ($Commit) {
            $msg = "Docs: place $($written + $replaced) file(s) from $(Split-Path $Source -Leaf)"
            git commit -m $msg | Out-Null
            Write-Ok "Committed: $msg"
        } else {
            Write-Host ""
            Write-Host "  Staged, not committed. Review the diff, then commit:" -ForegroundColor Gray
            Write-Host "      git diff --cached" -ForegroundColor Gray
        }
    } finally {
        Pop-Location
    }

} finally {
    Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
}