{
  stdenv,
  src,
}:
stdenv.mkDerivation {
  inherit src;
  inherit (src) version;
  inherit (src.config) patches;

  pname = "pcsx-redux-psx-tests";

  makeFlags = ["-C" "src/mips/tests" "PCSX_TESTS=true"];

  installPhase = ''
    for tname in basic cop0 cpu dma libc memcpy memset pcdrv; do
      install -D -m666 -t $out/$tname/ src/mips/tests/$tname/$tname.ps-exe
    done
  '';

  meta = {
    platforms = ["mipsel-none"];
  };
}
