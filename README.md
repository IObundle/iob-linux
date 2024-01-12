# iob-linux
This repository is a centralized resource containing essential tools for building a Linux Operating System tailored for the [IOb-SoC-OpenCryptoLinux](https://github.com/IObundle/iob-soc-opencryptolinux) platform.

The Operating System comprises four key files: the OpenSBI binary file (`fw_jump.bin`), the device tree blob file (`iob_soc.dtb`), the Linux kernel Image file, and the compressed root file system file. Pre-built versions of these files are included in this repository under the [`software/OS_build`](software/OS_build) directory. Additionally, a pre-built version of the Linux kernel for QEMU emulation is available under the same directory.

To recompile these files, utilize the provided Makefile commands detailed in the [Makefile](#makefile-targets) sections. For information on the necessary system requirements and development environment setup to compile all the essential files for running the Linux Operating System on [IOb-SoC-OpenCryptoLinux](https://github.com/IObundle/iob-soc-opencryptolinux), refer to the [development environment](#development-environment) section in this README.md.

## Makefile Targets
### `build-OS`
This is the main target that orchestrates the entire OS build process. It includes the following sub-targets:
- `build-dts`: Builds the IOb-SoC Device Tree.
- `build-opensbi`: Compiles the OpenSBI bootloader with IOb-SoC platform support.
- `build-rootfs`: Creates a minimal root filesystem using Busybox.
- `build-linux-kernel`: Builds the Linux kernel for the specified version.
- `build-buildroot`: Builds the root filesystem using Buildroot.
### `build-qemu`
Compiles the QEMU target for testing the generated OS.
### `run-qemu`
Runs QEMU to test the generated OS. This target assumes the QEMU target has been built successfully.
### `clean-OS`
Cleans the entire OS build directory.
### `clean-opensbi`
Cleans the OpenSBI build artifacts.
### `clean-rootfs`
Cleans the Busybox root filesystem build artifacts.
### `clean-linux-kernel`
Cleans the Linux kernel build artifacts.
### `clean-buildroot`
Cleans the Buildroot build artifacts.

## Makefile Variables
- `LINUX_OS_DIR`: Specifies the directory where the Linux OS is being built. The default value is the current working directory (`$(CURDIR)`).
- `OS_SOFTWARE_DIR`: Specifies the directory containing software-related files for the OS, such as configuration files and scripts.
- `OS_BUILD_DIR`: Specifies the directory where the final OS build artifacts will be placed.
- `OS_SUBMODULES_DIR`: Specifies the directory where external submodules (such as Linux kernel and Buildroot) are located.
- `MACROS_FILE`: Specifies the file containing macros for building the Device Tree and OpenSBI.
- `LINUX_VERSION`: Specifies the version of the Linux kernel to be used (default is 5.15.98).
- `BUILDROOT_VERSION`: Specifies the version of Buildroot to be used (default is buildroot-2022.02.10).

Before using this Makefile, ensure you have the necessary tools and dependencies installed. Customize these variables to match your project's directory structure and configurations.

## Makefile Usage
1. Set the appropriate values for `LINUX_OS_DIR`, `OS_SOFTWARE_DIR`, `OS_BUILD_DIR`, and `OS_SUBMODULES_DIR` variables.
2. Run `make build-OS` to build the entire OS.
3. Optionally, run `make build-qemu` to build QEMU target.
4. Run `make run-qemu` to test the generated OS in QEMU.

## Development Environment
Setting up the development environment is essential for building and testing your project. Whether you choose to work directly on your host machine, Nix environment, or within a Docker container, the following sections guide you through the necessary steps. Ensure that you have the required tools and dependencies installed to streamline the development process seamlessly.

Note: Instead of Docker, you may use the OpenSource solution Podman. Podman provides a lightweight, daemonless container engine that can be used as an alternative to Docker. The commands and workflows are similar, making it a viable choice for containerization in environments where Docker may not be the preferred option.

### Without Docker nor Nix
- **RISC-V Linux/GNU toolchain:**
  Obtain from [riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain). After cloning the repository, navigate to the respective directory and configure with `./configure --prefix=/opt/riscv --enable-multilib`. Build the Linux cross-compiler with `make Linux`.  
- **Linux Kernel development requirements:**
  The required packages depend on the host OS. For Ubuntu or similar Debian-based distributions, refer to [Kernel/BuildYourOwnKernel](https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel).  
- **dtc (device-tree-compiler):**
  Install on Debian/Ubuntu with `sudo apt-get install device-tree-compiler`.  
- **Buildroot system requirements:**
  Software dependencies are listed in the [Buildroot manual](https://buildroot.org/downloads/manual/manual.html#requirement).

### With Nix
To start the [Nix](https://nixos.org/) environment with included dependencies for building the Device Tree and OpenSBI, run:
- `nix-shell`

Note: [nix-shell](https://nixos.org/download.html#nix-install-linux) must be installed by the user.

### With Docker (Docker must be installed by the user)
To build the Docker image corresponding to this project's development environment:
- `docker build --pull --rm -t iob_linux "."`, or alternatively, you can pull the pre-built image: `docker pull IObundle/iob-linux:latest`

After a successful build, run a container in interactive mode:
- `docker run -it iob_linux`

If the user exits the container, they can restart it:
- `docker restart <container_id>`, where the `<container_id>` can be obtained from `docker ps -a`
- `docker exec -it <container_id> bash` to run an interactive shell

To copy files or folders to/from the container:
- `docker cp CONTAINER:SRC_PATH DEST_PATH` or `docker cp SRC_PATH CONTAINER:DEST_PATH`

For example, copying the output of `make build-OS`:
- `docker cp a6a26dbec0cf:/iob_linux/software/OS_build/ software`

Note: Docker must be installed by the user. If not already installed, please follow the instructions at https://docs.docker.com/engine/install/.
