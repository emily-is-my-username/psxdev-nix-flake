# TODO: make this generic / merge with pcsx-redux source package
{
  lib,
  fetchFromGitHub,
  gitRev ? "06e65bea3a778b2dae5af77a7935ae3868ddd4d3",
  profile ? "full",
}: let
  inherit (builtins) concatStringsSep fetchGit;
  inherit (lib.attrsets) optionalAttrs recursiveUpdate;
  inherit (lib.lists) optional optionals;

  # per-revision config. Allows us to support multiple versions.
  # newer versions should be at the top

  config = let
    configMap = rec {
      "06e65bea3a778b2dae5af77a7935ae3868ddd4d3" = rec {
        full.hash = "sha256-eH8wp2e5+tFpI02j6s1oUsdkFCW5su/Eq/uPlZYfxec=";
      };
      common.full = {};
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
      owner = "Lameguy64";
      repo = "PSn00bSDK";
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
in
  src // {inherit version config srcInfo;}
