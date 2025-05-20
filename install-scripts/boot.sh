#!/usr/bin/env bash
set -euo pipefail

# boot.sh - Install and configure bootloader (GRUB or systemd-boot)

# Prompt for bootloader choice (default: GRUB)
read -rp "Select bootloader - GRUB or systemd-boot [GRUB]: " boot_choice
boot_choice=${boot_choice:-GRUB}

# Normalize and validate choice\Bootloader
boot_norm=$(echo "$boot_choice" | tr '[:upper:]' '[:lower:]')
if [[ "$boot_norm" != "grub" && "$boot_norm" != "systemd-boot" ]]; then
  echo "Invalid choice '$boot_choice', defaulting to GRUB."
  boot_norm="grub"
fi

echo "Bootloader selected: ${boot_norm^}"

case "$boot_norm" in
  systemd-boot)
    echo "Installing systemd-boot..."
    pacman -S --noconfirm systemd-boot
    bootctl --path=/boot install

    # Create loader config
    cat <<EOF > /boot/loader/loader.conf
default  arch
timeout  5
EOF

    # Determine root partition and PARTUUID
    ROOT_PART=$(awk '$2=="/" {print $1; exit}' /etc/fstab)
    PARTUUID=$(blkid -s PARTUUID -o value "$ROOT_PART")

    # Create entry
    cat <<EOF > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /amd-ucode.img
initrd  /initramfs-linux.img
options root=PARTUUID=${PARTUUID} rw nvidia-drm.modeset=1
EOF
    ;;

  grub)
    echo "Installing GRUB..."
    pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools

    # Detect EFI vs BIOS using efivar
    if efivar -l > /dev/null 2>&1; then
      echo "UEFI environment detected via efivar."
      ESP_MNT="/boot"
      grub-install --target=x86_64-efi --efi-directory="$ESP_MNT" \
        --bootloader-id=GRUB --recheck
    else
      echo "Legacy BIOS environment detected."
      BOOT_DISK=${BOOT_DISK:-/dev/sda}
      grub-install --target=i386-pc "$BOOT_DISK"
    fi

    # Configure kernel command line for NVIDIA modeset
    sed -i 's|^GRUB_CMDLINE_LINUX="\(.*\)"|GRUB_CMDLINE_LINUX="\1 nvidia-drm.modeset=1"|' /etc/default/grub

    # Generate GRUB configuration
    grub-mkconfig -o /boot/grub/grub.cfg
    ;;

esac

echo "Bootloader setup complete."
