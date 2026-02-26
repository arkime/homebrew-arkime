#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 6.0.0"
  exit 1
fi

VERSION=$1
TARBALL_URL="https://github.com/arkime/arkime/archive/refs/tags/v${VERSION}.tar.gz"

echo "Downloading v${VERSION} tarball to compute sha256..."
SHA=$(curl -sfL "$TARBALL_URL" | shasum -a 256 | cut -d' ' -f1)

if [ -z "$SHA" ]; then
  echo "Error: Failed to download tarball for v${VERSION}"
  exit 1
fi

echo "SHA256: ${SHA}"

cd "$(dirname "$0")/Formula"

for f in *.rb; do
  sed -i '' "s|archive/refs/tags/v.*\.tar\.gz|archive/refs/tags/v${VERSION}.tar.gz|" "$f"
  sed -i '' "s|sha256 \".*\"|sha256 \"${SHA}\"|" "$f"
  echo "Updated $f"
done

echo ""
echo "Done. Review changes with: git diff"
echo "Then: git commit -am 'Bump to v${VERSION}' && git push"
