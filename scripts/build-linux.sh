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
# Ordered arrays are used instead of associative arrays to guarantee
# iteration order and avoid bash associative array quirks.
#
# linux-musl is excluded from the multi-arch manifest (same platform as
# linux-x64) and pushed separately with a -musl tag suffix.

ARCHES=(linux-x64 linux-arm linux-arm64)
PLATFORMS=(linux/amd64 linux/arm/v7 linux/arm64)

# Strip "-final" suffix for clean semver tags e.g. v1.1.0.6085
CLEAN_VERSION="${VERSION%-final}"

# ---------------------------------------------------------------------------
# Step 1: Build and push each Linux arch individually
# These intermediate per-arch images are pushed so we can later assemble
# them into a single manifest via imagetools. Tagged with an arch suffix.
# ---------------------------------------------------------------------------

echo ""
echo "=== Building Linux arch images ==="

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
    --push \
    "$ROOT_DIR"
done

# ---------------------------------------------------------------------------
# Step 2: Build and push linux-musl separately (same platform as linux-x64
# so it cannot be included in the multi-arch manifest)
# ---------------------------------------------------------------------------

echo ""
echo "=== Building linux-musl image ==="

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
  --push \
  "$ROOT_DIR"

echo ""
for TAG in "${MUSL_TAGS[@]}"; do
  echo "  Pushed: $TAG"
done

# ---------------------------------------------------------------------------
# Step 3: Create and push the multi-arch manifest using imagetools.
# imagetools works natively with buildx-pushed images, unlike the legacy
# `docker manifest` command which cannot inspect buildx-pushed manifests.
# Tags: latest and vVERSION
# ---------------------------------------------------------------------------

echo ""
echo "=== Creating multi-arch manifest ==="

# Build the source list: all per-arch images pushed in Step 1
SOURCE_TAGS=()
for ARCH in "${ARCHES[@]}"; do
  SOURCE_TAGS+=("${IMAGE_NAME}:${VERSION}-${ARCH}")
done

MANIFEST_TAGS=(
  "${IMAGE_NAME}:latest"
  "${IMAGE_NAME}:v${CLEAN_VERSION}"
)

for TAG in "${MANIFEST_TAGS[@]}"; do
  echo "Creating manifest: $TAG"
  docker buildx imagetools create \
    --tag "$TAG" \
    "${SOURCE_TAGS[@]}"
  echo "  Pushed: $TAG"
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "=== Linux build complete ==="
echo ""
echo "Multi-arch manifest (linux/amd64, linux/arm/v7, linux/arm64):"
for TAG in "${MANIFEST_TAGS[@]}"; do
  echo "  $TAG"
done
echo ""
echo "Musl (linux/amd64, statically linked):"
for TAG in "${MUSL_TAGS[@]}"; do
  echo "  $TAG"
done
