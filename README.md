# clonehero-standalone-server 🎸 🥁 🐳

Docker image for Clone Hero dedicated server software. Available on [Docker Hub](https://hub.docker.com/r/vloschiavo/clonehero-standalone-server)
Built with version: v1.0.0.4080 V1.0 Final Release of Clone Hero.

This was forked from: https://gitlab.com/CorySanin/clone-hero-server-docker / https://hub.docker.com/r/corysanin/clone-hero-server.

I updated the base container to the latest version of Clone Hero, debian bookworm, and included libicu72 and libssl1.1 which are needed by Clone Hero.

### Docker Compose:
```docker compose up -d```

The Docker image exposes port 14242 for network communication by default. This can be configured in `server-settings.ini`

`server-settings.ini` is stored in `/usr/src/clonehero/config/` inside the container. So if you want to modify it, create a `server-settings.ini` file.

Get Clone Hero clients here: https://clonehero.net/
Github release here: https://github.com/clonehero-game/releases
