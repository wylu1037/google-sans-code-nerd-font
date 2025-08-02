#!/bin/bash

# Google Sans Code Nerd Font - 环境设置脚本 (Unix/Linux/macOS)
# 此脚本下载并设置构建环境

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# 检查并安装依赖
check_dependencies() {
    print_status "检查系统依赖..."
    
    local missing_deps=()
    
    # 检查 Python
    if ! command_exists python3 && ! command_exists python; then
        missing_deps+=("python3")
    fi
    
    # 检查 FontForge
    if ! command_exists fontforge; then
        missing_deps+=("fontforge")
    fi
    
    # 检查 curl
    if ! command_exists curl; then
        missing_deps+=("curl")
    fi
    
    # 检查 git
    if ! command_exists git; then
        missing_deps+=("git")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "缺少以下依赖: ${missing_deps[*]}"
        print_status "请根据您的操作系统安装:"
        
        local os=$(detect_os)
        case $os in
            "macos")
                print_status "macOS (使用 Homebrew):"
                echo "  brew install fontforge python3"
                ;;
            "linux")
                print_status "Ubuntu/Debian:"
                echo "  sudo apt update && sudo apt install fontforge python3 python3-pip curl git"
                print_status "Arch Linux:"
                echo "  sudo pacman -S fontforge python python-pip curl git"
                print_status "CentOS/RHEL/Fedora:"
                echo "  sudo dnf install fontforge python3 python3-pip curl git"
                ;;
            *)
                print_status "请手动安装: ${missing_deps[*]}"
                ;;
        esac
        exit 1
    fi
    
    print_success "所有系统依赖已安装"
}

# 安装 Python 依赖
install_python_deps() {
    print_status "安装 Python 依赖..."
    
    local python_cmd
    if command_exists python3; then
        python_cmd="python3"
    else
        python_cmd="python"
    fi
    
    local pip_cmd
    if command_exists pip3; then
        pip_cmd="pip3"
    elif command_exists pip; then
        pip_cmd="pip"
    else
        print_error "未找到 pip，请手动安装 Python 包管理器"
        exit 1
    fi
    
    # 安装必要的 Python 包
    $pip_cmd install --user fonttools configparser argparse
    
    print_success "Python 依赖安装完成"
}

# 创建目录结构
create_directories() {
    print_status "创建目录结构..."
    
    local dirs=(
        "src"
        "src/glyphs"
        "patched-fonts"
        "docs/previews"
        "temp"
    )
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            print_status "创建目录: $dir"
        fi
    done
    
    print_success "目录结构创建完成"
}

# 下载 Nerd Font patcher
download_font_patcher() {
    print_status "下载 Nerd Font patcher..."
    
    local patcher_url="https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/font-patcher"
    local patcher_path="src/font-patcher"
    
    if [ ! -f "$patcher_path" ]; then
        curl -fLo "$patcher_path" "$patcher_url"
        chmod +x "$patcher_path"
        print_success "Font patcher 下载完成"
    else
        print_warning "Font patcher 已存在，跳过下载"
    fi
}

# 下载字形文件
download_glyphs() {
    print_status "下载字形文件..."
    
    local glyphs_dir="src/glyphs"
    local temp_dir="temp"
    
    # 如果字形目录不为空，跳过下载
    if [ "$(ls -A $glyphs_dir 2>/dev/null)" ]; then
        print_warning "字形文件已存在，跳过下载"
        return
    fi
    
    # 定义需要下载的字形文件
    local base_url="https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/src/glyphs"
    local glyph_files=(
        "Symbols-1000-em Nerd Font Mono.ttf"
        "Symbols-2048-em Nerd Font Mono.ttf"
        "FontAwesome.otf"
        "FontAwesome-Solid.otf"
        "FontAwesome-Brands.otf"
        "fontawesome-extension.ttf"
        "octicons.ttf"
        "codicons.ttf"
        "PowerlineSymbols.otf"
        "PowerlineExtraSymbols.otf"
        "Pomicons.otf"
        "materialdesignicons-webfont.ttf"
        "weather-icons.ttf"
        "devicons.ttf"
        "font-logos.ttf"
        "UnicodePowerSymbols.otf"
    )
    
    print_status "下载字形文件到 $glyphs_dir"
    
    for file in "${glyph_files[@]}"; do
        local url="$base_url/$file"
        local dest="$glyphs_dir/$file"
        
        print_status "下载: $file"
        if curl -fL "$url" -o "$dest" 2>/dev/null; then
            print_success "下载完成: $file"
        else
            print_warning "下载失败: $file (可能不存在，继续...)"
            rm -f "$dest"
        fi
    done
    
    print_success "字形文件下载完成"
}

# 验证 Google Sans Code 字体文件
verify_source_fonts() {
    print_status "验证源字体文件..."
    
    local font_dir="Google Sans Code"
    
    if [ ! -d "$font_dir" ]; then
        print_error "未找到 Google Sans Code 字体目录"
        print_error "请确保 '$font_dir' 目录存在并包含字体文件"
        exit 1
    fi
    
    # 检查是否包含字体文件
    local font_count=$(find "$font_dir" -name "*.ttf" -o -name "*.otf" | wc -l)
    
    if [ "$font_count" -eq 0 ]; then
        print_error "在 '$font_dir' 中未找到字体文件"
        print_error "请确保目录包含 Google Sans Code 的 .ttf 或 .otf 文件"
        exit 1
    fi
    
    print_success "找到 $font_count 个字体文件"
    
    # 列出找到的字体文件
    print_status "字体文件列表:"
    find "$font_dir" -name "*.ttf" -o -name "*.otf" | sort | while read -r font; do
        echo "  - $(basename "$font")"
    done
}

# 创建配置文件
create_config() {
    print_status "创建配置文件..."
    
    local config_file="src/config.json"
    
    if [ ! -f "$config_file" ]; then
        cat > "$config_file" << 'EOF'
{
  "remove_ligatures": false,
  "custom_icons": [],
  "font_name_suffix": "Nerd Font",
  "font_name_mono_suffix": "Nerd Font Mono",
  "font_name_propo_suffix": "Nerd Font Propo",
  "output_dir": "patched-fonts",
  "temp_dir": "temp"
}
EOF
        print_success "配置文件已创建: $config_file"
    else
        print_warning "配置文件已存在，跳过创建"
    fi
}

# 主函数
main() {
    print_status "Google Sans Code Nerd Font 环境设置开始..."
    echo
    
    # 检查依赖
    check_dependencies
    echo
    
    # 安装 Python 依赖
    install_python_deps
    echo
    
    # 创建目录
    create_directories
    echo
    
    # 下载 font-patcher
    download_font_patcher
    echo
    
    # 下载字形文件
    download_glyphs
    echo
    
    # 验证源字体
    verify_source_fonts
    echo
    
    # 创建配置
    create_config
    echo
    
    print_success "环境设置完成！"
    echo
    print_status "接下来可以运行构建脚本:"
    echo "  ./scripts/build.sh"
    echo
    print_status "或者构建特定字体:"
    echo "  ./scripts/build.sh --font GoogleSansCode-Regular.ttf"
}

# 运行主函数
main "$@"