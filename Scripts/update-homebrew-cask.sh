#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${1:?Usage: $0 <version> <sha256> [arch]}"
SHA256="${2:?Usage: $0 <version> <sha256> [arch]}"
ARCH="${3:-arm64}"

CASK_PATH="$ROOT/packaging/homebrew/Casks/byword-editor.rb"
TAG="v${VERSION#v}"
URL="https://github.com/laboritdev/byword-editor/releases/download/${TAG}/BywordEditor-${VERSION}-macos-${ARCH}.zip"

cat > "$CASK_PATH" <<RUBY
cask "byword-editor" do
  version "${VERSION#v}"
  sha256 "${SHA256}"

  url "${URL}"
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
RUBY

echo "Updated $CASK_PATH"
