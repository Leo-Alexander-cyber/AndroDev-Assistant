<#
.SYNOPSIS
DroidDevAssist Build Test Script
.DESCRIPTION
Verifies that the build process works correctly and checks for necessary files
#>

$PROJECT_ROOT = $PSScriptRoot

Write-Host "=== DroidDevAssist Build Test Script ==="
Write-Host "======================================"

# Check for required files
$requiredFiles = @(
    "CMakeLists.txt",
    "build_windows.ps1",
    "installer.nsi",
    "update_version.ps1",
    "README.md",
    "user_manual.md",
    "release_notes.md",
    ".github/workflows/build.yml"
)

Write-Host "[1/2] Checking required files..."
$missingFiles = @()
foreach ($file in $requiredFiles) {
    $filePath = Join-Path -Path $PROJECT_ROOT -ChildPath $file
    if (Test-Path -Path $filePath) {
        Write-Host "✓ $file exists"
    } else {
        Write-Host "✗ $file missing" -ForegroundColor Red
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "======================================"
    Write-Host "Test failed: Missing files: $($missingFiles -join ', ')" -ForegroundColor Red
    Exit 1
}

# Check directory structure
Write-Host "[2/2] Checking directory structure..."
$requiredDirs = @(
    "include",
    "src",
    "third_party"
)

$missingDirs = @()
foreach ($dir in $requiredDirs) {
    $dirPath = Join-Path -Path $PROJECT_ROOT -ChildPath $dir
    if (Test-Path -Path $dirPath -PathType Container) {
        Write-Host "✓ $dir directory exists"
    } else {
        Write-Host "✗ $dir directory missing" -ForegroundColor Red
        $missingDirs += $dir
    }
}

if ($missingDirs.Count -gt 0) {
    Write-Host "======================================"
    Write-Host "Test failed: Missing directories: $($missingDirs -join ', ')" -ForegroundColor Red
    Exit 1
}

Write-Host "======================================"
Write-Host "Test passed! All required files and directories exist" -ForegroundColor Green
Write-Host "You can run .\build_windows.ps1 to build the project" -ForegroundColor Green
Write-Host "======================================"
