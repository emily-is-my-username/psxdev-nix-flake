{
  stdenv,
  lib,
  src,
}:
stdenv.mkDerivation {
  inherit src;
  inherit (src) version;
  inherit (src.config) patches;

  pname = "openbios";

  makeFlags = ["-C" "src/mips/openbios"];

  installPhase = ''
    install -D -m666 -t $out src/mips/openbios/openbios.{bin,elf,map}
  '';

  meta = {
    homepage = "https://github.com/grumpycoders/pcsx-redux/tree/main/src/mips/openbios";
    maintainer = {
      name = "Emily Username";
      github = "emily-is-my-username";
    };
    platforms = ["mipsel-none"];
  };
}
