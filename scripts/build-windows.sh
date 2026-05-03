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

# ---------------------------------------------------------------------------
# Windows VM Docker host configuration
# Set DOCKER_HOST to point to your Windows 11 VM running Docker in Windows
# container mode. Override via environment or edit the default below.
# Examples:
#   tcp://192.168.1.100:2375        (unencrypted, not recommended)
#   tcp://192.168.1.100:2376        (TLS secured, recommended)
# ---------------------------------------------------------------------------

: "${WINDOWS_DOCKER_HOST:?WINDOWS_DOCKER_HOST must be set (e.g. tcp://192.168.1.100:2376)}"

export DOCKER_HOST="$WINDOWS_DOCKER_HOST"

# Optionally point to TLS certs if your Windows VM Docker host uses TLS.
# Uncomment and set if needed:
# export DOCKER_TLS_VERIFY=1
# export DOCKER_CERT_PATH="$HOME/.docker/certs/windows-vm"

# ---------------------------------------------------------------------------
# Fetch binaries if needed (runs on the local Ubuntu machine)
# Temporarily unset DOCKER_HOST so fetch-server.sh doesn't try to run
# docker commands against the Windows host.
# ---------------------------------------------------------------------------

DOCKER_HOST="" "$SCRIPT_DIR/fetch-server.sh"

# ---------------------------------------------------------------------------
# Build matrix
# Each entry: "ARCH|DOCKERFILE"
# ---------------------------------------------------------------------------

declare -A WINDOWS_TARGETS=(
  [win-x64]="docker/windows/Dockerfile.win-x64"
  [win-x86]="docker/windows/Dockerfile.win-x86"
)

# Strip "-final" suffix for clean semver tags e.g. v1.1.0.6085
CLEAN_VERSION="${VERSION%-final}"

echo ""
echo "=== Building Windows images against host: $WINDOWS_DOCKER_HOST ==="

for ARCH in "${!WINDOWS_TARGETS[@]}"; do
  DOCKERFILE="${WINDOWS_TARGETS[$ARCH]}"

  TAGS=(
    "${IMAGE_NAME}:${ARCH}"
    "${IMAGE_NAME}:v${CLEAN_VERSION}-${ARCH}"
  )

  TAG_ARGS=()
  for TAG in "${TAGS[@]}"; do
    TAG_ARGS+=(--tag "$TAG")
  done

  echo ""
  echo "--- Building $ARCH ---"
  echo "    Dockerfile : $DOCKERFILE"
  for TAG in "${TAGS[@]}"; do
    echo "    Tag        : $TAG"
  done

  docker build \
    --file "$ROOT_DIR/$DOCKERFILE" \
    "${TAG_ARGS[@]}" \
    "$ROOT_DIR"

  echo "Pushing $ARCH images..."
  for TAG in "${TAGS[@]}"; do
    docker push "$TAG"
    echo "  Pushed: $TAG"
  done

done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "=== Windows build complete ==="
echo ""
for ARCH in "${!WINDOWS_TARGETS[@]}"; do
  echo "  ${IMAGE_NAME}:${ARCH}"
  echo "  ${IMAGE_NAME}:v${CLEAN_VERSION}-${ARCH}"
done
echo ""
echo "NOTE: win-arm64 is not built. See README for details."
