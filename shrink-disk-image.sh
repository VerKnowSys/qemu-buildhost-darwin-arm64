#!/usr/bin/env sh

set -e

_format="qcow2"
_disk="freebsd14-arm64.${_format}"

echo "Reclaiming disk space by converting the disk image: ${_disk}"
qemu-img \
    convert \
    -p \
    -c \
    -O ${_format} \
    "${_disk}" \
    "${_disk}-resized"
rm -f "${_disk}"
mv "${_disk}-resized" "${_disk}"
echo "Done"
