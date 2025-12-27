<#
.SYNOPSIS
DroidDevAssist 版本更新脚本
.DESCRIPTION
用于更新项目中的版本号，确保所有相关文件的版本号保持一致
支持语义化版本控制和自动版本递增
.EXAMPLE
.\update_version.ps1 -NewVersion 1.0.1
.\update_version.ps1 -Increment Major
.\update_version.ps1 -Increment Minor
.\update_version.ps1 -Increment Patch
.\update_version.ps1 -NewVersion 1.0.0-beta.1
#>

[CmdletBinding(DefaultParameterSetName='NewVersion')]
param(
    [Parameter(Mandatory=$true, ParameterSetName='NewVersion')]
    [string]$NewVersion,
    
    [Parameter(Mandatory=$true, ParameterSetName='Increment')]
    [ValidateSet('Major', 'Minor', 'Patch')]
    [string]$Increment
)

# 设置错误处理
$ErrorActionPreference = "Stop"

# 项目文件路径
$PROJECT_ROOT = $PSScriptRoot
$CMAKE_LISTS = "$PROJECT_ROOT\CMakeLists.txt"
$BUILD_SCRIPT = "$PROJECT_ROOT\build_windows.ps1"
$NSIS_SCRIPT = "$PROJECT_ROOT\installer.nsi"
$RELEASE_NOTES = "$PROJECT_ROOT\release_notes.md"

# 日志函数
function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("Info", "Warning", "Error", "Success")]
        [string]$Level = "Info"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $levelColor = @{
        "Info" = "Cyan"
        "Warning" = "Yellow"
        "Error" = "Red"
        "Success" = "Green"
    }[$Level]
    
    $levelPrefix = @{
        "Info" = "[INFO]"
        "Warning" = "[WARN]"
        "Error" = "[ERROR]"
        "Success" = "[SUCCESS]"
    }[$Level]
    
    Write-Host "$timestamp $levelPrefix $Message" -ForegroundColor $levelColor
}

# 函数：验证语义化版本号
function Test-SemanticVersion {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Version
    )
    
    $semverPattern = '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$'
    return $Version -match $semverPattern
}

# 函数：获取当前版本号
function Get-CurrentVersion {
    try {
        $content = Get-Content $CMAKE_LISTS -Raw
        $content -match 'project\(DroidDevAssist VERSION ([\d.\-+a-zA-Z]+) LANGUAGES CXX\)'
        return $matches[1]
    } catch {
        Write-Log -Message "无法从 CMakeLists.txt 获取当前版本号: $_" -Level "Error"
        exit 1
    }
}

# 函数：递增版本号
function Increment-Version {
    param(
        [Parameter(Mandatory=$true)]
        [string]$CurrentVersion,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet('Major', 'Minor', 'Patch')]
        [string]$IncrementType
    )
    
    # 提取版本号组件
    if ($CurrentVersion -match '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(.*)$') {
        $major = [int]$matches[1]
        $minor = [int]$matches[2]
        $patch = [int]$matches[3]
        $preRelease = $matches[4]
        
        # 递增相应组件
        switch ($IncrementType) {
            'Major' {
                $major++
                $minor = 0
                $patch = 0
            }
            'Minor' {
                $minor++
                $patch = 0
            }
            'Patch' {
                $patch++
            }
        }
        
        # 移除预发布标签
        return "$major.$minor.$patch"
    } else {
        Write-Log -Message "无法解析当前版本号: $CurrentVersion" -Level "Error"
        exit 1
    }
}

# 函数：更新文件中的版本号
function Update-Version {
    param(
        [string]$FilePath,
        [string]$Pattern,
        [string]$Replacement
    )
    
    Write-Log -Message "更新 $FilePath 中的版本号..."
    try {
        (Get-Content $FilePath -Raw) -replace $Pattern, $Replacement | Set-Content $FilePath -NoNewline
        Write-Log -Message "成功更新 $FilePath" -Level "Success"
    } catch {
        Write-Log -Message "更新 $FilePath 时出错: $_" -Level "Error"
        return $false
    }
    
    return $true
}

Write-Log -Message "=== DroidDevAssist 版本更新脚本 ==="

