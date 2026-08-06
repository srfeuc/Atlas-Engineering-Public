#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Guarded wrapper that seals the golden image: runs the readiness check, then (only
    with -Execute) runs 'sysprep /generalize /oobe /shutdown'.

.DESCRIPTION
    This is DESTRUCTIVE and FINAL: generalize strips the machine SID and device state,
    OOBE re-arms first-boot setup, and the VM powers off. After this you must NOT boot
    the source VM again — in Proxmox, right-click -> Convert to template, then clone.

    Safety design:
      * DRY-RUN by default. It prints exactly what it would run and stops.
      * It calls Test-SysprepReadiness.ps1 (must be in the same folder) first and ABORTS
        on NO-GO unless you pass -Force.
      * It only actually seals when you pass -Execute.

.PARAMETER Execute
    Actually run sysprep. Without this, the script only shows what it would do (dry run).

.PARAMETER ModeVM
    Add '/mode:vm' — skips hardware re-detection on first boot. Valid because the template
    and its clones live on the same PVE01 hypervisor; makes a Proxmox template first-boot
    faster. Recommended for this lab.

.PARAMETER UnattendPath
    Optional path to an unattend.xml (e.g. one with CopyProfile=true). Leave unset for a
    plain generalize. If set, the file must exist.

.PARAMETER Force
    Proceed even if the readiness check returns NO-GO. Use only if you have manually
    confirmed the flagged item is a false positive.

.EXAMPLE
    .\Invoke-SysprepGeneralize.ps1
        Dry run — shows the command and the readiness result, changes nothing.

.EXAMPLE
    .\Invoke-SysprepGeneralize.ps1 -Execute -ModeVM
        Runs the check, then seals the image (OOBE + Generalize + Shutdown, /mode:vm).

.NOTES
    Atlas Lab-02 · Devices/PAW01-Tier0-Admin · pairs with Build-Guide.md Part 1e.
    If sealing ever fails, read C:\Windows\System32\Sysprep\Panther\setupact.log.
#>
[CmdletBinding()]
param(
    [switch] $Execute,
    [switch] $ModeVM,
    [string] $UnattendPath,
    [switch] $Force
)

$sysprepExe = Join-Path $env:windir 'System32\Sysprep\sysprep.exe'
if (-not (Test-Path $sysprepExe)) { Write-Host "sysprep.exe not found at $sysprepExe" -ForegroundColor Red; exit 2 }

# Build the argument list
$argList = @('/generalize','/oobe','/shutdown','/quiet')
if ($ModeVM) { $argList += '/mode:vm' }
if ($UnattendPath) {
    if (-not (Test-Path $UnattendPath)) { Write-Host "Unattend file not found: $UnattendPath" -ForegroundColor Red; exit 2 }
    $argList += "/unattend:$UnattendPath"
}
$cmd = "$sysprepExe $($argList -join ' ')"

Write-Host "`n=== Seal the golden image ===" -ForegroundColor Cyan
Write-Host "Command that will run:" -ForegroundColor White
Write-Host "  $cmd`n" -ForegroundColor Yellow

# 1. Readiness check (must be alongside this script)
$check = Join-Path $PSScriptRoot 'Test-SysprepReadiness.ps1'
if (Test-Path $check) {
    Write-Host "Running readiness check..." -ForegroundColor DarkGray
    & $check
    $ready = ($LASTEXITCODE -eq 0)
} else {
    Write-Host "  [WARN] Test-SysprepReadiness.ps1 not found next to this script — skipping the automated check." -ForegroundColor Yellow
    $ready = $true
}

if (-not $ready -and -not $Force) {
    Write-Host "`nNO-GO from the readiness check. Fix the FAIL item(s), or re-run with -Force if you've verified it's a false positive." -ForegroundColor Red
    exit 1
}

# 2. Execute or dry-run
if (-not $Execute) {
    Write-Host "`nDRY RUN — nothing changed. Re-run with -Execute to actually seal the image." -ForegroundColor Green
    Write-Host "Reminder: after it powers off, do NOT boot this VM again — Convert to template in Proxmox, then clone." -ForegroundColor White
    exit 0
}

Write-Host "`n*** SEALING NOW — the VM will generalize and power off. Do not boot it again; convert it to a template. ***" -ForegroundColor Magenta
Start-Sleep -Seconds 3
& $sysprepExe $argList
