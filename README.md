# Google Sans Code Nerd Font

**English** | [中文](README_zh.md)

An open-source project that adds Nerd Font icon support to Google Sans Code font.

## 📖 About

Google Sans Code is an excellent programming font from Google, but there's no official Nerd Font version. This project uses the official Nerd Font patcher to add 3600+ icons to all weights of Google Sans Code, including:

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

## 🚀 Quick Start

### Method 1: Download Pre-built Fonts (Recommended)

1. Visit the [GitHub Actions](../../actions) page
2. Click the latest successful build
3. Download `google-sans-code-nerd-font` from "Artifacts" section
4. Extract and install font files

### Method 2: Local Build

#### Prerequisites

- Python 3.7+
- FontForge and python3-fontforge

**Ubuntu/Debian:**
```bash
sudo apt-get install fontforge python3-fontforge
```

**macOS:**
```bash
brew install fontforge
```

#### Build Steps

1. Clone the repository:
```bash
git clone https://github.com/your-username/google-sans-code-nerd-font.git
cd google-sans-code-nerd-font
```

2. Run test build:
```bash
./test-build.sh
```

3. Or build manually:
```bash
mkdir -p tools output
cd tools
curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FontPatcher.zip -o FontPatcher.zip
unzip FontPatcher.zip
chmod +x font-patcher

# Process all fonts
for font in ../data/google-sans-code/static/*.ttf; do
  fontforge -script font-patcher "$font" --complete --outputdir ../output/
done
```

## 📁 Project Structure

```
├── data/
│   └── google-sans-code/          # Original Google Sans Code font files
│       ├── static/                # Static font files (TTF)
│       ├── GoogleSansCode-*.ttf   # Variable font files
│       └── OFL.txt               # Open Font License
├── .github/
│   └── workflows/
│       └── build-fonts.yml       # GitHub Actions auto-build config
├── test-build.sh                 # Local test build script
└── README.md
```

## 🤖 Automated Build

This project uses GitHub Actions to automatically build fonts:

- **Trigger**: Push to main branch or manual trigger
- **Environment**: Ubuntu Latest + Docker  
- **Process**: All static font files (12 weights)
- **Output**: TTF format with complete Nerd Font icon set
- **Artifacts**: 90-day retention with all built fonts and release packages

### 🐳 Docker Solution

To solve compatibility issues with `python3-fontforge` in Ubuntu 24.04, we adopted a Docker containerized solution:

- Uses official `nerdfonts/patcher:latest` Docker image
- Avoids FontForge Python binding version conflicts
- Ensures build environment consistency and reliability
- Supports complete `--complete` parameter with all icon sets

### Build Process

1. **Environment Setup**: Install Docker and pull Nerd Font Patcher image
2. **Font Processing**: Use containerized Font Patcher to batch process fonts
3. **Verification**: Ensure generated font file integrity
4. **Package Upload**: Create release package and upload Artifacts

## 💡 Font Features

### Supported Weights

- **Light** (300) + Italic
- **Regular** (400) + Italic  
- **Medium** (500) + Italic
- **SemiBold** (600) + Italic
- **Bold** (700) + Italic
- **ExtraBold** (800) + Italic

### Icon Support

- ✅ 3600+ programming-related icons
- ✅ Complete Powerline support
- ✅ Perfect terminal and editor compatibility
- ✅ Maintains excellent readability of original font

## 🛠️ Usage Instructions

### Terminal Configuration

After installing the fonts, set the font family in your terminal to:
- **Font Name**: `GoogleSansCodeNerdFont`
- **Alternative Name**: `GoogleSansCode Nerd Font`

### Editor Configuration

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

## 🔧 Troubleshooting

### Font Display Issues

1. **Icons display as squares**: Confirm you installed the Nerd Font version
2. **Font not taking effect**: Restart application or clear font cache
3. **Spacing issues**: Use monospace version (Mono)

### Build Issues

1. **FontForge import error**: Confirm python3-fontforge is installed
2. **Out of memory**: Process font files separately, avoid batch processing
3. **Permission issues**: Ensure scripts have execute permissions

## 📄 License

- **Original Font**: Google Sans Code uses [SIL Open Font License 1.1](data/google-sans-code/OFL.txt)
- **Nerd Font Icons**: Respective original licenses
- **Build Scripts**: MIT License

## 🤝 Contributing

Issues and Pull Requests are welcome!

### Contribution Guidelines

1. Fork this repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push branch: `git push origin feature/amazing-feature`
5. Submit Pull Request

## 🔗 Related Links

- [Google Sans Code Official Repository](https://github.com/googlefonts/googlesans-code)
- [Nerd Fonts Project](https://github.com/ryanoasis/nerd-fonts)
- [Font Patcher Documentation](https://github.com/ryanoasis/nerd-fonts#font-patcher)

---

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=wylu1037/google-sans-code-nerd-font&type=Date)](https://star-history.com/#your-username/google-sans-code-nerd-font&Date)

---

**⭐ If this project helps you, please give it a Star!**
