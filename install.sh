#!/usr/bin/env bash

root="$(cd "$(dirname "$0")" && pwd)"

if [ "$(grep "zweileros" /etc/pacman.conf)" = "" ]; then
	echo "-- Adding the [zweileros] keyring to pacman .."
	tempfile=$(mktemp)
	wget "https://zweilerserver.ddns.net/PacmanRepo/zweileros/zweileros-keyring-1.0.0-1-any.pkg.tar.zst" $tempfile
	sudo pacman -U $tempfile

	echo "-- Adding the [zweileros] repo to pacman.conf .."
	echo '' >> /etc/pacman.conf
	echo '[zweileros]' >> /etc/pacman.conf
	echo 'Server = https://zweilerserver.ddns.net/PacmanRepo/$repo' >> /etc/pacman.conf
fi

system_packages=(
	paru
	hyprland
	hyprpaper
	hyprlauncher
	waybar
	wl-clipboard
	awesome-terminal-fonts
	ttf-nerd-fonts-symbols
	ttf-nerd-fonts-symbols-common
	ttf-nerd-fonts-symbols-mono
	ttf-dejavu
	brightnessctl
	bluez
	bluez-utils
	blueman
	pavucontrol
	kgpg
	asusctl
	supergfxctl
	kvantum
	qt6ct-kde
	breeze
	kde-cli-tools
	hyprpicker
	archlinux-xdg-menu # To get /etc/xdg/menus/arch-applications.menu for the default-applications
	fastfetch
	tldr
	kdeconnect
)

dev_packages=(
	git
	github-cli
	neovim
	gitui
	base-devel
	clang
	ninja
	cmake
	fzf
	zig
	lld  # LLVM Linker
	lldb # LLVM Debugger
	code # OSS VSCode
	direnv
	cloc # Cout Lines Of Code
	poop # Performance Optimization & Obvervation Platform
)

misc_packages=(
	discord
	firefox
	kate
	dolphin
	ark
	gwenview
)

# Install required packages
#shellcheck disable=2068
sudo pacman -Syy --needed ${system_packages[@]} ${dev_packages[@]} ${misc_packages[@]}

# Activate services
echo "-- Enabling the 'bluetooth' service..."
sudo systemctl enable --now bluetooth.service
echo "-- Enabling the 'supergfxd' service..."
sudo systemctl enable --now supergfxd.service

# Set charge limit to 80%
echo "-- Setting battery charge limit to 80%..."
asusctl -c 80

# Set default power profile when plugged in to Balanced
echo "-- Setting power mode when plugged in to 'Balanced'..."
asusctl profile -a Balanced

# The theme in use is 'KvAdaptaDark', you need to change it in the qt6 settings panel

# Fetching the neovim config
if ! [ -d "$HOME/.config/nvim" ]; then
	echo "-- Cloning the 'zweiler1/kickstart.nvim' repo into '$HOME/.config/nvim'..."
	cd $HOME/.config
	git clone "https://github.com/zweiler1/kickstart.nvim.git"
	cd $HOME
fi

# Creating the symlinks for all the dotfiles
if ! [ -d "$HOME/.config/waybar" ]; then
	echo "-- Creating symlinks for all dotfiles..."
	echo "-- Creting symlink for 'qt6ct'..."
	ln -sfn "$root/qt6ct" "$HOME/.config/qt6ct"

	echo "-- Creting symlink for 'waybar'..."
	ln -sfn "$root/waybar" "$HOME/.config/waybar"

	echo "-- Creting symlink for 'hypr'..."
	ln -sfn "$root/hypr" "$HOME/.config/hypr"

	echo "-- Creting symlink for 'kitty'..."
	ln -sfn "$root/kitty" "$HOME/.config/kitty"
fi
