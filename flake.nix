{
  description = "a collection of Playstation 1 homebrew tools packaged for nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      imports = [
        ./util/psx-pkgs.nix
        ./util/runner-scripts.nix
        ./packages/pcsx-redux
        ./packages/PSn00bSDK
      ];
      _module.args.flakeName = "emily-psxdev";

      perSystem = {pkgs, ...}: {formatter = pkgs.alejandra;};
    };
}
