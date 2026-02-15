{
  programs = {
    # Enable binaries to be executable
    nix-ld = {
      enable = true;
      libraries = [ ];
    };

    # Enable Steam
    steam = {
      enable = true;
      # Open ports in the firewall for Steam Remote Play
      remotePlay.openFirewall = true;
      # Open ports in the firewall for Source Dedicated Server
      dedicatedServer.openFirewall = true;
      # Open ports in the firewall for Steam Local Network Game Transfers
      localNetworkGameTransfers.openFirewall = true;
    };

    # Enable Hyprland
    hyprland = {
      enable = true;
      withUWSM = true;
    };

    # Enable KDE Connect
    kdeconnect.enable = true;

    # Enable the GnuPG agent
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # Git and GitHub
    git.enable = true;
  };
}
