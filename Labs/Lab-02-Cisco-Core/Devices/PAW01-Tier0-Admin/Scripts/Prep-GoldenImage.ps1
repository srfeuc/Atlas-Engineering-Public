#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Cleans and finalizes a Windows 11 image in AUDIT MODE, before sysprep /generalize,
    to produce a small, clean Atlas golden image (PAW01 + future VLAN-50 clients).

.DESCRIPTION
    Run this INSIDE AUDIT MODE (logged on as the built-in Administrator with the
    System Preparation Tool dialog open), AFTER Windows Update has fully finished,
    and BEFORE you seal the image with sysprep.

    What it does:
      1. Bakes MACHINE-level settings every clone should inherit (power, hibernation,
         time zone) — generic only.
      2. Removes build cruft so clones start clean and the template is as small as
         possible: Windows Update caches, WinSxS component store (optional ResetBase),
         temp folders, all event logs, Delivery-Optimization cache, the recycle bin,
         and (optional) a volume TRIM so Proxmox can reclaim the freed blocks.

    What it deliberately does NOT do (per Build-Guide.md Part 1 — keep the image
    generic + role-neutral):
      * No sysprep (use Invoke-SysprepGeneralize.ps1 after Test-SysprepReadiness.ps1).
      * No computer name / domain join / IP / VLAN — those are per-clone.
      * No RSAT / security baseline / PAW hardening — those are PAW-only, via GPO.
      * It will NOT force-remove Store apps (that can itself break generalize). It only
        reports risky appx; see Test-SysprepReadiness.ps1.

.PARAMETER TimeZoneId
    Time zone to bake in. Default 'Central Standard Time' (Atlas = America/Chicago).

.PARAMETER SkipComponentCleanup
    Skip 'DISM /StartComponentCleanup /ResetBase'. That step compacts WinSxS after
    updates (big size win) but ResetBase means the installed updates can no longer be
    uninstalled — which is exactly what you want for a golden image, so it's ON by default.

.PARAMETER SkipTrim
    Skip 'Optimize-Volume -ReTrim' (the TRIM that lets thin-provisioned storage reclaim).

.PARAMETER DisableStoreAutoUpdate
    Set the policy that stops the Microsoft Store auto-updating appx packages. Prevents
    the classic race where a per-user Store update makes 'sysprep /generalize' fail.

.EXAMPLE
    .\Prep-GoldenImage.ps1
.EXAMPLE
    .\Prep-GoldenImage.ps1 -DisableStoreAutoUpdate -TimeZoneId 'Central Standard Time'

.NOTES
    Atlas Lab-02 · Devices/PAW01-Tier0-Admin · pairs with Build-Guide.md Part 1 (1c-1e).
    Safe to re-run. Transcript logged to C:\Windows\Temp\Prep-GoldenImage-<timestamp>.log.
    POL-0001: this is a convenience wrapper around documented steps — verify results
    (the console summary) before you seal.
#>
[CmdletBinding()]
param(
    [string] $TimeZoneId = 'Central Standard Time',
    [switch] $SkipComponentCleanup,
    [switch] $SkipTrim,
    [switch] $DisableStoreAutoUpdate
)

$ErrorActionPreference = 'Continue'
$stamp = (Get-Date).ToString('yyyyMMdd-HHmmss')
$log   = "C:\Windows\Temp\Prep-GoldenImage-$stamp.log"
try { Start-Transcript -Path $log -Force | Out-Null } catch {}

function Write-Step { param([string]$Msg) Write-Host "`n=== $Msg ===" -ForegroundColor Cyan }
function Write-Ok   { param([string]$Msg) Write-Host "  [ OK ] $Msg" -ForegroundColor Green }
function Write-Warn { param([string]$Msg) Write-Host "  [WARN] $Msg" -ForegroundColor Yellow }

Write-Host "Atlas Golden-Image Prep  —  $stamp" -ForegroundColor White
Write-Host "Log: $log`n" -ForegroundColor DarkGray

# --- Sanity: are we plausibly in Audit Mode (built-in Administrator, RID 500)? ---
Write-Step "Environment sanity check"
try {
    $meSid = ([Security.Principal.WindowsIdentity]::GetCurrent()).User.Value
    if ($meSid -like '*-500') { Write-Ok "Running as the built-in Administrator (RID 500) — consistent with Audit Mode." }
    else { Write-Warn "Not the built-in Administrator (SID $meSid). Audit Mode logs on as the built-in Administrator; confirm you're in Audit Mode before sealing." }
} catch { Write-Warn "Could not resolve current SID: $($_.Exception.Message)" }

