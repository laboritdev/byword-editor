cask "byword-editor" do
  version "1.0.0"
  sha256 "8bc7e708bdb87eafce7db32723977c6e600109edc8666a5ffbd04d38fd91a5c8"

  url "https://github.com/laboritdev/byword-editor/releases/download/v1.0.0/BywordEditor-1.0.0-macos-arm64.zip"
  name "BywordEditor"
  desc "Minimalist Markdown editor for macOS"
  homepage "https://github.com/laboritdev/byword-editor"

  depends_on macos: ">= :sonoma"

  app "BywordEditor.app"

  zap trash: [
    "~/Library/Application Support/BywordEditor",
    "~/Library/Preferences/com.bywordeditor.app.plist",
  ]
end
