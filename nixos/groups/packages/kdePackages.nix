{ pkgs }:
{
  packages = with pkgs; [
    kate
    polkit-kde-agent-1
    kgpg # GPG Key manager for hyprland

    # Dolphin
    dolphin
    breeze
    breeze-icons

    # KDE Framework Packages for Dolphin and Icon Support
    qtstyleplugin-kvantum # For the KvAdaptaDark theme
    qtwayland
    kiconthemes
    kitemmodels
    kdeclarative
    kio
    kservice # Provides kbuildsycoca6
    plasma-workspace # For the XDG menu fix (mime types)
    kirigami
    frameworkintegration
  ];
}
