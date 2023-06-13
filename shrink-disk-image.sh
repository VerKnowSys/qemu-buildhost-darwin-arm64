#!/usr/bin/env sh

set -e

_format="qcow2"
_disk="freebsd13.${_format}"

echo "Reclaiming disk space by converting the disk image: ${_disk}"
qemu-img \
    convert \
    -c \
    -O ${_format} \
    "${_disk}" \
    "${_disk}-resized"
rm -f "${_disk}"
mv "${_disk}-resized" "${_disk}"
echo "Done"
