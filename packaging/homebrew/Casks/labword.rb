cask "labword" do
  version "1.0.6"
  sha256 "1eaf5d0c89c8f8c5a600a942c30266a016e22beb5608d22656dd6d2c074fe861"

  url "https://github.com/laboritdev/labword/releases/download/v1.0.6/LabWord-1.0.6-macos-arm64.zip"
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
