#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="archdev-wsl:build"
OUTPUT_FILE="archdev.wsl"

echo "==> Building image"
docker build -t "$IMAGE_TAG" .

echo "==> Exporting rootfs"
docker create --name archdev_export "$IMAGE_TAG" >/dev/null
docker export archdev_export -o archlinux.tar
docker rm archdev_export >/dev/null
docker rmi "$IMAGE_TAG" >/dev/null

echo "==> Applying WSL packaging recommendations"
# WSL manages resolv.conf itself; shipping one from the image breaks that.
# https://learn.microsoft.com/windows/wsl/build-custom-distro#configuration-file-recommendations
tar --delete -f archlinux.tar etc/resolv.conf || true

echo "==> Repacking with correct ownership/permissions"
# fakeroot preserves things like setuid bits (e.g. /usr/bin/sudo) correctly
# when the retar happens as a non-root CI user.
rm -rf rootfs && mkdir rootfs
pushd rootfs >/dev/null
fakeroot bash -c "tar -xf ../archlinux.tar && tar --numeric-owner --absolute-names -c -- * | gzip --best > ../${OUTPUT_FILE}"
popd >/dev/null

rm -rf rootfs archlinux.tar
echo "==> Done: ${OUTPUT_FILE}"
