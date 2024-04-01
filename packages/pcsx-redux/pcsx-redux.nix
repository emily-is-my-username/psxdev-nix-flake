{
  lib,
  # selects source and version
  gitRev ? "e6bf14c6c7f1bb7f2e86c004c00c1f32918beb21",
  flakeRev ? null, # setting this caueses rebuilds
  flakeName ? "nix",
  # build tools
  fetchFromGitHub,
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
  ffmpeg-full, # TODO: only some libs
  libXrender,
  # needed for testing,
  openbios,
  psx-tests,
  # needed for install
  imagemagick,
}: let
  inherit (builtins) concatStringsSep fetchGit toJSON;
  inherit (lib.lists) optional optionals;

  # per-revision config. Allows us to support multiple versions.
  # newer versions should be at the top
  revConfig =
    {
      "e6bf14c6c7f1bb7f2e86c004c00c1f32918beb21" = {
        hash = "sha256-8RnBQKEIGVg3/FHs4NnVjaIKDrLk+wzEnGleTJLyztM=";
        patches = [
          ./patches/0001-dont-build-tools-static.patch
        ];
      };
      "9d2249aee4d8122509ac2a8371eb1592de8b0cfc" = {
        hash = "sha256-PSLQkiKaCz6SghPFpt0UYIP0FOYaqgxry8Z7uvESIPI=";
        patches = [
          ./patches/0001-dont-build-tools-static.patch
          ./patches/0002-allow-version-info-file-without-updateInfo.patch
        ];
      };
    }
    .${gitRev};

  src = fetchFromGitHub {
    owner = "grumpycoders";
    repo = "pcsx-redux";
    rev = gitRev;
    hash = revConfig.hash;
    fetchSubmodules = true;
  };

  # generate version infos
  srcInfo = fetchGit {
    url = src.gitRepoUrl;
    rev = gitRev;
  };
  version =
    concatStringsSep "."
    [(toString srcInfo.revCount) srcInfo.shortRev];
in
  stdenv.mkDerivation rec {
    inherit version src;
    pname = "pcsx-redux";

    patches = optionals (revConfig ? patches) revConfig.patches;

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
      ffmpeg-full
      libXrender
    ];

    doCheck = true;
    nativeCheckInputs = [openbios psx-tests];

    preCheck = ''
      cp -v ${openbios}/openbios.bin -t src/mips/openbios
      cp -rv ${psx-tests}/* -t src/mips/tests
    '';

    checkTarget = "runtests";

    versionJSON = let
      jsonVersion = concatStringsSep "." (
        [version]
        ++ optional (flakeName != null) (
          if (flakeRev != null)
          then "${flakeName}-${flakeRev}"
          else "${flakeName}"
        )
      );
    in
      writeTextFile rec {
        name = "version.json";
        destination = "/share/pcsx-redux/resources/${name}";
        text = toJSON {
          version = jsonVersion;
          changeset = srcInfo.rev;
          timestamp = srcInfo.lastModified;
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
