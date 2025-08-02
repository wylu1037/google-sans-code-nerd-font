# Google Sans Code Nerd Font - 环境设置脚本 (Windows PowerShell)
# 此脚本下载并设置构建环境

param(
    [switch]$Force = $false
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

# 检查命令是否存在
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# 检查并安装依赖
function Test-Dependencies {
    Write-Status "检查系统依赖..."
    
    $missingDeps = @()
    
    # 检查 Python
    if (-not (Test-Command "python") -and -not (Test-Command "python3")) {
        $missingDeps += "python"
    }
    
    # 检查 FontForge
    if (-not (Test-Command "fontforge")) {
        $missingDeps += "fontforge"
    }
    
    # 检查 Git
    if (-not (Test-Command "git")) {
        $missingDeps += "git"
    }
    
    if ($missingDeps.Count -gt 0) {
        Write-Error "缺少以下依赖: $($missingDeps -join ', ')"
        Write-Status "请安装缺少的依赖："
        Write-Status ""
        Write-Status "方法 1 - 使用 Chocolatey (推荐):"
        Write-Status "  安装 Chocolatey: https://chocolatey.org/install"
        Write-Status "  choco install fontforge python git"
        Write-Status ""
        Write-Status "方法 2 - 使用 Scoop:"
        Write-Status "  安装 Scoop: https://scoop.sh/"
        Write-Status "  scoop install fontforge python git"
        Write-Status ""
        Write-Status "方法 3 - 手动安装:"
        Write-Status "  Python: https://www.python.org/downloads/"
        Write-Status "  FontForge: https://fontforge.org/en-US/downloads/"
        Write-Status "  Git: https://git-scm.com/download/win"
        exit 1
    }
    
    Write-Success "所有系统依赖已安装"
}

# 安装 Python 依赖
function Install-PythonDeps {
    Write-Status "安装 Python 依赖..."
    
    $pythonCmd = if (Test-Command "python3") { "python3" } else { "python" }
    $pipCmd = if (Test-Command "pip3") { "pip3" } else { "pip" }
    
    if (-not (Test-Command $pipCmd)) {
        Write-Error "未找到 pip，请确保 Python 正确安装"
        exit 1
    }
    
    # 安装必要的 Python 包
    & $pipCmd install --user fonttools configparser argparse
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Python 依赖安装失败"
        exit 1
    }
    
    Write-Success "Python 依赖安装完成"
}

# 创建目录结构
function New-Directories {
    Write-Status "创建目录结构..."
    
    $dirs = @(
        "src",
        "src\glyphs",
        "patched-fonts",
        "docs\previews",
        "temp"
    )
    
    foreach ($dir in $dirs) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Status "创建目录: $dir"
        }
    }
    
    Write-Success "目录结构创建完成"
}

# 下载文件的辅助函数
function Get-FileFromUrl {
    param(
        [string]$Url,
        [string]$Path,
        [string]$Description = ""
    )
    
    try {
        if ($Description) {
            Write-Status "下载: $Description"
        }
        
        Invoke-WebRequest -Uri $Url -OutFile $Path -UseBasicParsing
        return $true
    }
    catch {
        Write-Warning "下载失败: $Description ($($_.Exception.Message))"
        if (Test-Path $Path) {
            Remove-Item $Path -Force
        }
        return $false
    }
}

# 下载 Nerd Font patcher
function Get-FontPatcher {
    Write-Status "下载 Nerd Font patcher..."
    
    $patcherUrl = "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/font-patcher"
    $patcherPath = "src\font-patcher"
    
    if (-not (Test-Path $patcherPath) -or $Force) {
        if (Get-FileFromUrl -Url $patcherUrl -Path $patcherPath -Description "Font Patcher") {
            Write-Success "Font patcher 下载完成"
        } else {
            Write-Error "Font patcher 下载失败"
            exit 1
        }
    } else {
        Write-Warning "Font patcher 已存在，跳过下载 (使用 -Force 强制重新下载)"
    }
}

