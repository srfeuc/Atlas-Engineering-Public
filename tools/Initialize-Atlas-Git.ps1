[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git is not installed or is not available in PATH.'
}

if (-not (Test-Path '.git')) {
    git init
    git branch -M main
}

git add .
$hasCommit = git rev-parse --verify HEAD 2>$null
if (-not $hasCommit) {
    git commit -m 'Initialize Atlas engineering repository'
} else {
    Write-Host 'Git repository already initialized. Files were staged; review with git status.'
}

Write-Host "Atlas repository ready: $RepoRoot"
git status --short
