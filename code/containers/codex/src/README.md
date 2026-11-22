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

## pnpm and version pinning

Corepack uses the version specified in your project’s `packageManager` field if it is set. The image defaults to pnpm `10.34.9`. To install dependencies for a repository with a `pnpm-lock.yaml` file, run the following command.

```bash
docker compose run --rm --entrypoint pnpm codex install --frozen-lockfile
```

The Dockerfile pins the `node:26.13-alpine3.24` base image by digest. It also pins Corepack to `0.36.0`, pnpm to `10.34.9` and Codex CLI to `0.171.0`. To update a component, change its version in the Dockerfile and rerun `docker compose build`. If you update the base image, update its digest too.

## Running Docker directly

After running `docker compose build`, you can use the same image and volume.

```bash
docker run --rm -it --init --cap-drop=ALL --security-opt=no-new-privileges \
  -v "$PWD/project:/home/workspace/project" \
  -v codex_data:/home/workspace/.codex \
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

Docker provides isolation. Codex runs as a regular user and can read and modify both the mounted repository and the contents of `codex_data`. When the container exits, `run --rm` removes it and keeps the volume. **Running `docker compose down -v` also deletes `codex_data`.**

## Checking the image build

Run `./code/containers/codex/ci/build-image.sh docker` or `./code/containers/codex/ci/build-image.sh podman` from the repository root. CI runs both checks as independent jobs. Each engine builds the image and runs its entrypoint with `--version` and networking disabled.

GitHub, Forgejo and Gitea use the workflow in `.github/workflows/`. On Forgejo and Gitea, enable Actions and provide runners labelled `ubuntu-24.04` with Node.js for checkout, Docker with access to its daemon, and a working Podman installation. Two free runner slots allow both jobs to run at once. If your instance uses an action mirror, make sure its copy of `actions/checkout` contains the pinned upstream commit.

Both GitLab jobs use the build stage. The Docker job uses Docker-in-Docker with TLS. For a self-managed Docker executor, enable privileged mode for the Docker-in-Docker service and share `/certs/client` between the service and the job. The Podman job uses its own pinned image and needs a runner that supports building and running containers inside the job.
