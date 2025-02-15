#!/bin/bash

set -e  # Exit script on error

echo "Setting up Pacman hooks..."

sudo -p /etc/pacman.d/hooks
sudo cp -v hooks/*.hook /etc/pacman.d/hooks

echo "Pacman hooks installed successfully."
