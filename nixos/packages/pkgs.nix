{ pkgs }: {
  packages = with pkgs; [
    # System and Terminal packages
    wget
    vim
    neovim
    lf
    fzf
    killall
    shared-mime-info # Myme type database
    supergfxctl
    asusctl
    mesa
    fastfetch
    # smartmontools
    # libva-utils
    # pv # progress viewer through pipes

    # GIT
    git
    gnupg
    pinentry-curses # Needed by gpg to sign commits
    gitui
    git-credential-oauth
    git-credential-manager
    # dotnet-sdk_7 # Needed by the git-credential-manager
    # fontconfig
    # freetype
    #libSkiaSharp

    # NIX
    #home-manager

    # NVIM Dependencies
    gcc
    ripgrep
    gnumake
    unzip
    cargo

    # Applications
    kitty
    firefox
    nextcloud-client
    seahorse # Needed to properly manage the gnome-keyrings (service)
    discord
    # whatsapp-for-linux

    # QT & KDE & SDDM
    # qt5.qtwayland # Provides QT Support for wayland
    # libsForQt5.qt5.qtgraphicaleffects # Provides graphical effects for QT5 for sddm
    # plymouth
    udisks # needed by dolphin for block disk devices
    qdirstat
    libsForQt5.qt5ct # Needed by qdirstat for proper theming

    # Gaming Related
    mangohud
    gamemode
    prismlauncher
    # heroic
    # lutris
    # wineWowPackages.stable
    # winetricks
    # protonup-qt

    # Developement
    zig
    clang
    ninja
    lld
    cmake
    python315
    glibc
    gcc
  ];
}
