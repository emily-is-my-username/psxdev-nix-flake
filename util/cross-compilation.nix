{lib, ...}: let
  inherit (builtins) mapAttrs elem;
  inherit (lib.options) mkOption;
  inherit (lib.types) attrsOf unspecified;
in {
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    options.pkgsCross = mkOption {
      type = attrsOf unspecified;
      default = pkgs.pkgsCross;
    };
    config._module.args.pkgsCross = config.pkgsCross;
  };
}
