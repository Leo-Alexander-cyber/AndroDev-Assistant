<#
.SYNOPSIS
DroidDevAssist Pre-Release Check Script
.DESCRIPTION
Automatically checks all necessary steps before release
#>

$ErrorActionPreference = "Stop"

Write-Host "=== DroidDevAssist Pre-Release Check Script ==="
Write-Host "======================================"

# Check Git status (optional)
Write-Host "\n1. Checking Git status..."
if (Get-Command "git" -ErrorAction SilentlyContinue) {
    $gitStatus = git status --porcelain
    if ($gitStatus) {
        Write-Host "✗ There are uncommitted changes, please commit or stash all changes first" -ForegroundColor Red
        git status
        exit 1
    } else {
        Write-Host "✓ Git workspace is clean" -ForegroundColor Green
    }
} else {
    Write-Host "⚠ Git not found, skipping Git status check" -ForegroundColor Yellow
}

# Check version number
Write-Host "\n2. Checking version number..."
# Function to get current version
function Get-CurrentVersion {
    try {
        $content = Get-Content "$PSScriptRoot\CMakeLists.txt" -Raw
        $content -match 'project\(DroidDevAssist VERSION ([\d.\-+a-zA-Z]+) LANGUAGES CXX\)'
        return $matches[1]
    } catch {
        Write-Host "Failed to get current version from CMakeLists.txt: $_" -ForegroundColor Red
        exit 1
    }
}

$currentVersion = Get-CurrentVersion
if ($currentVersion -match '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(.*)$') {
    Write-Host "✓ Version format is correct: $currentVersion" -ForegroundColor Green
} else {
    Write-Host "✗ Version format is incorrect: $currentVersion" -ForegroundColor Red
    exit 1
}

# Check build script
Write-Host "\n3. Running build test..."
& "$PSScriptRoot\test_build.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Build test failed" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✓ Build test passed" -ForegroundColor Green
}

# Check documentation updates
Write-Host "\n4. Checking documentation updates..."
$releaseNotes = Get-Content "$PSScriptRoot\release_notes.md" -Raw
if ($releaseNotes -notlike "*## Version $currentVersion*") {
    Write-Host "✗ Release notes for current version not found in release_notes.md" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✓ release_notes.md is updated" -ForegroundColor Green
}

Write-Host "\n======================================"
Write-Host "✓ All pre-release checks passed!" -ForegroundColor Green
Write-Host "You can proceed with the release process" -ForegroundColor Green
Write-Host "======================================"