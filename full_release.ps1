<#
.SYNOPSIS
DroidDevAssist 完整发布脚本
.DESCRIPTION
用于自动化执行完整的发布流程
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$NewVersion,
    
    [Parameter(Mandatory=$false)]
    [string]$QtPath,
    
    [Parameter(Mandatory=$false)]
    [int]$ParallelJobs = 4,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipTests
)

$ErrorActionPreference = "Stop"

Write-Host "=== DroidDevAssist 完整发布脚本 ==="
Write-Host "新版本: $NewVersion"
Write-Host "======================================"

# 1. 运行发布前检查
if (-not $SkipTests) {
    Write-Host "\n1. 运行发布前检查..."
    & "$PSScriptRoot\release_precheck.ps1"
    if ($LASTEXITCODE -ne 0) {
        exit 1
    }
}

# 2. 更新版本号
Write-Host "\n2. 更新版本号..."
& "$PSScriptRoot\update_version.ps1" -NewVersion $NewVersion

# 3. 构建发布版本
Write-Host "\n3. 构建发布版本..."
$buildArgs = @(
    "-BuildType", "Release",
    "-ParallelJobs", $ParallelJobs
)

if (-not [string]::IsNullOrEmpty($QtPath)) {
    $buildArgs += "-QtPath", $QtPath
}

& "$PSScriptRoot\build_windows.ps1" @buildArgs
if ($LASTEXITCODE -ne 0) {
    exit 1
}

# 4. 验证构建产物
Write-Host "\n4. 验证构建产物..."
$outputDir = "$PSScriptRoot\output\DroidDevAssist-$NewVersion"
$installerFile = "$PSScriptRoot\DroidDevAssist-Setup-$NewVersion.exe"

if (Test-Path -Path "$outputDir\DroidDevAssist.exe") {
    Write-Host "✓ 主程序文件存在" -ForegroundColor Green
} else {
    Write-Host "✗ 主程序文件不存在: $outputDir\DroidDevAssist.exe" -ForegroundColor Red
    exit 1
}

if (Test-Path -Path $installerFile) {
    Write-Host "✓ 安装程序文件存在" -ForegroundColor Green
} else {
    Write-Host "✗ 安装程序文件不存在: $installerFile" -ForegroundColor Red
    exit 1
}

# 5. 发布完成
Write-Host "\n======================================"
Write-Host "✓ 发布流程完成！" -ForegroundColor Green
Write-Host "发布版本: $NewVersion" -ForegroundColor Green
Write-Host "构建产物目录: $outputDir" -ForegroundColor Green
Write-Host "安装程序: $installerFile" -ForegroundColor Green
Write-Host "\n下一步: 发布到 GitHub Releases" -ForegroundColor Cyan
Write-Host "======================================"