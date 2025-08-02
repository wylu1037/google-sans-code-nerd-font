#!/bin/bash

# Google Sans Code Nerd Font - 构建脚本 (Unix/Linux/macOS)
# 此脚本使用 Nerd Font patcher 为 Google Sans Code 添加图标

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 获取脚本所在目录和项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# 切换到项目根目录
cd "$PROJECT_DIR"

# 输出调试信息
echo "DEBUG: 脚本目录: $SCRIPT_DIR"
echo "DEBUG: 项目根目录: $PROJECT_DIR"
echo "DEBUG: 当前工作目录: $(pwd)"

# 默认配置（相对于项目根目录）
DEFAULT_FONT_DIR="Google Sans Code"
DEFAULT_OUTPUT_DIR="patched-fonts"
DEFAULT_TEMP_DIR="temp"
PATCHER_SCRIPT="src/font-patcher"
GLYPHS_DIR="src/glyphs"

# 全局变量
FONT_FILE=""
OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
PARALLEL_JOBS=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
BUILD_TYPE="complete"  # complete, mono, propo
VERBOSE=false
DRY_RUN=false

# 图标选项
COMPLETE=true
FONTAWESOME=false
FONTAWESOME_EXT=false
OCTICONS=false
CODICONS=false
POWERLINE=false
POWERLINE_EXTRA=false
MATERIAL=false
WEATHER=false
DEVICONS=false
POMICONS=false
FONTLOGOS=false
POWERSYMBOLS=false

# 函数：打印彩色消息
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_debug() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${PURPLE}[DEBUG]${NC} $1"
    fi
}

# 显示帮助信息
show_help() {
    cat << EOF
Google Sans Code Nerd Font 构建脚本

用法: $0 [选项]

基本选项:
  --font FONT_NAME        指定要处理的字体文件名
  --output DIR            指定输出目录 (默认: $DEFAULT_OUTPUT_DIR)
  --parallel N            并行处理数量 (默认: $PARALLEL_JOBS)
  --verbose               详细输出
  --dry-run               预览要执行的操作，不实际构建
  --help                  显示此帮助信息

构建类型:
  --complete              构建完整版本（默认，包含所有图标）
  --mono                  构建等宽版本 (Nerd Font Mono)
  --propo                 构建比例版本 (Nerd Font Propo)

图标选择 (仅在未使用 --complete 时有效):
  --fontawesome           添加 Font Awesome 图标
  --fontawesome-ext       添加 Font Awesome Extension 图标
  --octicons              添加 Octicons 图标 (GitHub)
  --codicons              添加 Codicons 图标 (VS Code)
  --powerline             添加 Powerline 图标
  --powerline-extra       添加 Powerline Extra 图标
  --material              添加 Material Design 图标
  --weather               添加 Weather 图标
  --devicons              添加 Devicons 图标
  --pomicons              添加 Pomicons 图标
  --fontlogos             添加 Font Logos 图标
  --powersymbols          添加 IEC Power Symbols 图标

示例:
  $0                                    # 构建所有字体的完整版本
  $0 --font GoogleSansCode-Regular.ttf # 构建特定字体
  $0 --mono                            # 构建所有字体的等宽版本
  $0 --fontawesome --octicons          # 仅添加指定图标集
  $0 --parallel 8                      # 使用8个并行任务
  $0 --dry-run                         # 预览操作而不实际执行

EOF
}

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --font)
                FONT_FILE="$2"
                shift 2
                ;;
            --output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            --parallel)
                PARALLEL_JOBS="$2"
                shift 2
                ;;
            --complete)
                BUILD_TYPE="complete"
                COMPLETE=true
                shift
                ;;
            --mono)
                BUILD_TYPE="mono"
                COMPLETE=true
                shift
                ;;
            --propo)
                BUILD_TYPE="propo"
                COMPLETE=true
                shift
                ;;
            --fontawesome)
                FONTAWESOME=true
                COMPLETE=false
                shift
                ;;
            --fontawesome-ext)
                FONTAWESOME_EXT=true
                COMPLETE=false
                shift
                ;;
            --octicons)
                OCTICONS=true
                COMPLETE=false
                shift
                ;;
            --codicons)
                CODICONS=true
                COMPLETE=false
                shift
                ;;
            --powerline)
                POWERLINE=true
                COMPLETE=false
                shift
                ;;
            --powerline-extra)
                POWERLINE_EXTRA=true
                COMPLETE=false
                shift
                ;;
            --material)
                MATERIAL=true
                COMPLETE=false
                shift
                ;;
            --weather)
                WEATHER=true
                COMPLETE=false
                shift
                ;;
            --devicons)
                DEVICONS=true
                COMPLETE=false
                shift
                ;;
            --pomicons)
                POMICONS=true
                COMPLETE=false
                shift
                ;;
            --fontlogos)
                FONTLOGOS=true
                COMPLETE=false
                shift
                ;;
            --powersymbols)
                POWERSYMBOLS=true
                COMPLETE=false
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                print_error "未知选项: $1"
                echo "使用 --help 查看帮助信息"
                exit 1
                ;;
        esac
    done
}

