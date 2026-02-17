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
	hyprcursor
	rose-pine-hyprcursor
	hyprshot
	hyprpicker
	hyprpaper
	# hyprlauncher
	noctalia-shell
	cliphist # Clipboard history manager
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
	zweilerserver/asusctl
	supergfxctl
	kvantum
	qt6ct-kde
	breeze
	kde-cli-tools
	archlinux-xdg-menu # To get /etc/xdg/menus/arch-applications.menu for the default-applications
	xdg-desktop-portal-gtk # Needed for gtk apps like 'bottles' for example
	kdeconnect
	webapp-manager
	xorg-xrdb # For proper xwayland scaling with the ~/.Xresources file
)

cli_packages=(
	less
	wine
	unzip
	fastfetch
	tldr
	tree
	fzf
	flatpak
	jq # Json-Query needed for the 'toggle_screens' script
	man-db
	man-pages
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
	qdirstat
	gnome-keyring # Needed for auto-login of the nextcloud-client
	seahorse      # Needed to properly manage the gnome-keyrings
)

gaming_packages=(
	steam
	mangohud
	gamemode
	prismlauncher
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

# Add asusctl to the list of ignored updates if it's not already present, we do not want the new version
if grep -e "^#IgnorePkg" "/etc/pacman.conf"; then
	# The IgnorePkg option does not exist, add it
	sudo sed -iE "s/^#IgnorePkg[^=]*=/IgnorePkg = asusctl/" "/etc/pacman.conf"
elif [ "$(grep -e "^IgnorePkg" "/etc/pacman.conf" | grep "asusctl")" = "" ]; then
	# The IgnorePkg option exists, but it does not contain 'asusctl'
	sudo sed -iE 's/^\(IgnorePkg[^=]*=[^\$]*\)/\1 asusctl/' "/etc/pacman.conf"
fi

# Activate services
echo "-- Enabling the 'bluetooth' service..."
sudo systemctl enable --now bluetooth.service
echo "-- Enabling the 'supergfxd' service..."
sudo systemctl enable --now supergfxd.service

# Set charge limit to 80%
echo "-- Setting battery charge limit to 80%..."
asusctl -c 80 > /dev/null

# Set default power profile when plugged in to Balanced
echo "-- Setting power mode when plugged in to 'Balanced'..."
asusctl profile -a Balanced > /dev/null

# The theme in use is 'KvAdaptaDark', you need to change it in the qt6 settings panel

# Fetching the neovim config
if ! [ -d "$HOME/.config/nvim" ]; then
	echo "-- Cloning the 'zweiler1/kickstart.nvim' repo into '$HOME/.config/nvim'..."
	cd "$HOME/.config" || exit 1
	git clone "https://github.com/zweiler1/kickstart.nvim.git" nvim
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

	echo "-- Creting symlink for 'theme-manager'..."
	ln -sfn "$root/theme-manager" "$HOME/.config/theme-manager"

	echo "-- Creting symlink for 'noctalia'..."
	ln -sfn "$root/noctalia" "$HOME/.config/noctalia"
fi

# Installing nix
if [ "$(which nix)" = "" ]; then
	echo "-- Installing nix..."
	sh <(curl -L https://nixos.org/nix/install) --daemon
	
	echo "[INFO]: If you see 32 new users in your login screen then just add these lines to your '/etc/sddm.conf' file:"
	echo "  [Users]"
	echo "  HideShells=/usr/bin/nologin,/sbin/nologin,/bin/false"
else
	echo "-- Skipping nix installation..."
fi

echo "-- Creating symlink for the .local/bin binaries..."
ln -sfn "$root/bin/toggle_network" "$HOME/.local/bin/toggle_network"
ln -sfn "$root/bin/toggle_screen" "$HOME/.local/bin/toggle_screen"
ln -sfn "$root/bin/toggle_touchpad" "$HOME/.local/bin/toggle_touchpad"

if ! [ -f "$HOME/.Xresources" ]; then
	echo "-- Creating the '$HOME/.Xresources' file..."
	sudo tee -a "$HOME/.Xresources" >/dev/null <<EOF
Xft.dpi: 115
Xft.autohint: 0
Xft.lcdfilter: lcddefault
Xft.hintstyle: hintfull
Xft.hinting: 1
Xft.antialias: 1
Xft.rgba: rgb
EOF
fi
