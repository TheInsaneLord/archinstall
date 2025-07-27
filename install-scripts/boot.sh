#!/bin/bash

# Later, in system.sh or boot.sh, you can do:
# if $nvidia_gpu; then
#   echo "Loading NVIDIA prerequisites…"
#   pacman -S --noconfirm nvidia nvidia-utils
#   # or add the kernel param in grub… 
# fi

# Set up bootloader
bootctl install
touch /boot/loader/entries/def.conf

# def.conf contents
echo "title Arch Linux" >> /boot/loader/entries/def.conf
echo "linux /vmlinuz-linux" >> /boot/loader/entries/def.conf
echo "initrd /amd-ucode.img" >> /boot/loader/entries/def.conf
echo "initrd /initramfs-linux.img" >> /boot/loader/entries/def.conf

lsblk
read -p "select a disk (e.g. sda1): " disk

# Add boot drive to def.conf
echo "options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/$disk) rw nvidia-drm.modeset=1" >> /boot/loader/entries/def.conf

# GRUB setup
pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools
nano /etc/default/grub  # Add GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1"
grub-install --target=x86_64-efi --bootloader-id=grub_efi --efi-directory=/boot/ --recheck
grub-mkconfig -o /boot/grub/grub.cfg
