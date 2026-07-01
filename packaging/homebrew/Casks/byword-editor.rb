cask "byword-editor" do
  version "1.0.0"
  sha256 "5776fb3c9637be797f93b1cc07bd36cd5b96c64c3dbeed31b50881607c8b9f3c"

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
