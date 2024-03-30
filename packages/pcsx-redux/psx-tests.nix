{
  stdenv,
  pcsx-redux,
}:
stdenv.mkDerivation {
  inherit (pcsx-redux) src version;
  pname = "pcsx-redux-psx-tests";

  makeFlags = ["-C" "src/mips/tests" "PCSX_TESTS=true"];

  installPhase = ''
    for tname in basic cop0 cpu dma libc memcpy memset pcdrv; do
      install -D -m666 -t $out/$tname/ src/mips/tests/$tname/$tname.ps-exe
    done
  '';
}
