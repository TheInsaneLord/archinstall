#!/bin/bash

set -e  # Exit script on error

echo 
echo "This sets up the following items and only these items"
echo "- fstab secondery drives."
echo "- Network settings."
echo "- vconsole.conf"
echo 

# vconsole
sudo echo KEYMAP=uk > /etc/vconsole.conf

# add fstab drives
echo >> /etc/fstab


# setup network
sudo pacman -S networkmanager dhcpcd
sudo system enable NetworkManager.service  
sudo system enable dhcpcd@enp3s0.service

echo "Installation and configuration complete!"