#!/bin/bash

set -e  # Exit script on error

# Prompt for Wayland or X11
read -p "Do you want Wayland or X11? (wayland/X11, default: X11) " Window_manager_choice
Window_manager_choice=${Window_manager_choice,,}  # Convert to lowercase

if [[ "$Window_manager_choice" == "wayland" ]]; then
    echo "Installing Wayland environment..."
    sudo pacman -S --noconfirm wayland wlroots qt5-wayland qt6-wayland xorg-xwayland xwayland
    sudo pacman -S --noconfirm sway swaybg swaylock swayidle waybar wofi grim slurp mako foot
else
    echo "Installing X11 environment..."
    sudo pacman -S --noconfirm xorg-twm xorg-xclock xterm xorg-apps xorg-server xorg-xinit
fi

# Prompt for KDE or Gnome
read -p "Do you want KDE or Gnome? (kde/gnome, default: KDE) " Desktop_manager_choice
Desktop_manager_choice=${Desktop_manager_choice,,}  # Convert to lowercase

if [[ "$Desktop_manager_choice" == "gnome" ]]; then
    echo "Installing Gnome..."
    sudo pacman -S --noconfirm gnome gnome-extra gdm
    sudo systemctl enable gdm.service
elif [[ "$Desktop_manager_choice" == "kde" ]] || [[ -z "$Desktop_manager_choice" ]]; then
    echo "Installing KDE..."
    sudo pacman -S --noconfirm plasma kde-applications sddm
    sudo systemctl enable sddm.service
else
    echo "Invalid input. Skipping desktop environment installation."
fi

echo "GUI installation complete."
