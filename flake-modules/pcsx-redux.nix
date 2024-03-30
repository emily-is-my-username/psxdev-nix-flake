{
  self,
  flakeName,
  ...
}: let
  inherit (builtins) mapAttrs elem;
in {
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
      else if sourceInfo ? rev
      then sourceInfo.rev
      else "unknown";

    openbios =
      pkgsCross.PSX.callPackage
      ../packages/pcsx-redux/openbios.nix
      {inherit pcsx-redux;};

    psx-tests =
      pkgsCross.PSX.callPackage
      ../packages/pcsx-redux/psx-tests.nix
      {inherit pcsx-redux;};

    pcsx-redux =
      pkgs.callPackage
      ../packages/pcsx-redux
      {inherit openbios flakeName psx-tests;};

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

    pcsx-redux-tools =
      pkgs.callPackage
      ../packages/pcsx-redux/tools.nix
      {inherit pcsx-redux;};

    pcsx-redux-with-openbios = let
      stable = pcsx-redux;
      full = pcsx-redux.override {inherit flakeRev;};
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
      inherit openbios pcsx-redux pcsx-redux-with-openbios pcsx-redux-tools pcsx-redux-untested;
    };
  };
}
