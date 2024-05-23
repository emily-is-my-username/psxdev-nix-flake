{
  lib,
  src,
  stdenv,
  cmake,
  psn00bsdk-libpsn00b,
  psn00bsdk-tools,
  psn00bsdk-mkpsxiso,
}:
stdenv.mkDerivation {
  inherit src;
  inherit (src) version;
  inherit (src.config) patches;

  pname = "psn00bsdk-examples";
  enableParallelBuilding = true;

  sourceRoot = "${src.name}/examples";

  cmakeFlags = ["-DCMAKE_TOOLCHAIN_FILE=${psn00bsdk-libpsn00b}/lib/libpsn00b/cmake/sdk.cmake"];

  nativeBuildInputs = [
    cmake
    psn00bsdk-tools
    psn00bsdk-mkpsxiso
  ];
  buildInputs = [
    psn00bsdk-libpsn00b
  ];
}
