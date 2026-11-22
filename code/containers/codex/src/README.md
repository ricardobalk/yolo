# Getting started

The files in this `src/` directory are all you need to run Codex CLI with Docker Compose.

Place your project files in `project/` and run the following commands from this directory.

```bash
docker compose build
docker compose run --rm codex login --device-auth
docker compose run --rm codex
```

Before you log in for the first time, enable device code authentication in your ChatGPT settings or workspace policy. [Codex authentication](https://learn.chatgpt.com/docs/auth#login-on-headless-devices)

If your repository is elsewhere, specify its parent directory and the name of the repository directory.

```bash
CODEX_PROJECTS_DIR="$HOME/dev" CODEX_PROJECT_NAME=my-repo docker compose run --rm codex
```

## Install dependencies with pnpm

```bash
docker compose run --rm --entrypoint pnpm codex install --frozen-lockfile
```

### Considerations

We pin tool versions so rebuilds use the same toolchain and keep packages fetched with `pnpm fetch` in `codex_pnpm_store` for offline installs with `pnpm install --offline --frozen-lockfile`.

## Running Docker directly

After running `docker compose build`, you can use the same image and volumes.

```bash
docker run --rm -it --init --cap-drop=ALL --security-opt=no-new-privileges \
  -v "$PWD/project:/home/workspace/project" \
  -v codex_data:/home/workspace/.codex \
  -v codex_pnpm_store:/home/workspace/.local/share/pnpm/store \
  -w /home/workspace/project \
  codex-local
```

## Files and permissions

With a standard Docker installation on Linux, if your host user’s UID and GID differ from `1000:1000`, you can set them before the first build.

```bash
export CODEX_UID="$(id -u)" CODEX_GID="$(id -g)"
docker compose build
```

Rootless Docker uses a different [UID/GID mapping](https://docs.docker.com/engine/security/rootless/uid-gid-mapping).

Docker provides isolation. Codex runs as a regular user and can read and modify the mounted repository and volumes. When the container exits, `run --rm` removes it and keeps the volumes. **Running `docker compose down -v` also deletes `codex_data` and `codex_pnpm_store`.**

## Checking the image build

Run `./code/containers/codex/ci/build-image.sh docker` or `./code/containers/codex/ci/build-image.sh podman` from the repository root. CI runs both checks as independent jobs. Each engine builds the image and runs its entrypoint with `--version` and networking disabled.

The Docker and Podman airplane-mode jobs warm the build cache, disconnect the builder, rebuild the Codex image, and run `codex --version` offline.

The GitLab CI configuration is in `code/containers/codex/ci/gitlab.yml`. The Docker jobs use Docker-in-Docker with TLS. For a self-managed Docker executor, enable privileged mode for the Docker-in-Docker service and share `/certs/client` between the service and the job. The Podman jobs need a runner that supports nested containers and network namespaces.
