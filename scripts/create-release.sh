#!/bin/bash

# Google Sans Code Nerd Font - 创建发布脚本
# 此脚本帮助维护者创建新的 GitHub Release

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

# 显示帮助信息
show_help() {
    cat << EOF
Google Sans Code Nerd Font 发布脚本

用法: $0 [版本号]

参数:
  版本号    要发布的版本号 (如: v1.0.0)

选项:
  --help    显示此帮助信息
  --dry-run 预览操作，不实际创建标签

示例:
  $0 v1.0.0           # 创建 v1.0.0 版本
  $0 v1.1.0 --dry-run # 预览 v1.1.0 版本的创建过程

注意:
  - 版本号建议遵循语义化版本规范 (semver.org)
  - 此脚本只创建 Git 标签，GitHub Release 需要手动创建
  - 创建标签后，需要在 GitHub 网页界面创建 Release 以触发自动构建

EOF
}

# 验证版本号格式
validate_version() {
    local version="$1"
    
    if [[ ! "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$ ]]; then
        print_error "版本号格式不正确"
        print_status "正确格式: v1.0.0 或 v1.0.0-beta"
        return 1
    fi
    
    return 0
}

# 检查 Git 状态
check_git_status() {
    print_status "检查 Git 状态..."
    
    # 检查是否在 Git 仓库中
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        print_error "当前目录不是 Git 仓库"
        return 1
    fi
    
    # 检查是否有未提交的更改
    if ! git diff-index --quiet HEAD --; then
        print_warning "有未提交的更改"
        echo "未提交的文件:"
        git status --porcelain
        echo
        read -p "是否继续？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "操作已取消"
            return 1
        fi
    fi
    
    # 检查当前分支
    local branch=$(git branch --show-current)
    print_status "当前分支: $branch"
    
    if [ "$branch" != "main" ] && [ "$branch" != "master" ]; then
        print_warning "当前不在主分支上"
        read -p "是否继续？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "操作已取消"
            return 1
        fi
    fi
    
    return 0
}

# 检查标签是否已存在
check_tag_exists() {
    local version="$1"
    
    if git tag -l | grep -q "^$version$"; then
        print_error "标签 $version 已存在"
        return 1
    fi
    
    return 0
}

# 更新 CHANGELOG
update_changelog() {
    local version="$1"
    local changelog_file="CHANGELOG.md"
    
    print_status "检查 CHANGELOG.md..."
    
    if [ ! -f "$changelog_file" ]; then
        print_warning "未找到 CHANGELOG.md 文件"
        return 0
    fi
    
    # 检查是否包含新版本信息
    if grep -q "## \[$version\]" "$changelog_file"; then
        print_success "CHANGELOG.md 已包含 $version 的信息"
    else
        print_warning "CHANGELOG.md 中未找到 $version 的信息"
        print_status "建议在发布前更新 CHANGELOG.md"
    fi
}

# 生成发布说明模板
generate_release_notes() {
    local version="$1"
    local notes_file="release-notes-$version.md"
    
    cat > "$notes_file" << EOF
## Google Sans Code Nerd Font $version

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

构建时间: $(date)
EOF

    print_success "已生成发布说明模板: $notes_file"
    print_status "请编辑此文件后在 GitHub 创建 Release 时使用"
}

# 创建标签
create_tag() {
    local version="$1"
    local dry_run="$2"
    
    if [ "$dry_run" = true ]; then
        print_status "预览模式 - 将创建标签: $version"
        return 0
    fi
    
    print_status "创建标签: $version"
    
    # 创建带注释的标签
    git tag -a "$version" -m "Release $version"
    
    print_status "推送标签到远程仓库..."
    git push origin "$version"
    
    print_success "标签 $version 已创建并推送"
}

# 显示后续步骤
show_next_steps() {
    local version="$1"
    local notes_file="release-notes-$version.md"
    
    print_success "标签创建完成！"
    echo
    print_status "下一步操作："
    echo "1. 访问 GitHub 仓库页面"
    echo "2. 点击 'Releases' → 'Create a new release'"
    echo "3. 选择标签: $version"
    echo "4. 填写发布标题: Google Sans Code Nerd Font $version"
    echo "5. 复制 $notes_file 的内容作为发布说明"
    echo "6. 点击 'Publish release'"
    echo "7. 等待 GitHub Actions 自动构建和上传字体文件"
    echo
    print_status "GitHub Actions 构建完成后，用户就可以下载字体了！"
}

# 主函数
main() {
    local version=""
    local dry_run=false
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_help
                exit 0
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            v*.*.*)
                version="$1"
                shift
                ;;
            *)
                print_error "未知参数: $1"
                echo "使用 --help 查看帮助信息"
                exit 1
                ;;
        esac
    done
    
    # 检查版本号
    if [ -z "$version" ]; then
        print_error "请提供版本号"
        echo "使用方法: $0 v1.0.0"
        echo "使用 --help 查看帮助信息"
        exit 1
    fi
    
    print_status "准备创建 Google Sans Code Nerd Font $version 发布..."
    echo
    
    # 验证版本号
    if ! validate_version "$version"; then
        exit 1
    fi
    
    # 检查 Git 状态
    if ! check_git_status; then
        exit 1
    fi
    
    # 检查标签是否已存在
    if ! check_tag_exists "$version"; then
        exit 1
    fi
    
    # 更新 CHANGELOG
    update_changelog "$version"
    echo
    
    # 生成发布说明
    generate_release_notes "$version"
    echo
    
    # 创建标签
    create_tag "$version" "$dry_run"
    echo
    
    # 显示后续步骤
    if [ "$dry_run" = false ]; then
        show_next_steps "$version"
    else
        print_status "预览模式 - 未实际创建标签"
        print_status "移除 --dry-run 参数以实际执行"
    fi
}

# 运行主函数
main "$@"