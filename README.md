# Arch Install Script

## By The Insane Lord

This script automates the post-installation configuration of Arch Linux. It is designed to be executed **inside** an `arch-chroot` environment after completing the base system installation.

## 📌 Features
- Installs **default Pacman hooks** (optional)
- Configures **fstab and system settings** (optional)
- Installs and configures **GUI environments** (optional)
- Ensures **Bluetooth and printing support** (if required)
- Supports **Flatpak application installation**

## ⚠️ Prerequisites
Before running this script, ensure:
1. You have booted into an **Arch Linux live ISO**.
2. You have installed the **base system** and entered `arch-chroot`:
   ```sh
   mount /dev/sdXn /mnt  # Replace sdXn with your root partition
   arch-chroot /mnt
   ```
3. You have network access (`ping -c 3 archlinux.org` should succeed).

## 🛠️ Installation & Usage
### 1️⃣ Clone the Repository
```sh
git clone https://github.com/TheInsaneLord/archinstall.git
cd archinstall
```

### 2️⃣ Make the Script Executable
```sh
chmod +x install.sh
```

### 3️⃣ Run the Script
```sh
./install.sh
```
The script will **prompt you for configurations**, allowing you to:
- Install **Pacman hooks**
- Configure **system settings**
- Set up a **GUI environment** (Wayland/X11, KDE/Gnome)
- Install **essential applications**

## 🔧 Available Install Scripts
Each component of the installation is modular:
| Script | Description |
|--------|-------------|
| `install.sh` | Main interactive installer |
| `install-scripts/hooks.sh` | Sets up Pacman hooks |
| `install-scripts/system.sh` | Configures fstab and system settings |
| `install-scripts/gui.sh` | Installs GUI components (Wayland/X11, KDE/Gnome) |
| `install-scripts/apps.sh` | Installs default applications & Flatpak apps |

## 📝 Notes
- Ensure this script is run **inside** `arch-chroot`.
- After installation, reboot your system:
  ```sh
  exit
  umount -R /mnt
  reboot
  ```
- If using a printer, **add your user to the `lp` group**:
  ```sh
  usermod -aG lp <your-username>
  ```

## 💡 Troubleshooting
- If the script does not run, check execution permissions:
  ```sh
  chmod +x install.sh
  ```
- If `git` is missing, install it manually:
  ```sh
  pacman -S git
  ```
- If networking is unavailable, check `ip link` and ensure your interface is up.

## 📜 License
This project is open-source. Feel free to modify and improve it to fit your needs.

---

**Enjoy your Arch installation!**
EOF
