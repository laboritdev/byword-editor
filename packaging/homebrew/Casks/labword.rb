cask "labword" do
  version "1.0.7"
  sha256 "c4703f373ad48937958af5e7701d2478f626c1c44d3272ed36c0fcd17840d49a"

  url "https://github.com/laboritdev/labword/releases/download/v1.0.7/LabWord-1.0.7-macos-arm64.zip"
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
