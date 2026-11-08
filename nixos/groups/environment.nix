{ pkgs }:

let
  # Import the unstable channel
  unstable = import <nixos-unstable> { };

  # Packages on unstable base
  unstablePackages = (import ./packages/unstable.nix { pkgs = unstable; }).packages;

  # Packages on stable base
  systemPackages = (import ./packages/pkgs.nix { pkgs = pkgs; }).packages;
  devtoolsPackages = (import ./packages/devtools.nix { pkgs = pkgs; }).packages;
  hyprlandPackages = (import ./packages/hyprland.nix { pkgs = pkgs; }).packages;
  kdePackages = (import ./packages/kdePackages.nix { pkgs = pkgs.kdePackages; }).packages;
  qt6ctPackage = (import ./packages/qt6ct-kde.nix { inherit pkgs; });
in
{
  environment = {
    systemPackages =
      systemPackages ++
      devtoolsPackages ++
      hyprlandPackages ++
      kdePackages ++
      unstablePackages ++ [
        qt6ctPackage
      ];

    etc = {
      # Store the system config files as part of the system iteration itself so that we can always tell what the
      # input of a given built system was.
      "nixos-config-snapshot".source = ./.;

      # Needed for proper mime types
      "xdg/menus/applications.menu".source = "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
    };
    sessionVariables.XDG_MENU_PREFIX = "plasma-";
  };
}
