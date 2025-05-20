#!/bin/bash

# Later, in system.sh or boot.sh, you can do:
# if $nvidia_gpu; then
#   echo "Loading NVIDIA prerequisites…"
#   pacman -S --noconfirm nvidia nvidia-utils
#   # or add the kernel param in grub… 
# fi
# set up bootloader
# systemd-boot
bootctl install
touch /boot/loader/entries/def.conf
# def.conf
echo "title Arch Linux" >>
echo "linux /vmlinuz-linux" >>
echo "initrd /amd-ucode.img" >>
echo "initrd /initramfs-linux.img" >>

lsblk
read -p "select a disk (sda1)" disk

# add boot drive to def.conf
echo "options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/$disk) rw nvidia-drm.modeset=1" >> /boot/loader/entries/def.conf

# GRUB
pacman -S grub efibootmgr dostools os-prober mtools
nano /etc/default/grub # add GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1"
grub-install  --target=x86_64-efi --bootloader-id=grub_efi --efi-directory=/boot/ --recheck
grub-mkconfig -o /boot/grub/grub.cfg
