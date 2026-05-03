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

CLEAN_VERSION="${VERSION%-final}"

# New tag arrays for specific architectures based on requested project labeling
# Musl tags[cite: 5]
MUSL_TAGS=(
  "${IMAGE_NAME}:latest"
  "${IMAGE_NAME}:latest-alpine"
  "${IMAGE_NAME}:latest-alpine-musl"
  "${IMAGE_NAME}:latest-alpine-amd64-musl"
  "${IMAGE_NAME}:v${CLEAN_VERSION}-alpine-musl"
)

# ARM64 tags[cite: 5]
ARM64_TAGS=(
  "${IMAGE_NAME}:latest-alpine-arm64"
  "${IMAGE_NAME}:${CLEAN_VERSION}-alpine-arm64"
)

# ARMv7 tags[cite: 5]
ARMV7_TAGS=(
  "${IMAGE_NAME}:latest-alpine-armv7"
  "${IMAGE_NAME}:${CLEAN_VERSION}-alpine-armv7"
)

# x86 (glibc) tags[cite: 5]
X86_TAGS=(
  "${IMAGE_NAME}:latest-alpine-x86"
  "${IMAGE_NAME}:${CLEAN_VERSION}-alpine-x86"
)

# ---------------------------------------------------------------------------
# Preflight: verify local images exist before pushing[cite: 5]
# ---------------------------------------------------------------------------

echo "=== Preflight: checking local images ==="

MISSING=()

# Function to check tags in the local store
check_tags() {
  for TAG in "$@"; do
    if ! docker image inspect "$TAG" &>/dev/null; then
      MISSING+=("$TAG")
    else
      echo "  OK: $TAG"
    fi
  done
}

check_tags "${MUSL_TAGS[@]}" "${ARM64_TAGS[@]}" "${ARMV7_TAGS[@]}" "${X86_TAGS[@]}"

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
# Step 1: Push Musl images[cite: 5]
# ---------------------------------------------------------------------------
echo ""
echo "=== Pushing Musl images ==="
for TAG in "${MUSL_TAGS[@]}"; do
  echo "  Pushing $TAG ..."
  docker push "$TAG"
done

# ---------------------------------------------------------------------------
# Step 2: Push ARM64 images[cite: 5]
# ---------------------------------------------------------------------------
echo ""
echo "=== Pushing ARM64 images ==="
for TAG in "${ARM64_TAGS[@]}"; do
  echo "  Pushing $TAG ..."
  docker push "$TAG"
done

# ---------------------------------------------------------------------------
# Step 3: Push ARMv7 images[cite: 5]
# ---------------------------------------------------------------------------
echo ""
echo "=== Pushing ARMv7 images ==="
for TAG in "${ARMV7_TAGS[@]}"; do
  echo "  Pushing $TAG ..."
  docker push "$TAG"
done

# ---------------------------------------------------------------------------
# Step 4: Push x86 images[cite: 5]
# ---------------------------------------------------------------------------
echo ""
echo "=== Pushing x86 images ==="
for TAG in "${X86_TAGS[@]}"; do
  echo "  Pushing $TAG ..."
  docker push "$TAG"
done

# ---------------------------------------------------------------------------
# Summary[cite: 5]
# ---------------------------------------------------------------------------
echo ""
echo "=== Push complete ==="
echo "All images for musl, arm64, armv7, and x86 have been pushed with their new labels."
