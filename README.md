# iob-linux
This repository organizes and complements the needed tools to create a Linux Operating System that is capable of running in [IOb-SoC-OpenCryptoLinux](https://github.com/IObundle/iob-soc-opencryptolinux) with the VexRiscv core.

## Requirements (If not using Docker)
- RISC-V Linux/GNU toolchain: can be obtained from https://github.com/riscv-collab/riscv-gnu-toolchain; after cloning the repository in the terminal `cd` to the respective directory and configure with `./configure --prefix=/opt/riscv --enable-multilib`; After configuring you can build the Linux cross-compiler with `make Linux`.
- dtc: dtc can be installed on Debian/Ubuntu with -> `sudo apt-get install device-tree-compiler`
- build dependencies: `sudo apt install -y autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build bash binutils bzip2 cpio g++ gcc git gzip locales libncurses5-dev libdevmapper-dev libsystemd-dev make mercurial whois patch perl rsync sed tar unzip wget libssl-dev libfdt-dev`

## How to use Docker (Docker must be installed by the user)
To build the docker image corresponding to this projects development environment do:
- `docker build --pull --rm -t iob_linux "."`

After the build is successfully you can start running a container in interactive mode:
- `docker run -it iob_linux`

If the user exits the container, he can always restart it:
- `docker restart <container_id>`, where the `<container_id>` can be obtained from `docker ps -a`
- `docker exec -it <container_id> bash` to run an interactive shell

The following comands allow to copy files or folders from/to the container:
- `docker cp CONTAINER:SRC_PATH DEST_PATH` or `docker cp SRC_PATH CONTAINER:DEST_PATH`

For example, copying the output of `make build-OS`:
- `docker cp a6a26dbec0cf:/iob_linux/software/OS_build/ software`

## Makefile Targets
- build-opensbi: build the OpenSBI Linux Bootloader.
- build-rootfs: build the Linux root file system with busybox.
- build-linux-kernel: build the Linux kernel
- build-dts: build the IOb-SoC device tree needed by the Linux Kernel
- build-buildroot: build all of the OS with buildroot (WIP)
- build-qemu: build all of the OS to test with qemu (WIP)
- run-qemu: run the OS in qemu (WIP)
- clean-opensbi: remove the OpenSBI files
- clean-rootfs: remove the root file system files
- clean-linux-kernel: remove the Linux kernel files
- clean-buildroot: remove the buildroot files
- clean-OS: remove all of the OS files
- clean-all: do all of the cleaning above