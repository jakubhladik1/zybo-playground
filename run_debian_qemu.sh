#!/usr/bin/env bash

#
#    Copyright (C) 2022  Jakub Hladik
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

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
