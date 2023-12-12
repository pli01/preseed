#!/bin/bash
# This script start qemu on mac M1 to build the usb disk img
#  the directory "share" is shared with qemu, to access script and preseed
#

MYDISK=mydisk.qcow2
if [ ! -f "$MYDISK" ] ; then
    echo "qemu disk "$MYDISK" not found"
    echo "To create one use: qemu-img create -f qcow2 $MYDISK 5G"
    exit 1
fi

qemu-system-x86_64 \
-m 2G \
-k fr \
-boot menu=on \
-drive file=$MYDISK,if=virtio \
-virtfs local,path=$(pwd)/share,mount_tag=hostshare,security_model=none,id=hostshare \
-vga virtio \
-display default,show-cursor=on \
-usb \
-device e1000,netdev=net0 \
-netdev user,id=net0,hostfwd=tcp::6543-:22,hostfwd=tcp::6443-:443,ipv6=off

#-nic vmnet-bridged,ifname=en0 \
