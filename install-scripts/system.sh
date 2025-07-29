#!/bin/bash

set -e  # Exit script on error

echo
echo "This sets up the following items and only these items:"
echo "- fstab secondary drives."
echo "- Network settings."
echo "- vconsole.conf"
echo "- Nano as default editor"
echo "- Optional sg-module for MakeMKV"
echo

# Configure vconsole.conf
echo "Setting keyboard layout to UK..."
echo "KEYMAP=uk" | sudo tee /etc/vconsole.conf > /dev/null

# Append fstab entries for secondary drives
if [[ -f "confs/fstab" ]]; then
    echo "Appending secondary drives to fstab..."
    cat confs/fstab | sudo tee -a /etc/fstab > /dev/null
else
    echo "Warning: 'confs/fstab' not found! Skipping fstab setup."
fi

# Samba setup
echo "Installing Samba for Windows file sharing..."
sudo pacman -S --noconfirm samba
if [[ -f "confs/samba-credentials" ]]; then
    echo "Copying Samba credentials..."
    sudo install -m 600 confs/samba-credentials /etc/samba-credentials
else
    echo "Warning: Samba credentials file not found! Skipping..."
fi

: <<'COMMENT'
# Function to list available network interfaces (excluding loopback)
list_interfaces() {
    ip -o link show | awk -F': ' '{print $2}' | grep -v "lo"
}

# Network setup
echo "Setting up network configuration..."

# List available network interfaces
echo "Available network interfaces:"
list_interfaces

# Prompt user for the primary NIC (Internet)
read -p "Enter the primary network interface (for internet access): " PRIMARY_NIC
COMMENT

# Install NetworkManager
echo "Installing NetworkManager..."
sudo pacman -S --noconfirm networkmanager

# Ensure NetworkManager starts on boot
echo "Enabling NetworkManager..."
sudo systemctl enable NetworkManager.service

: <<'COMMENT'
# Configure PRIMARY NIC (Main Internet Connection)
echo "Setting up $PRIMARY_NIC as the default internet connection..."
sudo nmcli connection add type ethernet ifname "$PRIMARY_NIC" con-name "$PRIMARY_NIC"
sudo nmcli connection modify "$PRIMARY_NIC" ipv4.method auto ipv4.route-metric 100
sudo nmcli connection modify "$PRIMARY_NIC" connection.autoconnect yes
sudo nmcli connection up "$PRIMARY_NIC"

# Configure additional network interfaces
echo "Configuring additional network interfaces..."
for NIC in $(list_interfaces); do
    # Skip the primary NIC
    if [[ "$NIC" == "$PRIMARY_NIC" ]]; then
        continue
    fi

    echo "Setting up $NIC as a secondary network (no default route)..."
    sudo nmcli connection add type ethernet ifname "$NIC" con-name "$NIC"
    sudo nmcli connection modify "$NIC" ipv4.method auto ipv4.never-default yes
    sudo nmcli connection modify "$NIC" ipv4.route-metric 200
    sudo nmcli connection modify "$NIC" connection.autoconnect yes
    sudo nmcli connection up "$NIC"
done

# Verify network setup
echo "Checking network configuration..."
ip route show
nmcli connection show --active

echo "Network setup complete!"
COMMENT

# Setting up nano as default editor
echo "Setting nano as the default editor..."
sudo pacman -S --noconfirm nano
echo "EDITOR=/usr/bin/nano" | sudo tee -a /etc/environment > /dev/null
echo "VISUAL=/usr/bin/nano" | sudo tee -a /etc/environment > /dev/null

# Optional sg-module for MakeMKV
read -p "Do you need sg-module for MakeMKV? (Y/n) " sgmodule_choice
if [[ "$sgmodule_choice" =~ ^[Yy]$ ]] || [[ -z "$sgmodule_choice" ]]; then
    if [[ -f "confs/sg-module-load.service" ]]; then
        echo "Installing sg-module-load.service..."
        sudo install -m 644 confs/sg-module-load.service /etc/systemd/system/sg-module-load.service
        sudo systemctl enable sg-module-load.service
        sudo systemctl daemon-reload
        sudo systemctl restart sg-module-load.service
        echo "sg-module-load.service has been installed and enabled."
    else
        echo "Error: confs/sg-module-load.service not found! Skipping installation."
    fi
else
    echo "Skipping sg-module."
fi


# Base system conf I.e. users and system settings
read -p "Create a main user? (Y/n) " user_choice
if [[ "$user_choice" =~ ^[Yy]$ ]] || [[ -z "$user_choice" ]]; then
  # Prompt for username, default to "mypcuser"
  read -p "Enter main username [mypcuser]: " main_user
  main_user=${main_user:-mypcuser}

  # Create the user, its own group, and add to wheel/storage/power
  useradd -m -U -G wheel,storage,power -s /bin/bash "$main_user"

  echo "Set password for $main_user:"
  passwd "$main_user"
  chown -R "$main_user":"$main_user" /home/"$main_user" # update perms in the event the folder alredy exists
  
  # set admin password //temp add may change later. : Jul 23 2025
  read -p "Enter Admin Password: " adminpass
  passwd "$adminpass"

  # Ensure sudoers wheel group is enabled
  #sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
  sudo cp -v confs/sudoers /etc/sudoers # Copy default sudoers file and overwrite old one 
else
  echo "Skipping user creation."
fi

# Prompt for a hostname, default to "mypc-01"
read -p "Enter hostname [mypc-01]: " host
host=${host:-mypc-01}

echo "$host" > /etc/hostname

echo
echo "Installation and configuration complete!"
