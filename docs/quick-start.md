# 快速入门指南

## 🎯 给项目维护者：如何发布字体

### 第一次发布

1. **确保环境准备就绪**
   ```bash
   # 测试构建脚本是否正常工作
   ./scripts/setup.sh
   ./scripts/build.sh --font "GoogleSansCode-Regular.ttf" --dry-run
   ```

2. **创建 GitHub Release**
   - 访问您的仓库页面
   - 点击右侧的 "Releases"
   - 点击 "Create a new release"
   - 填写版本信息：
     
     ```
     Tag version: v1.0.0
     Release title: Google Sans Code Nerd Font v1.0.0
     
     描述:
     ## 🎉 首次发布！
     
     Google Sans Code Nerd Font 现已可用！包含所有字重和 3600+ 个开发者图标。
     
     ### 📥 下载
     
     - **Complete**: 完整版（推荐）
     - **Mono**: 终端专用等宽版
     - **Propo**: 编辑器友好比例版
     
     ### 📋 包含字重
     
     Light, Regular, Medium, SemiBold, Bold, ExtraBold（及对应斜体）
     ```

3. **点击 "Publish release"**
   - GitHub Actions 会自动开始构建
   - 大约 10-15 分钟后，字体文件会自动上传到 Release

4. **验证发布**
   - 检查 [Actions](../actions) 页面确保构建成功
   - 确认 Release 页面显示了三个 zip 文件
   - 下载测试一个字体包

## 👥 给用户：如何下载和使用字体

### 快速下载

1. **访问 Releases 页面**
   - 点击项目页面的 [Releases](../releases)
   - 选择最新版本

2. **选择合适的版本**
   - 🎯 **Complete**: 包含所有图标，适合大多数用户
   - 💻 **Mono**: 等宽图标，适合终端用户
   - ✏️ **Propo**: 比例图标，适合代码编辑器

3. **下载并安装**
   - 点击 zip 文件下载
   - 解压到任意文件夹
   - 双击 `.ttf` 文件安装字体

### 配置您的工具

#### VS Code
```json
{
    "editor.fontFamily": "'GoogleSansCodeNerdFont', monospace",
    "terminal.integrated.fontFamily": "GoogleSansCodeNerdFont Mono"
}
```

#### Windows Terminal
```json
{
    "profiles": {
        "defaults": {
            "fontFace": "GoogleSansCodeNerdFont Mono"
        }
    }
}
```

#### iTerm2 (macOS)
1. iTerm2 → Preferences → Profiles → Text
2. Font → "GoogleSansCodeNerdFont Mono"

### 验证安装

在终端中输入以下命令，如果看到图标则安装成功：

```bash
echo -e "\ue0b0 \uf09b \uf413 \ue702"  # 应该显示箭头、GitHub、锁和Git图标
```

## 🔧 故障排除

### 字体未出现在列表中

1. **重启应用**: 安装字体后重启终端/编辑器
2. **检查字体名称**: 使用完整名称 "GoogleSansCodeNerdFont"
3. **手动安装**: 复制字体文件到系统字体目录

### 图标显示为方块

1. **选择正确版本**: 确保使用 Nerd Font 版本
2. **检查字体**: 某些应用需要明确指定字体
3. **编码问题**: 确保终端支持 UTF-8

### 构建失败（维护者）

1. **检查 Actions 日志**: 查看具体错误
2. **本地测试**: 运行 `./scripts/build.sh --verbose`
3. **依赖问题**: 重新运行 `./scripts/setup.sh`

## 🆘 获取帮助

- 📝 [创建 Issue](../issues) - 报告问题
- 💬 [参与讨论](../discussions) - 提问交流
- 📚 [查看文档](./examples.md) - 详细使用指南

---

**快速链接**:
- 🏠 [项目主页](../)
- 📦 [下载字体](../releases)
- 📖 [详细文档](./examples.md)
- 🚀 [发布指南](./release-guide.md)