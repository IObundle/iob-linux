{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    # To build the kernel
    bash
    gcc
    fakeroot
    xz
    ncurses
    bc
    flex
    bison
    # To build the device tree
    dtc
    # To Run the QEMU simulation
    qemu
    ];
}