# 下载字形文件
function Get-Glyphs {
    Write-Status "下载字形文件..."
    
    $glyphsDir = "src\glyphs"
    
    # 如果字形目录不为空，跳过下载
    if ((Test-Path $glyphsDir) -and (Get-ChildItem $glyphsDir).Count -gt 0 -and -not $Force) {
        Write-Warning "字形文件已存在，跳过下载 (使用 -Force 强制重新下载)"
        return
    }
    
    # 定义需要下载的字形文件
    $baseUrl = "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/src/glyphs"
    $glyphFiles = @(
        "Symbols-1000-em Nerd Font Mono.ttf",
        "Symbols-2048-em Nerd Font Mono.ttf", 
        "FontAwesome.otf",
        "FontAwesome-Solid.otf",
        "FontAwesome-Brands.otf",
        "fontawesome-extension.ttf",
        "octicons.ttf",
        "codicons.ttf",
        "PowerlineSymbols.otf",
        "PowerlineExtraSymbols.otf",
        "Pomicons.otf",
        "materialdesignicons-webfont.ttf",
        "weather-icons.ttf",
        "devicons.ttf",
        "font-logos.ttf",
        "UnicodePowerSymbols.otf"
    )
    
    Write-Status "下载字形文件到 $glyphsDir"
    
    $successCount = 0
    foreach ($file in $glyphFiles) {
        $url = "$baseUrl/$file"
        $dest = Join-Path $glyphsDir $file
        
        if (Get-FileFromUrl -Url $url -Path $dest -Description $file) {
            $successCount++
        }
    }
    
    Write-Success "字形文件下载完成 ($successCount/$($glyphFiles.Count) 成功)"
}

# 验证 Google Sans Code 字体文件
function Test-SourceFonts {
    Write-Status "验证源字体文件..."
    
    $fontDir = "Google Sans Code"
    
    if (-not (Test-Path $fontDir)) {
        Write-Error "未找到 Google Sans Code 字体目录"
        Write-Error "请确保 '$fontDir' 目录存在并包含字体文件"
        exit 1
    }
    
    # 检查是否包含字体文件
    $fontFiles = Get-ChildItem -Path $fontDir -Include "*.ttf", "*.otf" -Recurse
    
    if ($fontFiles.Count -eq 0) {
        Write-Error "在 '$fontDir' 中未找到字体文件"
        Write-Error "请确保目录包含 Google Sans Code 的 .ttf 或 .otf 文件"
        exit 1
    }
    
    Write-Success "找到 $($fontFiles.Count) 个字体文件"
    
    # 列出找到的字体文件
    Write-Status "字体文件列表:"
    $fontFiles | Sort-Object Name | ForEach-Object {
        Write-Host "  - $($_.Name)" -ForegroundColor Gray
    }
}

# 创建配置文件
function New-Config {
    Write-Status "创建配置文件..."
    
    $configFile = "src\config.json"
    
    if (-not (Test-Path $configFile) -or $Force) {
        $config = @{
            remove_ligatures = $false
            custom_icons = @()
            font_name_suffix = "Nerd Font"
            font_name_mono_suffix = "Nerd Font Mono"
            font_name_propo_suffix = "Nerd Font Propo"
            output_dir = "patched-fonts"
            temp_dir = "temp"
        } | ConvertTo-Json -Depth 3
        
        $config | Out-File -FilePath $configFile -Encoding UTF8
        Write-Success "配置文件已创建: $configFile"
    } else {
        Write-Warning "配置文件已存在，跳过创建 (使用 -Force 强制重新创建)"
    }
}

# 主函数
function Main {
    Write-Status "Google Sans Code Nerd Font 环境设置开始..."
    Write-Host ""
    
    try {
        # 检查依赖
        Test-Dependencies
        Write-Host ""
        
        # 安装 Python 依赖
        Install-PythonDeps
        Write-Host ""
        
        # 创建目录
        New-Directories
        Write-Host ""
        
        # 下载 font-patcher
        Get-FontPatcher
        Write-Host ""
        
        # 下载字形文件
        Get-Glyphs
        Write-Host ""
        
        # 验证源字体
        Test-SourceFonts
        Write-Host ""
        
        # 创建配置
        New-Config
        Write-Host ""
        
        Write-Success "环境设置完成！"
        Write-Host ""
        Write-Status "接下来可以运行构建脚本:"
        Write-Host "  .\scripts\build.ps1" -ForegroundColor Gray
        Write-Host ""
        Write-Status "或者构建特定字体:"
        Write-Host "  .\scripts\build.ps1 -Font 'GoogleSansCode-Regular.ttf'" -ForegroundColor Gray
    }
    catch {
        Write-Error "设置过程中出现错误: $($_.Exception.Message)"
        exit 1
    }
}

# 运行主函数
Main