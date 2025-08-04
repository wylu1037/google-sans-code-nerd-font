# Homebrew Installation Guide

## Quick Installation

### Official Homebrew Fonts (Recommended)
```bash
brew install font-google-sans-code-nerd
```

### Alternative: Direct Cask
```bash
brew install --cask google-sans-code-nerd-font
```

## How it Works

This repository includes a Homebrew Cask formula that allows macOS users to install Google Sans Code Nerd Font easily through Homebrew.

### What the Cask Does

1. **Downloads**: Automatically downloads the latest `GoogleSansCodeNerdFont.zip` from GitHub Releases
2. **Installs**: Installs all 12 font variants to your system:
   - GoogleSansCodeNerdFont-Regular.ttf
   - GoogleSansCodeNerdFont-Bold.ttf
   - GoogleSansCodeNerdFont-Light.ttf
   - GoogleSansCodeNerdFont-Medium.ttf
   - GoogleSansCodeNerdFont-SemiBold.ttf
   - GoogleSansCodeNerdFont-ExtraBold.ttf
   - And their italic variants
3. **Configures**: Makes the fonts available system-wide

## Using the Font

After installation, you can use the font in:

### Terminal Applications
Set your terminal font to:
- **Font Name**: `Google Sans Code Nerd`
- **Family Name**: `Google Sans Code Nerd`

### Text Editors & IDEs
- VS Code: `"editor.fontFamily": "'Google Sans Code Nerd'"`
- Sublime Text: `"font_face": "Google Sans Code Nerd"`
- Vim/Neovim: `set guifont=Google\ Sans\ Code\ Nerd:h12`

## Submitting to Homebrew Official Taps

To make this font available in the official Homebrew cask-fonts tap, we would need to:

1. Submit a PR to [homebrew/homebrew-cask-fonts](https://github.com/Homebrew/homebrew-cask-fonts)
2. Follow their naming conventions (they typically use `font-` prefix)
3. The formula would be located at: `Casks/font-google-sans-code-nerd-font.rb`

### Official Submission Formula Example

```ruby
cask "font-google-sans-code-nerd-font" do
  version :latest
  sha256 :no_check

  url "https://github.com/wenyanglu/google-sans-code-nerd-font/releases/latest/download/GoogleSansCodeNerdFont.zip"
  name "Google Sans Code Nerd Font"
  desc "Google Sans Code font patched with Nerd Fonts"
  homepage "https://github.com/wenyanglu/google-sans-code-nerd-font"

  livecheck do
    url :url
    strategy :github_latest
  end

  font "GoogleSansCodeNerdFont-Bold.ttf"
  font "GoogleSansCodeNerdFont-BoldItalic.ttf"
  font "GoogleSansCodeNerdFont-ExtraBold.ttf"
  font "GoogleSansCodeNerdFont-ExtraBoldItalic.ttf"
  font "GoogleSansCodeNerdFont-Italic.ttf"
  font "GoogleSansCodeNerdFont-Light.ttf"
  font "GoogleSansCodeNerdFont-LightItalic.ttf"
  font "GoogleSansCodeNerdFont-Medium.ttf"
  font "GoogleSansCodeNerdFont-MediumItalic.ttf"
  font "GoogleSansCodeNerdFont-Regular.ttf"
  font "GoogleSansCodeNerdFont-SemiBold.ttf"
  font "GoogleSansCodeNerdFont-SemiBoldItalic.ttf"
end
```

## Troubleshooting

### Font Cache Issues
If the font doesn't appear after installation:
```bash
# Clear font cache
sudo atsutil databases -remove
# Restart font management
sudo atsutil server -shutdown
sudo atsutil server -ping
```

### Manual Installation
If Homebrew installation fails, you can always download and install manually:
1. Download from [Releases](https://github.com/wenyanglu/google-sans-code-nerd-font/releases/latest)
2. Double-click each `.ttf` file to install
3. Or drag to Font Book application

## Development

The Cask formula is maintained in this repository at `Casks/google-sans-code-nerd-font.rb`.

For updates or issues with the Homebrew installation, please open an issue in this repository.