# Google Sans Code Nerd Font 安装指南

## 📦 下载说明

### 构建变体说明

- **GoogleSansCodeNerdFont-Complete.zip** - 完整版本，包含所有图标（推荐）
- **GoogleSansCodeNerdFont-Mono.zip** - 等宽图标版本，适合终端使用
- **GoogleSansCodeNerdFont-Propo.zip** - 比例宽度图标版本

如果不确定选择哪个版本，建议下载 **Complete** 版本。

## 💾 安装方法

### Windows 安装

#### 方法一：右键安装（推荐）
1. 下载对应的 zip 文件
2. 解压缩到任意目录
3. 选择所有字体文件（Ctrl+A）
4. 右键选择"安装"或"为所有用户安装"

#### 方法二：字体文件夹安装
1. 解压缩字体文件
2. 复制所有 `.ttf` 文件到 `C:\Windows\Fonts\` 目录
3. 或者打开"设置" → "个性化" → "字体" → 拖拽字体文件

### macOS 安装

#### 方法一：Font Book 安装（推荐）
1. 下载对应的 zip 文件
2. 解压缩到任意目录
3. 选择所有字体文件
4. 双击任意字体文件，点击"安装字体"
5. 或者打开 Font Book 应用，将字体文件拖拽进去

#### 方法二：系统字体目录
```bash
# 用户安装
cp *.ttf ~/Library/Fonts/

# 系统级安装 (需要管理员权限)
sudo cp *.ttf /Library/Fonts/
```

### Linux 安装

#### 用户级安装（推荐）
```bash
# 创建字体目录
mkdir -p ~/.local/share/fonts

# 解压并安装
unzip GoogleSansCodeNerdFont-Complete.zip -d ~/.local/share/fonts/

# 刷新字体缓存
fc-cache -fv
```

#### 系统级安装
```bash
# 解压到系统字体目录 (需要 sudo)
sudo unzip GoogleSansCodeNerdFont-Complete.zip -d /usr/share/fonts/

# 刷新字体缓存
sudo fc-cache -fv
```

#### 包管理器安装（如果可用）
```bash
# Arch Linux (AUR)
yay -S google-sans-code-nerd-font

# Ubuntu/Debian (如果有 PPA)
sudo add-apt-repository ppa:font-manager/google-sans-code-nerd
sudo apt update && sudo apt install google-sans-code-nerd-font
```

## 🔧 使用方法

### 在终端中使用

安装完成后，在终端配置中将字体设置为：
- **字体名称**: `GoogleSansCodeNerdFont`
- **等宽版本**: `GoogleSansCodeNerdFont Mono`

#### 常见终端配置

**Windows Terminal**
```json
{
    "profiles": {
        "defaults": {
            "fontFace": "GoogleSansCodeNerdFont"
        }
    }
}
```

**VS Code**
```json
{
    "editor.fontFamily": "'GoogleSansCodeNerdFont', 'Courier New', monospace",
    "terminal.integrated.fontFamily": "GoogleSansCodeNerdFont"
}
```

**iTerm2 (macOS)**
1. Preferences → Profiles → Text
2. Font: GoogleSansCodeNerdFont

**GNOME Terminal (Linux)**
1. 偏好设置 → 配置文件 → 字体
2. 选择 GoogleSansCodeNerdFont

### 在编辑器中使用

大多数代码编辑器支持字体配置：

- **JetBrains IDEs**: Settings → Editor → Font
- **Sublime Text**: Preferences → Settings → font_face
- **Atom**: Settings → Editor → Font Family
- **Vim/Neovim**: `set guifont=GoogleSansCodeNerdFont:h12`

## 🔐 文件验证

为确保下载的文件完整性，请验证校验和：

### Linux/macOS
```bash
# 验证 SHA256 校验和
sha256sum -c checksums.sha256
```

### Windows PowerShell
```powershell
# 计算并显示文件哈希
Get-FileHash *.zip -Algorithm SHA256 | Format-Table

# 与提供的校验和对比
```

## ❓ 常见问题

### Q: 字体安装后在应用中找不到？
A: 
1. 确保重启了应用程序
2. 在字体列表中搜索 "GoogleSansCodeNerdFont" 或 "Google Sans Code"
3. 某些应用可能需要重启系统

### Q: 图标显示为方块或问号？
A: 
1. 确保使用的是 Complete 版本
2. 检查应用程序是否支持 Unicode 字符
3. 尝试使用 Mono 版本

### Q: 字体在终端中显示异常？
A: 
1. 确保终端支持真彩色和 Unicode
2. 检查终端的字体渲染设置
3. 尝试调整字体大小

### Q: Linux 下字体缓存问题？
A: 
```bash
# 清除并重建字体缓存
fc-cache -fv
# 或者
sudo fc-cache -fv
```

## 🗑️ 卸载字体

### Windows
1. 打开 `C:\Windows\Fonts\`
2. 删除所有 GoogleSansCodeNerdFont 相关文件

### macOS
```bash
# 删除用户字体
rm ~/Library/Fonts/GoogleSansCodeNerdFont*

# 删除系统字体 (需要 sudo)
sudo rm /Library/Fonts/GoogleSansCodeNerdFont*
```

### Linux
```bash
# 删除用户字体
rm ~/.local/share/fonts/GoogleSansCodeNerdFont*

# 删除系统字体 (需要 sudo)
sudo rm /usr/share/fonts/GoogleSansCodeNerdFont*

# 刷新字体缓存
fc-cache -fv
```

## 📞 获取帮助

如果遇到问题，请：

1. 查看 [项目 README](../README.md)
2. 搜索 [已知问题](../../issues)
3. 创建新的 [Issue](../../issues/new)
4. 参与 [讨论](../../discussions)

---

**享受美丽的编程字体！** ❤️