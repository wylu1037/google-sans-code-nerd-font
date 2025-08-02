# Google Sans Code Nerd Font - 构建脚本 (Windows PowerShell)
# 此脚本使用 Nerd Font patcher 为 Google Sans Code 添加图标

param(
    [string]$Font = "",
    [string]$Output = "patched-fonts",
    [int]$Parallel = 0,
    [switch]$Complete = $false,
    [switch]$Mono = $false,
    [switch]$Propo = $false,
    [switch]$FontAwesome = $false,
    [switch]$FontAwesomeExt = $false,
    [switch]$Octicons = $false,
    [switch]$Codicons = $false,
    [switch]$Powerline = $false,
    [switch]$PowerlineExtra = $false,
    [switch]$Material = $false,
    [switch]$Weather = $false,
    [switch]$Devicons = $false,
    [switch]$Pomicons = $false,
    [switch]$FontLogos = $false,
    [switch]$PowerSymbols = $false,
    [switch]$Verbose = $false,
    [switch]$DryRun = $false,
    [switch]$Help = $false
)

# 设置错误处理
$ErrorActionPreference = "Stop"

# 默认配置
$script:DefaultFontDir = "Google Sans Code"
$script:DefaultOutputDir = "patched-fonts"
$script:PatcherScript = "src\font-patcher"
$script:GlyphsDir = "src\glyphs"

# 如果未指定并行数，使用CPU核心数
if ($Parallel -eq 0) {
    $Parallel = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
}

# 确定构建类型
$BuildType = "complete"
$UseComplete = $true

if ($Mono) {
    $BuildType = "mono"
} elseif ($Propo) {
    $BuildType = "propo"
} elseif ($FontAwesome -or $FontAwesomeExt -or $Octicons -or $Codicons -or 
         $Powerline -or $PowerlineExtra -or $Material -or $Weather -or 
         $Devicons -or $Pomicons -or $FontLogos -or $PowerSymbols) {
    $UseComplete = $false
}

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

function Write-Debug {
    param([string]$Message)
    if ($Verbose) {
        Write-ColorOutput "[DEBUG] $Message" "Magenta"
    }
}

# 显示帮助信息
function Show-Help {
    @"
Google Sans Code Nerd Font 构建脚本

用法: .\scripts\build.ps1 [参数]

基本参数:
  -Font FONT_NAME         指定要处理的字体文件名
  -Output DIR             指定输出目录 (默认: $DefaultOutputDir)
  -Parallel N             并行处理数量 (默认: CPU核心数)
  -Verbose                详细输出
  -DryRun                 预览要执行的操作，不实际构建
  -Help                   显示此帮助信息

构建类型:
  -Complete               构建完整版本（默认，包含所有图标）
  -Mono                   构建等宽版本 (Nerd Font Mono)
  -Propo                  构建比例版本 (Nerd Font Propo)

图标选择 (仅在未使用 -Complete 时有效):
  -FontAwesome            添加 Font Awesome 图标
  -FontAwesomeExt         添加 Font Awesome Extension 图标
  -Octicons               添加 Octicons 图标 (GitHub)
  -Codicons               添加 Codicons 图标 (VS Code)
  -Powerline              添加 Powerline 图标
  -PowerlineExtra         添加 Powerline Extra 图标
  -Material               添加 Material Design 图标
  -Weather                添加 Weather 图标
  -Devicons               添加 Devicons 图标
  -Pomicons               添加 Pomicons 图标
  -FontLogos              添加 Font Logos 图标
  -PowerSymbols           添加 IEC Power Symbols 图标

示例:
  .\scripts\build.ps1                                    # 构建所有字体的完整版本
  .\scripts\build.ps1 -Font "GoogleSansCode-Regular.ttf" # 构建特定字体
  .\scripts\build.ps1 -Mono                              # 构建所有字体的等宽版本
  .\scripts\build.ps1 -FontAwesome -Octicons             # 仅添加指定图标集
  .\scripts\build.ps1 -Parallel 8                        # 使用8个并行任务
  .\scripts\build.ps1 -DryRun                            # 预览操作而不实际执行

"@
}

