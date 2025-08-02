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

# 默认配置
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
        exit 1
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
        print_status "搜索字体文件..."
        
        # 搜索字体文件
        while IFS= read -r -d '' file; do
            font_files+=("$file")
        done < <(find "$DEFAULT_FONT_DIR" -name "*.ttf" -o -name "*.otf" -print0 2>/dev/null | sort -z)
        
        if [ ${#font_files[@]} -eq 0 ]; then
            print_error "在 $DEFAULT_FONT_DIR 中未找到字体文件"
            exit 1
        fi
    fi
    
    print_success "找到 ${#font_files[@]} 个字体文件"
    
    # 如果是详细模式，列出所有文件
    if [ "$VERBOSE" = true ]; then
        print_debug "字体文件列表:"
        for file in "${font_files[@]}"; do
            echo "  - $file"
        done
    fi
    
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

# 处理单个字体文件
process_font() {
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
    
    # 使用 GNU parallel 或者简单的后台任务处理
    if command -v parallel >/dev/null 2>&1; then
        # 使用 GNU parallel
        export -f process_font print_status print_success print_error print_debug build_patcher_args
        export PATCHER_SCRIPT GLYPHS_DIR OUTPUT_DIR BUILD_TYPE COMPLETE
        export FONTAWESOME FONTAWESOME_EXT OCTICONS CODICONS POWERLINE POWERLINE_EXTRA
        export MATERIAL WEATHER DEVICONS POMICONS FONTLOGOS POWERSYMBOLS
        export VERBOSE DRY_RUN BLUE GREEN RED YELLOW PURPLE NC
        
        printf '%s\n' "${font_files[@]}" | parallel -j "$PARALLEL_JOBS" process_font
        
        # 统计结果
        local exit_codes
        mapfile -t exit_codes < <(parallel --joblog /tmp/font_build.log -j "$PARALLEL_JOBS" process_font ::: "${font_files[@]}")
        for code in "${exit_codes[@]}"; do
            if [ "$code" -eq 0 ]; then
                ((success_count++))
            else
                ((error_count++))
            fi
        done
    else
        # 简单的后台任务处理
        local pids=()
        local job_count=0
        
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
            process_font "$font_file" &
            pids+=($!)
            ((job_count++))
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
    
    # 显示结果
    echo
    print_success "处理完成"
    print_status "成功: $success_count, 失败: $error_count, 总计: $total"
    
    if [ $error_count -gt 0 ]; then
        print_warning "部分字体处理失败，请检查日志"
        return 1
    fi
    
    return 0
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
    mapfile -t font_files < <(get_font_files)
    echo
    
    # 处理字体文件
    if process_fonts_parallel "${font_files[@]}"; then
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