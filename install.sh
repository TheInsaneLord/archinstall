#!/bin/bash

set -e  # Exit script on error

echo "* Arch Install Script *"
echo "* By The Insane Lord *"
echo "* This script will configure your Arch system. *"
echo "* Make sure this script is ran after running arch-chroot *"
echo "* Version: 2.0 - Updated last: 2025 *"

echo "Available scripts."
ls  install-scripts
echo " "

nvidia_gpu=false
amd_gpu=false

# Ask user if they have an NVIDIA GPU
read -rp "Do you have an NVIDIA GPU? (Y/n) " nvidia_choice
nvidia_choice=${nvidia_choice:-Y}
nvidia_gpu=$([[ "${nvidia_choice,,}" == "y" ]] && echo true || echo false)

# Ask user if they have an AMD GPU
read -rp "Do you have an AMD GPU? (Y/n) " amd_choice
amd_choice=${amd_choice:-Y}
amd_gpu=$([[ "${amd_choice,,}" == "y" ]] && echo true || echo false)

# If both selected, ask which one to use
while [[ "$nvidia_gpu" == true && "$amd_gpu" == true ]]; do
  echo
  echo "Both NVIDIA and AMD were selected. This installer supports one primary GPU."
  echo "  1) NVIDIA"
  echo "  2) AMD"
  read -rp "Enter 1 or 2 [1]: " gpu_sel
  gpu_sel=${gpu_sel:-1}
  if [[ "$gpu_sel" == "1" ]]; then
    nvidia_gpu=true; amd_gpu=false
  else
    nvidia_gpu=false; amd_gpu=true
  fi
done

# If neither selected, confirm headless/server install
if [[ "$nvidia_gpu" == false && "$amd_gpu" == false ]]; then
  echo
  read -rp "No GPU selected. Proceed as headless/server install? (Y/n) " headless_ans
  headless_ans=${headless_ans:-Y}
  if [[ "${headless_ans,,}" != "y" ]]; then
    echo "Okay, let's choose again."
    # re-ask
    read -rp "Do you have an NVIDIA GPU? (Y/n) " nvidia_choice
    nvidia_choice=${nvidia_choice:-Y}
    nvidia_gpu=$([[ "${nvidia_choice,,}" == "y" ]] && echo true || echo false)

    read -rp "Do you have an AMD GPU? (Y/n) " amd_choice
    amd_choice=${amd_choice:-Y}
    amd_gpu=$([[ "${amd_choice,,}" == "y" ]] && echo true || echo false)

    # enforce single-GPU again
    while [[ "$nvidia_gpu" == true && "$amd_gpu" == true ]]; do
      echo
      echo "Both NVIDIA and AMD were selected. Which one do you want to use?"
      echo "  1) NVIDIA"
      echo "  2) AMD"
      read -rp "Enter 1 or 2 [1]: " gpu_sel
      gpu_sel=${gpu_sel:-1}
      if [[ "$gpu_sel" == "1" ]]; then
        nvidia_gpu=true; amd_gpu=false
      else
        nvidia_gpu=false; amd_gpu=true
      fi
    done
  fi
fi

export nvidia_gpu amd_gpu
echo "nvidia_gpu is set to: $nvidia_gpu"
echo "amd_gpu is set to: $amd_gpu"


# Warn if likely not in arch-chroot (non-fatal)
if ! mountpoint -q /; then
  echo "⚠ Warning: / is not a mountpoint. Are you inside arch-chroot?"
  echo "   Proceeding anyway; make sure you've already run: arch-chroot /mnt"
fi


# Ensure the install-scripts directory exists
if [[ ! -d "install-scripts" ]]; then
    echo "Error: 'install-scripts' directory is missing!"
    exit 1
fi

# Ensure all install scripts are executable
chmod +x install-scripts/*.sh

# Ask if the user wants the bootloader installed
if [[ -f "install-scripts/boot.sh" ]]; then
    read -p "Do you want to install boot loader? (Y/n) " boot_choice
    if [[ "$boot_choice" =~ ^[Yy]$ ]] || [[ -z "$boot_choice" ]]; then
        ./install-scripts/boot.sh
    fi
else
    echo "Warning: boot.sh not found, skipping boot loader setup."
fi

# Ask if the user wants to configure system files
if [[ -f "install-scripts/system.sh" ]]; then
    read -p "Do you want to configure system files (fstab, console settings)? (Y/n) " sys_choice
    if [[ "$sys_choice" =~ ^[Yy]$ ]] || [[ -z "$sys_choice" ]]; then
        ./install-scripts/system.sh
    fi
else
    echo "Warning: system.sh not found, skipping system configuration."
fi

# Ask if the user wants to configure GUI
if [[ -f "install-scripts/gui.sh" ]]; then
    read -p "Do you want to configure GUI? (Y/n) " gui_choice
    if [[ "$gui_choice" =~ ^[Yy]$ ]] || [[ -z "$gui_choice" ]]; then
        ./install-scripts/gui.sh
    fi
else
    echo "Warning: gui.sh not found, skipping GUI setup."
fi

# Ask if the user wants default Pacman hooks
if [[ -f "install-scripts/hooks.sh" ]]; then
    read -p "Do you want to install default Pacman hooks? (Y/n) " hooks_choice
    if [[ "$hooks_choice" =~ ^[Yy]$ ]] || [[ -z "$hooks_choice" ]]; then
        ./install-scripts/hooks.sh
    fi
else
    echo "Warning: hooks.sh not found, skipping hooks setup."
fi

# Ask if the user wants to install default applications
if [[ -f "install-scripts/apps.sh" ]]; then
    read -p "Do you want to install default applications? (Y/n) " apps_choice
    if [[ "$apps_choice" =~ ^[Yy]$ ]] || [[ -z "$apps_choice" ]]; then
        ./install-scripts/apps.sh
    fi
else
    echo "Warning: apps.sh not found, skipping application installation."
fi

#Example query (Replace [query] and [script-name] as needed)
#read -p "Ask question here? (Y/n) " [query]_choice
#if [[ "$[query]_choice" =~ ^[Yy]$ ]] || [[ -z "$[query]_choice" ]]; then
#    ./install-scripts/[script-name].sh
#fi

echo
echo "Installation and configuration complete!"
echo "You may want to reboot now."