# 确定新版本号
if ($PSCmdlet.ParameterSetName -eq 'Increment') {
    $currentVersion = Get-CurrentVersion
    Write-Log -Message "当前版本号: $currentVersion"
    Write-Log -Message "递增类型: $Increment"
    
    $NewVersion = Increment-Version -CurrentVersion $currentVersion -IncrementType $Increment
} else {
    # 验证新版本号
    if (-not (Test-SemanticVersion -Version $NewVersion)) {
        Write-Log -Message "版本号 $NewVersion 不符合语义化版本格式" -Level "Error"
        Write-Log -Message "请使用格式: MAJOR.MINOR.PATCH（例如: 1.0.0）" -Level "Error"
        exit 1
    }
}

Write-Log -Message "新版本号: $NewVersion"
Write-Log -Message "======================================"

# 步骤 1: 更新 CMakeLists.txt
$CMAKE_PATTERN = 'project\(DroidDevAssist VERSION [\d.\-+a-zA-Z]+ LANGUAGES CXX\)'
$CMAKE_REPLACEMENT = "project(DroidDevAssist VERSION $NewVersion LANGUAGES CXX)"
if (-not (Update-Version -FilePath $CMAKE_LISTS -Pattern $CMAKE_PATTERN -Replacement $CMAKE_REPLACEMENT)) {
    exit 1
}

# 步骤 2: 更新 build_windows.ps1
$BUILD_PATTERN = '\$ProjectVersion = "[\d.\-+a-zA-Z]+"'
$BUILD_REPLACEMENT = "\$ProjectVersion = \"$NewVersion\""
if (-not (Update-Version -FilePath $BUILD_SCRIPT -Pattern $BUILD_PATTERN -Replacement $BUILD_REPLACEMENT)) {
    exit 1
}

# 步骤 3: 更新 installer.nsi
$NSIS_PATTERN = '!define PRODUCT_VERSION "[\d.\-+a-zA-Z]+"'
$NSIS_REPLACEMENT = "!define PRODUCT_VERSION \"$NewVersion\""
if (-not (Update-Version -FilePath $NSIS_SCRIPT -Pattern $NSIS_PATTERN -Replacement $NSIS_REPLACEMENT)) {
    exit 1
}

# 步骤 4: 更新发布说明
Write-Log -Message "更新发布说明..."
$today = Get-Date -Format "yyyy-MM-dd"
try {
    $releaseContent = Get-Content $RELEASE_NOTES -Raw
    $newReleaseSection = "## Version $NewVersion ($today)\n\n### 新增功能\n\n\n### 改进功能\n\n\n### 修复问题\n\n\n"
    $updatedContent = $releaseContent -replace '^# DroidDevAssist 发布说明\n', "# DroidDevAssist 发布说明\n\n$newReleaseSection"
    Set-Content $RELEASE_NOTES -Value $updatedContent -NoNewline
    Write-Log -Message "成功更新发布说明" -Level "Success"
} catch {
    Write-Log -Message "更新发布说明时出错: $_" -Level "Warning"
}

# 步骤 5: 创建 Git 标签
Write-Log -Message "======================================"
Write-Log -Message "创建 Git 标签 v$NewVersion..."

# 检查 Git 是否已安装
if (Get-Command git -ErrorAction SilentlyContinue) {
    # 检查是否在 Git 仓库中
    if (Test-Path -Path ".git") {
        # 检查标签是否已存在
        $existingTag = git tag -l "v$NewVersion"
        if (-not [string]::IsNullOrEmpty($existingTag)) {
            Write-Log -Message "Git 标签 v$NewVersion 已存在，跳过创建" -Level "Warning"
        } else {
            git tag -a "v$NewVersion" -m "版本 $NewVersion"
            git push origin "v$NewVersion"
            Write-Log -Message "Git 标签创建成功!" -Level "Success"
        }
    } else {
        Write-Log -Message "当前目录不是 Git 仓库，跳过标签创建" -Level "Warning"
    }
} else {
    Write-Log -Message "Git 未安装，跳过标签创建" -Level "Warning"
}

Write-Log -Message "======================================"
Write-Log -Message "版本更新完成!" -Level "Success"
Write-Log -Message "已更新以下文件:" -Level "Success"
Write-Log -Message "- CMakeLists.txt" -Level "Success"
Write-Log -Message "- build_windows.ps1" -Level "Success"
Write-Log -Message "- installer.nsi" -Level "Success"
Write-Log -Message "- release_notes.md" -Level "Success"
Write-Log -Message "======================================"
