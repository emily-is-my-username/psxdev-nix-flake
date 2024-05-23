{
  lib,
  src,
  stdenv,
  cmake,
  target,
}:
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
}
