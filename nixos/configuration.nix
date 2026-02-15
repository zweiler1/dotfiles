# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  # Import the unstable channel
  unstable = import <nixos-unstable> { };

  # path to local package
  qt6ctKde = ./packages/qt6ct-kde;

  myOverlay = final: prev: {
    kdePackages = prev.kdePackages // {
      qt6ct-kde = final.callPackage qt6ctKde {
        # provide the kdePackages versions of the Qt inputs
        qtbase    = final.kdePackages.qtbase;
        qtsvg     = final.kdePackages.qtsvg;
        qttools   = final.kdePackages.qttools;
        qtwayland = final.kdePackages.qtwayland;
        wrapQtAppsHook = final.kdePackages.wrapQtAppsHook;
        qqc2-desktop-style = final.kdePackages.qqc2-desktop-style;
      };
    };
  };

  # create a pkgs with this overlay applied (we only need its kdePackages)
  pkgsWithOverlay = import <nixpkgs> { overlays = [ myOverlay ]; };

  # use that kdePackages when importing the packages list
  kdePackages = (import ./packages/kdePackages.nix { pkgs = pkgsWithOverlay.kdePackages; }).packages;

  unstablePackages = (import ./packages/unstable.nix { pkgs = unstable; }).packages;
  systemPackages = (import ./packages/pkgs.nix { pkgs = pkgs; }).packages;
  hyprlandPackages = (import ./packages/hyprland.nix { pkgs = pkgs; }).packages;
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./groups/hardware.nix
      ./groups/programs.nix
      ./groups/security.nix
      ./groups/services.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_AT.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
  };

  console.keyMap = "de-latin1";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.zweiler1 = {
    isNormalUser = true;
    description = "Marc Zweiler";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    systemPackages ++
    hyprlandPackages ++
    kdePackages ++
    unstablePackages;
  # with pkgs; [
  #   vim
  #   kitty
  #   neovim
  #   asusctl
  #   supergfxctl
  #   firefox
  #   kdePackages.dolphin
  #   kdePackages.partitionmanager
  #   qdirstat
  #   hyprpolkitagent
  #   brightnessctl
  # ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
