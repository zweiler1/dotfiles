{ pkgs, homeManagerSrc, module, optionsPath, pageName, revision ? "local" }:

let
  # Load the Home Manager extended library.
  lib = import "${homeManagerSrc}/modules/lib/stdlib-extended.nix" pkgs.lib;

  # Replace derivations in pkgs with lightweight representations.
  # This avoids unnecessarily instantiating packages during documentation.
  scrubDerivations = prefixPath: attrs:
    let
      scrubDerivation = name: value:
        let
          pkgAttrName = prefixPath + "." + name;
        in
          if lib.isAttrs value then
            scrubDerivations pkgAttrName value
            // lib.optionalAttrs (lib.isDerivation value) {
              outPath = "\${${pkgAttrName}}";
            }
          else
            value;
    in
      lib.mapAttrs scrubDerivation attrs;

  # Provide a lightweight package set to the module evaluator.
  scrubbedPkgsModule = {
    _module.args = {
      pkgs = lib.mkForce (scrubDerivations "pkgs" pkgs);
      pkgs_i686 = lib.mkForce { };
    };
  };

  # Load Home Manager's standard modules.
  homeManagerModules = import "${homeManagerSrc}/modules/modules.nix" {
    inherit pkgs;
    inherit lib;
    check = false;
  };

  # Evaluate the complete Home Manager module collection.
  evaluated = lib.evalModules {
    class = "homeManager";

    modules = homeManagerModules ++ [
      module
      scrubbedPkgsModule
      # Documentation does not need to validate all config definitions.
      {
        _module.check = false;
      }

      # Supply dummy user information for documentation evaluation.
      {
        home.username = "documentation";
        home.homeDirectory = "/tmp";
        home.stateVersion = "26.05";
      }
    ];
  };

  # Extract only the options of the packages we care about
  optionsDoc = pkgs.buildPackages.nixosOptionsDoc {
    lib = pkgs.lib;

    options = pkgs.lib.setAttrByPath optionsPath (pkgs.lib.getAttrFromPath optionsPath evaluated.options);

    documentType = "none";
  };

in
  pkgs.runCommand "${pageName}-manpage" {
    nativeBuildInputs = [
      pkgs.buildPackages.nixos-render-docs
    ];
  } ''
    mkdir -p "$out/share/man/man5"

    nixos-render-docs options manpage \
      --revision ${pkgs.lib.escapeShellArg revision} \
      ${optionsDoc.optionsJSON}/share/doc/nixos/options.json \
      "$out/share/man/man5/${pageName}.5"
  ''
