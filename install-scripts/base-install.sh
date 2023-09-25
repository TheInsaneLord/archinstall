#!/bin/bash

# Display header
echo "-----------------------------------------------------"
echo "base linux install script"
echo "by The Insane Lord (2023)"
echo "-----------------------------------------------------"
echo ""
echo "Important: This script will install Arch Linux "
echo "up to a certain point and chroot the user into the"
echo "drive where Arch Linux was installed."
echo ""
echo "Warning: Before running this script, ensure you have"
echo "a good understanding of installing Arch Linux."
echo ""


loadkeys uk.map.gz
lsblk

echo "enter drive (i.e. sdb)"
read drive


# Mount root drive
mount /dev/"$drive"3 /mnt

# Create filesystem paths for mounting
echo "Making filesystem"
mkdir -p /mnt/boot
mkdir -p /mnt/home

# Mount boot and home partitions
mount /dev/"$drive"1 /mnt/boot
mount /dev/"$drive"4 /mnt/home

# Install base system
pacstrap /mnt base base-devel linux linux-headers linux-firmware

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# install Arch
arch-chroot /mnt <<EOF
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc
pacman -Sy
pacman -S nano
echo "#   local.gen selection uk and us" >> /etc/locale.gen
echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
Locale-gen
echo LANG=en_GB.UTF-8 > /etc/locale.conf
echo KEYMAP=uk.map.gz > /etc/vconsole.conf
export LANG=LANG=en_GB.UTF-8
EOF


echo "end of script"
echo "please continue installation"
