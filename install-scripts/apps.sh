#!/bin/bash

set -e  # Exit script on error

echo "Installing Default Applications..."
echo "Copying the pacman.conf"

sudo cp -v confs/pacman.conf /etc/pacman.conf

echo "Refreshing all package databases (including multilib)…"
pacman -Syy --noconfirm

# Install core applications
main_apps=(konsole firefox steam blender ntfs-3g kate dolphin fastfetch git bash-completion flatpak bashtop pacman-contrib man ufw)

sudo pacman -S --noconfirm "${main_apps[@]}"

# Enable application
systemctl enable ufw.service

# install nvidia drivers
read -p "Install proprietary drivers for Nvidia? (Y/n) " nvidia_choice
if [[ "$nvidia_choice" =~ ^[Yy]$ ]] || [[ -z "$nvidia_choice" ]]; then
    sudo pacman -S --noconfirm nvidia-dkms nvidia-utils opencl-nvidia libglvnd lib32-libglvnd lib32-nvidia-utils lib32-opencl-nvidia nvidia-settings
    sudo cp -v confs/mkinitcpio.conf /etc/mkinitcpio.conf
else
    echo 'Skipping Nvidia Drivers'
fi

# Install optional apps
opt_apps=(traceroute libreoffice-fresh p7zip python3 python-pip filezilla unison filezilla openrgb)

read -p "Do you want to install optional apps? (Y/n) " opt_apps_choice
if [[ "$opt_apps_choice" =~ ^[Yy]$ ]] || [[ -z "$opt_apps_choice" ]]; then
  sudo pacman -S --noconfirm "${opt_apps[0]}"
else
  echo "optional apps skipped."
fi

# install wine
sudo pacman -S --noconfirm wine wine-mono wine-gecko winetricks lib32-mesa lib32-nvidia-utils lib32-libpulse lib32-alsa-plugins lib32-openal lib32-vkd3d
 
# Bluetooth support
sudo pacman -S --noconfirm bluez bluez-utils bluez-deprecated-tools
sudo systemctl enable bluetooth.service

# Printer support
sudo pacman -S --noconfirm system-config-printer cups cups-pdf
sudo systemctl enable cups.service

echo "Default application installation complete."
echo " --- Notes ---"
echo "If you need printer access, add the user to the 'lp' group:"
echo "sudo usermod -aG lp <username>"

# Audio setup for Pipewire
sudo pacman -S --noconfirm pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber qjackctl

# Prompt for Flatpak installation
read -p "Do you want to install Flatpaks? (Y/n) " flatpak_choice
if [[ "$flatpak_choice" =~ ^[Yy]$ ]] || [[ -z "$flatpak_choice" ]]; then
  echo "Installing Flatpak packages..."
  
  # Ensure Flatpak is initialized
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

  # Install Flatpak applications
  flatpak install -y com.discordapp.Discord
  flatpak install -y com.google.Chrome
  flatpak install -y org.prismlauncher.PrismLauncher
  flatpak install -y com.spotify.Client
  flatpak install -y org.inkscape.Inkscape
  flatpak install -y org.kde.krita
  flatpak install -y flathub com.obsproject.Studio
  flatpak install -y flathub com.obsproject.Studio.Plugin.CompositeBlur
  flatpak install -y flathub com.obsproject.Studio.Plugin.AitumMultistream
  flatpak install -y flathub com.obsproject.Studio.Plugin.MoveTransition
  flatpak install -y flathub org.godotengine.Godot

  echo "Flatpak installation complete."
else
  echo "Flatpak installation skipped."
fi