# 检查依赖
check_dependencies() {
    print_status "检查依赖..."
    
    local missing_deps=()
    
    # 检查 Python
    if ! command -v python3 >/dev/null 2>&1 && ! command -v python >/dev/null 2>&1; then
        missing_deps+=("python")
    fi
    
    # 检查 FontForge
    if ! command -v fontforge >/dev/null 2>&1; then
        missing_deps+=("fontforge")
    fi
    
    # 检查 font-patcher
    if [ ! -f "$PATCHER_SCRIPT" ]; then
        missing_deps+=("font-patcher")
    fi
    
    # 检查字形目录
    if [ ! -d "$GLYPHS_DIR" ] || [ -z "$(ls -A "$GLYPHS_DIR" 2>/dev/null)" ]; then
        missing_deps+=("glyphs")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "缺少以下依赖: ${missing_deps[*]}"
        print_status "请先运行设置脚本: ./scripts/setup.sh"
        print_status "或手动安装缺少的依赖"
        
        # 提供安装建议
        print_status "安装建议:"
        if command -v apt-get >/dev/null 2>&1; then
            echo "  sudo apt-get install fontforge python3 python3-pip"
        elif command -v brew >/dev/null 2>&1; then
            echo "  brew install fontforge python3"
        elif command -v pacman >/dev/null 2>&1; then
            echo "  sudo pacman -S fontforge python python-pip"
        elif command -v dnf >/dev/null 2>&1; then
            echo "  sudo dnf install fontforge python3 python3-pip"
        fi
        
        exit 1
    fi
    
    # 验证 Python 模块
    local python_cmd
    if command -v python3 >/dev/null 2>&1; then
        python_cmd="python3"
    else
        python_cmd="python"
    fi
    
    if ! $python_cmd -c "import fontTools" >/dev/null 2>&1; then
        print_warning "fontTools 模块未安装，字体处理可能出现问题"
        print_status "建议安装: pip install fonttools"
    fi
    
    print_success "所有依赖检查通过"
}

