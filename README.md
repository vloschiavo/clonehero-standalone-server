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
```yml
services:
  clone-hero-server:
    image: vloschiavo/clonehero-standalone-server
    container_name: clone-hero-server
    restart: unless-stopped
    user: "1000:1000"

    # Server Options
    environment:
      - CH_NAME=My Clone Hero Server       # Specify server name
      - CH_PORT=14242                      # Specify single server port
      - CH_ADDRESS=0.0.0.0                 # Specify server binding address
      - CH_LOG_LEVEL=4                     # Set max logging level. default 4, range: 0-4
      - CH_PASSWORD=                     # Specify server password or leave CH_PASSWORD= blank and set CH_NO_PASS=true
      - CH_NO_PASS=true                    # Don't set a Server Password
      - CH_ALLOW_RESET=true                # When the server becomes empty, game values are set to default
      - CH_USE_DEFAULTS=false              # Skip address and port setup and startup a server with default settings
      # Use these two variables to spin up one or more servers.  You'll need to change the ports section below to match
      - CH_INSTANCE_COUNT=1                # Specify max server instance count
      #- CH_PORTRANGE=14242-14251          # Specify multi server port range
    
    ports:
      - "14242:14242/udp"
      #- "14242-14251:14242-14251/udp" 

    volumes:
      - ./settings.ini:/usr/src/clonehero/settings.ini
    
    # Optional: Give the container more resources if you expect many players or are launching multiple instances
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 256M
```

settings.ini
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
3. Launch the container
```bash
docker compose up -d
```
---
The Docker image exposes port 14242 for network communication by default. This and other settings can be configured in the docker-compose.yml.  The current server version includes the ability to spawn multiple Clone Hero servers (on different ports) on the same host with the single server executable.

`settings.ini` is stored in `/usr/src/clonehero/` inside the container. So if you want to modify it, create a `settings.ini` file.


Get Clone Hero clients here: https://clonehero.net/
Github release here: https://github.com/clonehero-game/releases