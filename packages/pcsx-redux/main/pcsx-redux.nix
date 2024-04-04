{
  lib,
  src,
  # full version causes rebuilds when flake changes
  fullVersionInfo ? false,
  # build tools
  writeTextFile,
  stdenv,
  pkg-config,
  # dependencies
  # TODO: split build-time and run-time deps
  libuv,
  zlib,
  curl, # TODO: only libcurl
  glfw,
  capstone,
  freetype,
  ffmpeg,
  libXrender,
  # needed for testing,
  openbios,
  psx-tests,
  # needed for install
  imagemagick,
}: let
  inherit (builtins) concatStringsSep fetchGit toJSON;
  inherit (lib.lists) optional optionals;
  # generate version infos
in
  stdenv.mkDerivation rec {
    inherit src;
    inherit (src) version;
    inherit (src.config) patches;

    pname = "pcsx-redux";

    enableParallelBuilding = true;

    makeFlags = ["PREFIX=$(out)" "DESTDIR=$(PREFIX)"];
    nativeBuildInputs = [
      pkg-config
      imagemagick
    ];
    buildInputs = [
      libuv
      zlib
      curl
      glfw
      capstone
      freetype
      ffmpeg
      libXrender
    ];

    doCheck = true;
    nativeCheckInputs = [openbios psx-tests];

    preCheck = ''
      mkdir -vp src/mips/openbios
      cp -v ${openbios}/openbios.bin -t src/mips/openbios
      mkdir -vp src/mips/tests
      cp -rv ${psx-tests}/* -t src/mips/tests
    '';

    checkTarget = "runtests";

    versionJSON = writeTextFile rec {
      name = "version.json";
      destination = "/share/pcsx-redux/resources/${name}";
      text = toJSON {
        version =
          if fullVersionInfo
          then src.fullVersion
          else src.version;
        changeset = src.srcInfo.rev;
        timestamp = src.srcInfo.lastModified;
      };
    };

    postInstall = ''
      mkdir -p $out
      cp -rv ${versionJSON}/. $out/
    '';

    meta = with lib; {
      homepage = "https://github.com/grumpycoders/pcsx-redux";
      maintainer = {
        name = "Emily Username";
        github = "emily-is-my-username";
      };
      mainProgram = "${pname}";
      # TODO: define this better
      platforms = platforms.x86_64;
    };
  }
