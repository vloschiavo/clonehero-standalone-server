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

ARCHES=(linux-x64 linux-arm linux-arm64)
CLEAN_VERSION="${VERSION%-final}"

MUSL_TAGS=(
  "${IMAGE_NAME}:latest-musl"
  "${IMAGE_NAME}:v${CLEAN_VERSION}-musl"
)

MANIFEST_TAGS=(
  "${IMAGE_NAME}:latest"
  "${IMAGE_NAME}:v${CLEAN_VERSION}"
)

# ---------------------------------------------------------------------------
# Preflight: verify all expected local images exist before pushing anything
# ---------------------------------------------------------------------------

echo "=== Preflight: checking local images ==="

MISSING=()

for ARCH in "${ARCHES[@]}"; do
  TAG="${IMAGE_NAME}:${VERSION}-${ARCH}"
  if ! docker image inspect "$TAG" &>/dev/null; then
    MISSING+=("$TAG")
  else
    echo "  OK: $TAG"
  fi
done

for TAG in "${MUSL_TAGS[@]}"; do
  if ! docker image inspect "$TAG" &>/dev/null; then
    MISSING+=("$TAG")
  else
    echo "  OK: $TAG"
  fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo ""
  echo "ERROR: The following images are missing from the local Docker image store:"
  for TAG in "${MISSING[@]}"; do
    echo "  $TAG"
  done
  echo ""
  echo "Run 'bash scripts/build-linux.sh' first, then re-run this script."
  exit 1
fi

echo ""
echo "All expected images found locally. Proceeding with push."

# ---------------------------------------------------------------------------
# Step 1: Push per-arch images
# These must be on the registry before imagetools can assemble the manifest.
# ---------------------------------------------------------------------------

echo ""
echo "=== Pushing per-arch images ==="

for ARCH in "${ARCHES[@]}"; do
  TAG="${IMAGE_NAME}:${VERSION}-${ARCH}"
  echo "  Pushing $TAG ..."
  docker push "$TAG"
done

# ---------------------------------------------------------------------------
# Step 2: Push musl images
# ---------------------------------------------------------------------------

echo ""
echo "=== Pushing musl images ==="

for TAG in "${MUSL_TAGS[@]}"; do
  echo "  Pushing $TAG ..."
  docker push "$TAG"
done

# ---------------------------------------------------------------------------
# Step 3: Assemble and push the multi-arch manifest
# imagetools create reads the per-arch manifests from the registry and
# assembles them into a single multi-arch manifest list.
# ---------------------------------------------------------------------------

echo ""
echo "=== Creating and pushing multi-arch manifest ==="

SOURCE_TAGS=()
for ARCH in "${ARCHES[@]}"; do
  SOURCE_TAGS+=("${IMAGE_NAME}:${VERSION}-${ARCH}")
done

for TAG in "${MANIFEST_TAGS[@]}"; do
  echo "  Creating manifest: $TAG"
  docker buildx imagetools create \
    --tag "$TAG" \
    "${SOURCE_TAGS[@]}"
  echo "  Pushed: $TAG"
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "=== Push complete ==="
echo ""
echo "Multi-arch manifest (linux/amd64, linux/arm/v7, linux/arm64):"
for TAG in "${MANIFEST_TAGS[@]}"; do
  echo "  $TAG"
done
echo ""
echo "Per-arch images:"
for ARCH in "${ARCHES[@]}"; do
  echo "  ${IMAGE_NAME}:${VERSION}-${ARCH}"
done
echo ""
echo "Musl (linux/amd64, statically linked):"
for TAG in "${MUSL_TAGS[@]}"; do
  echo "  $TAG"
done
echo ""
echo "Verify the manifest with:"
echo "  docker buildx imagetools inspect ${IMAGE_NAME}:latest"
