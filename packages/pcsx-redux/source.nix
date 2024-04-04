{
  lib,
  fetchFromGitHub,
  gitRev ? "e6bf14c6c7f1bb7f2e86c004c00c1f32918beb21",
  flakeRev ? null,
  flakeName ? "nix",
  profile ? "full",
}: let
  inherit (builtins) concatStringsSep fetchGit;
  inherit (lib.attrsets) optionalAttrs recursiveUpdate;
  inherit (lib.lists) optional optionals;

  # per-revision config. Allows us to support multiple versions.
  # newer versions should be at the top
  config = let
    configMap = rec {
      "e6bf14c6c7f1bb7f2e86c004c00c1f32918beb21" = rec {
        full.hash = "sha256-8RnBQKEIGVg3/FHs4NnVjaIKDrLk+wzEnGleTJLyztM=";
        main.hash = "sha256-yFIxiV6KmBsGo2sqIwncy9m87A1Hoa8/4XBw3auYeQ4=";
        mips.hash = "sha256-cqio/sHbBOb7e5Ad4nZ9+Ixs2/BlVE8KAJkIZcj9Uzo=";
        tools.hash = "sha256-CvRpWyxF0lnRr2v4lJyqyouqhUGb1Yr9rQqfls4pXr4=";
      };

      common = rec {
        full = {};
        main.sparseCheckout = [
          "/i18n"
          "/lua"
          "/resources"
          "/src/cdrom"
          "/src/core"
          "/src/forced-includes"
          "/src/gpu"
          "/src/gui"
          "/src/lua"
          "/src/main"
          "/src/mips/common/util"
          "/src/spu"
          "/src/support"
          "/src/supportpsx"
          "/tests"
          "/third_party"
        ];

        tools.patches = [./main/patches/0001-dont-build-tools-static.patch];
        tools.toolNames = [
          "exe2elf"
          "exe2iso"
          "ps1-packer"
          "psyq-obj-parser"
          "modconv"
        ];
        tools.sparseCheckout =
          [
            "/src/mips/common/util"
            "/src/support"
            "/src/supportpsx"
            "/third_party"
          ]
          ++ (map (name: "/tools/${name}") tools.toolNames);

        mips.hash = lib.fakeHash;
        mips.sparseCheckout = ["/src/mips"];
      };
    };
  in (
    {
      hash = lib.fakeHash;
      patches = [];
      sparseCheckout = [];
    }
    // (recursiveUpdate configMap.common configMap.${gitRev}).${profile}
  );

  # build time source
  src =
    (fetchFromGitHub {
      owner = "grumpycoders";
      repo = "pcsx-redux";
      rev = gitRev;
      hash = config.hash;
      fetchSubmodules = true;
      inherit (config) sparseCheckout;
    })
    .overrideAttrs {inherit version;};

  # eval time source
  srcInfo = fetchGit {
    url = src.gitRepoUrl;
    rev = gitRev;
  };

  # parsed version
  version =
    concatStringsSep "."
    [(toString srcInfo.revCount) srcInfo.shortRev];

  # includes flake name and rev
  fullVersion = concatStringsSep "." (
    [version]
    ++ optional (flakeName != null) (
      if (flakeRev != null)
      then "${flakeName}-${flakeRev}"
      else "${flakeName}"
    )
  );
in
  src // {inherit version fullVersion config srcInfo;}
