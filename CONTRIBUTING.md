# 贡献指南

感谢您对 Google Sans Code Nerd Font 项目的关注！我们欢迎所有形式的贡献。

## 🤝 如何贡献

### 报告问题

如果您发现了 bug 或有功能建议，请：

1. 检查是否已有相关的 [Issue](../../issues)
2. 如果没有，请创建新的 Issue，包含：
   - 清晰的标题和描述
   - 重现步骤（如果是 bug）
   - 预期行为和实际行为
   - 系统环境信息（操作系统、版本等）
   - 相关的错误日志或截图

### 提交代码

1. **Fork 项目**
   ```bash
   # 在 GitHub 上 Fork 项目
   # 然后克隆您的 Fork
   git clone https://github.com/您的用户名/google-sans-code-nerd-font.git
   cd google-sans-code-nerd-font
   ```

2. **创建分支**
   ```bash
   git checkout -b feature/您的功能名称
   # 或
   git checkout -b fix/修复的问题
   ```

3. **设置开发环境**
   ```bash
   # Unix/Linux/macOS
   ./scripts/setup.sh
   
   # Windows
   ./scripts/setup.ps1
   ```

4. **进行更改**
   - 遵循现有的代码风格
   - 添加必要的注释
   - 更新相关文档

5. **测试更改**
   ```bash
   # 测试构建脚本
   ./scripts/build.sh --dry-run
   
   # 测试特定字体
   ./scripts/build.sh --font GoogleSansCode-Regular.ttf --dry-run
   ```

6. **提交更改**
   ```bash
   git add .
   git commit -m "feat: 添加新功能" 
   # 或
   git commit -m "fix: 修复构建问题"
   ```

7. **推送到您的 Fork**
   ```bash
   git push origin feature/您的功能名称
   ```

8. **创建 Pull Request**
   - 在 GitHub 上创建 Pull Request
   - 提供清晰的标题和描述
   - 引用相关的 Issue（如果有）

## 📝 代码规范

### Bash 脚本

- 使用 4 个空格缩进
- 函数名使用 snake_case
- 变量名使用 UPPER_CASE（全局变量）或 lower_case（局部变量）
- 添加必要的错误处理
- 使用 `set -e` 启用错误时退出

```bash
#!/bin/bash
set -e

# 全局变量
DEFAULT_OUTPUT_DIR="patched-fonts"

# 函数示例
process_font() {
    local font_file="$1"
    local output_dir="$2"
    
    # 函数逻辑
}
```

### PowerShell 脚本

- 使用 4 个空格缩进
- 函数名使用 PascalCase
- 变量名使用 camelCase
- 使用 `param()` 定义参数
- 添加适当的错误处理

```powershell
param(
    [string]$FontFile,
    [string]$OutputDir = "patched-fonts"
)

function Invoke-FontProcessing {
    param(
        [string]$FontFile,
        [string]$OutputDir
    )
    
    # 函数逻辑
}
```

### 文档

- 使用清晰、简洁的中文
- 为新功能添加示例
- 更新 README.md（如果需要）
- 保持文档与代码同步

## 🧪 测试

### 本地测试

1. **环境测试**
   ```bash
   # 验证设置脚本
   ./scripts/setup.sh
   
   # 验证依赖
   fontforge --version
   python --version
   ```

2. **构建测试**
   ```bash
   # 完整构建测试
   ./scripts/build.sh --font GoogleSansCode-Regular.ttf
   
   # 预览模式测试
   ./scripts/build.sh --dry-run
   ```

3. **跨平台测试**
   - 在不同操作系统上测试脚本
   - 确保路径处理正确
   - 验证字体输出质量

### CI/CD 测试

项目使用 GitHub Actions 进行自动化测试：

- **构建测试**: 验证所有字体可以正确构建
- **环境测试**: 在 Ubuntu、macOS、Windows 上测试
- **脚本测试**: 验证脚本语法和功能

## 📦 发布流程

### 版本号

使用语义化版本控制 (SemVer)：

- `MAJOR.MINOR.PATCH`
- `MAJOR`: 不兼容的 API 变更
- `MINOR`: 向后兼容的功能增加
- `PATCH`: 向后兼容的 bug 修复

### 发布步骤

1. **更新版本**
   - 更新 README.md 中的版本信息
   - 更新 CHANGELOG.md

2. **创建标签**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

3. **GitHub Release**
   - GitHub Actions 自动创建 Release
   - 自动构建并上传字体包

## 🎯 项目结构

```
google-sans-code-nerd-font/
├── Google Sans Code/          # 源字体文件
├── scripts/                   # 构建脚本
│   ├── setup.sh              # Unix 环境设置
│   ├── setup.ps1             # Windows 环境设置
│   ├── build.sh              # Unix 构建脚本
│   └── build.ps1             # Windows 构建脚本
├── .github/workflows/         # GitHub Actions
├── src/                       # Nerd Font patcher 和配置
├── patched-fonts/            # 输出目录（构建时创建）
├── docs/                     # 文档和预览图
├── README.md                 # 项目说明
├── CONTRIBUTING.md           # 本文档
├── LICENSE                   # 许可证
└── CHANGELOG.md              # 变更日志
```

## 💡 贡献想法

我们欢迎以下类型的贡献：

### 代码贡献

- 🚀 **新功能**: 
  - 添加新的构建选项
  - 改进并行处理性能
  - 增强错误处理
  
- 🐛 **Bug 修复**:
  - 修复跨平台兼容性问题
  - 解决构建错误
  - 改进脚本稳定性

- 🎨 **改进**:
  - 优化构建速度
  - 简化使用流程
  - 增强用户体验

### 文档贡献

- 📚 **文档完善**:
  - 添加更多使用示例
  - 改进安装说明
  - 翻译到其他语言

- 🖼️ **视觉内容**:
  - 创建字体预览图
  - 设计项目 Logo
  - 制作使用演示

### 社区贡献

- 🗣️ **推广项目**:
  - 在博客或社交媒体分享
  - 在相关社区介绍项目
  - 为项目写教程

- 🤝 **用户支持**:
  - 回答 Issues 中的问题
  - 帮助新用户解决问题
  - 分享使用经验

## ❓ 需要帮助？

如果您在贡献过程中遇到问题：

1. 查看 [Issues](../../issues) 中是否有相关讨论
2. 创建新的 Issue 寻求帮助
3. 在 [Discussions](../../discussions) 中参与讨论

## 🏆 贡献者

感谢所有为此项目做出贡献的人！

<!-- 这里将显示贡献者列表 -->

---

再次感谢您的贡献！每一个贡献都让这个项目变得更好。🎉