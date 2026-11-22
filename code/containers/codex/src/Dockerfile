FROM docker.io/library/node:26.13-alpine3.24@sha256:6bd9ab43c0ec0190ca7b2d193906cb8b7edf6e7f4afa43ddeccd6452710bffb5

ARG COREPACK_VERSION=0.36.0
ARG PNPM_VERSION=10.34.9
ARG CODEX_CLI_VERSION=0.171.0
ARG CODEX_UID=1000
ARG CODEX_GID=1000

ARG HTTP_PROXY
ARG http_proxy
ARG HTTPS_PROXY
ARG https_proxy
ARG NO_PROXY
ARG no_proxy
ARG ALL_PROXY
ARG all_proxy

RUN apk add --no-cache bash ca-certificates git ripgrep shadow

RUN npm install --global "corepack@$COREPACK_VERSION" \
    && corepack enable pnpm \
    && npm cache clean --force

ENV HOME=/home/workspace
ENV CODEX_HOME=/home/workspace/.codex
ENV PNPM_HOME=/home/workspace/.local/share/pnpm
ENV npm_config_store_dir="${PNPM_HOME}/store"
ENV COREPACK_DEFAULT_TO_LATEST=0
ENV NODE_USE_ENV_PROXY=1
ENV PATH="${PNPM_HOME}:${PATH}"

RUN test "$CODEX_UID" -gt 0 \
    && { getent group "$CODEX_GID" >/dev/null || groupadd --gid "$CODEX_GID" codex; } \
    && usermod --uid "$CODEX_UID" --gid "$CODEX_GID" --home "$HOME" --move-home node \
    && install -d -m 0700 -o node -g "$CODEX_GID" "$CODEX_HOME"

USER node
WORKDIR /home/workspace

RUN mkdir -p "$PNPM_HOME" \
    && corepack install --global "pnpm@$PNPM_VERSION" \
    && pnpm add --global "@openai/codex@$CODEX_CLI_VERSION" \
    && codex --version

ENTRYPOINT ["codex", \
    "-c", "cli_auth_credentials_store=\"file\"", \
    "-c", "sandbox_mode=\"danger-full-access\"", \
    "-c", "approval_policy=\"on-request\""]
