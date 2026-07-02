cask "labword" do
  version "1.0.6"
  sha256 "148b9311200505871d045d21214dd1eeeb2ddee1e4bf5b5cd1c3c62ef571c6ca"

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
