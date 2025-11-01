#!/bin/bash

set -e  # Exit script on error

# Prompt for Wayland or X11
read -p "Do you want Wayland or X11? (wayland/X11, default: X11) " Window_manager_choice
Window_manager_choice=${Window_manager_choice,,}  # Convert to lowercase

if [[ "$Window_manager_choice" == "wayland" ]]; then
    echo "Installing Wayland environment..."
    sudo pacman -S --noconfirm wayland plasma-workspace kwin qt5-wayland qt6-wayland xorg-xwayland kscreen
    sudo pacman -S --noconfirm xdg-desktop-portal xdg-desktop-portal-kde wl-clipboard
    sudo pacman -S --noconfirm sway swaybg swaylock swayidle waybar wofi grim slurp mako foot
    wayland_selected=true
else
    echo "Installing X11 environment..."
    sudo pacman -S --noconfirm xorg-server xorg-xinit xorg-apps xorg-twm xorg-xclock xterm plasma-x11-session kwin-x11
    sudo pacman -S --noconfirm xdg-desktop-portal xdg-desktop-portal-kde wl-clipboard
    x11_selected=true
fi

# Prompt for KDE or Gnome
read -p "Do you want KDE or Gnome? (kde/gnome, default: KDE) " Desktop_manager_choice
Desktop_manager_choice=${Desktop_manager_choice,,}  # Convert to lowercase

if [[ "$Desktop_manager_choice" == "gnome" ]]; then
    echo "Installing GNOME..."
    sudo pacman -S --noconfirm gnome gnome-extra gdm
    sudo systemctl enable gdm.service
elif [[ "$Desktop_manager_choice" == "kde" ]] || [[ -z "$Desktop_manager_choice" ]]; then
    echo "Installing KDE..."
    
    if [[ "$wayland_selected" == true ]]; then
        sudo pacman -S --noconfirm plasma-meta plasma-meta plasma-wayland-session sddm
    else
        sudo pacman -S --noconfirm plasma-meta plasma-workspace-x11 sddm
        # Optional: remove Wayland extras if already in system
        sudo pacman -Rns --noconfirm plasma-wayland-session qt5-wayland qt6-wayland kwayland 2>/dev/null || true
    fi

    sudo systemctl enable sddm.service
else
    echo "Invalid input. Skipping desktop environment installation."
fi

echo "GUI installation complete."
