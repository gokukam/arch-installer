#!/usr/bin/env bash

# Some variables
GREEN='\033[1;32m'
NC='\033[0m'

# Update the system clock
timedatectl set-ntp true

# Take CPU manufacturer input for microcode
read -p "CPU: " cpu

# Run pacstrap command and generate fs table
pacstrap /mnt base linux-lts linux-firmware $cpu-ucode
genfstab -U /mnt >> /mnt/etc/fstab

# Copy scripts and package lists to the system's mounted location
cp install.sh setup.sh pkglist.txt aurpkglist.txt /mnt/home/

# Chroot into the system and run the install script
arch-chroot /mnt bash /home/install.sh

# Once the install script exits chroot, clean up
rm /mnt/home/install.sh /mnt/home/pkglist.txt

# Now chroot into the system as the normal user and run the setup script
user=$(cat /mnt/home/username)
arch-chroot -u $user /mnt ./home/$user/setup.sh

# Once the setup script exits chroot, clean up
rm /mnt/home/$user/setup.sh /mnt/home/$user/aurpkglist.txt /mnt/home/username

echo -e "${GREEN}You can reboot and remove the live USB now${NC}"
