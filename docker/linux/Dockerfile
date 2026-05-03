# syntax=docker/dockerfile:1

# Build argument to select the target architecture binary.
# Valid values: linux-x64, linux-arm, linux-arm64, linux-musl
ARG ARCH=linux-x64

FROM alpine:latest

ARG ARCH

# All targets require bash, libgcc, and libstdc++.
# The linux-musl binary was expected to be fully statically linked but still
# depends on libgcc_s.so.1 and libstdc++.so.6 at runtime.
# linux-x64, linux-arm, linux-arm64 additionally need gcompat and libc6-compat
# for glibc compatibility on Alpine's musl-based userspace.
RUN if [ "$ARCH" != "linux-musl" ]; then \
      # Added libintl and explicitly listed gcompat/libc6-compat
      apk add --no-cache bash gcompat libc6-compat libgcc libstdc++ libintl; \
      if [ "$ARCH" = "linux-arm" ]; then \
        ln -sf /lib/ld-musl-armhf.so.1 /lib/ld-linux-armhf.so.3; \
        apk add --no-cache libssl3; \
      fi; \
    else \
      apk add --no-cache bash libgcc libstdc++; \
    fi

WORKDIR /usr/src/clonehero

# Copy the correct pre-extracted binary for this architecture
COPY server-bins/${ARCH}/Server ./Server

# Copy startup script and default settings
COPY startup.sh ./startup.sh
COPY settings.ini ./settings.ini

# Create directories and set ownership before dropping to non-root user:
#   /tmp/CloneHeroServer       — persistent song hash cache (can be bind-mounted)
#   /tmp/dotnet-bundle-extract — .NET single-file bundle extraction directory
RUN chmod +x ./Server ./startup.sh \
    && mkdir -p /tmp/CloneHeroServer /tmp/dotnet-bundle-extract \
    && chown -R 1000:1000 /usr/src/clonehero /tmp/CloneHeroServer /tmp/dotnet-bundle-extract

# Run as non-root user
USER 1000:1000

# Default environment variables — override via docker-compose or docker run -e
ENV LD_PRELOAD="/lib/libgcompat.so.0" \
    DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp/dotnet-bundle-extract \
    CH_NAME="My Clone Hero Server" \
    CH_PORT=14242 \
    CH_ADDRESS=0.0.0.0 \
    CH_LOG_LEVEL=4 \
    CH_PASSWORD="" \
    CH_NO_PASS=true \
    CH_ALLOW_RESET=true \
    CH_USE_DEFAULTS=false \
    CH_INSTANCE_COUNT=1 \
    CH_PORTRANGE=14242-14251

EXPOSE 14242/udp

ENTRYPOINT ["./startup.sh"]
