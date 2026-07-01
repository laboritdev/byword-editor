cask "byword-editor" do
  version "1.0.2"
  sha256 "74e60e2a1894e6b717ff059d5e3e63f84b536dc8fa5e04dd1bb3929fe4af5615"

  url "https://github.com/laboritdev/byword-editor/releases/download/v1.0.2/BywordEditor-1.0.2-macos-arm64.zip"
  name "BywordEditor"
  desc "Minimalist Markdown editor for macOS"
  homepage "https://github.com/laboritdev/byword-editor"

  depends_on macos: :sonoma

  app "BywordEditor.app"

  zap trash: [
    "~/Library/Application Support/BywordEditor",
    "~/Library/Preferences/com.bywordeditor.app.plist",
  ]
end
