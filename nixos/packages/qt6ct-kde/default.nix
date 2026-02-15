{ cmake,
  fetchFromGitLab,
  lib,
  qtbase,
  qtsvg,
  qttools,
  qtwayland,
  qqc2-desktop-style,
  stdenv,
  wrapQtAppsHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qt6ct-kde";
  version = "0.11";

  src = fetchFromGitLab {
    domain = "www.opencode.net";
    owner = "trialuser";
    repo = "qt6ct";
    tag = finalAttrs.version;
    hash = "sha256-aQmqLpM0vogMsYaDS9OeKVI3N53uY4NBC4FF10hK8Uw=";
  };

  # Remove automatic patching; we'll do it manually below
  # patches = [ ./qt6ct-shenanigans.patch ];

  postUnpack = ''
    echo "APPLYING PATCH ON '$sourceRoot', CWD IS '$(pwd)'"
    ls -lah $sourceRoot
    patch -d $sourceRoot -p1 < ${./qt6ct-shenanigans.patch}
  '';

  nativeBuildInputs = [
    cmake
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtsvg
    qtwayland
  ];

  # ensure the theme/style package is in the runtime closure
  propagatedBuildInputs = [
    qqc2-desktop-style
  ];

  cmakeFlags = [
    (lib.cmakeFeature "PLUGINDIR" "${placeholder "out"}/${qtbase.qtPluginPrefix}")
  ];

  meta = {
    description = "Qt6 Configuration Tool";
    homepage = "https://www.opencode.net/trialuser/qt6ct";
    platforms = lib.platforms.linux;
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [
      Flakebi
      Scrumplex
    ];
    mainProgram = "qt6ct";
  };
})