# 检查依赖
function Test-Dependencies {
    Write-Status "检查依赖..."
    
    $missingDeps = @()
    
    # 检查 Python
    if (-not (Get-Command "python" -ErrorAction SilentlyContinue) -and 
        -not (Get-Command "python3" -ErrorAction SilentlyContinue)) {
        $missingDeps += "python"
    }
    
    # 检查 FontForge
    if (-not (Get-Command "fontforge" -ErrorAction SilentlyContinue)) {
        $missingDeps += "fontforge"
    }
    
    # 检查 font-patcher
    if (-not (Test-Path $PatcherScript)) {
        $missingDeps += "font-patcher"
    }
    
    # 检查字形目录
    if (-not (Test-Path $GlyphsDir) -or (Get-ChildItem $GlyphsDir).Count -eq 0) {
        $missingDeps += "glyphs"
    }
    
    if ($missingDeps.Count -gt 0) {
        Write-Error "缺少以下依赖: $($missingDeps -join ', ')"
        Write-Status "请先运行设置脚本: .\scripts\setup.ps1"
        exit 1
    }
    
    Write-Success "所有依赖检查通过"
}

# 获取要处理的字体文件列表
function Get-FontFiles {
    $fontFiles = @()
    
    if ($Font) {
        # 处理单个指定的字体文件
        $fontPath = $null
        
        if (Test-Path $Font) {
            $fontPath = $Font
        } elseif (Test-Path (Join-Path $DefaultFontDir $Font)) {
            $fontPath = Join-Path $DefaultFontDir $Font
        } elseif (Test-Path (Join-Path $DefaultFontDir "static" $Font)) {
            $fontPath = Join-Path $DefaultFontDir "static" $Font
        } else {
            Write-Error "未找到字体文件: $Font"
            exit 1
        }
        
        $fontFiles += $fontPath
    } else {
        # 处理所有字体文件
        Write-Status "搜索字体文件..."
        
        $fontFiles = Get-ChildItem -Path $DefaultFontDir -Include "*.ttf", "*.otf" -Recurse | 
                     Sort-Object Name |
                     ForEach-Object { $_.FullName }
        
        if ($fontFiles.Count -eq 0) {
            Write-Error "在 $DefaultFontDir 中未找到字体文件"
            exit 1
        }
    }
    
    Write-Success "找到 $($fontFiles.Count) 个字体文件"
    
    # 如果是详细模式，列出所有文件
    if ($Verbose) {
        Write-Debug "字体文件列表:"
        $fontFiles | ForEach-Object {
            Write-Host "  - $(Split-Path $_ -Leaf)" -ForegroundColor Gray
        }
    }
    
    return $fontFiles
}

# 构建 patcher 参数
function Build-PatcherArgs {
    $args = @()
    
    # 基本参数
    $args += "--quiet"
    $args += "--glyphdir"
    $args += $GlyphsDir
    $args += "--outputdir" 
    $args += $Output
    
    # 构建类型参数
    switch ($BuildType) {
        "mono" {
            $args += "--mono"
            $args += "--complete"
        }
        "propo" {
            $args += "--variable-width-glyphs"
            $args += "--complete"
        }
        "complete" {
            $args += "--complete"
        }
    }
    
    # 如果不是完整构建，添加指定的图标集
    if (-not $UseComplete) {
        if ($FontAwesome) { $args += "--fontawesome" }
        if ($FontAwesomeExt) { $args += "--fontawesomeextension" }
        if ($Octicons) { $args += "--octicons" }
        if ($Codicons) { $args += "--codicons" }
        if ($Powerline) { $args += "--powerline" }
        if ($PowerlineExtra) { $args += "--powerlineextra" }
        if ($Material) { $args += "--material" }
        if ($Weather) { $args += "--weather" }
        if ($Devicons) { $args += "--devicons" }
        if ($Pomicons) { $args += "--pomicons" }
        if ($FontLogos) { $args += "--fontlogos" }
        if ($PowerSymbols) { $args += "--powersymbols" }
    }
    
    return $args
}

