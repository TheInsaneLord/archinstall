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

# warn if not in arch-chroot, but don’t bail out
if ! grep -q '/mnt ' /proc/1/mountinfo; then
  echo "⚠Warning: you’re not inside an arch-chroot—some operations may fail."
  echo "   Proceeding anyway; make sure you’ve already run arch-chroot /mnt"
  # no exit here, script will continue
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
