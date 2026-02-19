#!/usr/bin/env sh

# _disk_name="/dev/rdisk4"
# _hard_drive_image="${_disk_name},format=raw"
_disk_name="freebsd15-arm64.qcow2"
_hard_drive_image="${_disk_name},format=qcow2"

_machine_id="05" # the ID of the machine - for multiple VMs running at once
_memory="12" # GB RAM for the VM
_cores="4" # performance cores on M2 Pro - 2
_bridge_socket="/var/run/socket_vmnet.shared"

# set the terminal title
printf "\e]2;%b\a" \
    "Qemu-6.1-hvf-fBSD-15-arm64"

/opt/socket_vmnet/bin/socket_vmnet_client "${_bridge_socket}" \
    /Users/Shared/Software/Qemu-m1/bin/qemu-system-aarch64 \
    -M virt,accel=hvf,highmem=off,secure=off,virtualization=off \
    -overcommit cpu-pm=on \
    -m "$(( ${_memory} * 1024 ))" \
    -smp cores="${_cores}" \
    -cpu cortex-a72 \
    -bios "u-boot.bin" \
    -drive if=none,file="${_hard_drive_image}",id=maind,discard='unmap' \
    -device nvme,drive=maind,serial=foo \
    -nographic \
    -device "virtio-net-pci,netdev=net0,mac=de:ad:be:ef:00:${_machine_id}" \
    -netdev socket,id=net0,fd=3 \
    -pidfile freebsd.pid
