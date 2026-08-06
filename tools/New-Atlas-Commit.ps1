[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Message
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

git add .
git commit -m $Message
git status --short
