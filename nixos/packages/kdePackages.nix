{ pkgs }: {
  packages = with pkgs; [
    # KDE Packages
    qt6ct-kde
    qtwayland
    kgpg # GPG Key manager for hyprland
    breeze
    kcolorscheme
    kconfigwidgets
    kiconthemes
    # breeze-icons
    # breeze-gtk

    # KDE Connect
    kdeconnect-kde

    # KDE Applications
    dolphin
    kate
    ark

    # KDE Framework Packages for Dolphin and Icon Support
    qtstyleplugin-kvantum
    # kitemmodels
    # kdeclarative
    # kio
    # kservice
    # kirigami
    # frameworkintegration

    # SDDM
    sddm
    # qt5compat
  ];
}
