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
        ./flake-modules/psx-pkgs.nix
        ./flake-modules/pcsx-redux.nix
      ];
      _module.args.flakeName = "emily-psxdev";

      perSystem = {pkgs, ...}: {formatter = pkgs.alejandra;};
    };
}
