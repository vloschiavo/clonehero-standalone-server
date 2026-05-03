# syntax=docker/dockerfile:1

# Build argument to select the target architecture binary.
# Valid values: linux-x64, linux-arm, linux-arm64, linux-musl
ARG ARCH=linux-x64

FROM alpine:latest

ARG ARCH

# linux-musl is statically linked against musl — no compat layer needed.
# linux-x64, linux-arm, linux-arm64 are glibc-linked — install gcompat + libc6-compat.
# bash is required by startup.sh (uses [[ ]] and array syntax).
# dos2unix is installed to sanitize startup.sh line endings (CRLF -> LF)
# regardless of the host OS that built the repo, then removed to keep the image lean.
RUN if [ "$ARCH" != "linux-musl" ]; then \
      apk add --no-cache bash gcompat libc6-compat dos2unix; \
    else \
      apk add --no-cache bash dos2unix; \
    fi

WORKDIR /usr/src/clonehero

# Copy the correct pre-extracted binary for this architecture
COPY server-bins/${ARCH}/Server ./Server

# Copy startup script and default settings
COPY startup.sh ./startup.sh
COPY settings.ini ./settings.ini

# Sanitize line endings, set permissions, then remove dos2unix
RUN dos2unix ./startup.sh \
    && apk del dos2unix \
    && chmod +x ./Server ./startup.sh

# Create cache directory
RUN mkdir -p /tmp/CloneHeroServer

# Run as non-root user
USER 1000:1000

# Default environment variables — override via docker-compose or docker run -e
ENV CH_NAME="My Clone Hero Server" \
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
