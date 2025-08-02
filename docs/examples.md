# 使用示例

本文档提供了 Google Sans Code Nerd Font 的各种使用示例。

## 🚀 快速开始

### 1. 基础构建

```bash
# 克隆项目
git clone https://github.com/你的用户名/google-sans-code-nerd-font.git
cd google-sans-code-nerd-font

# 设置环境（首次运行）
./scripts/setup.sh

# 构建所有字体（完整版）
./scripts/build.sh
```

### 2. Windows 用户

```powershell
# 克隆项目
git clone https://github.com/你的用户名/google-sans-code-nerd-font.git
cd google-sans-code-nerd-font

# 设置环境（首次运行）
.\scripts\setup.ps1

# 构建所有字体（完整版）
.\scripts\build.ps1
```

## 🎯 高级用法

### 构建特定字体

```bash
# 只构建 Regular 字重
./scripts/build.sh --font "GoogleSansCode-Regular.ttf"

# 构建多个特定字体
./scripts/build.sh --font "GoogleSansCode-Regular.ttf"
./scripts/build.sh --font "GoogleSansCode-Bold.ttf"
```

### 不同构建类型

```bash
# 构建等宽版本（适合终端）
./scripts/build.sh --mono

# 构建比例版本（适合编辑器）
./scripts/build.sh --propo

# 构建完整版本（推荐）
./scripts/build.sh --complete
```

### 选择特定图标集

```bash
# 只添加 Font Awesome 图标
./scripts/build.sh --fontawesome

# 添加多个图标集
./scripts/build.sh --fontawesome --octicons --material

# 添加开发者常用图标
./scripts/build.sh --fontawesome --octicons --devicons --codicons
```

### 并行处理

```bash
# 使用 8 个并行任务（加速构建）
./scripts/build.sh --parallel 8

# 使用最大并行数（CPU 核心数）
./scripts/build.sh --parallel $(nproc)
```

### 自定义输出目录

```bash
# 输出到自定义目录
./scripts/build.sh --output my-fonts

# 输出到绝对路径
./scripts/build.sh --output /home/user/fonts
```

## 🐍 Python 脚本使用

### 基础用法

```python
# 使用 Python 脚本补丁单个字体
python scripts/patch-single-font.py "Google Sans Code/GoogleSansCode-Regular.ttf"

# 指定构建类型
python scripts/patch-single-font.py "Google Sans Code/GoogleSansCode-Regular.ttf" --type mono

# 自定义输出目录
python scripts/patch-single-font.py "Google Sans Code/GoogleSansCode-Regular.ttf" --output my-fonts
```

### 获取字体信息

```python
# 查看字体信息
python scripts/patch-single-font.py "Google Sans Code/GoogleSansCode-Regular.ttf" --info

# 列出可用图标集
python scripts/patch-single-font.py --list-icons
```

### 选择特定图标

```python
# 只添加 GitHub 和 VS Code 图标
python scripts/patch-single-font.py "Google Sans Code/GoogleSansCode-Regular.ttf" --icons octicons codicons

# 添加开发者图标包
python scripts/patch-single-font.py "Google Sans Code/GoogleSansCode-Regular.ttf" --icons fontawesome devicons fontlogos
```

## 📱 终端配置示例

### iTerm2 (macOS)

1. 打开 iTerm2 → Preferences → Profiles → Text
2. 在 Font 中选择 "GoogleSansCodeNerdFont-Regular"
3. 推荐使用 Mono 版本以保证对齐

### Windows Terminal

```json
{
    "profiles": {
        "defaults": {
            "fontFace": "GoogleSansCodeNerdFont Mono"
        }
    }
}
```

### VS Code

```json
{
    "editor.fontFamily": "'GoogleSansCodeNerdFont', 'Consolas', monospace",
    "terminal.integrated.fontFamily": "GoogleSansCodeNerdFont Mono"
}
```

### Vim/Neovim

```vim
set guifont=GoogleSansCodeNerdFont\ Mono:h12
```

## 🔧 故障排除

### 常见问题

#### 1. FontForge 未找到

```bash
# macOS
brew install fontforge

# Ubuntu/Debian
sudo apt install fontforge

# Windows (使用 Chocolatey)
choco install fontforge
```

#### 2. Python 依赖问题

```bash
# 安装 fonttools
pip install fonttools

# 如果有权限问题
pip install --user fonttools
```

#### 3. 字体文件未找到

确保 `Google Sans Code` 目录包含字体文件：

```bash
# 检查字体文件
ls -la "Google Sans Code/"

# 应该看到类似输出：
# GoogleSansCode-Regular.ttf
# GoogleSansCode-Bold.ttf
# 等等...
```

#### 4. 构建失败

```bash
# 启用详细输出查看错误
./scripts/build.sh --verbose

# 检查依赖
./scripts/setup.sh
```

### 性能优化

#### 1. 使用并行处理

```bash
# 检查 CPU 核心数
nproc  # Linux
sysctl -n hw.ncpu  # macOS

# 使用适当的并行数（通常是核心数）
./scripts/build.sh --parallel 8
```

#### 2. 减少字体数量

```bash
# 只构建需要的字重
./scripts/build.sh --font "GoogleSansCode-Regular.ttf"
./scripts/build.sh --font "GoogleSansCode-Bold.ttf"
```

#### 3. 选择性图标集

```bash
# 只添加必要的图标（减少文件大小）
./scripts/build.sh --fontawesome --octicons
```

## 🎨 自定义配置

### 创建配置文件

```json
{
    "remove_ligatures": false,
    "custom_icons": [],
    "font_name_suffix": "Nerd Font",
    "font_name_mono_suffix": "Nerd Font Mono", 
    "font_name_propo_suffix": "Nerd Font Propo",
    "output_dir": "patched-fonts",
    "temp_dir": "temp"
}
```

保存为 `src/config.json`

### 使用自定义配置

```python
# 使用自定义配置文件
python scripts/patch-single-font.py "font.ttf" --config my-config.json
```

## 📦 CI/CD 集成

### GitHub Actions

项目已包含 GitHub Actions 配置，支持：

- 自动构建所有字体变体
- 发布时自动创建 Release
- 跨平台测试

### 自定义构建

```yaml
# 在你的项目中使用
- name: Build fonts
  run: |
    git clone https://github.com/你的用户名/google-sans-code-nerd-font.git
    cd google-sans-code-nerd-font
    ./scripts/setup.sh
    ./scripts/build.sh --mono --output ../fonts
```

## 📚 更多资源

- [Nerd Fonts 图标列表](https://www.nerdfonts.com/cheat-sheet)
- [字体预览](../docs/previews/)
- [贡献指南](../CONTRIBUTING.md)
- [问题反馈](../../issues)

---

如果您有其他使用场景或问题，欢迎提出 [Issue](../../issues) 或参与 [讨论](../../discussions)！