#!/bin/bash
# install package to generate usb disk auto install with preseed
apt-get update -qy
apt-get install -qy parted curl sudo kpartx rsync dosfstools
