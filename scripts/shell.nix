{ pkgs ? import (builtins.fetchTarball {
  # Descriptive name to make the store path easier to identify
  name = "nixos-22.11";
  # Commit hash for nixos-22.11
  url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/22.11.tar.gz";
  # Hash obtained using `nix-prefetch-url --unpack <url>`
  sha256 = "11w3wn2yjhaa5pv20gbfbirvjq6i3m7pqrq2msf0g7cv44vijwgw";
}) {}}:
pkgs.mkShell {
  name = "iob-shell";
  buildInputs = with pkgs; [     
    bash
    gnumake
    dtc
    (callPackage ./scripts/riscv-gnu-toolchain.nix { })
    # Linux kernel build packages
    libyaml
  ];
}
