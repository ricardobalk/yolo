# Codex CLI in Docker

The setup in this directory runs Codex CLI in a disposable container and keep your project changes, settings and sessions between runs.

The container uses `/home/workspace` as its home directory. Compose mounts your project at `/home/workspace/<project-name>` with write access. The named volume `codex_data` stores your login details, settings and sessions in `/home/workspace/.codex`.

Agentic AI workflows often involve running shell commands, installing dependencies and editing files. Running those commands directly on your workstation gives them access to the files your account can reach. Here, Docker runs Codex as a non-root user with the selected repository mounted for editing. A build script can change files in that repository, while neighbouring checkouts stay outside the container.

## Getting started

Follow the [setup guide](src/README.md) to build the image, sign in and start Codex in your repository. It also covers pnpm, running Docker directly and Linux file permissions.

# License

[Internet Systems Consortium (ISC) License](LICENSE)
