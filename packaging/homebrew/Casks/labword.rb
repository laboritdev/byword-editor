cask "labword" do
  version "1.0.6"
  sha256 "1a7d18b58db5324d88a6246beac0b67e107beb7add053f09fb3fd2289882e186"

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
