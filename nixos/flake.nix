{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia/v5.0.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    # use "nixos", or your hostname as the name of the configuration
    # it's a better practice than "default" shown in the video
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };

      modules = [
        ./configuration.nix
        inputs.home-manager.nixosModules.default
      ];
    };

    # Manpages
    packages.${system}.noctalia-manpage = import ./docs/module-manpage.nix {
      inherit pkgs;
      homeManagerSrc = inputs.home-manager.outPath;
      module = inputs.noctalia.homeModules.default;
      optionsPath = [ "programs" "noctalia" ];
      pageName = "home-noctalia.nix";
      revision = "Noctalia";
    };
  };
}
