# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project setup
- Cross-platform build scripts (Unix/Windows)
- Automated GitHub Actions workflow
- Support for all Google Sans Code font weights
- Three build variants: Complete, Mono, and Propo
- Comprehensive documentation in Chinese
- Python-based single font patcher utility

### Features
- ✨ Complete Nerd Font icon integration (3600+ icons)
- 🔧 Cross-platform compatibility (Linux, macOS, Windows)
- ⚡ Parallel font processing for faster builds
- 🎯 Support for all Google Sans Code weights and styles
- 📦 Automated CI/CD with GitHub Actions
- 🐍 Python utility for advanced font patching
- 📚 Comprehensive Chinese documentation

### Icon Sets Included
- Font Awesome (5000+ icons)
- Material Design Icons (7000+ icons) 
- Octicons (GitHub icons)
- Powerline Symbols
- Devicons (Developer icons)
- Weather Icons
- Codicons (VS Code icons)
- Pomicons
- Font Logos
- IEC Power Symbols

### Build Variants
- **Complete**: Full icon set with double-width glyphs (recommended)
- **Mono**: Single-width glyphs for terminal use
- **Propo**: Proportional-width glyphs

### Supported Font Weights
- Regular / Italic
- Light / Light Italic  
- Medium / Medium Italic
- SemiBold / SemiBold Italic
- Bold / Bold Italic
- ExtraBold / ExtraBold Italic

### Technical Details
- Based on official Nerd Fonts patcher v3.4.0+
- Uses FontForge for font manipulation
- Supports both static and variable fonts
- Automatic font naming following Nerd Font conventions
- Parallel processing for improved build performance

## [1.0.0] - TBD

### Added
- Initial release of Google Sans Code Nerd Font
- Complete build infrastructure
- Documentation and contribution guidelines

### Planned Features for Future Releases

#### v1.1.0 (Minor Update)
- [ ] Web font support (WOFF/WOFF2)
- [ ] Font preview generation
- [ ] Docker container for isolated builds
- [ ] Additional language documentation (English)

#### v1.2.0 (Feature Update)  
- [ ] Custom icon set configuration
- [ ] Ligature preservation options
- [ ] Font subsetting capabilities
- [ ] Performance optimizations

#### v2.0.0 (Major Update)
- [ ] GUI application for font patching
- [ ] Plugin system for custom processors
- [ ] Cloud-based font generation
- [ ] Integration with font managers

### Known Issues
- None currently reported

### Dependencies
- FontForge >= 20141231
- Python >= 3.6
- fonttools Python package

### Breaking Changes
- None in initial release

---

## Development Notes

### Version Numbering
We follow [Semantic Versioning](https://semver.org/):
- **MAJOR**: Incompatible API changes
- **MINOR**: Backward-compatible functionality additions
- **PATCH**: Backward-compatible bug fixes

### Release Process
1. Update version numbers in documentation
2. Update this CHANGELOG.md
3. Create Git tag (e.g., `v1.0.0`)
4. GitHub Actions automatically builds and creates release
5. Font packages are automatically uploaded to GitHub Releases

### Contribution
See [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to contribute to this project.

### License
This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

### Acknowledgments
- [Google Fonts](https://fonts.google.com/) for the excellent Google Sans Code typeface
- [Nerd Fonts](https://www.nerdfonts.com/) for the amazing icon collection and patcher tools
- All the icon designers and maintainers of the various icon sets
- The open source community for FontForge and related tools