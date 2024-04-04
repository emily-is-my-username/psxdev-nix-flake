{
  self,
  flakeName,
  ...
}: {
  perSystem = {
    config,
    pkgs,
    pkgsCross,
    self',
    ...
  }: let
    inherit (self) sourceInfo;
    flakeRev =
      if sourceInfo ? dirtyShortRev
      then sourceInfo.dirtyShortRev
      else if sourceInfo ? shortRev
      then sourceInfo.shortRev
      else "unknown";

    pcsx-redux-src-full =
      pkgs.callPackage
      ./source.nix
      {inherit flakeRev flakeName;};

    pcsx-redux-src-main = pcsx-redux-src-full.override {profile = "main";};
    pcsx-redux-src-mips = pcsx-redux-src-full.override {profile = "mips";};
    pcsx-redux-src-tools = pcsx-redux-src-full.override {profile = "tools";};

    openbios =
      pkgsCross.PSX.callPackage ./mips/openbios.nix {src = pcsx-redux-src-mips;};

    psx-tests =
      pkgsCross.PSX.callPackage ./mips/tests.nix {src = pcsx-redux-src-mips;};

    pcsx-redux =
      pkgs.callPackage
      ./main/pcsx-redux.nix
      {
        inherit openbios psx-tests;
        src = pcsx-redux-src-main;
      };

    pcsx-redux-tools =
      pkgs.callPackage ./main/tools.nix {src = pcsx-redux-src-tools;};

    # don't build and run tests
    # also removes dependency on openbios and mips toolchain
    pcsx-redux-untested =
      (pcsx-redux.override {
        openbios = null;
        psx-tests = null;
      })
      .overrideAttrs {
        doCheck = false;
        preCheck = null;
      };

    pcsx-redux-with-openbios = let
      stable = pcsx-redux;
      full = pcsx-redux.override {fullVersionInfo = true;};
    in
      pkgs.symlinkJoin {
        inherit (full) name;
        paths = [full.versionJSON stable];
        postBuild = ''
          install -D -t $out/bin "$(readlink -f $out/bin/pcsx-redux)"
          mkdir -p $out/share/pcsx-redux/resources/
          ln -s -t $out/share/pcsx-redux/resources/ ${openbios}/openbios.bin
        '';
      };
  in {
    packages = rec {
      inherit
        openbios
        pcsx-redux
        pcsx-redux-with-openbios
        pcsx-redux-tools
        pcsx-redux-untested
        ;
    };
  };
}
