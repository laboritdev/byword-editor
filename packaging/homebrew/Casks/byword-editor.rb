cask "byword-editor" do
  version "1.0.0"
  sha256 "PLACEHOLDER_UPDATE_ON_FIRST_RELEASE"

  url "https://github.com/laboritdev/byword-editor/releases/download/v#{version}/BywordEditor-#{version}-macos-arm64.zip"
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
