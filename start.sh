#!/usr/bin/env sh

/opt/socket_vmnet/bin/socket_vmnet_client /var/run/socket_vmnet.bridged.en0 \
    /Users/Shared/Software/Qemu-m1/bin/qemu-system-aarch64-unsigned \
    -M virt,accel=hvf,highmem=off \
    -m 12288 \
    -smp cores=4 \
    -cpu cortex-a72 \
    -drive file=edk2-aarch64-code.fd,if=pflash,format=raw,readonly=on \
    -drive file=freebsd13.qcow2,format=qcow2 \
    -nographic \
    -device virtio-net-pci,netdev=net0,mac=de:ad:be:ef:00:02 \
    -netdev socket,id=net0,fd=3 \
    -pidfile freebsd13.pid