# 获取要处理的字体文件列表
get_font_files() {
    local font_files=()
    
    if [ -n "$FONT_FILE" ]; then
        # 处理单个指定的字体文件
        local font_path
        if [ -f "$FONT_FILE" ]; then
            font_path="$FONT_FILE"
        elif [ -f "$DEFAULT_FONT_DIR/$FONT_FILE" ]; then
            font_path="$DEFAULT_FONT_DIR/$FONT_FILE"
        elif [ -f "$DEFAULT_FONT_DIR/static/$FONT_FILE" ]; then
            font_path="$DEFAULT_FONT_DIR/static/$FONT_FILE"
        else
            print_error "未找到字体文件: $FONT_FILE"
            exit 1
        fi
        font_files+=("$font_path")
    else
        # 处理所有字体文件
        # 注意：不要在这里使用 print_status，因为这个函数的输出会被 mapfile 捕获
        
        # 搜索字体文件
        while IFS= read -r -d '' file; do
            font_files+=("$file")
        done < <(find "$DEFAULT_FONT_DIR" -name "*.ttf" -o -name "*.otf" -print0 2>/dev/null | sort -z)
        
        if [ ${#font_files[@]} -eq 0 ]; then
            echo "ERROR: 在 $DEFAULT_FONT_DIR 中未找到字体文件" >&2
            exit 1
        fi
    fi
    
    # 只输出文件路径，不输出任何状态信息
    printf '%s\n' "${font_files[@]}"
}

# 构建 patcher 参数
build_patcher_args() {
    local args=()
    
    # 基本参数
    args+=("--quiet")
    args+=("--glyphdir" "$GLYPHS_DIR")
    args+=("--outputdir" "$OUTPUT_DIR")
    
    # 构建类型参数
    case $BUILD_TYPE in
        "mono")
            args+=("--mono")
            args+=("--complete")
            ;;
        "propo")
            args+=("--variable-width-glyphs")
            args+=("--complete")
            ;;
        "complete")
            args+=("--complete")
            ;;
    esac
    
    # 如果不是完整构建，添加指定的图标集
    if [ "$COMPLETE" = false ]; then
        [ "$FONTAWESOME" = true ] && args+=("--fontawesome")
        [ "$FONTAWESOME_EXT" = true ] && args+=("--fontawesomeextension")
        [ "$OCTICONS" = true ] && args+=("--octicons")
        [ "$CODICONS" = true ] && args+=("--codicons")
        [ "$POWERLINE" = true ] && args+=("--powerline")
        [ "$POWERLINE_EXTRA" = true ] && args+=("--powerlineextra")
        [ "$MATERIAL" = true ] && args+=("--material")
        [ "$WEATHER" = true ] && args+=("--weather")
        [ "$DEVICONS" = true ] && args+=("--devicons") 
        [ "$POMICONS" = true ] && args+=("--pomicons")
        [ "$FONTLOGOS" = true ] && args+=("--fontlogos")
        [ "$POWERSYMBOLS" = true ] && args+=("--powersymbols")
    fi
    
    printf '%s\n' "${args[@]}"
}

# 处理单个字体文件（用于并行处理）
process_font() {
    local font_file="$1"
    local font_name=$(basename "$font_file")
    
    # 在并行模式下，减少输出避免混乱
    echo "[INFO] 处理字体: $font_name" >&2
    
    if [ "$DRY_RUN" = true ]; then
        echo "[DEBUG] 预览模式 - 跳过实际处理" >&2
        return 0
    fi
    
    # 构建参数
    local patcher_args
    mapfile -t patcher_args < <(build_patcher_args)
    
    # 确保输出目录存在
    mkdir -p "$OUTPUT_DIR"
    
    if [ "$VERBOSE" = true ]; then
        echo "[DEBUG] 执行命令: fontforge -script $PATCHER_SCRIPT ${patcher_args[*]} $font_file" >&2
    fi
    
    # 执行 font-patcher
    if fontforge -script "$PATCHER_SCRIPT" "${patcher_args[@]}" "$font_file" 2>/dev/null; then
        echo "[SUCCESS] 完成: $font_name" >&2
        return 0
    else
        echo "[ERROR] 处理失败: $font_name" >&2
        return 1
    fi
}

# 处理单个字体文件（用于顺序处理）
process_font_sequential() {
    local font_file="$1"
    local font_name=$(basename "$font_file")
    
    print_status "处理字体: $font_name"
    
    if [ "$DRY_RUN" = true ]; then
        print_debug "预览模式 - 跳过实际处理"
        return 0
    fi
    
    # 构建参数
    local patcher_args
    mapfile -t patcher_args < <(build_patcher_args)
    
    # 确保输出目录存在
    mkdir -p "$OUTPUT_DIR"
    
    print_debug "执行命令: fontforge -script $PATCHER_SCRIPT ${patcher_args[*]} $font_file"
    
    # 执行 font-patcher
    if fontforge -script "$PATCHER_SCRIPT" "${patcher_args[@]}" "$font_file" 2>/dev/null; then
        print_success "完成: $font_name"
        return 0
    else
        print_error "处理失败: $font_name"
        return 1
    fi
}

