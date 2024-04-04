{
  stdenv,
  lib,
  src,
  pkg-config,
  libuv,
  zlib,
  curl,
  glfw,
  capstone,
  freetype,
  ffmpeg,
  ...
}: let
  inherit (builtins) concatStringsSep;
in
  stdenv.mkDerivation {
    inherit src;
    inherit (src) version;
    inherit (src.config) patches;

    enableParallelBuilding = true;
    makeFlags = ["PREFIX=$(out)" "DESTDIR=$(PREFIX)"];

    pname = "pcsx-tools";

    nativeBuildInputs = [
      pkg-config
      libuv
      zlib
      curl
      glfw
      capstone
      freetype
      ffmpeg
    ];

    buildFlags = ["tools"];

    doCheck = false;

    installTargets = ["tools"];

    postInstall = concatStringsSep "\n" (
      map
      (name: "install -D -t $out/bin ${name}")
      src.config.toolNames
    );
  }
