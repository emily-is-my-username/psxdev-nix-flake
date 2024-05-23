{...}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages = rec {
      run-n00bdemo-with-pcsx-redux = pkgs.writeScriptBin "run-n00bdemo-with-pcsx-redux" ''
        ${self'.packages.pcsx-redux-with-openbios}/bin/pcsx-redux -stdout -run -exe ${self'.packages.psn00bsdk-examples}/demos/n00bdemo.exe $@
      '';
    };
  };
}
