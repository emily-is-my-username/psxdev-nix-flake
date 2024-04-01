{inputs, ...}: {
  imports = [
    ./cross-compilation.nix
  ];
  perSystem = {
    system,
    pkgsCross,
    ...
  }: {
    pkgsCross.PSX = import inputs.nixpkgs {
      # TODO: rust mipsel-sony-psx target?
      inherit system;
      crossSystem = {
        config = "mipsel-none-elf";
        gcc = {
          abi = "32";
          arch = "mips1";
        };
      };
    };
  };
}
