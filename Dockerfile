FROM debian:bookworm-slim AS build-env

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /clonehero

RUN apt-get update \
 && apt-get install --no-install-recommends -y ca-certificates wget unzip \
 && rm -rf /var/lib/apt/lists/*

ARG VERSION=1.1.0.6085-final

RUN wget -qO chserver.zip "https://github.com/clonehero-game/releases/releases/download/v${VERSION}/CloneHero-StandaloneServer.zip" \
 && unzip chserver.zip \
 && rm chserver.zip \
 && mv CloneHero-StandaloneServer chserver \
 # Normalize arch folder names to match `arch` command output
 && mv ./chserver/linux-x64   ./chserver/linux-x86_64  2>/dev/null || true \
 && mv ./chserver/linux-arm64 ./chserver/linux-aarch64 2>/dev/null || true \
 && mv ./chserver/linux-arm   ./chserver/linux-armv7l  2>/dev/null || true \
 # Extract only the binary for the current architecture
 && cp ./chserver/linux-$(arch)/Server . \
 && rm -rf ./chserver \
 && chmod +x ./Server

COPY startup.sh .

RUN chown -R 1000:1000 /clonehero

# --- Runtime image ---
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install --no-install-recommends -y \
      libicu72 \
      libgssapi-krb5-2 \
      libssl3 \
 && rm -rf /var/lib/apt/lists/* \
 && useradd -m -u 1000 clonehero \
 && mkdir /usr/src/clonehero && chown clonehero:clonehero /usr/src/clonehero

WORKDIR /usr/src/clonehero
COPY --from=build-env --chown=clonehero:clonehero /clonehero .

USER clonehero
EXPOSE 14242/udp
ENTRYPOINT ["./startup.sh"]