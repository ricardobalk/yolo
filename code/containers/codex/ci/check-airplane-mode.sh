#!/bin/sh
set -eu

engine=${1:-docker}
case "$engine" in
    docker|podman) ;;
    *) echo "Usage: $0 [docker|podman]" >&2; exit 2 ;;
esac

cd "$(dirname "$0")/../src"
image_id_file=$(mktemp)
builder=
container=
cleanup() {
    set +e
    if [ -n "$builder" ]; then
        docker buildx rm "$builder" >/dev/null
    fi
    if [ -n "$container" ]; then
        docker rm -fv "$container" >/dev/null
    fi
    rm -f "$image_id_file"
}
trap cleanup EXIT

case "$engine" in
    docker)
        container=$(docker run -d --privileged --network=bridge \
            moby/buildkit:v0.26.2@sha256:de10faf919fc71ba4eb1dd7bd6449566d012b0c9436b1c61bfee21d621b009aa)
        builder=$(docker buildx create --driver remote "docker-container://$container")
        docker buildx build --builder "$builder" --output=type=cacheonly .
        docker network disconnect bridge "$container"
        docker buildx build --builder "$builder" --load --iidfile "$image_id_file" .
        ;;
    podman)
        podman build --layers .
        podman unshare unshare --net podman build --layers --pull=never --network=none --iidfile "$image_id_file" .
        ;;
esac

"$engine" run --rm --pull=never --network=none "$(cat "$image_id_file")" --version
