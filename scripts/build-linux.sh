#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load .env
if [[ -f "$ROOT_DIR/.env" ]]; then
  source "$ROOT_DIR/.env"
fi

: "${VERSION:?VERSION must be set in .env or environment}"
: "${IMAGE_NAME:?IMAGE_NAME must be set in .env or environment}"

# Fetch binaries if needed
"$SCRIPT_DIR/fetch-server.sh"

# ---------------------------------------------------------------------------
# Builder setup
# ---------------------------------------------------------------------------

BUILDER_NAME="clonehero-multiarch"

# Create a new buildx builder if it doesn't already exist
if ! docker buildx inspect "$BUILDER_NAME" &>/dev/null; then
  echo "Creating buildx builder: $BUILDER_NAME"
  docker buildx create \
    --name "$BUILDER_NAME" \
    --driver docker-container \
    --platform linux/amd64,linux/arm/v7,linux/arm64 \
    --use
else
  echo "Using existing buildx builder: $BUILDER_NAME"
  docker buildx use "$BUILDER_NAME"
fi

# Ensure QEMU binfmt handlers are registered for cross-arch emulation
echo "Registering QEMU binfmt handlers..."
docker run --rm --privileged tonistiigi/binfmt --install all

# ---------------------------------------------------------------------------
# Build matrix
# ---------------------------------------------------------------------------
# Ordered arrays guarantee iteration order.
# Each arch is built one at a time with --load so the image lands in the
# local Docker image store for testing. --load only works for single-platform
# builds, which is why we loop instead of passing all platforms at once.
#
# linux-musl shares linux/amd64 with linux-x64 so it is built and tagged
# separately and excluded from the multi-arch manifest.

ARCHES=(linux-x64 linux-arm linux-arm64)
PLATFORMS=(linux/amd64 linux/arm/v7 linux/arm64)

# Strip "-final" suffix for clean semver tags e.g. v1.1.0.6085
CLEAN_VERSION="${VERSION%-final}"

# ---------------------------------------------------------------------------
# Step 1: Build each Linux arch image locally
# ---------------------------------------------------------------------------

echo ""
echo "=== Building Linux arch images (local only, no push) ==="

for i in "${!ARCHES[@]}"; do
  ARCH="${ARCHES[$i]}"
  PLATFORM="${PLATFORMS[$i]}"
  TAG_ARCH="${IMAGE_NAME}:${VERSION}-${ARCH}"

  echo ""
  echo "--- Building $ARCH ($PLATFORM) -> $TAG_ARCH ---"

  docker buildx build \
    --builder "$BUILDER_NAME" \
    --platform "$PLATFORM" \
    --build-arg ARCH="$ARCH" \
    --file "$ROOT_DIR/docker/linux/Dockerfile" \
    --tag "$TAG_ARCH" \
    --load \
    "$ROOT_DIR"
done

# ---------------------------------------------------------------------------
# Step 2: Build linux-musl locally
# ---------------------------------------------------------------------------

echo ""
echo "=== Building linux-musl image (local only, no push) ==="

MUSL_TAGS=(
  "${IMAGE_NAME}:latest-musl"
  "${IMAGE_NAME}:v${CLEAN_VERSION}-musl"
)

MUSL_TAG_ARGS=()
for TAG in "${MUSL_TAGS[@]}"; do
  MUSL_TAG_ARGS+=(--tag "$TAG")
done

docker buildx build \
  --builder "$BUILDER_NAME" \
  --platform "linux/amd64" \
  --build-arg ARCH="linux-musl" \
  --file "$ROOT_DIR/docker/linux/Dockerfile" \
  "${MUSL_TAG_ARGS[@]}" \
  --load \
  "$ROOT_DIR"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "=== Linux build complete (local) ==="
echo ""
echo "Per-arch images loaded into local Docker image store:"
for ARCH in "${ARCHES[@]}"; do
  echo "  ${IMAGE_NAME}:${VERSION}-${ARCH}"
done
echo ""
echo "Musl images:"
for TAG in "${MUSL_TAGS[@]}"; do
  echo "  $TAG"
done
echo ""
echo "To test locally:"
echo "  docker run --rm -p 14242:14242/udp ${IMAGE_NAME}:${VERSION}-linux-x64"
echo "  docker run --rm -p 14242:14242/udp ${IMAGE_NAME}:latest-musl"
echo ""
echo "To test a non-native arch (requires QEMU):"
echo "  docker run --rm --platform linux/arm64 -p 14242:14242/udp ${IMAGE_NAME}:${VERSION}-linux-arm64"
echo ""
echo "When ready to publish, run:"
echo "  bash scripts/push-linux.sh"
