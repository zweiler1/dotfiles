#!/usr/bin/env bash

root="$(cd "$(dirname "$0")" && pwd)"

if [ "$(grep "zweileros" /etc/pacman.conf)" = "" ]; then
	echo "-- Adding the [zweileros] keyring to pacman .."
	tempfile=$(mktemp)
	wget --output-document "$tempfile" "https://zweilerserver.ddns.net/PacmanRepo/zweileros/zweileros-keyring-1.0.0-1-any.pkg.tar.zst"
	sudo pacman -U "$tempfile"

	sudo tee -a /etc/pacman.conf >/dev/null <<EOF

[zweileros]
Server = https://zweilerserver.ddns.net/PacmanRepo/\$repo
EOF
fi

system_packages=(
	paru
	hyprland
	# hyprpaper
	# hyprlauncher
	noctalia-shell
	cliphist # Clipboard history manager
	hyprshot
	hyprpicker
	# waybar
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
	archlinux-xdg-menu # To get /etc/xdg/menus/arch-applications.menu for the default-applications
	xdg-desktop-portal-gtk # Needed for gtk apps like 'bottles' for example
	kdeconnect
	webapp-manager
)

cli_packages=(
	wine
	unzip
	fastfetch
	tldr
	tree
	fzf
	flatpak
	jq # Json-Query needed for the 'toggle_screens' script
)

dev_packages=(
	git
	github-cli
	gitui
	git-credential-manager-bin
	base-devel
	clang
	ninja
	cmake
	nix
	zig
	lld  # LLVM Linker
	lldb # LLVM Debugger
	zed
	neovim
	code   # OSS VSCode
	direnv # Needed for vscode
	cloc # Cout Lines Of Code
	poop # Performance Optimization & Obvervation Platform
	raylib
)

misc_packages=(
	discord
	firefox
	kate
	dolphin
	ark
	gwenview
	nextcloud-client
	btop
	gnome-keyring # Needed for auto-login of the nextcloud-client
	seahorse      # Needed to properly manage the gnome-keyrings
)

gaming_packages=(
	steam
	mangohud
)

# Install required packages
#shellcheck disable=2068
sudo pacman -Syy --needed ${system_packages[@]} ${cli_packages[@]} ${dev_packages[@]} ${misc_packages[@]} ${gaming_packages[@]}

# Install the required flatpak-only packages
flatpak_packages=(
	bottles
	whatsie
)

#shellcheck disable=2068
flatpak --assumeyes install ${flatpak_packages[@]}

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
	cd "$HOME/.config" || exit 1
	git clone "https://github.com/zweiler1/kickstart.nvim.git"
	cd "$HOME" || exit 1
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

echo "-- Creating symlink for the .local/bin binaries..."
ln -sfn "$root//bin/toggle_network" "$HOME/.local/bin/toggle_network"
ln -sfn "$root//bin/toggle_screen" "$HOME/.local/bin/toggle_screen"
ln -sfn "$root//bin/toggle_touchpad" "$HOME/.local/bin/toggle_touchpad"
