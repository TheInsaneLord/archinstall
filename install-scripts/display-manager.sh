#!/bin/bash

echo "-----------------------------------------------------"
echo "Display Manager Install Script"
echo "by The Insane Lord (2023)"
echo "-----------------------------------------------------"
echo ""
echo "This script will install a display manager, either SDDM"
echo "(for KDE/Plasma) or GNOME, along with Xorg and Mesa."
echo ""
echo "Note: The changes will take effect after a reboot."
echo "Please ensure you have configured your system properly."
echo ""


# install xorg
echo "installing xorg and mesa"
pacman -S xorg-twm xorg-xclock xterm xorg-apps xorg-server xorg-xinit mesa
echo "install compleat"


# install gnomr or sddm
read -p "Choose a display manager (SDDM/GNOME): " display_manager

if [[ "$display_manager" == "SDDM" || "$display_manager" == "sddm" ]]; then
  echo "Installing gnome"
  pacman -S gnome gnome-extra gdm
  systemctl enable gdm.service
  echo "install compleat"

else #install sddm
  echo "installing DDM."
  pacman -S plasma kde-applications sddm
  systemctl enable sddm.service
  echo "install compleat"

fi

# End of script
echo "-----------------------------------------------------"
echo "End of Display Manager Install Script by "
echo "The Insane Lord (2023)"
echo "-----------------------------------------------------"
echo "Thank you for using this installation script."
echo "If you encounter any issues, please consult"
echo "the documentation"
echo "or seek assistance from the administrator."
