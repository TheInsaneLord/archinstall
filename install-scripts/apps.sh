#!/bin/bash
echo "-----------------------------------------------------"
echo "App install script"
echo "by The Insane Lord (2023)"
echo "-----------------------------------------------------"
echo ""
echo "Important: This script will install apps that are "
echo "required by the setup"
echo ""
echo "Warning: This script should be run at the end of"
echo "the installation for best comparability."
echo ""

# install must have apps
echo "installing required apps"
pacman -S konsole firefox discord steam kate dolphin neofetch git bash-completion  flatpak packagekit-qt5 pacman-contrib bashtop ufw

# install qemu and kvm
opt=0
read -p "Do you want to GNS3? (y/n): " opt
if [[ "$opt" == "y" || "$opt" == "Y" || "$opt" == "yes" || "$opt" == "Yes" ]]; then
  # install GNS3
  echo "Installing QEMU and kvm"

  sudo pacman -S qemu-full virt-manager ovmf vde2 dnsmasq bridge-utils openbsd-netcat edk2-ovmf
  sudo systemctl enable libvirtd
  sudo systemctl start libvirtd

  echo ""
  echo "QEMU and kvm install completed."
else
  echo "skipping QEMU and kvm."
fi


# install GNS3
# install GNS3
opt=0
read -p "Do you want to GNS3? (y/n): " opt
if [[ "$opt" == "y" || "$opt" == "Y" || "$opt" == "yes" || "$opt" == "Yes" ]]; then
  # setup GNS3
  echo "Installing GNS3."
  read -p "Please provide a user name: " user

  # creating GNS3 temporary folder
  mkdir /home/"$user"/tmp

  # Update the package manager
  sudo pacman -Syy

  # Install required packages
  sudo pacman -S python-pip wget git cmake make gcc bison flex base-devel qt5-tools qt5-multimedia python-pyqt5 python-pyzmq libelf libpcap iniparser

  # Upgrade pip
  sudo pip install --upgrade pip

  # Install Python packages
  sudo pip install -U tornado setuptools netifaces zmq dev ws4py pyqt5

  # Install Dynamips
  cd /home/"$user"/tmp
  git clone git://github.com/GNS3/dynamips.git
  cd dynamips
  make
  sudo make install

  # Install iouyap
  cd /home/"$user"/tmp
  git clone https://github.com/GNS3/iouyap.git
  cd iouyap
  make
  sudo make install

  # Install ubridge
  cd /home/"$user"/tmp
  git clone https://github.com/GNS3/ubridge.git
  cd ubridge
  make
  sudo make install

  # Download GNS3 logo
  cd /usr/share/
  sudo wget https://www.gns3.com/assets/custom/gns3/images/logo-colour.png

  # Install GNS3 GUI
  cd /home/"$user"/tmp
  git clone https://github.com/GNS3/gns3-gui.git
  cd gns3-gui
  sudo python setup.py install

  # Create launcher
  sudo pacman -S vim

  # Create gns3.desktop file
 sudo vim /usr/share/applications/gns3.desktop <<EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=GNS3
GenericName=Graphical Network Simulator
Comment= Network simulator
Path=/usr/bin/gns3
TryExec=/usr/bin/gns3
Exec=/usr/bin/gns3 %f
Icon=/usr/share/logo-colour.png
Terminal=false
MimeType=application/vnd.tcpdump.pcap;application/x-pcapng;application/x-snoop;application/x-iptrace;application/x-lanalyzer;application/x-nettl;application/x-radcom;application/x-etherpeek;application/x-visualnetworks;application/x-netinstobserver;application/x-5view;
Categories=Application;Network;
Keywords=simulator;network;netsim;
EOF

  echo "GNS3 installation completed."

  echo ""
  echo "GNS3 install completed."
else
  echo "Skipping GNS3."
fi

# End of script
echo "-----------------------------------------------------"
echo "End of app install script by The Insane Lord (2023)"
echo "-----------------------------------------------------"
echo "Thank you for using this installation script."
echo "If you encounter any issues, please consult"
echo "the documentation"
echo "or seek assistance from the administrator."
