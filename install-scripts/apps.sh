#!/bin/bash

# install GPU drivers
nvidia_gpu=false
amd_gpu=false

set -e  # Exit script on error

echo "Installing Default Applications..."
echo "Copying the pacman.conf"

sudo cp -v confs/pacman.conf /etc/pacman.conf

echo "Refreshing all package databases (including multilib)…"
pacman -Syy --noconfirm

# Install core applications
main_apps=(konsole firefox steam blender ntfs-3g kate dolphin fastfetch git bash-completion flatpak bashtop pacman-contrib man ufw openssh wget tree libappimage)

sudo pacman -S --noconfirm "${main_apps[@]}"

# Enable application
systemctl enable ufw.service

# install GPU drivers
# ---- Nvidia GPU drivers ----
read -p "Install proprietary drivers for Nvidia? (Y/n) " nvidia_choice
if [[ "$nvidia_choice" =~ ^[Yy]$ ]] || [[ -z "$nvidia_choice" ]]; then
  nvidia_gpu=true
  echo "Select Nvidia driver type:"
  echo "  1) Latest (recommended for modern GPUs, 1000+ series)"
  echo "  2) Legacy 470xx (for Kepler GPUs)"
  echo "  3) Legacy 390xx (for older Fermi GPUs)"
  read -p "Enter 1, 2 or 3 [1]: " nvidia_family
  nvidia_family=${nvidia_family:-1}

  if [[ "$nvidia_family" == "1" ]]; then
    nvidia_pkgs=(nvidia-dkms nvidia-utils libglvnd lib32-libglvnd lib32-nvidia-utils nvidia-settings)

    # Vulkan
    echo "Choose Vulkan driver:"
    echo "  1) Included in nvidia-utils (recommended)"
    echo "  2) Nvidia Vulkan Beta driver (AUR)"
    read -p "Enter 1 or 2 [1]: " vk_choice
    vk_choice=${vk_choice:-1}
    if [[ "$vk_choice" == "2" ]]; then
      echo "Note: Vulkan beta drivers are only in AUR, not pacman."
    fi

    # OpenCL
    read -p "Install Nvidia OpenCL support? (Y/n) " opencl_choice
    if [[ "$opencl_choice" =~ ^[Yy]$ ]] || [[ -z "$opencl_choice" ]]; then
      nvidia_pkgs+=(opencl-nvidia lib32-opencl-nvidia)
    fi

    sudo pacman -S --noconfirm "${nvidia_pkgs[@]}"
    sudo cp -v confs/mkinitcpio.conf /etc/mkinitcpio.conf

  elif [[ "$nvidia_family" == "2" ]]; then
    sudo pacman -S --noconfirm nvidia-470xx-dkms nvidia-470xx-utils lib32-nvidia-470xx-utils opencl-nvidia-470xx nvidia-470xx-settings

  elif [[ "$nvidia_family" == "3" ]]; then
    sudo pacman -S --noconfirm nvidia-390xx-dkms nvidia-390xx-utils lib32-nvidia-390xx-utils opencl-nvidia-390xx nvidia-390xx-settings

  else
    echo "Invalid selection. Skipping Nvidia driver installation."
    nvidia_gpu=false
  fi
else
  echo "Skipping Nvidia Drivers"
fi
# ---- end Nvidia GPU drivers ----

# ---- AMD GPU drivers (place this block after the Nvidia section and before optional apps) ----
read -p "Install drivers for AMD GPU? (Y/n) " amd_choice
if [[ "$amd_choice" =~ ^[Yy]$ ]] || [[ -z "$amd_choice" ]]; then
  amd_gpu=true
  echo "Select AMD driver family:"
  echo "  1) AMDGPU (most GCN 3+/Polaris, Vega, RDNA/RDNA2/RDNA3 — recommended)"
  echo "  2) Radeon (legacy/older GPUs)"
  read -p "Enter 1 or 2 [1]: " amd_family
  amd_family=${amd_family:-1}

  if [[ "$amd_family" == "1" ]]; then
    # Base modern AMDGPU stack (with 32-bit where applicable)
    amd_pkgs=(mesa lib32-mesa libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau xf86-video-amdgpu)
    # Choose Vulkan implementation
    echo "Choose Vulkan driver:"
    echo "  1) RADV (Mesa) — recommended"
    echo "  2) AMDVLK (official)"
    read -p "Enter 1 or 2 [1]: " vk_choice
    vk_choice=${vk_choice:-1}
    if [[ "$vk_choice" == "2" ]]; then
      amd_pkgs+=("amdvlk" "lib32-amdvlk")
    else
      amd_pkgs+=("vulkan-radeon" "lib32-vulkan-radeon")
    fi

    # Optional OpenCL (ROCm)
    read -p "Install OpenCL runtime (ROCm) for AMD? (y/N) " opencl_choice
    if [[ "$opencl_choice" =~ ^[Yy]$ ]]; then
      amd_pkgs+=("rocm-opencl-runtime" "ocl-icd" "opencl-headers")
      # Note: 32-bit OpenCL for AMD is generally not provided on Arch.
    fi

    sudo pacman -S --noconfirm "${amd_pkgs[@]}"

  elif [[ "$amd_family" == "2" ]]; then
    # Legacy Radeon stack (no Vulkan on many older GPUs)
    sudo pacman -S --noconfirm mesa lib32-mesa libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau xf86-video-ati
  else
    echo "Invalid selection. Skipping AMD driver installation."
  fi
else
  echo "Skipping AMD drivers"
fi
# ---- end AMD GPU drivers ----

# Install optional apps
opt_apps=(vlc traceroute libreoffice-fresh p7zip python3 python-pip filezilla unison openrgb jdk-openjdk goverlay mangohud lib32-mangohud rsync)

read -p "Do you want to install optional apps? (Y/n) " opt_apps_choice
if [[ "$opt_apps_choice" =~ ^[Yy]$ ]] || [[ -z "$opt_apps_choice" ]]; then
  sudo pacman -S --noconfirm "${opt_apps[@]}"
else
  echo "optional apps skipped."
fi

# install wine
wine_pkgs=(wine wine-mono wine-gecko winetricks lib32-mesa lib32-libpulse lib32-alsa-plugins lib32-openal lib32-vkd3d)

if [[ "$nvidia_gpu" == true ]]; then
  wine_pkgs+=(lib32-nvidia-utils)
elif [[ "$amd_gpu" == true ]]; then
  wine_pkgs+=(lib32-vulkan-radeon)
fi

sudo pacman -S --noconfirm "${wine_pkgs[@]}"

# Install croni
sudo pacman -S --noconfirm cronie
sudo systemctl enable cronie --now

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
  flatpak install -y org.prismlauncher.PrismLauncher
  flatpak install -y org.inkscape.Inkscape
  flatpak install -y org.kde.krita
  flatpak install -y flathub org.godotengine.Godot
  flatpak install -y com.github.Matoking.protontricks
  flatpak install -y io.github.streetpea.Chiaki4deck
  flatpak install -y org.kde.krita
  
  # OBS and OBS plugins
  flatpak install -y flathub com.obsproject.Studio
  flatpak install -y flathub com.obsproject.Studio.Plugin.CompositeBlur
  flatpak install -y flathub com.obsproject.Studio.Plugin.AitumMultistream
  flatpak install -y flathub com.obsproject.Studio.Plugin.MoveTransition
  flatpak install -y flathub com.obsproject.Studio.Plugin.waveform 
  

  echo "Flatpak installation complete."
  echo "install problematic apps on your own. [Spotify, Chrome]"
  
else
  echo "Flatpak installation skipped."
fi
