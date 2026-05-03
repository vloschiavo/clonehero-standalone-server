#!/bin/bash
set -euo pipefail

# Load .env if not already set
if [[ -f "$(dirname "$0")/../.env" ]]; then
  source "$(dirname "$0")/../.env"
fi

: "${ZIP_URL:?ZIP_URL must be set in .env or environment}"
: "${VERSION:?VERSION must be set in .env or environment}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BINS_DIR="$ROOT_DIR/server-bins"
ZIP_FILE="$ROOT_DIR/CloneHeroServer.zip"

LINUX_TARGETS=(linux-x64 linux-arm linux-arm64 linux-musl)
WINDOWS_TARGETS=(win-x64 win-x86)
ALL_TARGETS=("${LINUX_TARGETS[@]}" "${WINDOWS_TARGETS[@]}")

# Check if already extracted
if [[ -d "$BINS_DIR" ]]; then
  echo "server-bins/ already exists. Skipping download."
  echo "To re-fetch, delete ./server-bins and re-run."
  exit 0
fi

# Download
echo "Downloading CloneHero Standalone Server v${VERSION}..."
curl -L --progress-bar "$ZIP_URL" -o "$ZIP_FILE"

# Extract
echo "Extracting zip..."
mkdir -p "$BINS_DIR"
unzip -q "$ZIP_FILE" -d "$BINS_DIR"

# The zip extracts into a subdirectory CloneHero-StandaloneServer/
# Move contents up one level
EXTRACTED_DIR="$BINS_DIR/CloneHero-StandaloneServer"
if [[ -d "$EXTRACTED_DIR" ]]; then
  mv "$EXTRACTED_DIR"/* "$BINS_DIR/"
  rmdir "$EXTRACTED_DIR"
fi

# Cleanup zip
rm -f "$ZIP_FILE"

# chmod +x Linux binaries
echo "Setting execute permissions on Linux binaries..."
for target in "${LINUX_TARGETS[@]}"; do
  BIN="$BINS_DIR/$target/Server"
  if [[ -f "$BIN" ]]; then
    chmod +x "$BIN"
    echo "  chmod +x $target/Server"
  else
    echo "  WARNING: Expected binary not found: $target/Server"
  fi
done

# Verify Windows binaries exist
echo "Verifying Windows binaries..."
for target in "${WINDOWS_TARGETS[@]}"; do
  BIN="$BINS_DIR/$target/Server.exe"
  if [[ -f "$BIN" ]]; then
    echo "  OK: $target/Server.exe"
  else
    echo "  WARNING: Expected binary not found: $target/Server.exe"
  fi
done

echo ""
echo "Done. Binaries available in: $BINS_DIR"
