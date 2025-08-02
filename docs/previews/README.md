# 字体预览

本目录包含 Google Sans Code Nerd Font 各种字重的预览图片。

## 📸 预览图片

### 可用预览

- `light.png` - Light 字重预览
- `regular.png` - Regular 字重预览  
- `medium.png` - Medium 字重预览
- `semibold.png` - SemiBold 字重预览
- `bold.png` - Bold 字重预览
- `extrabold.png` - ExtraBold 字重预览

### 斜体预览

- `light-italic.png` - Light Italic 字重预览
- `regular-italic.png` - Regular Italic 字重预览
- `medium-italic.png` - Medium Italic 字重预览
- `semibold-italic.png` - SemiBold Italic 字重预览
- `bold-italic.png` - Bold Italic 字重预览
- `extrabold-italic.png` - ExtraBold Italic 字重预览

### 图标示例

- `icons-overview.png` - 图标总览
- `powerline-symbols.png` - Powerline 符号示例
- `devicons.png` - 开发者图标示例
- `material-icons.png` - Material Design 图标示例

## 🎨 预览内容

每个预览图包含：

1. **基本字符**: 英文字母、数字、符号
2. **编程符号**: 常用编程符号和操作符
3. **Nerd Font 图标**: 各种图标集的示例
4. **中文字符**: 中文字符显示效果（如果支持）

## 📝 示例文本

预览图使用以下示例文本：

```
GoogleSansCodeNerdFont - Regular
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz
0123456789 !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~

编程示例:
function hello() {
    console.log("Hello, World! 🌍");
    return true && false || null;
}

图标示例:
   文件夹    Git 分支   错误   警告   JSON
   Python   JavaScript  React   Vue    Docker
```

## 🔧 生成预览图

如果您想生成自己的预览图，可以使用以下工具：

### 1. 使用 FontForge

```python
# 在 FontForge 中生成预览
import fontforge
font = fontforge.open("path/to/font.ttf")
font.generate("preview.png")
```

### 2. 使用在线工具

- [Font Squirrel](https://www.fontsquirrel.com/tools/webfont-generator)
- [Google Fonts](https://fonts.google.com/)

### 3. 使用终端截图

配置您的终端使用字体，然后截图保存。

## 📱 在不同环境中的效果

### 终端环境

- iTerm2 (macOS)
- Windows Terminal
- GNOME Terminal (Linux)
- Visual Studio Code 集成终端

### 编辑器环境  

- Visual Studio Code
- Vim/Neovim
- Sublime Text
- Atom

### 字体大小建议

- **12pt**: 适合笔记本屏幕
- **14pt**: 适合桌面显示器
- **16pt**: 适合大屏幕或高分辨率显示器

## 🎯 注意事项

1. 预览图可能因操作系统和渲染引擎而有所不同
2. 建议在实际使用环境中测试字体效果
3. 不同的终端和编辑器可能有不同的字体渲染设置

---

如果您创建了更好的预览图，欢迎提交 PR 分享给社区！