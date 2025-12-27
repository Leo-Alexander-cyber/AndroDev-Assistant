<#
.SYNOPSIS
ADB Wireless Manager Windows Build Script
.DESCRIPTION
Builds the ADB Wireless Manager for Windows platform
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Debug", "Release", "RelWithDebInfo", "MinSizeRel")]
    [string]$BuildType = "Release",
    
    [Parameter(Mandatory=$false)]
    [string]$QtPath,
    
    [Parameter(Mandatory=$false)]
    [int]$ParallelJobs = 4,
    
    [Parameter(Mandatory=$false)]
    [string]$InstallDir = "$PSScriptRoot\install",
    
    [Parameter(Mandatory=$false)]
    [string]$Generator = "Ninja",
    
    [Parameter(Mandatory=$false)]
    [switch]$CleanBuild,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipInstall
)

$ErrorActionPreference = "Stop"

Write-Host "=== ADB Wireless Manager Windows Build Script ==="
Write-Host "Build Type: $BuildType"
if ($QtPath) {
    Write-Host "Qt Path: $QtPath"
} else {
    Write-Host "Qt Path: Auto-detected"
}
Write-Host "Parallel Jobs: $ParallelJobs"
Write-Host "Install Directory: $InstallDir"
Write-Host "======================================="

# Set project root
$PROJECT_ROOT = $PSScriptRoot
$BUILD_DIR = Join-Path -Path $PROJECT_ROOT -ChildPath "build\$BuildType"

# Clean build if requested
if ($CleanBuild -and (Test-Path -Path $BUILD_DIR)) {
    Write-Host "Cleaning build directory..."
    Remove-Item -Path $BUILD_DIR -Recurse -Force
}

# Create build directory
if (-not (Test-Path -Path $BUILD_DIR)) {
    Write-Host "Creating build directory: $BUILD_DIR"
    New-Item -Path $BUILD_DIR -ItemType Directory -Force | Out-Null
}

# Configure CMake
Write-Host "Configuring CMake..."
$cmakeArgs = @(
    "-S", $PROJECT_ROOT,
    "-B", $BUILD_DIR,
    "-G", "$Generator",
    "-DCMAKE_BUILD_TYPE=$BuildType",
    "-DCMAKE_INSTALL_PREFIX=$InstallDir",
    "-DCMAKE_PREFIX_PATH=$QtPath"
)

if ($QtPath) {
    Write-Host "Using Qt from: $QtPath"
    $env:PATH = "$QtPath\bin;$env:PATH"
}

& cmake @cmakeArgs
if ($LASTEXITCODE -ne 0) {
    Write-Host "CMake configuration failed!" -ForegroundColor Red
    Exit 1
}

# Build the project
Write-Host "Building the project..."
$buildArgs = @(
    "--build", $BUILD_DIR,
    "--config", $BuildType,
    "--parallel", $ParallelJobs
)

& cmake @buildArgs
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    Exit 1
}

# Install the project if requested
if (-not $SkipInstall) {
    Write-Host "Installing the project..."
    $installArgs = @(
        "--install", $BUILD_DIR,
        "--config", $BuildType
    )
    
    & cmake @installArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Installation failed!" -ForegroundColor Red
        Exit 1
    }
    
    Write-Host "Installation completed successfully!" -ForegroundColor Green
    Write-Host "Installed to: $InstallDir" -ForegroundColor Green
}

Write-Host "======================================="
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host "Build directory: $BUILD_DIR" -ForegroundColor Green
if (-not $SkipInstall) {
    Write-Host "Install directory: $InstallDir" -ForegroundColor Green
}
Write-Host "======================================="
