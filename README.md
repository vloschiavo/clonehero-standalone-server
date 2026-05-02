# clonehero-standalone-server 🎸 🥁 🐳

This is Docker image for a Clone Hero dedicated server software. 
Available on [Docker Hub](https://hub.docker.com/r/vloschiavo/clonehero-standalone-server)

Built with version v1.1.0.6085-Final release of Clone Hero.

This was project was forked from: https://gitlab.com/CorySanin/clone-hero-server-docker / https://hub.docker.com/r/corysanin/clone-hero-server.  Thank you for the inspiration.

I updated the base container to the latest version of Clone Hero, debian bookworm, and included libicu72 and libssl3 which are needed by Clone Hero.

---
Installation:
1. Clone this repo
```bash
git clone https://github.com/vloschiavo/clonehero-standalone-server.git
```
2. Edit the docker compose and settings.ini files to your taste.
  
3. Launch the container
```bash
docker compose up -d
```
---
The Docker image exposes port 14242 for network communication by default. This and other settings can be configured in the docker-compose.yml.  The current server version includes the ability to spawn multiple Clone Hero servers (on different ports) on the same host with the single server executable.

Pre-built Docker Hub image [here](https://hub.docker.com/r/vloschiavo/clonehero-standalone-server).

`settings.ini` is stored in `/usr/src/clonehero/` inside the container. So if you want to modify it, create a `settings.ini` file.

Get Clone Hero clients here: https://clonehero.net/
Github release here: https://github.com/clonehero-game/releases