# --- 1. Machine-level settings that every clone should inherit (generic only) ---
Write-Step "Machine settings (baked into the image)"
try { powercfg.exe /setactive SCHEME_MIN | Out-Null; Write-Ok "Power plan = High performance." } catch { Write-Warn "powercfg setactive failed: $($_.Exception.Message)" }
try { powercfg.exe /hibernate off      | Out-Null; Write-Ok "Hibernation disabled (removes hiberfil.sys)." } catch { Write-Warn "powercfg hibernate off failed: $($_.Exception.Message)" }
try { Set-TimeZone -Id $TimeZoneId; Write-Ok "Time zone = $TimeZoneId." } catch { Write-Warn "Set-TimeZone failed for '$TimeZoneId': $($_.Exception.Message)" }

if ($DisableStoreAutoUpdate) {
    try {
        $k = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore'
        if (-not (Test-Path $k)) { New-Item -Path $k -Force | Out-Null }
        New-ItemProperty -Path $k -Name 'AutoDownload' -Value 2 -PropertyType DWord -Force | Out-Null
        Write-Ok "Store auto-update disabled (policy AutoDownload=2) — prevents the generalize appx race."
    } catch { Write-Warn "Could not set Store policy: $($_.Exception.Message)" }
}

# --- 2. Windows Update / component store cleanup ---
Write-Step "Windows Update + component store cleanup"
try {
    Stop-Service -Name wuauserv,bits -Force -ErrorAction SilentlyContinue
    $sd = 'C:\Windows\SoftwareDistribution\Download'
    if (Test-Path $sd) { Get-ChildItem $sd -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue }
    Start-Service -Name wuauserv,bits -ErrorAction SilentlyContinue
    Write-Ok "Cleared SoftwareDistribution\Download."
} catch { Write-Warn "SoftwareDistribution clean failed: $($_.Exception.Message)" }

if (-not $SkipComponentCleanup) {
    Write-Host "  Running DISM component cleanup (/ResetBase) — this can take several minutes..." -ForegroundColor DarkGray
    try {
        & Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase | Out-Null
        if ($LASTEXITCODE -eq 0) { Write-Ok "WinSxS compacted (StartComponentCleanup /ResetBase)." }
        else { Write-Warn "DISM returned exit code $LASTEXITCODE (check the DISM log)." }
    } catch { Write-Warn "DISM cleanup failed: $($_.Exception.Message)" }
} else { Write-Warn "Skipped component cleanup (-SkipComponentCleanup)." }

# --- 3. Temp / logs / caches ---
Write-Step "Temp, caches, and event logs"
foreach ($p in @("$env:windir\Temp\*", "$env:TEMP\*", "C:\Windows\Prefetch\*")) {
    try { Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue } catch {}
}
Write-Ok "Cleared Windows\Temp, user TEMP, Prefetch."

try { Clear-DnsClientCache; Write-Ok "Flushed DNS client cache." } catch { Write-Warn "Clear-DnsClientCache failed: $($_.Exception.Message)" }
try { Delete-DeliveryOptimizationCache -Force -ErrorAction SilentlyContinue; Write-Ok "Cleared Delivery-Optimization cache." } catch { Write-Warn "DO cache clear skipped: $($_.Exception.Message)" }
try { Clear-RecycleBin -Force -ErrorAction SilentlyContinue; Write-Ok "Emptied the recycle bin." } catch {}

Write-Host "  Clearing all event logs (so clones don't inherit build noise)..." -ForegroundColor DarkGray
$cleared = 0; $failed = 0
foreach ($lg in (wevtutil el)) {
    try { wevtutil cl "$lg" 2>$null; $cleared++ } catch { $failed++ }
}
Write-Ok "Event logs cleared: $cleared (skipped/protected: $failed)."

# --- 4. TRIM so the hypervisor can reclaim freed space ---
if (-not $SkipTrim) {
    Write-Step "Volume TRIM (reclaim freed blocks)"
    try { Optimize-Volume -DriveLetter C -ReTrim -ErrorAction Stop; Write-Ok "Optimize-Volume ReTrim complete on C:." }
    catch { Write-Warn "ReTrim skipped/failed: $($_.Exception.Message)" }
}

# --- Summary ---
Write-Step "Done — next steps"
Write-Host @"
  Image cleaned. Before sealing:
    1) Run  .\Test-SysprepReadiness.ps1   (BitLocker off? pending reboot? risky appx?)
    2) If GO, seal with the GUI Sysprep dialog (OOBE + Generalize + Shutdown)
       or  .\Invoke-SysprepGeneralize.ps1 -Execute
    3) In Proxmox: Convert to template (do NOT boot the sealed VM again).
  Log saved: $log
"@ -ForegroundColor White

try { Stop-Transcript | Out-Null } catch {}
