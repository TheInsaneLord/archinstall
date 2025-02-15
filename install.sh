#!/bin/bash

set -e  # Exit script on error

echo "* Arch Install Script *"
echo "* By The Insane Lord *"
echo "* This script will configure your Arch system. "
echo "* Version: 1.0 - Updated last: 2025 *"

# Ensure install scripts are executable
chmod +x install-scripts/*.sh

# Ask if the user wants default Pacman hooks
read -p "Do you want to install default Pacman hooks? (Y/n) " hooks_choice
if [[ "$hooks_choice" =~ ^[Yy]$ ]] || [[ -z "$hooks_choice" ]]; then
    ./install-scripts/setup-hooks.sh
fi

# Ask if the user wants to configure system files
read -p "Do you want to configure system files (fstab, console settings)? (Y/n) " sys_choice
if [[ "$sys_choice" =~ ^[Yy]$ ]] || [[ -z "$sys_choice" ]]; then
    ./install-scripts/setup-system.sh
fi

# Example query (Replace [query] and [script-name] as needed)
# read -p "Ask question here? (Y/n) " [query]_choice
# if [[ "$[query]_choice" =~ ^[Yy]$ ]] || [[ -z "$[query]_choice" ]]; then
#     ./install-scripts/[script-name].sh
# fi

echo
echo "Installation and configuration complete!"
echo "You may want to reboot now."
