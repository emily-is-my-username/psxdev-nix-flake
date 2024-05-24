{
  lib,
  src,
  stdenv,
  cmake,
  target,
}: let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.strings) hasPrefix;
in
  stdenv.mkDerivation {
    inherit src;
    inherit (src) version;
    inherit (src.config) patches;

    pname = "psn00bsdk-${target}";
    enableParallelBuilding = true;

    buildPhase = ''
      runHook preBuild
      cmake --build . --target=${target}
      runHook postBuild
    '';

    installPhase = ''
      mv tree $out
    '';

    nativeBuildInputs = [cmake];
    buildInputs = [];

    meta =
      {
        homepage = "https://github.com/Lameguy64/PSn00bSDK";
        maintainer = {
          name = "Emily Username";
          github = "emily-is-my-username";
        };
      }
      // optionalAttrs (hasPrefix "libpsn00b-" target) {
        platforms = ["mipsel-none"];
      };
  }