# 并行处理字体文件
process_fonts_parallel() {
    local font_files=("$@")
    local total=${#font_files[@]}
    local success_count=0
    local error_count=0
    
    print_status "开始处理 $total 个字体文件 (并行任务数: $PARALLEL_JOBS)"
    
    if [ "$DRY_RUN" = true ]; then
        print_warning "预览模式 - 显示将要执行的操作"
        for font_file in "${font_files[@]}"; do
            print_debug "将处理: $(basename "$font_file")"
        done
        return 0
    fi
    
    # 简化的并行处理策略
    if [ ${#font_files[@]} -le 2 ] || [ "$PARALLEL_JOBS" -eq 1 ]; then
        # 少量文件或单线程，使用顺序处理
        local current=0
        for font_file in "${font_files[@]}"; do
            ((current++))
            print_status "处理 ($current/$total): $(basename "$font_file")"
            
            if process_font_sequential "$font_file"; then
                ((success_count++))
            else
                ((error_count++))
                # 允许继续处理其他文件
                print_warning "跳过失败的字体，继续处理其他文件"
            fi
        done
    else
        # 使用 GNU parallel 或者简单的后台任务处理
        if command -v parallel >/dev/null 2>&1; then
            # 使用 GNU parallel
            export -f process_font build_patcher_args
            export PATCHER_SCRIPT GLYPHS_DIR OUTPUT_DIR BUILD_TYPE COMPLETE
            export FONTAWESOME FONTAWESOME_EXT OCTICONS CODICONS POWERLINE POWERLINE_EXTRA
            export MATERIAL WEATHER DEVICONS POMICONS FONTLOGOS POWERSYMBOLS
            export VERBOSE DRY_RUN
            
            print_status "使用 GNU parallel 并行处理字体..."
            
            # 使用 parallel 处理，并收集退出码
            local temp_results="/tmp/font_build_results_$$"
            if printf '%s\n' "${font_files[@]}" | parallel -j "$PARALLEL_JOBS" --results "$temp_results" --bar process_font; then
                # 统计成功的任务
                success_count=$(find "$temp_results" -name "stdout" -exec grep -l "SUCCESS" {} \; 2>/dev/null | wc -l)
                error_count=$((total - success_count))
            else
                # 如果 parallel 本身失败，统计实际结果
                success_count=$(find "$temp_results" -name "exitval" -exec cat {} \; 2>/dev/null | grep -c "^0$" || echo 0)
                error_count=$((total - success_count))
            fi
            
            # 清理临时文件
            rm -rf "$temp_results" 2>/dev/null
        else
            # 简单的后台任务处理（限制并发数）
            local pids=()
            local current=0
            
            for font_file in "${font_files[@]}"; do
                # 等待空闲槽位
                while [ ${#pids[@]} -ge "$PARALLEL_JOBS" ]; do
                    for i in "${!pids[@]}"; do
                        if ! kill -0 "${pids[$i]}" 2>/dev/null; then
                            wait "${pids[$i]}"
                            local exit_code=$?
                            if [ $exit_code -eq 0 ]; then
                                ((success_count++))
                            else
                                ((error_count++))
                            fi
                            unset "pids[$i]"
                        fi
                    done
                    pids=("${pids[@]}")  # 重新索引数组
                    sleep 0.1
                done
                
                # 启动新任务
                ((current++))
                print_status "启动处理 ($current/$total): $(basename "$font_file")"
                process_font_sequential "$font_file" &
                pids+=($!)
            done
            
            # 等待所有任务完成
            for pid in "${pids[@]}"; do
                wait "$pid"
                local exit_code=$?
                if [ $exit_code -eq 0 ]; then
                    ((success_count++))
                else
                    ((error_count++))
                fi
            done
        fi
    fi
    
    # 显示结果
    echo
    print_success "处理完成"
    print_status "成功: $success_count, 失败: $error_count, 总计: $total"
    
    if [ $error_count -gt 0 ]; then
        print_warning "部分字体处理失败，请检查日志"
        # 但不完全失败，只要有成功的就算部分成功
        if [ $success_count -gt 0 ]; then
            print_status "已成功处理 $success_count 个字体文件"
            return 0
        else
            return 1
        fi
    fi
    
    return 0
}

# 生成字体元数据和校验和
generate_metadata() {
    local output_dir="$1"
    
    if [ ! -d "$output_dir" ]; then
        print_error "输出目录不存在: $output_dir"
        return 1
    fi
    
    print_status "生成字体元数据和校验和..."
    
    # 创建元数据文件
    local metadata_file="$output_dir/font-info.json"
    local checksums_file="$output_dir/checksums.sha256"
    
    # 获取版本信息
    local version=$(git describe --tags --always 2>/dev/null || echo "unknown")
    local commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    local build_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # 生成 JSON 元数据
    cat > "$metadata_file" << EOF
{
  "name": "Google Sans Code Nerd Font",
  "version": "$version",
  "build": {
    "type": "$BUILD_TYPE",
    "date": "$build_date",
    "commit": "$commit",
    "platform": "$(uname -s)-$(uname -m)",
    "script_version": "2.0"
  },
  "source": {
    "base_font": "Google Sans Code",
    "nerd_fonts_version": "auto-detected",
    "patcher_script": "$PATCHER_SCRIPT"
  },
  "fonts": []
}
EOF
    
    # 收集字体文件信息
    local font_info=""
    local first=true
    
    while IFS= read -r -d '' font_file; do
        if [ "$first" = true ]; then
            first=false
        else
            font_info+=","
        fi
        
        local filename=$(basename "$font_file")
        local filesize=$(stat -c%s "$font_file" 2>/dev/null || stat -f%z "$font_file" 2>/dev/null || echo "unknown")
        local sha256_hash
        
        if command -v sha256sum >/dev/null 2>&1; then
            sha256_hash=$(sha256sum "$font_file" | cut -d' ' -f1)
        elif command -v shasum >/dev/null 2>&1; then
            sha256_hash=$(shasum -a 256 "$font_file" | cut -d' ' -f1)
        else
            sha256_hash="unavailable"
        fi
        
        font_info+=$(cat << EOF

    {
      "filename": "$filename",
      "size": $filesize,
      "sha256": "$sha256_hash",
      "path": "${font_file#$output_dir/}"
    }
EOF
        )
    done < <(find "$output_dir" -name "*.ttf" -o -name "*.otf" -print0)
    
    # 更新 JSON 文件
    sed -i "s/\"fonts\": \[\]/\"fonts\": [$font_info\n  ]/" "$metadata_file"
    
    # 生成校验和文件
    cd "$output_dir"
    if command -v sha256sum >/dev/null 2>&1; then
        find . -name "*.ttf" -o -name "*.otf" | sort | xargs sha256sum > "$checksums_file"
    elif command -v shasum >/dev/null 2>&1; then
        find . -name "*.ttf" -o -name "*.otf" | sort | xargs shasum -a 256 > "$checksums_file"
    else
        print_warning "无法生成校验和文件，系统缺少 sha256sum 或 shasum 命令"
    fi
    cd - >/dev/null
    
    # 复制安装文档到输出目录
    if [ -f "docs/INSTALL.md" ]; then
        cp "docs/INSTALL.md" "$output_dir/README.md"
        print_status "已添加安装说明文档"
    fi
    
    # 创建简化的许可证文件
    cat > "$output_dir/LICENSE.txt" << EOF
Google Sans Code Nerd Font

This package contains Google Sans Code font patched with Nerd Font icons.

Font License:
- Google Sans Code: SIL Open Font License 1.1
- Nerd Font Icons: Various licenses (see source repositories)

Source: https://github.com/google/fonts/tree/main/ofl/googlesanscode
Nerd Fonts: https://github.com/ryanoasis/nerd-fonts

For detailed license information, please visit the source repositories.
EOF
    
    # 显示统计信息
    local font_count=$(find "$output_dir" -name "*.ttf" -o -name "*.otf" | wc -l)
    local total_size=$(du -sh "$output_dir" | cut -f1)
    
    print_success "元数据生成完成"
    print_status "字体数量: $font_count"
    print_status "总大小: $total_size"
    print_status "元数据文件: $metadata_file"
    
    if [ -f "$checksums_file" ]; then
        print_status "校验和文件: $checksums_file"
    fi
}

# 显示构建摘要
show_summary() {
    print_status "构建摘要:"
    echo "  构建类型: $BUILD_TYPE"
    echo "  输出目录: $OUTPUT_DIR"
    echo "  并行任务: $PARALLEL_JOBS"
    
    if [ "$COMPLETE" = true ]; then
        echo "  图标集: 完整 (所有图标)"
    else
        local selected_icons=()
        [ "$FONTAWESOME" = true ] && selected_icons+=("Font Awesome")
        [ "$FONTAWESOME_EXT" = true ] && selected_icons+=("Font Awesome Ext")
        [ "$OCTICONS" = true ] && selected_icons+=("Octicons")
        [ "$CODICONS" = true ] && selected_icons+=("Codicons")
        [ "$POWERLINE" = true ] && selected_icons+=("Powerline")
        [ "$POWERLINE_EXTRA" = true ] && selected_icons+=("Powerline Extra")
        [ "$MATERIAL" = true ] && selected_icons+=("Material Design")
        [ "$WEATHER" = true ] && selected_icons+=("Weather")
        [ "$DEVICONS" = true ] && selected_icons+=("Devicons")
        [ "$POMICONS" = true ] && selected_icons+=("Pomicons")
        [ "$FONTLOGOS" = true ] && selected_icons+=("Font Logos")
        [ "$POWERSYMBOLS" = true ] && selected_icons+=("Power Symbols")
        
        if [ ${#selected_icons[@]} -eq 0 ]; then
            echo "  图标集: 默认 (Seti-UI + Custom + Devicons)"
        else
            echo "  图标集: ${selected_icons[*]}"
        fi
    fi
    
    [ -n "$FONT_FILE" ] && echo "  指定字体: $FONT_FILE"
    echo
}

# 主函数
main() {
    print_status "Google Sans Code Nerd Font 构建开始..."
    echo
    
    # 解析参数
    parse_args "$@"
    
    # 显示摘要
    show_summary
    
    # 检查依赖
    check_dependencies
    echo
    
    # 获取字体文件列表
    print_status "搜索字体文件..."
    print_debug "当前工作目录: $(pwd)"
    print_debug "检查字体目录: $DEFAULT_FONT_DIR"
    
    if [ ! -d "$DEFAULT_FONT_DIR" ]; then
        print_error "字体目录不存在: $DEFAULT_FONT_DIR"
        print_debug "当前目录内容:"
        ls -la
        exit 1
    fi
    
    mapfile -t font_files < <(get_font_files)
    
    if [ ${#font_files[@]} -eq 0 ]; then
        print_error "未找到任何字体文件"
        print_debug "字体目录内容:"
        find "$DEFAULT_FONT_DIR" -type f -name "*" 2>/dev/null || echo "无法访问目录"
        exit 1
    fi
    
    print_success "找到 ${#font_files[@]} 个字体文件"
    
    # 如果是详细模式，列出所有文件
    if [ "$VERBOSE" = true ]; then
        print_debug "字体文件列表:"
        for file in "${font_files[@]}"; do
            echo "  - $file"
        done
    fi
    echo
    
    # 处理字体文件
    if process_fonts_parallel "${font_files[@]}"; then
        echo
        
        # 生成元数据和校验和
        generate_metadata "$OUTPUT_DIR"
        echo
        
        print_success "所有字体构建完成！"
        print_status "输出目录: $OUTPUT_DIR"
        
        if [ -d "$OUTPUT_DIR" ]; then
            local output_count
            output_count=$(find "$OUTPUT_DIR" -name "*.ttf" -o -name "*.otf" | wc -l)
            print_status "生成字体数量: $output_count"
        fi
    else
        echo
        print_error "部分字体构建失败"
        exit 1
    fi
}

# 运行主函数
main "$@"