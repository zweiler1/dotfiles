{
  pkgs,
  ...
}:

{
  programs = {
    steam = {
      enable = true;

      # Better Steam Input/controller support under Wayland (Hyprland)
      extest.enable = true;

      # Manage Proton prefixes and run Winetricks operations
      protontricks.enable = true;

      # Additional compatibility tool
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];

      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;

      package = pkgs.steam.override {
        extraEnv = {
          MANGOHUD = true;
        };
      };

      extraPackages = with pkgs; [
        mangohud
      ];
    };

    # GameMode: temporary performance optimisations while gaming
    gamemode.enable = true;
  };
}
