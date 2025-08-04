cask "google-sans-code-nerd-font" do
  version :latest
  sha256 :no_check

  url "https://github.com/wylu1037/google-sans-code-nerd-font/releases/latest/download/GoogleSansCodeNerdFont.zip"
  name "Google Sans Code Nerd Font"
  desc "Google Sans Code font patched with Nerd Fonts"
  homepage "https://github.com/wylu1037/google-sans-code-nerd-font"

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

  # Optional: Add caveats for installation instructions
  caveats do
    <<~EOS
      Google Sans Code Nerd Font has been installed.
      
      To use in your terminal:
      1. Set your terminal font to "GoogleSansCodeNerdFont"
      2. Or use the family name "Google Sans Code Nerd Font"
      
      The font includes 3600+ programming and UI icons from:
      - Font Awesome, Material Design Icons, Octicons
      - Powerline Symbols, Devicons, Weather Icons
      - Codicons, Pomicons, Font Logos, and more
      
      For more information: https://github.com/wylu1037/google-sans-code-nerd-font
    EOS
  end
end