# 处理单个字体文件
function Invoke-FontProcessing {
    param(
        [string]$FontFile
    )
    
    $fontName = Split-Path $FontFile -Leaf
    Write-Status "处理字体: $fontName"
    
    if ($DryRun) {
        Write-Debug "预览模式 - 跳过实际处理"
        return $true
    }
    
    # 构建参数
    $patcherArgs = Build-PatcherArgs
    
    # 确保输出目录存在
    if (-not (Test-Path $Output)) {
        New-Item -ItemType Directory -Path $Output -Force | Out-Null
    }
    
    Write-Debug "执行命令: fontforge -script $PatcherScript $($patcherArgs -join ' ') $FontFile"
    
    try {
        # 执行 font-patcher
        $process = Start-Process -FilePath "fontforge" -ArgumentList @("-script", $PatcherScript) + $patcherArgs + @($FontFile) -Wait -PassThru -NoNewWindow -RedirectStandardError "nul"
        
        if ($process.ExitCode -eq 0) {
            Write-Success "完成: $fontName"
            return $true
        } else {
            Write-Error "处理失败: $fontName (退出代码: $($process.ExitCode))"
            return $false
        }
    }
    catch {
        Write-Error "处理失败: $fontName ($($_.Exception.Message))"
        return $false
    }
}

# 并行处理字体文件
function Invoke-FontsProcessingParallel {
    param(
        [string[]]$FontFiles
    )
    
    $total = $FontFiles.Count
    Write-Status "开始处理 $total 个字体文件 (并行任务数: $Parallel)"
    
    if ($DryRun) {
        Write-Warning "预览模式 - 显示将要执行的操作"
        $FontFiles | ForEach-Object {
            Write-Debug "将处理: $(Split-Path $_ -Leaf)"
        }
        return $true
    }
    
    # 使用 PowerShell 作业进行并行处理
    $jobs = @()
    $successCount = 0
    $errorCount = 0
    
    try {
        # 启动并行作业
        foreach ($fontFile in $FontFiles) {
            # 等待空闲槽位
            while (($jobs | Where-Object { $_.State -eq "Running" }).Count -ge $Parallel) {
                Start-Sleep -Milliseconds 100
                
                # 检查已完成的作业
                $completedJobs = $jobs | Where-Object { $_.State -ne "Running" }
                foreach ($job in $completedJobs) {
                    $result = Receive-Job -Job $job
                    Remove-Job -Job $job
                    
                    if ($result) {
                        $successCount++
                    } else {
                        $errorCount++
                    }
                }
                
                # 移除已完成的作业
                $jobs = $jobs | Where-Object { $_.State -eq "Running" }
            }
            
            # 启动新作业
            $scriptBlock = {
                param($FontFile, $PatcherScript, $GlyphsDir, $Output, $BuildType, $UseComplete, $FontAwesome, $FontAwesomeExt, $Octicons, $Codicons, $Powerline, $PowerlineExtra, $Material, $Weather, $Devicons, $Pomicons, $FontLogos, $PowerSymbols)
                
                # 重新定义构建参数函数（在作业中）
                function Build-PatcherArgs {
                    $args = @("--quiet", "--glyphdir", $GlyphsDir, "--outputdir", $Output)
                    
                    switch ($BuildType) {
                        "mono" { $args += @("--mono", "--complete") }
                        "propo" { $args += @("--variable-width-glyphs", "--complete") }
                        default { $args += "--complete" }
                    }
                    
                    if (-not $UseComplete) {
                        if ($FontAwesome) { $args += "--fontawesome" }
                        if ($FontAwesomeExt) { $args += "--fontawesomeextension" }
                        if ($Octicons) { $args += "--octicons" }
                        if ($Codicons) { $args += "--codicons" }
                        if ($Powerline) { $args += "--powerline" }
                        if ($PowerlineExtra) { $args += "--powerlineextra" }
                        if ($Material) { $args += "--material" }
                        if ($Weather) { $args += "--weather" }
                        if ($Devicons) { $args += "--devicons" }
                        if ($Pomicons) { $args += "--pomicons" }
                        if ($FontLogos) { $args += "--fontlogos" }
                        if ($PowerSymbols) { $args += "--powersymbols" }
                    }
                    
                    return $args
                }
                
                try {
                    $patcherArgs = Build-PatcherArgs
                    $process = Start-Process -FilePath "fontforge" -ArgumentList @("-script", $PatcherScript) + $patcherArgs + @($FontFile) -Wait -PassThru -NoNewWindow -RedirectStandardError "nul"
                    return $process.ExitCode -eq 0
                }
                catch {
                    return $false
                }
            }
            
            $job = Start-Job -ScriptBlock $scriptBlock -ArgumentList @($fontFile, $PatcherScript, $GlyphsDir, $Output, $BuildType, $UseComplete, $FontAwesome, $FontAwesomeExt, $Octicons, $Codicons, $Powerline, $PowerlineExtra, $Material, $Weather, $Devicons, $Pomicons, $FontLogos, $PowerSymbols)
            $jobs += $job
        }
        
        # 等待所有作业完成
        while ($jobs.Count -gt 0) {
            Start-Sleep -Milliseconds 100
            
            $completedJobs = $jobs | Where-Object { $_.State -ne "Running" }
            foreach ($job in $completedJobs) {
                $result = Receive-Job -Job $job
                Remove-Job -Job $job
                
                if ($result) {
                    $successCount++
                } else {
                    $errorCount++
                }
            }
            
            $jobs = $jobs | Where-Object { $_.State -eq "Running" }
        }
    }
    finally {
        # 清理任何剩余的作业
        $jobs | ForEach-Object {
            Stop-Job -Job $_
            Remove-Job -Job $_
        }
    }
    
    # 显示结果
    Write-Host ""
    Write-Success "处理完成"
    Write-Status "成功: $successCount, 失败: $errorCount, 总计: $total"
    
    if ($errorCount -gt 0) {
        Write-Warning "部分字体处理失败，请检查日志"
        return $false
    }
    
    return $true
}

