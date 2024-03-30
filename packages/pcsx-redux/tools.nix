{
  stdenv,
  lib,
  pcsx-redux,
  pkg-config,
  libuv,
  zlib,
  curl,
  glfw,
  capstone,
  freetype,
  ffmpeg-full,
  ...
}: let
  inherit (builtins) concatStringsSep fetchGit toJSON;
in
  stdenv.mkDerivation {
    inherit (pcsx-redux) src version patches enableParallelBuilding makeFlags meta;
    pname = "pcsx-tools";

    nativeBuildInputs =
      pcsx-redux.nativeBuildInputs
      ++ [
        libuv
        zlib
        curl
        glfw
        capstone
        freetype
        ffmpeg-full
      ];

    #

    buildFlags = ["tools"];

    doCheck = false;

    installTargets = ["tools"];

    postInstall =
      # TODO: generate these names from the makefile at build time?
      concatStringsSep "\n" (
        map
        (name: "install -D -t $out/bin ${name}")
        [
          "exe2elf"
          "exe2iso"
          "ps1-packer"
          "psyq-obj-parser"
        ]
      );
  }
