cask "labword" do
  version "1.0.4"
  sha256 "184db633b604ca5c89b041d95e76ae3ef016b38cd3c533815571261072d136de"

  url "https://github.com/laboritdev/labword/releases/download/v1.0.4/LabWord-1.0.4-macos-arm64.zip"
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
