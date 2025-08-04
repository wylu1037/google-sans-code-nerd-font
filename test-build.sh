#!/bin/bash

# Google Sans Code Nerd Font 构建测试脚本
# 用于在本地验证字体处理流程

set -e  # 遇到错误时退出

echo "🚀 开始测试 Google Sans Code Nerd Font 构建流程..."

# 检查必要的工具
check_dependencies() {
    echo "📋 检查依赖工具..."
    
    if ! command -v fontforge &> /dev/null; then
        echo "❌ FontForge 未安装。请先安装 FontForge:"
        echo "   Ubuntu/Debian: sudo apt-get install fontforge python3-fontforge"
        echo "   macOS: brew install fontforge"
        exit 1
    fi
    
    if ! command -v python3 &> /dev/null; then
        echo "❌ Python3 未安装"
        exit 1
    fi
    
    if ! command -v curl &> /dev/null; then
        echo "❌ curl 未安装"
        exit 1
    fi
    
    if ! command -v unzip &> /dev/null; then
        echo "❌ unzip 未安装"
        exit 1
    fi
    
    echo "✅ 依赖检查通过"
}

# 检查字体文件
check_fonts() {
    echo "📁 检查字体文件..."
    
    if [ ! -d "data/google-sans-code/static" ]; then
        echo "❌ 字体文件目录不存在: data/google-sans-code/static"
        exit 1
    fi
    
    font_count=$(find data/google-sans-code/static -name "*.ttf" | wc -l)
    echo "✅ 找到 $font_count 个字体文件"
    
    if [ $font_count -eq 0 ]; then
        echo "❌ 没有找到任何字体文件"
        exit 1
    fi
}

# 下载 Font Patcher
setup_patcher() {
    echo "⬇️ 设置 Nerd Font Patcher..."
    
    mkdir -p tools
    cd tools
    
    if [ ! -f "font-patcher" ]; then
        echo "正在下载 FontPatcher.zip..."
        curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FontPatcher.zip -o FontPatcher.zip
        unzip -q FontPatcher.zip
        chmod +x font-patcher
    fi
    
    if [ ! -f "font-patcher" ]; then
        echo "❌ font-patcher 脚本不存在"
        exit 1
    fi
    
    echo "✅ Font Patcher 设置完成"
    cd ..
}

# 测试处理单个字体
test_single_font() {
    echo "🧪 测试处理单个字体文件..."
    
    # 找到第一个字体文件进行测试
    test_font=$(find data/google-sans-code/static -name "*.ttf" | head -1)
    
    if [ -z "$test_font" ]; then
        echo "❌ 没有找到测试字体文件"
        exit 1
    fi
    
    echo "测试字体: $(basename "$test_font")"
    
    mkdir -p test-output
    
    cd tools
    echo "执行: fontforge -script font-patcher \"$test_font\" --fontawesome --outputdir ../test-output"
    
    # 只使用 --fontawesome 进行快速测试，避免 --complete 耗时过长
    if fontforge -script font-patcher "../$test_font" --fontawesome --outputdir ../test-output --quiet; then
        echo "✅ 字体处理测试成功"
    else
        echo "❌ 字体处理测试失败"
        exit 1
    fi
    
    cd ..
    
    # 检查输出文件
    output_count=$(find test-output -name "*.ttf" | wc -l)
    if [ $output_count -gt 0 ]; then
        echo "✅ 生成了 $output_count 个输出字体文件"
        ls -la test-output/
    else
        echo "❌ 没有生成输出文件"
        exit 1
    fi
}

# 清理测试文件
cleanup() {
    echo "🧹 清理测试文件..."
    rm -rf tools/FontPatcher.zip
    rm -rf test-output
    echo "✅ 清理完成"
}

# 主函数
main() {
    echo "📍 当前目录: $(pwd)"
    
    check_dependencies
    check_fonts
    setup_patcher
    test_single_font
    
    echo ""
    echo "🎉 测试完成！GitHub Actions 工作流应该可以正常运行。"
    echo ""
    echo "下一步:"
    echo "1. 提交并推送更改到 GitHub"
    echo "2. 查看 Actions 标签页查看构建状态"
    echo "3. 构建完成后下载 Artifacts 中的字体文件"
    echo ""
    
    read -p "是否清理测试文件？(y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cleanup
    fi
}

# 运行主函数
main "$@"