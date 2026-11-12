{
  home.shellAliases = {
    ls = "ls -lah --color=tty";
    nix-clean = "sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
    rebuild = "sudo nixos-rebuild switch --flake ~/dotfiles/nixos#nixos";
    upd = "sudo nixos-rebuild switch --flake ~/dotfiles/nixos#nixos --upgrade";
    upg = "sudo nixos-rebuild switch --flake ~/dotfiles/nixos#nixos --upgrade-all";
    use_dgpu = "DRI_PRIME=pci-0000_03_00_0";
    use_igpu = "DRI_PRIME=pci-0000_77_00_0";
  };

  programs.fish.interactiveShellInit = ''
    # Functions etc come here
  '';
}
