{
  programs = {
    # Enable binaries to be executable
    nix-ld.enable = true;

    firefox.enable = true;

    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    git.enable = true;
  };
}
