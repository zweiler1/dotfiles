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
    virt-manager.enable = true;
    fish = {
      enable = true;

      shellAliases = {
        ls = "eza -al --color=always --group-directories-first --icons=always";
        grep = "grep --color=auto";
        grub-update = "sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch --removable && sudo grub-mkconfig -o /boot/grub/grub.cfg";
        restart-pipewire = "systemctl restart --user pipewire wireplumber.service pipewire-pulse.service";
        kvm-start = "sudo virsh net-start default && sudo modprobe tun && sudo modprobe vhost_net";
        mount-nfs = "sudo mount -t nfs zweilerserver.ddns.net:/srv /NFS";
        ij = "env LC_ALL=\"de_AT.UTF-8\" intellij-idea-ultimate-edition";

        nix-clean = "sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
        nix-rebuild = "sudo nixos-rebuild switch --flake ~/dotfiles/nixos#nixos";
        nix-upd = "sudo nixos-rebuild switch --flake ~/dotfiles/nixos#nixos --upgrade";
        nix-upg = "sudo nixos-rebuild switch --flake ~/dotfiles/nixos#nixos --upgrade-all";
        use_dgpu = "DRI_PRIME=pci-0000_03_00_0";
        use_igpu = "DRI_PRIME=pci-0000_77_00_0";
      };

      interactiveShellInit = ''
        # Functions go here
      '';
    };
  };
}
