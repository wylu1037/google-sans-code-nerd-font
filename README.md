# Google Sans Code Nerd Font

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

## ✨ 字体变体

支持 Google Sans Code 的所有字重：

### 可变字体
- `GoogleSansCodeNerdFont-VariableFont_wght.ttf` - 可变字重版本
- `GoogleSansCodeNerdFont-Italic-VariableFont_wght.ttf` - 可变字重斜体版本

### 静态字体
- Regular / Italic
- Light / Light Italic  
- Medium / Medium Italic
- SemiBold / SemiBold Italic
- Bold / Bold Italic
- ExtraBold / ExtraBold Italic

每种字重都提供三个版本：
- **Regular**: 双倍宽度图标（推荐）
- **Mono**: 单倍宽度图标（等宽）
- **Propo**: 比例宽度图标

## 🚀 快速开始

### 方法 1: 直接下载（推荐）

从 [Releases](../../releases) 页面下载预构建的字体文件。

### 方法 2: 自己构建

#### 环境要求

**通用依赖：**
- Python 3.6+
- FontForge

**平台特定依赖：**

**macOS:**
```bash
brew install fontforge python3
pip3 install fonttools
```

**Windows:**
```powershell
# 使用 Scoop
scoop install fontforge python
pip install fonttools

# 或使用 Chocolatey  
choco install fontforge python
pip install fonttools
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install fontforge python3 python3-pip
pip3 install fonttools
```

**Linux (Arch):**
```bash
sudo pacman -S fontforge python python-pip
pip install fonttools
```

#### 构建步骤

1. **克隆仓库**
   ```bash
   git clone https://github.com/你的用户名/google-sans-code-nerd-font.git
   cd google-sans-code-nerd-font
   ```

2. **设置环境并下载依赖**
   ```bash
   # macOS/Linux
   ./scripts/setup.sh
   
   # Windows
   ./scripts/setup.ps1
   ```

3. **构建字体**
   ```bash
   # 构建所有字体
   ./scripts/build.sh
   
   # 构建特定字重
   ./scripts/build.sh --font "GoogleSansCode-Regular.ttf"
   
   # 构建 Mono 版本
   ./scripts/build.sh --mono
   
   # 构建 Propo 版本  
   ./scripts/build.sh --propo
   ```

4. **输出位置**
   构建完成的字体文件将保存在 `patched-fonts/` 目录中。

## 📂 项目结构

```
google-sans-code-nerd-font/
├── Google Sans Code/              # 源字体文件
│   ├── *.ttf                     # 静态字体文件
│   ├── *.ttf                     # 可变字体文件
│   └── static/                   # 静态字体文件夹
├── scripts/                      # 构建脚本
│   ├── setup.sh                  # Unix 环境设置
│   ├── setup.ps1                 # Windows 环境设置  
│   ├── build.sh                  # Unix 构建脚本
│   ├── build.ps1                 # Windows 构建脚本
│   └── patch-single-font.py      # 单字体补丁脚本
├── patched-fonts/                # 输出目录
├── src/                          # Nerd Font patcher 和图标
│   ├── glyphs/                   # 图标字体文件
│   └── font-patcher              # 官方 patcher 脚本
├── .github/workflows/            # GitHub Actions
└── README.md
```

## 🔧 高级选项

### 自定义构建选项

`build.sh` 脚本支持多种选项：

```bash
./scripts/build.sh [OPTIONS]

选项:
  --font FONT_NAME     指定要处理的字体文件
  --mono              生成等宽版本 (Nerd Font Mono)
  --propo             生成比例版本 (Nerd Font Propo)  
  --complete          添加所有可用图标 (默认)
  --output DIR        指定输出目录
  --parallel N        并行处理数量 (默认: CPU核心数)
  --help              显示帮助信息
```

### 选择特定图标集

```bash
# 只添加 Font Awesome 和 Octicons
./scripts/build.sh --fontawesome --octicons

# 添加 Powerline 和 Material Design Icons
./scripts/build.sh --powerline --material
```

## 🎨 字体预览

| 字重 | 预览 |
|------|------|
| Light | ![Light Preview](docs/previews/light.png) |
| Regular | ![Regular Preview](docs/previews/regular.png) |
| Medium | ![Medium Preview](docs/previews/medium.png) |
| SemiBold | ![SemiBold Preview](docs/previews/semibold.png) |
| Bold | ![Bold Preview](docs/previews/bold.png) |
| ExtraBold | ![ExtraBold Preview](docs/previews/extrabold.png) |

## 📋 图标列表

完整的图标列表可以在 [NerdFonts.com](https://www.nerdfonts.com/cheat-sheet) 查看。

## 🤝 贡献

欢迎贡献！请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解如何参与项目。

### 贡献方式

1. Fork 这个项目
2. 创建您的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的更改 (`git commit -m 'Add some AmazingFeature'`)  
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开一个 Pull Request

## 📄 许可证

本项目基于 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

### 字体许可证

- **Google Sans Code**: SIL Open Font License 1.1
- **Nerd Font Icons**: 各图标集的原始许可证

## 🙏 致谢

- [Google Fonts](https://fonts.google.com/) - 提供 Google Sans Code 字体
- [Nerd Fonts](https://www.nerdfonts.com/) - 提供图标集和 patcher 工具
- [Font Awesome](https://fontawesome.com/) - 图标
- [Material Design Icons](https://materialdesignicons.com/) - 图标
- [Octicons](https://primer.style/octicons/) - GitHub 图标

## 📧 联系

如有问题或建议，请：

1. 创建 [Issue](../../issues)
2. 参与 [Discussions](../../discussions)
3. 联系维护者

## 🌟 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=你的用户名/google-sans-code-nerd-font&type=Date)](https://star-history.com/#你的用户名/google-sans-code-nerd-font&Date)

---

**Made with ❤️ for developers who love beautiful code fonts**