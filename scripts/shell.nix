{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/25.05.tar.gz") {}}:
pkgs.mkShell {
  name = "iob-shell";
  buildInputs = with pkgs; [     
    bash
    gnumake
    dtc
    (callPackage ./scripts/riscv-gnu-toolchain.nix { })
    # Linux kernel build packages
    libyaml
    ncurses
    # Buildroot
    bc
  ];
  shellHook = ''
    # fixes libstdc++.so.6 issues of buildroot's patchelf
    export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib
  '';

  # Disable hardening flags for gcc. Prevents errors when running buildroot, like these:
  # https://github.com/riscv-collab/riscv-gnu-toolchain/issues/901
  hardeningDisable = [ "all" ];
}
