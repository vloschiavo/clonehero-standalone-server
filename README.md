<<<<<<< HEAD
# Clone Hero Standalone Server 🎸 🥁 

This is Docker image for a Clone Hero dedicated server software and is available on [Docker Hub](https://hub.docker.com/r/vloschiavo/clonehero-standalone-server)

Updated 2026-05-01 with version v1.1.0.6085-Final release of Clone Hero.

This was project was forked from: https://gitlab.com/CorySanin/clone-hero-server-docker / https://hub.docker.com/r/corysanin/clone-hero-server.  Thank you for the inspiration!

---
Installation:
1. Clone this repo:
```bash
git clone https://github.com/vloschiavo/clonehero-standalone-server.git

cd ./clonehero-standalone-server
```
2. Edit the docker compose and settings.ini files to your taste.

docker-compose.yml
=======
# Clone Hero Standalone Server 🎸 🥁

This is a Docker image for the Clone Hero dedicated server software and is available on [Docker Hub](https://hub.docker.com/r/vloschiavo/clonehero-standalone-server).

## Change Log

- 2026-05-01 Updated to version v1.1.0.6085-Final release of Clone Hero.
- 2026-05-03 Added a new multiarch build, plus separate tags musl (latest and latest-musl) & glibc (latest-glibc) for amd64 as well as armv7 and arm64 builds

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
>>>>>>> multi-arch
```yml
services:
  clone-hero-server:
    image: vloschiavo/clonehero-standalone-server
    container_name: clone-hero-server
    restart: unless-stopped
    user: "1000:1000"

<<<<<<< HEAD
    # Server Options
=======
>>>>>>> multi-arch
    environment:
      - CH_NAME=My Clone Hero Server       # Specify server name
      - CH_PORT=14242                      # Specify single server port
      - CH_ADDRESS=0.0.0.0                 # Specify server binding address
      - CH_LOG_LEVEL=4                     # Set max logging level. default 4, range: 0-4
<<<<<<< HEAD
      - CH_PASSWORD=                       # Specify server password or leave CH_PASSWORD= blank and set CH_NO_PASS=true
      - CH_NO_PASS=true                    # Don't set a Server Password
      - CH_ALLOW_RESET=true                # When the server becomes empty, game values are set to default
      - CH_USE_DEFAULTS=false              # Skip address and port setup and startup a server with default settings
      # Use these two variables to spin up one or more servers.  You'll need to change the ports section below to match
      - CH_INSTANCE_COUNT=1                # Specify max server instance count
      - CH_PORTRANGE=14242-14251           # Specify multi server port range
    
    ports:
      - "14242:14242/udp"                  # Single port for a single server

    volumes:
      - ./settings.ini:/usr/src/clonehero/settings.ini
      - ./cache:/tmp/CloneHeroServer       # Used for persistent cache of your users' song lists; speeds up subsequent connections between container restarts
    
    # Optional: Give the container more resources if you expect many players or are launching multiple instances
=======
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

>>>>>>> multi-arch
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 256M
```

<<<<<<< HEAD
settings.ini
=======
**settings.ini**
>>>>>>> multi-arch
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
<<<<<<< HEAD
redis_password = 
redis_hostname = localhost
```
3. Launch the container
```bash
docker compose up -d
=======
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
>>>>>>> multi-arch
```

---

<<<<<<< HEAD
### Notes:

#### Multiple Servers
- The current server version includes the ability to spawn multiple Clone Hero servers (on different ports) on the same host with the single server executable.
  - Simply increase the CH_INSTANCE_COUNT= variable to the number of servers you want to launch. 
  - Change your Ports section of the docker-compose.yml
  
  Here is an example to spin up 10 servers:
    ```yaml
    environment:
    - CH_INSTANCE_COUNT=10
    
    ports:
    # - "14242:14242/udp"             # comment out or remove this line
    - "14242-14251:14242-14251/udp"   # add this line for 10 server ports
    ```

#### Song Cache
- To speed up subsequent connections to your server between restarts, enable the cache as shown in the docker-yaml
  - This maps your ./cache directory to /tmp/CloneHeroServer in the container where the Clone Hero Server stores the song hash cache for each user.  
  - Using this saves a small amount of time during the time when a client first connects to the server by not having to upload the full songs hash.
  ```yaml
  volumes:
    - ./cache:/tmp/CloneHeroServer
  ```
  - Feel free to place this anywhere on your system or comment it out for an ephemeral cache.  In this case, the cache would be stored in the /tmp dir in the container and would be destroyed on restart.
  - the file sizes are relatively small.  6066 songs has a cache file size of 95KB.

---
Get Clone Hero clients here: https://clonehero.net/
Github release here: https://github.com/clonehero-game/releases
=======
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
>>>>>>> multi-arch
