#!/bin/bash

set -e  # Exit script on error

echo 
echo "This sets up the following items and only these items"
echo "- fstab secondary drives."
echo "- Network settings."
echo "- vconsole.conf"
echo 

# vconsole
sudo echo KEYMAP=uk > /etc/vconsole.conf

# add fstab drives
if [[ -f "confs/fstab" ]]; then
    echo "Appending secondary drives to fstab..."
    cat confs/fstab | sudo tee -a /etc/fstab > /dev/null
else
    echo "Warning: 'confs/fstab' not found! Skipping fstab setup."
fi

# samba setup
echo "Installing Samba for Windows file sharing..."
sudo pacman -S --noconfirm samba
if [[ -f "confs/samba-credentials" ]]; then
    echo "Copying Samba credentials..."
    sudo install -m 600 confs/samba-credentials /etc/samba-credentials
else
    echo "Warning: Samba credentials file not found! Skipping..."
fi

# setup network
#!/bin/bash

# Function to list available network interfaces (excluding loopback)
list_interfaces() {
    ip -o link show | awk -F': ' '{print $2}' | grep -v "lo"
}

echo "Setting up network configuration..."

# List available network interfaces
list_interfaces

# Prompt user for the primary NIC (Internet)
read -p "Enter the primary network interface (for internet access): " PRIMARY_NIC

# Update package list and install necessary network packages
echo "Installing NetworkManager..."
sudo pacman -S --noconfirm networkmanager

# Ensure NetworkManager starts on boot
echo "Enabling NetworkManager..."
sudo systemctl enable --now NetworkManager.service

# Configure PRIMARY NIC (Main Internet Connection)
echo "Setting up $PRIMARY_NIC as the default internet connection..."
sudo nmcli connection add type ethernet ifname "$PRIMARY_NIC" con-name "$PRIMARY_NIC"
sudo nmcli connection modify "$PRIMARY_NIC" ipv4.method auto ipv4.route-metric 100
sudo nmcli connection modify "$PRIMARY_NIC" connection.autoconnect yes
sudo nmcli connection up "$PRIMARY_NIC"

# Configure all other NICs as secondary (Server/Local Networks)
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

# Verify the network setup
echo "Checking network configuration..."
ip route show
nmcli connection show --active

echo "Network setup complete!"

echo "Setting up nano as default editor"
sudo pacman -S --noconfirm nano
echo "EDITOR=/usr/bin/nano" >> /etc/environment
echo "VISUAL=/usr/bin/nano" >> /etc/environment

echo "done."


echo "Installation and configuration complete!"
