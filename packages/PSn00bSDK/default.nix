{...}: {
  perSystem = {
    pkgs,
    pkgsCross,
    self',
    ...
  }: let
    src = pkgs.callPackage ./source.nix {};
  in {
    packages = rec {
      psn00bsdk-tools = pkgs.callPackage ./base.nix {
        inherit src;
        target = "tools";
      };
      psn00bsdk-mkpsxiso = pkgs.callPackage ./base.nix {
        inherit src;
        target = "mkpsxiso";
      };
      psn00bsdk-libpsn00b = pkgsCross.PSX.callPackage ./base.nix {
        inherit src;
        target = "libpsn00b-release";
      };

      psn00bsdk-examples = pkgsCross.PSX.callPackage ./examples.nix {
        inherit src psn00bsdk-libpsn00b psn00bsdk-tools psn00bsdk-mkpsxiso;
      };
    };
  };
}
