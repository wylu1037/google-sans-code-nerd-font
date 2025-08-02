# 发布指南

本文档说明如何发布 Google Sans Code Nerd Font 新版本，让用户能够下载构建好的字体文件。

## 🚀 发布流程

### 1. 准备发布

在发布之前，确保：

- [ ] 所有字体文件已更新
- [ ] 文档已更新（README.md, CHANGELOG.md）
- [ ] 版本号已确定
- [ ] 测试通过

### 2. 创建 GitHub Release

#### 方法一：通过 GitHub 网页界面

1. **访问项目页面**
   - 进入您的 GitHub 仓库
   - 点击右侧的 "Releases"

2. **创建新 Release**
   - 点击 "Create a new release"
   - 填写以下信息：

   ```
   Tag version: v1.0.0
   Release title: Google Sans Code Nerd Font v1.0.0
   
   描述:
   ## Google Sans Code Nerd Font v1.0.0
   
   ### ✨ 新功能
   - 首次发布 Google Sans Code Nerd Font
   - 包含所有字重和样式
   - 支持 3600+ 个 Nerd Font 图标
   
   ### 📦 下载文件
   
   选择适合您需求的版本：
   
   - **Complete**: 包含所有图标的完整版本（推荐大多数用户）
   - **Mono**: 等宽图标版本（推荐终端用户）  
   - **Propo**: 比例宽度图标版本（推荐编辑器用户）
   
   ### 💾 安装方法
   
   1. 下载对应的 zip 文件
   2. 解压后安装 .ttf 字体文件
   3. 在终端或编辑器中选择 "GoogleSansCodeNerdFont" 字体系列
   ```

3. **发布 Release**
   - 确保取消勾选 "Set as a pre-release"（除非是预发布版本）
   - 点击 "Publish release"

#### 方法二：通过命令行

```bash
# 确保所有更改已提交
git add .
git commit -m "Release v1.0.0"
git push origin main

# 创建并推送标签
git tag v1.0.0
git push origin v1.0.0
```

然后在 GitHub 网页界面创建 Release（引用刚创建的标签）。

### 3. 自动构建过程

当您创建 Release 后，GitHub Actions 会自动：

1. **触发构建**: 检测到 release 事件
2. **环境设置**: 安装 FontForge 和相关依赖
3. **下载资源**: 获取 Nerd Font patcher 和图标文件
4. **并行构建**: 同时构建三种版本的字体
   - Complete: 完整图标集
   - Mono: 等宽图标
   - Propo: 比例图标
5. **创建压缩包**: 将每种版本打包为 zip 文件
6. **上传到 Release**: 自动附加到 GitHub Release

### 4. 构建状态监控

您可以在以下位置监控构建状态：

- **Actions 页面**: `https://github.com/您的用户名/google-sans-code-nerd-font/actions`
- **Release 页面**: 构建完成后文件会自动出现

典型的构建时间：
- **单个字体**: 约 30-60 秒
- **所有字体**: 约 5-15 分钟（取决于字体数量和并行度）

## 📋 发布检查清单

### 发布前检查

- [ ] 确保 `Google Sans Code` 目录包含最新的字体文件
- [ ] 更新 `CHANGELOG.md` 记录新版本的变化
- [ ] 更新 `README.md` 中的版本信息（如需要）
- [ ] 运行本地测试确保构建脚本正常工作
- [ ] 检查 GitHub Actions 配置是否最新

### 发布后验证

- [ ] 验证 GitHub Actions 构建成功
- [ ] 确认 Release 页面显示了所有三个 zip 文件
- [ ] 下载并测试其中一个字体包
- [ ] 验证字体文件完整性和图标显示
- [ ] 检查 Release 说明是否正确

## 📦 发布文件结构

每个 Release 将包含以下文件：

```
Release Assets/
├── GoogleSansCodeNerdFont-Complete.zip    # 完整版 (~50-100MB)
├── GoogleSansCodeNerdFont-Mono.zip        # 等宽版 (~50-100MB)  
└── GoogleSansCodeNerdFont-Propo.zip       # 比例版 (~50-100MB)
```

每个 zip 文件内容：
```
GoogleSansCodeNerdFont-Complete/
├── GoogleSansCodeNerdFont-Light.ttf
├── GoogleSansCodeNerdFont-LightItalic.ttf
├── GoogleSansCodeNerdFont-Regular.ttf
├── GoogleSansCodeNerdFont-Italic.ttf
├── GoogleSansCodeNerdFont-Medium.ttf
├── GoogleSansCodeNerdFont-MediumItalic.ttf
├── GoogleSansCodeNerdFont-SemiBold.ttf
├── GoogleSansCodeNerdFont-SemiBoldItalic.ttf
├── GoogleSansCodeNerdFont-Bold.ttf
├── GoogleSansCodeNerdFont-BoldItalic.ttf
├── GoogleSansCodeNerdFont-ExtraBold.ttf
└── GoogleSansCodeNerdFont-ExtraBoldItalic.ttf
```

## 🔄 版本管理

### 版本号规范

遵循 [语义化版本](https://semver.org/lang/zh-CN/) 规范：

- **主版本号**: 不兼容的变更（如字体格式变化）
- **次版本号**: 向后兼容的功能增加（如新图标集）
- **修订号**: 向后兼容的问题修复

示例：
- `v1.0.0`: 首次正式发布
- `v1.1.0`: 添加了新的图标集
- `v1.1.1`: 修复了构建脚本的问题
- `v2.0.0`: 重大更新，可能不兼容旧版本

### 发布频率建议

- **重大更新**: 当 Google Sans Code 有重要更新时
- **功能更新**: 当 Nerd Fonts 增加新图标集时
- **修复更新**: 当发现重要 bug 时
- **定期更新**: 每季度检查并更新依赖

## 🚨 故障排除

### 构建失败

如果 GitHub Actions 构建失败：

1. **检查 Actions 日志**: 查看具体错误信息
2. **常见问题**:
   - FontForge 安装失败
   - 网络问题导致依赖下载失败
   - 字体文件路径问题
3. **解决方案**: 
   - 重新触发构建
   - 更新依赖版本
   - 修复配置文件

### Release 文件缺失

如果 Release 中缺少文件：

1. 检查 GitHub Actions 是否成功完成
2. 查看 artifacts 是否正确上传
3. 验证 release 工作流是否正确触发

### 字体质量问题

如果生成的字体有问题：

1. 本地测试构建脚本
2. 检查源字体文件
3. 验证 Nerd Font patcher 版本
4. 测试不同的构建选项

## 📞 获取帮助

如果遇到发布问题：

- 查看 [GitHub Actions 文档](https://docs.github.com/en/actions)
- 创建 [Issue](../../issues) 报告问题
- 参考 [Nerd Fonts 文档](https://github.com/ryanoasis/nerd-fonts)

---

**注意**: 首次发布可能需要更长时间，后续发布会利用缓存加速构建过程。