#!/usr/bin/env bash
qemu-system-x86_64 \
    -accel hvf \
    -cpu Haswell-v4 \
    -smp 2 \
    -m 4G \
    -nographic \
    -device virtio-net,netdev=vmnic \
    -netdev user,id=vmnic,hostfwd=tcp:127.0.0.1:9001-:22 \
    -drive file=~/qemu/debian.qcow2,if=virtio \
    -usb \
    -device usb-ehci,id=ehci \
    -device usb-host,vendorid=0x0403,productid=0x6010
