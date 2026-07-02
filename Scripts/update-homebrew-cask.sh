#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${1:?Usage: $0 <version> <sha256> [arch]}"
SHA256="${2:?Usage: $0 <version> <sha256> [arch]}"
ARCH="${3:-arm64}"

CASK_PATH="$ROOT/packaging/homebrew/Casks/labword.rb"
TAG="v${VERSION#v}"
URL="https://github.com/laboritdev/labword/releases/download/${TAG}/LabWord-${VERSION}-macos-${ARCH}.zip"

cat > "$CASK_PATH" <<RUBY
cask "labword" do
  version "${VERSION#v}"
  sha256 "${SHA256}"

  url "${URL}"
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
RUBY

echo "Updated $CASK_PATH"
