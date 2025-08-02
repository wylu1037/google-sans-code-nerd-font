# Google Sans Code Nerd Font - 创建发布脚本 (Windows PowerShell)
# 此脚本帮助维护者创建新的 GitHub Release

param(
    [string]$Version = "",
    [switch]$DryRun = $false,
    [switch]$Help = $false
)

# 设置错误处理
$ErrorActionPreference = "Stop"

# 颜色函数
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Status {
    param([string]$Message)
    Write-ColorOutput "[INFO] $Message" "Cyan"
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "[SUCCESS] $Message" "Green"
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "[WARNING] $Message" "Yellow"
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "[ERROR] $Message" "Red"
}

# 显示帮助信息
function Show-Help {
    @"
Google Sans Code Nerd Font 发布脚本

用法: .\scripts\create-release.ps1 [参数]

参数:
  -Version VERSION    要发布的版本号 (如: v1.0.0)
  -DryRun            预览操作，不实际创建标签
  -Help              显示此帮助信息

示例:
  .\scripts\create-release.ps1 -Version v1.0.0           # 创建 v1.0.0 版本
  .\scripts\create-release.ps1 -Version v1.1.0 -DryRun  # 预览 v1.1.0 版本的创建过程

注意:
  - 版本号建议遵循语义化版本规范 (semver.org)
  - 此脚本只创建 Git 标签，GitHub Release 需要手动创建
  - 创建标签后，需要在 GitHub 网页界面创建 Release 以触发自动构建

"@
}

# 验证版本号格式
function Test-VersionFormat {
    param([string]$Version)
    
    if ($Version -notmatch '^v\d+\.\d+\.\d+(-[a-zA-Z0-9]+)?$') {
        Write-Error "版本号格式不正确"
        Write-Status "正确格式: v1.0.0 或 v1.0.0-beta"
        return $false
    }
    
    return $true
}

# 检查 Git 状态
function Test-GitStatus {
    Write-Status "检查 Git 状态..."
    
    # 检查是否在 Git 仓库中
    try {
        git rev-parse --git-dir | Out-Null
    }
    catch {
        Write-Error "当前目录不是 Git 仓库"
        return $false
    }
    
    # 检查是否有未提交的更改
    $gitStatus = git status --porcelain
    if ($gitStatus) {
        Write-Warning "有未提交的更改"
        Write-Host "未提交的文件:"
        git status --porcelain
        Write-Host ""
        $response = Read-Host "是否继续？(y/N)"
        if ($response -notmatch '^[Yy]$') {
            Write-Status "操作已取消"
            return $false
        }
    }
    
    # 检查当前分支
    $branch = git branch --show-current
    Write-Status "当前分支: $branch"
    
    if ($branch -notin @("main", "master")) {
        Write-Warning "当前不在主分支上"
        $response = Read-Host "是否继续？(y/N)"
        if ($response -notmatch '^[Yy]$') {
            Write-Status "操作已取消"
            return $false
        }
    }
    
    return $true
}

# 检查标签是否已存在
function Test-TagExists {
    param([string]$Version)
    
    $existingTags = git tag -l
    if ($existingTags -contains $Version) {
        Write-Error "标签 $Version 已存在"
        return $true
    }
    
    return $false
}

# 更新 CHANGELOG
function Update-Changelog {
    param([string]$Version)
    
    $changelogFile = "CHANGELOG.md"
    Write-Status "检查 CHANGELOG.md..."
    
    if (-not (Test-Path $changelogFile)) {
        Write-Warning "未找到 CHANGELOG.md 文件"
        return
    }
    
    # 检查是否包含新版本信息
    $content = Get-Content $changelogFile -Raw
    if ($content -match "## \[$Version\]") {
        Write-Success "CHANGELOG.md 已包含 $Version 的信息"
    } else {
        Write-Warning "CHANGELOG.md 中未找到 $Version 的信息"
        Write-Status "建议在发布前更新 CHANGELOG.md"
    }
}

