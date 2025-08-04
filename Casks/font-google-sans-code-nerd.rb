cask "font-google-sans-code-nerd" do
  version :latest
  sha256 :no_check

  url "https://github.com/wylu1037/google-sans-code-nerd-font/releases/download/v1.0.0/google-sans-code-nerd-font.zip"
  name "Google Sans Code Nerd Font"
  desc "Google Sans Code font patched with Nerd Fonts"
  homepage "https://github.com/wylu1037/google-sans-code-nerd-font"

  livecheck do
    url :url
    strategy :github_latest
  end

  font "GoogleSansCodeNF-Bold.ttf"
  font "GoogleSansCodeNF-BoldItalic.ttf"
  font "GoogleSansCodeNF-ExtraBold.ttf"
  font "GoogleSansCodeNF-ExtraBoldItalic.ttf"
  font "GoogleSansCodeNF-Italic.ttf"
  font "GoogleSansCodeNF-Light.ttf"
  font "GoogleSansCodeNF-LightItalic.ttf"
  font "GoogleSansCodeNF-Medium.ttf"
  font "GoogleSansCodeNF-MediumItalic.ttf"
  font "GoogleSansCodeNF-Regular.ttf"
  font "GoogleSansCodeNF-SemiBold.ttf"
  font "GoogleSansCodeNF-SemiBoldItalic.ttf"

  # Optional: Add caveats for installation instructions
  caveats do
    <<~EOS
      Google Sans Code Nerd Font has been installed.
      
      To use in your applications:
      
      VS Code settings.json:
      {
        "editor.fontFamily": "'Google Sans Code NF'"
      }
      
      Terminal: Select "Google Sans Code NF" as your font family
      
      The font includes 3600+ programming and UI icons from:
      - Font Awesome, Material Design Icons, Octicons
      - Powerline Symbols, Devicons, Weather Icons
      - Codicons, Pomicons, Font Logos, and more
      
      For more information: https://github.com/wylu1037/google-sans-code-nerd-font
    EOS
  end
end