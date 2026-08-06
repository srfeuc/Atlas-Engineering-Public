#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Non-destructive pre-flight check that a Windows 11 image is safe to seal with
    'sysprep /generalize'. Prints a clear GO / NO-GO and sets an exit code.

.DESCRIPTION
    Run this in Audit Mode right before you seal the golden image. It only READS state
    (changes nothing) and checks the things that actually break generalize or produce a
    dirty clone:
      * BitLocker must be decrypted/off (Win11 24H2+ conflicts with generalize on an
        encrypted volume).
      * No pending reboot (CBS / Windows Update / PendingFileRenameOperations).
      * You appear to be the built-in Administrator (Audit-Mode heuristic).
      * Appx packages installed for a user but NOT provisioned for all users — the
        classic "...installed for a user, but not provisioned for all users" generalize
        failure. Reported as advisory (the setupact.log is the real source of truth).
      * Enough free disk to convert/clone.

.OUTPUTS
    Exit code 0 = GO (all hard checks passed), 1 = NO-GO (a hard check failed).
    Advisory findings (appx, disk) warn but do not by themselves force NO-GO.

.NOTES
    Atlas Lab-02 · Devices/PAW01-Tier0-Admin · pairs with Build-Guide.md Part 1d.
    POL-0001: this is an aid, not a guarantee — if generalize ever fails, read
    C:\Windows\System32\Sysprep\Panther\setupact.log for the real cause.
#>
[CmdletBinding()]
param(
    [int] $MinFreeGB = 15
)

$hardFail = $false
function Pass { param($m) Write-Host "  [ PASS ] $m" -ForegroundColor Green }
function Fail { param($m) Write-Host "  [ FAIL ] $m" -ForegroundColor Red;    $script:hardFail = $true }
function Note { param($m) Write-Host "  [ NOTE ] $m" -ForegroundColor Yellow }

Write-Host "`nSysprep readiness check  —  $((Get-Date).ToString('u'))`n" -ForegroundColor White

# 1. BitLocker ---------------------------------------------------------------
Write-Host "1) BitLocker" -ForegroundColor Cyan
try {
    $bl = Get-BitLockerVolume -MountPoint 'C:' -ErrorAction Stop
    if ($bl.VolumeStatus -eq 'FullyDecrypted' -or $bl.ProtectionStatus -eq 'Off') {
        Pass "C: is not encrypted (VolumeStatus=$($bl.VolumeStatus), Protection=$($bl.ProtectionStatus))."
    } else {
        Fail "C: BitLocker is $($bl.VolumeStatus)/$($bl.ProtectionStatus). Decrypt or suspend before generalize (24H2+ conflict).  Fix: manage-bde -off C:"
    }
} catch {
    Note "Get-BitLockerVolume unavailable (edition without BitLocker, or cmdlet missing). Confirm manually: manage-bde -status C:"
}

# 2. Pending reboot ----------------------------------------------------------
Write-Host "2) Pending reboot" -ForegroundColor Cyan
$pending = @()
if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending') { $pending += 'CBS (servicing)' }
if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired') { $pending += 'Windows Update' }
try {
    $pfr = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue).PendingFileRenameOperations
    if ($pfr) { $pending += 'PendingFileRenameOperations' }
} catch {}
if ($pending.Count -eq 0) { Pass "No pending reboot." }
else { Fail "Pending reboot: $($pending -join ', ').  Reboot (you stay in Audit Mode) and re-run before sealing." }

# 3. Audit-Mode heuristic ----------------------------------------------------
Write-Host "3) Audit Mode / identity" -ForegroundColor Cyan
try {
    $meSid = ([Security.Principal.WindowsIdentity]::GetCurrent()).User.Value
    if ($meSid -like '*-500') { Pass "Running as the built-in Administrator (RID 500) — consistent with Audit Mode." }
    else { Note "Not the built-in Administrator (SID $meSid). Audit Mode logs on as the built-in Administrator — confirm you're in Audit Mode." }
} catch { Note "Could not resolve current SID." }

# 4. Risky appx (installed-for-a-user, not-provisioned) ----------------------
Write-Host "4) Store apps that can block generalize" -ForegroundColor Cyan
try {
    $prov = (Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DisplayName -ErrorAction SilentlyContinue)
    $risky = Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue |
             Where-Object { $_.NonRemovable -ne $true -and $prov -notcontains $_.Name } |
             Select-Object -ExpandProperty Name -Unique
    if (-not $risky -or $risky.Count -eq 0) { Pass "No obvious installed-but-unprovisioned appx detected." }
    else {
        Note "Installed-but-not-provisioned appx (may or may not block generalize) — advisory only:"
        $risky | ForEach-Object { Write-Host "           - $_" -ForegroundColor DarkYellow }
        Note "Do NOT bulk-remove in Audit Mode (that can itself break sysprep). If generalize fails on one of these, remove that single package for the offending user and retry."
    }
} catch { Note "Appx enumeration failed: $($_.Exception.Message)" }

# 5. Free disk ---------------------------------------------------------------
Write-Host "5) Free disk" -ForegroundColor Cyan
try {
    $free = [math]::Round((Get-PSDrive C).Free/1GB,1)
    if ($free -ge $MinFreeGB) { Pass "$free GB free on C: (>= $MinFreeGB GB)." }
    else { Note "$free GB free on C: (< $MinFreeGB GB). Fine for sysprep, but tight for cloning; consider more cleanup or a bigger template disk." }
} catch { Note "Could not read free space." }

# Verdict --------------------------------------------------------------------
Write-Host ""
if ($hardFail) {
    Write-Host "RESULT: NO-GO  — fix the [FAIL] item(s) above before sealing." -ForegroundColor Red
    exit 1
} else {
    Write-Host "RESULT: GO  — hard checks passed. Review any [NOTE] items, then seal." -ForegroundColor Green
    exit 0
}
