{ pkgs }: {
  packages = with pkgs; [
    hyprcursor
    rose-pine-hyprcursor
    hyprpicker

    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    xdg-desktop-portal
    wl-clipboard
    wl-clipboard-x11
    pavucontrol # Audio management
    qpwgraph
    brightnessctl # control brightnes via shortcuts
    playerctl # media control via command line inputs
    networkmanagerapplet # GUI for selecting WiFi in Hyprland
  ];
}
