# Clone Hero Standalone Server 🎸 🥁

This is a Docker image for the Clone Hero dedicated server software and is available on [Docker Hub](https://hub.docker.com/r/vloschiavo/clonehero-standalone-server).

Updated 2026-05-01 with version v1.1.0.6085-Final release of Clone Hero.

This project was forked from: https://gitlab.com/CorySanin/clone-hero-server-docker / https://hub.docker.com/r/corysanin/clone-hero-server — thank you for the inspiration!

---

## Supported Architectures & Tags

### Linux (multi-arch manifest)

A single `docker pull` automatically selects the correct image for your architecture.

| Tag | Architectures | Notes |
|---|---|---|
| `latest`, `v1.1.0.6085` | linux/amd64, linux/arm/v7, linux/arm64 | glibc-linked, Alpine base |
| `latest-musl`, `v1.1.0.6085-musl` | linux/amd64 | Statically linked musl binary, Alpine base |

### Windows (explicit tags)

Windows containers must be pulled explicitly by tag and require a Docker host running in **Windows containers mode**.

| Tag | Architecture | Base Image | Notes |
|---|---|---|---|
| `win-x64`, `v1.1.0.6085-win-x64` | windows/amd64 | Windows Server Core ltsc2022 | |
| `win-x86`, `v1.1.0.6085-win-x86` | windows/amd64 | Windows Server Core ltsc2022 | Runs via WoW64 |
| `win-arm64` | windows/arm64 | — | ⚠️ Not available — see note below |

> **win-arm64 note:** Windows arm64 container builds require a native arm64 Windows host to build and test reliably. This target is currently out of scope. If you have access to Windows arm64 hardware and would like to contribute, please open a pull request.

---

## Linux Installation

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

### Using the musl image (Alpine, linux/amd64 only)

Docker Run:
```bash
docker run -d \
  -p 14242:14242/udp \
  -e CH_NAME="My Server" \
  -e CH_NO_PASS=true \
  vloschiavo/clonehero-standalone-server:latest-musl
```

---

## Windows Installation

Windows containers require Docker Desktop (or Docker Engine) running in **Windows containers mode**.

> To switch modes in Docker Desktop: right-click the system tray icon → **Switch to Windows containers**.

### Quick start (win-x64)

```powershell
docker compose -f docker-compose.win-x64.yml up -d
```

### Quick start (win-x86)

```powershell
docker compose -f docker-compose.win-x86.yml up -d
```

### Configuration

Edit the appropriate `docker-compose.win-*.yml` file. The environment variables and settings are identical to the Linux version. Volume paths use Windows-style paths:

```yml
volumes:
  - ./settings.ini:C:\clonehero\settings.ini
  - ./cache:C:\tmp\CloneHeroServer
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
  - ./cache:/tmp/CloneHeroServer        # Linux
  - ./cache:C:\tmp\CloneHeroServer      # Windows
```

- Comment out the volume mount for an ephemeral cache (destroyed on container restart)
- Cache files are small: 6066 songs produces a ~95KB cache file

---

## Building From Source

### Prerequisites (Linux builds — Ubuntu x86-64)

- Docker with `buildx` plugin
- QEMU binfmt handlers (installed automatically by `build-linux.sh`)
- `curl`, `unzip`

### Prerequisites (Windows builds)

- A Windows 11 (or Windows Server) machine or VM with Docker Desktop in **Windows containers mode**
- The VM must be reachable from your build machine via TCP (configure `WINDOWS_DOCKER_HOST`)

### Build Linux images

```bash
# Optionally set these in .env or export them
export WINDOWS_DOCKER_HOST=tcp://x.x.x.x:2376

bash scripts/build-linux.sh
```

### Build Windows images

```bash
export WINDOWS_DOCKER_HOST=tcp://x.x.x.x:2376
bash scripts/build-windows.sh
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
