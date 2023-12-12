#!/bin/sh
set -x

DEBIAN_VERSION="${1:-10.13.0}"
ISO_URL="https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/archive/${DEBIAN_VERSION}+nonfree/amd64/iso-cd/firmware-${DEBIAN_VERSION}-amd64-netinst.iso"
ISO_FILE=$(basename $ISO_URL)
FILE=debian-${DEBIAN_VERSION}-usb-preseed.img
#
echo "# Start: $(basename $0) build $FILE based on $ISO_FILE"

echo "# create new 1G image file, will overwrite $FILE if it already exists"
dd if=/dev/zero of=$FILE bs=1M count=1024

offset1=$(parted $FILE \
    mklabel msdos \
    mkpart primary fat32 0% 100% \
    unit B \
    print | awk '$1 == 1 {gsub("B","",$2); print $2}')

loop1=$(losetup -o $offset1 -f $FILE --show)

mkdir -p /mnt/data
mkfs.vfat $loop1
mount $loop1 /mnt/data

# mount iso
[ -f $ISO_FILE ] || curl -OL $ISO_URL
kpartx -v -a $ISO_FILE
mkdir -p /mnt/cdrom
mount /dev/mapper/loop1p1 /mnt/cdrom/
rsync -av /mnt/cdrom/ /mnt/data/
rsync -avL /mnt/cdrom/firmware/ /mnt/data/firmware/
umount /mnt/cdrom

# Same story with the second partition on the ISO
mount /dev/mapper/loop1p2 /mnt/cdrom/
rsync -av /mnt/cdrom/ /mnt/data/
umount /mnt/cdrom

# generate preseed with SSID  or ask SSID during install
if [ -n "$CHANGE_SSID" -a -n "$CHANGE_WPA_KEY" ] ; then
  echo "# define SSID and WPA auto install"
  ( export CHANGE_SSID=$CHANGE_SSID ; export CHANGE_WPA_KEY="$CHANGE_WPA_KEY"
    cat preseed.cfg.tpl|sed -e "s/_CHANGE_SSID_/${CHANGE_SSID}/; s/_CHANGE_WPA_KEY_/${CHANGE_WPA_KEY}/" ) > preseed-auto.cfg

  cp preseed-auto.cfg /mnt/data/preseed.cfg
else
  echo "# manually define SSID and WPA during install"
  cp preseed.cfg /mnt/data/
fi

cp grub.cfg /mnt/data/boot/grub/grub.cfg
#
#echo "linux    /install.amd/vmlinuz vga=788 --- quiet preseed/file=/cdrom/preseed.cfg" >> /mnt/data/boot/grub/grub.cfg

# cleanup
rm -rf preseed-auto.cfg
umount /mnt/data
losetup -d $loop1
kpartx -d -v $ISO_FILE

echo "# End: you can  dd  $FILE on your usb stick"
