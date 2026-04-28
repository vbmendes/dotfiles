# Docker

Sets up Docker Engine and Docker Compose.

## Usage

```bash
bash docker/setup.sh
```

## What it does

### macOS

Requires [Homebrew](https://brew.sh).

1. Removes **Docker Desktop** and all its leftover files if present (no subscription required)
2. Installs the **Docker CLI** (`docker` formula) and **`docker-credential-helper`** (`docker-credential-osxkeychain`)
3. Installs and starts **[Colima](https://github.com/abiosoft/colima)** as the Docker runtime
4. Installs **Docker Compose** and wires it as a CLI plugin

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
