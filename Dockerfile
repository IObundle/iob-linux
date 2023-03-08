# Specify the base image
FROM ubuntu:latest

ENV PATH "/opt/riscv/bin:${PATH}"

# Set the working directory
WORKDIR /iob_linux

# Update the package index and install dependencies
RUN apt-get update && \
    apt-get install -y device-tree-compiler autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build bash binutils bzip2 cpio g++ gcc git gzip locales libncurses5-dev libdevmapper-dev libsystemd-dev make mercurial whois patch perl rsync sed tar vim unzip wget libssl-dev libfdt-dev sudo && \
    git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git && \
    cd riscv-gnu-toolchain  && git checkout 2023.02.25 && \
    ./configure --prefix=/opt/riscv --enable-multilib && make linux && \
    rm -rf /iob_linux/riscv-gnu-toolchain

# Sometimes Buildroot need proper locale, e.g. when using a toolchain
# based on glibc.
RUN locale-gen en_US.utf8

# Copy the application files
COPY . .