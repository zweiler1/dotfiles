{ pkgs }:

let
  qt6ctShenanigansPatch = pkgs.fetchpatch {
    url = "https://raw.githubusercontent.com/ilya-fedin/nur-repository/master/pkgs/qt6ct/qt6ct-shenanigans.patch";
    hash = "sha256-Q8QOMDy84z6FD0OkSLylEwB+/Zs50jcUgR+4J6Lmwmk=";
  };
in
pkgs.kdePackages.qt6ct.overrideAttrs (old: {
  pname = "qt6ct-kde";

  buildInputs = (old.buildInputs or []) ++ (with pkgs.kdePackages; [
    qtdeclarative
    kconfig
    kcolorscheme
    kiconthemes
  ]);

  patches = (old.patches or []) ++ [ qt6ctShenanigansPatch ];
})
