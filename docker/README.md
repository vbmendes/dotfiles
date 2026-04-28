# Docker

Sets up Docker Engine and Docker Compose.

## Usage

```bash
bash docker/setup.sh
```

## What it does

### macOS

Installs **Docker Desktop** via Homebrew (includes Docker Engine, Docker CLI, and Docker Compose). After installation, launch Docker Desktop from your Applications folder to start the daemon.

Requires [Homebrew](https://brew.sh).

### Linux (Ubuntu / Debian)

1. Removes any conflicting legacy Docker packages
2. Adds the official Docker apt repository
3. Installs `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin`, and `docker-compose-plugin`
4. Adds the current user to the `docker` group (log out and back in for this to take effect)
5. Enables and starts the Docker systemd service

## Verify

```bash
docker run hello-world
```
