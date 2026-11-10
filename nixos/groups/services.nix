{
  pkgs,
  ...
}:

{
  services = {
    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    xserver.enable = true;

    # Enable the KDE Plasma Desktop Environment.
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;

    # Configure keymap in X11
    xserver.xkb = {
      layout = "at";
      variant = "";
    };

    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable sound with pipewire.
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Enable pinentry for gnupg
    pcscd.enable = true;

    # Needed by noctalia
    power-profiles-daemon.enable = true;
    upower.enable = true;

    # Udisks2 is a linux utility for disk operations (needed by dolphin)
    udisks2.enable = true;

    asusd = {
      enable = true;
      package = import ./packages/asusctl-uma.nix { inherit pkgs; };
    };

    # Keyring to remember passwords
    gnome.gnome-keyring.enable = true;
  };
}
