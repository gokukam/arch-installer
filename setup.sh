#!/usr/bin/env bash

# Some variables
GREEN='\033[1;32m'
BLUE='\033[1;34m'
NC='\033[0m'

# Make sure env variables are correct
source $HOME/.profile
[ ! -d $XDG_DATA_HOME ] && mkdir -p $XDG_DATA_HOME/themes

echo -e "${BLUE}Installing paru, the AUR helper...${NC}"
mkdir -p $HOME/.cache/paru/clone && git clone https://aur.archlinux.org/paru-bin.git $HOME/.cache/paru/clone/paru-bin
cd $HOME/.cache/paru/clone/paru-bin && makepkg -si
cd $HOME

echo -e "${BLUE}Installing AUR packages...${NC}"
paru -S - < aurpkglist.txt

echo -e "${BLUE}Enabling necessary user-level services...${NC}"
systemctl --user enable mpd pipewire-pulse clipmenud.service

echo -e "${BLUE}Installing and setting GTK theme...${NC}"
git clone https://github.com/vinceliuice/Graphite-gtk-theme.git
cd Graphite-gtk-theme && ./install.sh --tweaks darker --round 3px -t blue
echo -e "[Settings]\ngtk-theme-name=Graphite-blue-Dark\ngtk-icon-theme-name=Papirus" > $HOME/.config/gtk-4.0/settings.ini
cd ../ && rm -rf Graphite-gtk-theme

echo -e "${BLUE}Cloning dotfiles...${NC}"
git clone --bare https://github.com/gokukam/dotfiles.git $HOME/dotfiles
git --git-dir=$HOME/dotfiles --work-tree=$HOME checkout --force
git --git-dir=$HOME/dotfiles --work-tree=$HOME config --local status.showUntrackedFiles no

echo -e "${BLUE}Making all scripts in .local/bin executable...${NC}"
find $HOME/.local/bin -type f -print0 | xargs -0 chmod 755

echo -e "${GREEN}Dotfiles setup complete!${NC}"

exit
