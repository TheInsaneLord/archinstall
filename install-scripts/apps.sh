#!/bin/bash

set -e  # Exit script on error

echo "Installing Default Applications..."
echo "Copying the pacman.conf"

sudo cp -v confs/pacman.conf /etc/pacman.conf

echo "Refreshing all package databases (including multilib)…"
pacman -Syy --noconfirm

# Install core applications
main_apps=(konsole firefox steam kate dolphin fastfetch git bash-completion flatpak bashtop pacman-contrib man ufw)

sudo pacman -S --noconfirm "${main_apps[@]}"

# Install optional apps
opt_apps=(traceroute libreoffice-fresh p7zip python3 python-pip filezilla unison)

read -p "Do you want to install Flatpaks? (Y/n) " opt_apps_choice
if [[ "$opt_apps_choice" =~ ^[Yy]$ ]] || [[ -z "$opt_apps_choice" ]]; then
  sudo pacman -S --noconfirm "${opt_apps[0]}"
else
  echo "optional apps skipped."
fi
  
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
systemctl enable --now pipewire pipewire.socket wireplumber

# Prompt for Flatpak installation
read -p "Do you want to install Flatpaks? (Y/n) " flatpak_choice
if [[ "$flatpak_choice" =~ ^[Yy]$ ]] || [[ -z "$flatpak_choice" ]]; then
  echo "Installing Flatpak packages..."
  
  # Ensure Flatpak is initialized
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

  # Install Flatpak applications
  flatpak install -y flathub com.discordapp.Discord
  flatpak install -y flathub com.google.Chrome
  flatpak install -y flathub org.prismlauncher.PrismLauncher
  flatpak install -y flathub com.spotify.Client
  flatpak install -y flathub org.inkscape.Inkscape
  flatpak install -y flathub org.kde.krita
  flatpak install -y flathub com.obsproject.Studio
  flatpak install -y flathub com.obsproject.Studio.Plugin.CompositeBlur
  flatpak install -y flathub com.obsproject.Studio.Plugin.AitumMultistream
  flatpak install -y flathub com.obsproject.Studio.Plugin.MoveTransition

  echo "Flatpak installation complete."
else
  echo "Flatpak installation skipped."
fi
