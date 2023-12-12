# debian preseed usb disk

Script to generate a usb disk for automated debian install with preseed base on iso-cd firmware netinst.

Scripts are tested on Linux and Mac M1 with qemu

- qemu directory: contains script to start qemu linux vm on Mac M1
- share directory: contains script to generate usk disk, with preseed
    - mkusb-preseed.sh: script to build debian.img base on firmware iso and add preseed file. You can specify the debian version to download as argument
    - grub.cfg: grub menu with 2 entry : automated install and advanced manual install if neeeded
    - preseed.cfg: net install with wifi card. You must enter during install, the SSID and WPA
    - preseed.cfg.tpl: same but it s a template that can be used to automatically configure SSID and WPA. Replace value in preseed.cfg.tpl and copy to preseed.cfg

Preseed must be customized to your needs.

By default: you must replace user root, ansible password and crypto disk passphrase

## For Mac M1: run Qemu VM

- To start qemu linux VM on Mac M1, use the qemu/start.sh script
- the share directory will be available in the VM unser /mnt/host
- ssh into the vm
```bash
# ssh -p 6543 ansible@localhost
# cd /mnt/host
```

Then follow the steps below

## To build usb stick with auto install and wifi enabled

To build debian img

``` bash
# on linux
cd share

export CHANGE_SSID="REPLACE_WITH_MY_WIFI_NET"
export CHANGE_WPA_KEY="_REPLACE_WITH_MY_WPA_KEY_"

# default generate a 10.13.0 debian netinstall
./mkusb-preseed.sh

# To generate a 11.8.0 debian netinstall
# ./mkusb-preseed.sh 11.8.0
```
Then copy the debian img on your USB stick

```bash
sudo dd if=debian-${DEBIAN_VERSION}-usb-preseed.img  of=/dev/${YOUR_USB_DEVICE} bs=4M
```

Boot your PC on your usb stick.