# 显示构建摘要
function Show-Summary {
    Write-Status "构建摘要:"
    Write-Host "  构建类型: $BuildType" -ForegroundColor Gray
    Write-Host "  输出目录: $Output" -ForegroundColor Gray
    Write-Host "  并行任务: $Parallel" -ForegroundColor Gray
    
    if ($UseComplete) {
        Write-Host "  图标集: 完整 (所有图标)" -ForegroundColor Gray
    } else {
        $selectedIcons = @()
        if ($FontAwesome) { $selectedIcons += "Font Awesome" }
        if ($FontAwesomeExt) { $selectedIcons += "Font Awesome Ext" }
        if ($Octicons) { $selectedIcons += "Octicons" }
        if ($Codicons) { $selectedIcons += "Codicons" }
        if ($Powerline) { $selectedIcons += "Powerline" }
        if ($PowerlineExtra) { $selectedIcons += "Powerline Extra" }
        if ($Material) { $selectedIcons += "Material Design" }
        if ($Weather) { $selectedIcons += "Weather" }
        if ($Devicons) { $selectedIcons += "Devicons" }
        if ($Pomicons) { $selectedIcons += "Pomicons" }
        if ($FontLogos) { $selectedIcons += "Font Logos" }
        if ($PowerSymbols) { $selectedIcons += "Power Symbols" }
        
        if ($selectedIcons.Count -eq 0) {
            Write-Host "  图标集: 默认 (Seti-UI + Custom + Devicons)" -ForegroundColor Gray
        } else {
            Write-Host "  图标集: $($selectedIcons -join ', ')" -ForegroundColor Gray
        }
    }
    
    if ($Font) {
        Write-Host "  指定字体: $Font" -ForegroundColor Gray
    }
    Write-Host ""
}

# 主函数
function Main {
    # 显示帮助
    if ($Help) {
        Show-Help
        exit 0
    }
    
    Write-Status "Google Sans Code Nerd Font 构建开始..."
    Write-Host ""
    
    try {
        # 显示摘要
        Show-Summary
        
        # 检查依赖
        Test-Dependencies
        Write-Host ""
        
        # 获取字体文件列表
        $fontFiles = Get-FontFiles
        Write-Host ""
        
        # 处理字体文件
        if (Invoke-FontsProcessingParallel -FontFiles $fontFiles) {
            Write-Host ""
            Write-Success "所有字体构建完成！"
            Write-Status "输出目录: $Output"
            
            if (Test-Path $Output) {
                $outputCount = (Get-ChildItem -Path $Output -Include "*.ttf", "*.otf" -Recurse).Count
                Write-Status "生成字体数量: $outputCount"
            }
        } else {
            Write-Host ""
            Write-Error "部分字体构建失败"
            exit 1
        }
    }
    catch {
        Write-Error "构建过程中出现错误: $($_.Exception.Message)"
        exit 1
    }
}

# 运行主函数
Main