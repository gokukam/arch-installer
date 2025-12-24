#!/usr/bin/env bash

# Some variables
GREEN='\033[1;32m'
BLUE='\033[1;34m'
NC='\033[0m'

# Timezone
echo -e "${BLUE}Setting the timezone...${NC}"
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc

# Locale
echo -e "${BLUE}Setting the required locales...${NC}"
echo -e "en_US.UTF-8 UTF-8\nen_GB.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo -e "LANG=en_GB.UTF-8\nLC_CTYPE=en_GB.UTF-8" > /etc/locale.conf

# Hostname
echo -e "${BLUE}Setting the hostname...${NC}"
read -p "Enter hostname: " hname
echo $hname > /etc/hostname
echo "127.0.0.1    localhost
::1          localhost
127.0.1.1    $hname.localdomain    $hname" >> /etc/hosts

echo -e "${BLUE}Installing packages from the standard repos...${NC}"
pacman --needed -Sy - < /home/pkglist.txt

echo -e "${BLUE}Setting up GRUB bootloader...${NC}"
sed -i -e "s/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g" /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

echo -e "${BLUE}Enabling necessary system-wide services...${NC}"
systemctl enable --now NetworkManager bluetooth libvirtd tlp udisks2 sddm paccache.timer
sed -i -e "s/#AutoEnable=true/AutoEnable=false/g" /etc/bluetooth/main.conf

# Set the sddm theme (will be installed as AUR pkg later)
sed -i -e 's/^Current=*.*/Current=catppuccin-mocha-sky/g' /etc/sddm.conf

# Give elevated privileges to members of 'wheel' group
sed -i -e 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

# Set root password
echo 'Set root password'
passwd

# Create a new user
read -p "Enter username: " name
echo $name > /home/username
useradd -m $name
echo "Set password for the user $name"
passwd $name
usermod -aG wheel,audio,video,optical,storage,libvirt,vboxusers $name

# Move the setup script and AUR package list to user dir
mv /home/setup.sh /home/aurpkglist.txt /home/$name/
chown $name:$name /home/$name/setup.sh /home/$name/aurpkglist.txt

echo -e "${GREEN}Initial installation complete! \nNow setting up dotfiles...${NC}"

# Exit out of chroot
exit
