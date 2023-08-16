#!/usr/bin/env sh

_hard_drive_image="freebsd13-arm64.qcow2,format=qcow2"
_machine_id="02" # the ID of the machine - for multiple VMs running at once
_memory="12" # GB RAM for the VM
_cores="4" # performance cores on M1
_bridge_socket="/var/run/socket_vmnet.bridged.en0"

# set the terminal title
printf "\e]2;%b\a" \
    "Qemu-6.1-hvf-fBSD-13.2-arm64"

/opt/socket_vmnet/bin/socket_vmnet_client "${_bridge_socket}" \
    /Users/Shared/Software/Qemu-m1/bin/qemu-system-aarch64 \
    -M virt,accel=hvf,highmem=off \
    -m "$(( ${_memory} * 1024 ))" \
    -smp cores="${_cores}" \
    -cpu cortex-a72 \
    -drive file="/Users/Shared/Software/Qemu-m1/share/qemu/edk2-aarch64-code.fd,if=pflash,format=raw,readonly=on" \
    -drive file="${_hard_drive_image}" \
    -nographic \
    -device "virtio-net-pci,netdev=net0,mac=de:ad:be:ef:00:${_machine_id}" \
    -netdev "socket,id=net0,fd=3" \
    -pidfile freebsd.pid
