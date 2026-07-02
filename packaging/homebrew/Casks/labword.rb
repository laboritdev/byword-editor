cask "labword" do
  version "1.0.3"
  sha256 "d89a22424d89feb733af21fab0fd5b5b2138e26b6ea8c2ac04e5512eb03a05a9"

  url "https://github.com/laboritdev/labword/releases/download/v1.0.3/LabWord-1.0.3-macos-arm64.zip"
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
