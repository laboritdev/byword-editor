cask "labword" do
  version "1.0.2"
  sha256 "2a7a26d22ea346cfba0fd791d9ad075786406771cc9319e198a558671d49dac1"

  url "https://github.com/laboritdev/labword/releases/download/v1.0.2/LabWord-1.0.2-macos-arm64.zip"
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
