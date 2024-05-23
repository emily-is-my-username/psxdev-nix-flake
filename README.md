# psxdev-nix-flake

A collection of nix packages for Playstation 1 homebrew tools

## Quickstart

To download, compile and run PSn00bSDK's `n00bdemo` example with pcsx-redux and openbios:

```
nix run github:emily-is-my-username/psxdev-nix-flake#run-n00bdemo-with-pcsx-redux
```

## Package list

- [pcsx-redux](#pcsx-redux)
- [PSn00bSDK](#psn00bsdk)

## Package notes

### [pcsx-redux](https://github.com/grumpycoders/pcsx-redux)

#### Packages
- `openbios`:
  The [open source PSX BIOS](https://github.com/grumpycoders/pcsx-redux/tree/main/src/mips/openbios) provided by pcsx-redux.
  - Requires a MIPS1 toolchain, which is not cached by cache.nixos.org, so **it may take a long time to build this for the first time**.

- `pcsx-redux`:
  The main package. Includes everything the upstream Makefile would install.  
  - **Building this package requires the BIOS to run tests.** Use `pcsx-redux-untested` if you don't want to build `openbios`.

- `pcsx-redux-tools`:  
  Additional tools [`exe2elf`](https://github.com/grumpycoders/pcsx-redux/tree/main/tools/exe2elf), [`exe2iso`](https://github.com/grumpycoders/pcsx-redux/tree/main/tools/exe2iso), [`ps1-packer`](https://github.com/grumpycoders/pcsx-redux/tree/main/tools/ps1-packer), [`psyq-obj-parser`](https://github.com/grumpycoders/pcsx-redux/tree/main/tools/psyq-obj-parser) from the pcsx-redux repository.

- `pcsx-redux-untested`:  
  The same as `pcsx-redux`, but skips all tests. May be preferrable if you just want the emulator, not the BIOS and toolchain.
   
- `pcsx-redux-with-openbios`:  
  `pcsx-redux` and `openbios` packaged together in an environment where the emulator can find `openbios` as a fallback BIOS.

#### Known Issues

- There may be [audio issues on NixOS with unpatched miniaudio](https://github.com/NixOS/nixpkgs/pull/227972#issuecomment-1521020590). I am using pipewire and had no issues so far. If you encounter anything, let me know.

### [PSn00bSDK](https://github.com/Lameguy64/PSn00bSDK)

#### Packages
- `psn00bsdk-libpsn00b`:  
  The main MIPS library package

- `psn00bsdk-mkpsxiso`

- `psn00bsdk-tools`

- `psn00bsdk-examples`

### Misc

- `run-n00bdemo-with-pcsx-redux`:  
  Example entrypoint script to start n00bdemo (from `psn00bsdk-examples`) with pcsx-redux

## License note

Note: the unlicense applies to the code in this repository, not the packages built by it. It also might not apply to patches included, which may be derivative works of the packages to which they apply.