# 生成发布说明模板
function New-ReleaseNotes {
    param([string]$Version)
    
    $notesFile = "release-notes-$Version.md"
    $currentDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $content = @"
## Google Sans Code Nerd Font $Version

### ✨ 新功能
- [在此描述新功能]

### 🐛 Bug 修复
- [在此描述修复的问题]

### 📦 下载说明

选择适合您需求的版本：

- **Complete**: 包含所有图标的完整版本（推荐大多数用户）
- **Mono**: 等宽图标版本（推荐终端用户）
- **Propo**: 比例宽度图标版本（推荐编辑器用户）

### 💾 安装方法

1. 下载对应的 zip 文件
2. 解压后安装 .ttf 字体文件
3. 在终端或编辑器中选择 "GoogleSansCodeNerdFont" 字体系列

### 🔧 支持的字重

- Regular / Italic
- Light / Light Italic
- Medium / Medium Italic
- SemiBold / SemiBold Italic
- Bold / Bold Italic
- ExtraBold / ExtraBold Italic

### 🎯 包含的图标集

- Font Awesome (5000+ 图标)
- Material Design Icons (7000+ 图标)
- Octicons (GitHub 图标)
- Powerline Symbols
- Devicons (开发者图标)
- Weather Icons
- Codicons (VS Code 图标)
- 以及更多...

---

构建时间: $currentDate
"@

    $content | Out-File -FilePath $notesFile -Encoding UTF8
    
    Write-Success "已生成发布说明模板: $notesFile"
    Write-Status "请编辑此文件后在 GitHub 创建 Release 时使用"
}

# 创建标签
function New-Tag {
    param(
        [string]$Version,
        [bool]$DryRun
    )
    
    if ($DryRun) {
        Write-Status "预览模式 - 将创建标签: $Version"
        return
    }
    
    Write-Status "创建标签: $Version"
    
    try {
        # 创建带注释的标签
        git tag -a $Version -m "Release $Version"
        
        Write-Status "推送标签到远程仓库..."
        git push origin $Version
        
        Write-Success "标签 $Version 已创建并推送"
    }
    catch {
        Write-Error "创建标签失败: $($_.Exception.Message)"
        throw
    }
}

# 显示后续步骤
function Show-NextSteps {
    param([string]$Version)
    
    $notesFile = "release-notes-$Version.md"
    
    Write-Success "标签创建完成！"
    Write-Host ""
    Write-Status "下一步操作："
    Write-Host "1. 访问 GitHub 仓库页面" -ForegroundColor Gray
    Write-Host "2. 点击 'Releases' → 'Create a new release'" -ForegroundColor Gray
    Write-Host "3. 选择标签: $Version" -ForegroundColor Gray
    Write-Host "4. 填写发布标题: Google Sans Code Nerd Font $Version" -ForegroundColor Gray
    Write-Host "5. 复制 $notesFile 的内容作为发布说明" -ForegroundColor Gray
    Write-Host "6. 点击 'Publish release'" -ForegroundColor Gray
    Write-Host "7. 等待 GitHub Actions 自动构建和上传字体文件" -ForegroundColor Gray
    Write-Host ""
    Write-Status "GitHub Actions 构建完成后，用户就可以下载字体了！"
}

# 主函数
function Main {
    # 显示帮助
    if ($Help) {
        Show-Help
        exit 0
    }
    
    # 检查版本号
    if (-not $Version) {
        Write-Error "请提供版本号"
        Write-Host "使用方法: .\scripts\create-release.ps1 -Version v1.0.0" -ForegroundColor Gray
        Write-Host "使用 -Help 查看帮助信息" -ForegroundColor Gray
        exit 1
    }
    
    Write-Status "准备创建 Google Sans Code Nerd Font $Version 发布..."
    Write-Host ""
    
    try {
        # 验证版本号
        if (-not (Test-VersionFormat -Version $Version)) {
            exit 1
        }
        
        # 检查 Git 状态
        if (-not (Test-GitStatus)) {
            exit 1
        }
        
        # 检查标签是否已存在
        if (Test-TagExists -Version $Version) {
            exit 1
        }
        
        # 更新 CHANGELOG
        Update-Changelog -Version $Version
        Write-Host ""
        
        # 生成发布说明
        New-ReleaseNotes -Version $Version
        Write-Host ""
        
        # 创建标签
        New-Tag -Version $Version -DryRun $DryRun
        Write-Host ""
        
        # 显示后续步骤
        if (-not $DryRun) {
            Show-NextSteps -Version $Version
        } else {
            Write-Status "预览模式 - 未实际创建标签"
            Write-Status "移除 -DryRun 参数以实际执行"
        }
    }
    catch {
        Write-Error "脚本执行失败: $($_.Exception.Message)"
        exit 1
    }
}

# 运行主函数
Main