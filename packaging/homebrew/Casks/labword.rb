cask "labword" do
  version "1.0.5"
  sha256 "772c20dbe0d99dae1f70a032c27a6b144ea8b858913a624761f48fb9fca454b8"

  url "https://github.com/laboritdev/labword/releases/download/v1.0.5/LabWord-1.0.5-macos-arm64.zip"
  name "LabWord"
  desc "Minimalist Markdown editor for macOS by Laborit"
  homepage "https://github.com/laboritdev/labword"

  depends_on macos: :sonoma

  app "LabWord.app"

  zap trash: [
    "~/Library/Application Support/LabWord",
    "~/Library/Preferences/com.labword.app.plist",
  ]
end
