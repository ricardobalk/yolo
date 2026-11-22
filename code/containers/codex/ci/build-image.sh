#!/bin/sh
set -eu

engine=${1:-docker}
case "$engine" in
    docker|podman) ;;
    *) echo "Usage: $0 [docker|podman]" >&2; exit 2 ;;
esac

cd "$(dirname "$0")/../src"
image_id_file=$(mktemp)
trap 'rm -f "$image_id_file"' EXIT
"$engine" build --iidfile "$image_id_file" .
"$engine" run --rm --network=none "$(cat "$image_id_file")" --version
