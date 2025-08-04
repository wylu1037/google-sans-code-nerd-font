# Google Sans Code Nerd Font

[English](README.md) | **中文**

这是一个开源项目，为 Google Sans Code 字体添加 Nerd Font 图标支持。

## 📖 关于

Google Sans Code 是 Google 推出的一款优秀的编程字体，但官方没有提供 Nerd Font 版本。本项目使用官方 Nerd Font patcher 为 Google Sans Code 的所有字重添加了 3600+ 个图标，包括：

- 🎯 Font Awesome  
- 📦 Material Design Icons  
- 🐙 Octicons (GitHub)
- ⚡ Powerline Symbols
- 🔧 Devicons
- 🌤️ Weather Icons
- 📋 Codicons (VS Code)
- 🔌 IEC Power Symbols
- 💎 Pomicons
- 🐧 Font Logos

## 🚀 快速开始

### 方法1：下载预构建字体（推荐）

1. 访问 [GitHub Actions](../../actions) 页面
2. 点击最新的成功构建
3. 在 "Artifacts" 部分下载 `google-sans-code-nerd-font`
4. 解压并安装字体文件

### 方法2：本地构建

#### 前置要求

- Python 3.7+
- FontForge 和 python3-fontforge

**Ubuntu/Debian:**
```bash
sudo apt-get install fontforge python3-fontforge
```

**macOS:**
```bash
brew install fontforge
```

#### 构建步骤

1. 克隆仓库：
```bash
git clone https://github.com/your-username/google-sans-code-nerd-font.git
cd google-sans-code-nerd-font
```

2. 运行测试构建：
```bash
./test-build.sh
```

3. 或者手动构建全部：
```bash
mkdir -p tools output
cd tools
curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FontPatcher.zip -o FontPatcher.zip
unzip FontPatcher.zip
chmod +x font-patcher

# 处理所有字体
for font in ../data/google-sans-code/static/*.ttf; do
  fontforge -script font-patcher "$font" --complete --outputdir ../output/
done
```

## 📁 项目结构

```
├── data/
│   └── google-sans-code/          # 原版 Google Sans Code 字体文件
│       ├── static/                # 静态字体文件 (TTF)
│       ├── GoogleSansCode-*.ttf   # 可变字体文件
│       └── OFL.txt               # Open Font License
├── .github/
│   └── workflows/
│       └── build-fonts.yml       # GitHub Actions 自动构建配置
├── test-build.sh                 # 本地测试构建脚本
└── README.md
```

## 🤖 自动化构建

本项目使用 GitHub Actions 自动构建字体：

- **触发条件**: 推送到 main 分支或手动触发
- **构建环境**: Ubuntu Latest + Docker  
- **处理字体**: 所有静态字体文件 (12个字重)
- **输出格式**: TTF 格式，包含完整 Nerd Font 图标集
- **Artifacts**: 90天保留期，包含所有构建字体和发布包

### 🐳 Docker 化解决方案

为了解决 Ubuntu 24.04 中 `python3-fontforge` 的兼容性问题，我们采用了 Docker 容器化方案：

- 使用官方 `nerdfonts/patcher:latest` Docker 镜像
- 避免了 FontForge Python 绑定的版本冲突
- 确保构建环境的一致性和可靠性
- 支持完整的 `--complete` 参数，包含所有图标集

### 构建流程

1. **环境准备**: 安装 Docker 并拉取 Nerd Font Patcher 镜像
2. **字体处理**: 使用容器化 Font Patcher 批量处理字体
3. **验证检查**: 确保生成的字体文件完整性
4. **打包上传**: 创建发布包并上传 Artifacts

## 💡 字体特性

### 支持的字重

- **Light** (300) + Italic
- **Regular** (400) + Italic  
- **Medium** (500) + Italic
- **SemiBold** (600) + Italic
- **Bold** (700) + Italic
- **ExtraBold** (800) + Italic

### 图标支持

- ✅ 3600+ 编程相关图标
- ✅ 完整的 Powerline 支持
- ✅ 终端和编辑器完美兼容
- ✅ 保持原字体的优秀可读性

## 🛠️ 使用说明

### 终端配置

安装字体后，在终端中设置字体族为：
- **字体名称**: `GoogleSansCodeNerdFont`
- **备选名称**: `GoogleSansCode Nerd Font`

### 编辑器配置

**VS Code:**
```json
{
  "editor.fontFamily": "'GoogleSansCodeNerdFont', 'Google Sans Code', monospace"
}
```

**Vim/Neovim:**
```vim
set guifont=GoogleSansCodeNerdFont:h12
```

## 🔧 故障排除

### 字体显示问题

1. **图标显示为方块**: 确认安装的是 Nerd Font 版本
2. **字体不生效**: 重启应用程序或清除字体缓存
3. **间距问题**: 使用等宽版本 (Mono)

### 构建问题

1. **FontForge 导入错误**: 确认安装了 python3-fontforge
2. **内存不足**: 单独处理字体文件，避免批量处理
3. **权限问题**: 确保脚本有执行权限

## 📄 许可证

- **原字体**: Google Sans Code 使用 [SIL Open Font License 1.1](data/google-sans-code/OFL.txt)
- **Nerd Font 图标**: 各自原始许可证
- **构建脚本**: MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 贡献指南

1. Fork 此仓库
2. 创建功能分支: `git checkout -b feature/amazing-feature`
3. 提交更改: `git commit -m 'Add amazing feature'`
4. 推送分支: `git push origin feature/amazing-feature`
5. 提交 Pull Request

## 🔗 相关链接

- [Google Sans Code 官方仓库](https://github.com/googlefonts/googlesans-code)
- [Nerd Fonts 项目](https://github.com/ryanoasis/nerd-fonts)
- [Font Patcher 文档](https://github.com/ryanoasis/nerd-fonts#font-patcher)

---

## ⭐ Star 历史

[![Star History Chart](https://api.star-history.com/svg?repos=wylu1037/google-sans-code-nerd-font&type=Date)](https://star-history.com/#your-username/google-sans-code-nerd-font&Date)

---

**⭐ 如果这个项目帮助到你，请给个 Star！**