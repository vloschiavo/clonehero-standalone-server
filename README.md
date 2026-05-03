# Clone Hero Standalone Server 🎸 🥁

This is a Docker image for the Clone Hero dedicated server software and is available on [Docker Hub](https://hub.docker.com/r/vloschiavo/clonehero-standalone-server).

Updated 2026-05-01 with version v1.1.0.6085-Final release of Clone Hero.

This project was forked from: https://gitlab.com/CorySanin/clone-hero-server-docker / https://hub.docker.com/r/corysanin/clone-hero-server — thank you for the inspiration!

---

## Supported Architectures & Tags

A single `docker pull` automatically selects the correct image for your architecture.

| Tag | Architectures | Notes |
|---|---|---|
| `latest`, `v1.1.0.6085` | linux/amd64, linux/arm/v7, linux/arm64 | Alpine base |
| `latest-musl`, `v1.1.0.6085-musl` | linux/amd64 | musl binary, Alpine base |

---

## Installation

### Quick start

```bash
git clone https://github.com/vloschiavo/clonehero-standalone-server.git
cd ./clonehero-standalone-server
docker compose up -d
```

### Configuration

Edit `docker-compose.yml` and `settings.ini` before launching.

**docker-compose.yml**
```yml
services:
  clone-hero-server:
    image: vloschiavo/clonehero-standalone-server
    container_name: clone-hero-server
    restart: unless-stopped
    user: "1000:1000"

    environment:
      - CH_NAME=My Clone Hero Server       # Specify server name
      - CH_PORT=14242                      # Specify single server port
      - CH_ADDRESS=0.0.0.0                 # Specify server binding address
      - CH_LOG_LEVEL=4                     # Set max logging level. default 4, range: 0-4
      - CH_PASSWORD=                       # Specify server password or leave blank and set CH_NO_PASS=true
      - CH_NO_PASS=true                    # Don't set a server password
      - CH_ALLOW_RESET=true                # When the server becomes empty, reset game values to default
      - CH_USE_DEFAULTS=false              # Skip address and port setup and start with default settings
      - CH_INSTANCE_COUNT=1                # Specify max server instance count
      - CH_PORTRANGE=14242-14251           # Specify multi-server port range

    ports:
      - "14242:14242/udp"

    volumes:
      - ./settings.ini:/usr/src/clonehero/settings.ini
      - ./cache:/tmp/CloneHeroServer       # Persistent cache of users' song lists

    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 256M
```

**settings.ini**
```ini
[online]
defaultgamemode = quickplay
minrequiredplayers = 1
maxplayers = 4
onlyhostchoosesongs = 0
maxspectators = 4
servertickrate = 30
lowsongspeed = 50
maxsongspeed = 250
clientremovesongs = 0
songsperclient = 1

[redis]
redis_enable = 0
redis_db_id = 0
redis_password =
redis_hostname = localhost
```

### Using the musl image (linux/amd64 only)

```bash
docker run -d \
  -p 14242:14242/udp \
  -e CH_NAME="My Server" \
  -e CH_NO_PASS=true \
  vloschiavo/clonehero-standalone-server:latest-musl
```

---

## Notes

### Multiple Servers

The server supports spawning multiple instances on different ports from a single executable.

Increase `CH_INSTANCE_COUNT` and update the `ports` section to match:

```yaml
environment:
  - CH_INSTANCE_COUNT=10

ports:
  # - "14242:14242/udp"           # comment out single port
  - "14242-14251:14242-14251/udp" # use port range instead
```

### Song Cache

Mounting a cache directory speeds up client connections between container restarts by persisting each user's song hash cache.

```yaml
volumes:
  - ./cache:/tmp/CloneHeroServer
```

- Comment out the volume mount for an ephemeral cache (destroyed on container restart)
- Cache files are small: 6066 songs produces a ~95KB cache file

---

## Building From Source

### Prerequisites

- Ubuntu x86-64
- Docker with `buildx` plugin
- QEMU binfmt handlers (installed automatically by `build-linux.sh`)
- `curl`, `unzip`

### Build images locally

```bash
bash scripts/build-linux.sh
```

### Push to Docker Hub

```bash
bash scripts/push-linux.sh
```

### Fetch server binaries only

```bash
bash scripts/fetch-server.sh
```

Binaries are extracted to `./server-bins/` and gitignored. Re-running is a no-op if the directory already exists.

### .env reference

```ini
VERSION=1.1.0.6085-final
ZIP_URL=https://github.com/clonehero-game/releases/releases/download/v1.1.0.6085-final/CloneHero-StandaloneServer.zip
IMAGE_NAME=vloschiavo/clonehero-standalone-server
```

---

Get Clone Hero clients here: https://clonehero.net/
GitHub releases here: https://github.com/clonehero-game/releases
