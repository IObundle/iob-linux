# Specify the base image
FROM ubuntu:latest

ENV PATH "/opt/riscv/bin:${PATH}"

# Set the working directory
WORKDIR /iob_linux

# Update the package index and install dependencies
RUN apt-get update && \
    apt-get install -y device-tree-compiler autoconf automake autotools-dev curl python3 python3-setuptools libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build bash binutils bzip2 cpio g++ gcc git gzip make patch perl rsync sed tar unzip wget file sudo locales mercurial libncurses5-dev libfdt-dev libglib2.0-dev libpixman-1-dev

RUN git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git && \
    cd riscv-gnu-toolchain  && git checkout 2023.02.25 && \
    ./configure --prefix=/opt/riscv --enable-multilib && make linux -j`nproc` && \
    rm -rf /iob_linux/riscv-gnu-toolchain
    
RUN wget https://download.qemu.org/qemu-7.2.9.tar.xz && tar xvJf qemu-7.2.9.tar.xz && rm qemu-7.2.9.tar.xz && \
    cd qemu-7.2.9 && ./configure --target-list=riscv32-softmmu,riscv32-linux-user && \
    make -j`nproc` && make install && rm -r /iob_linux/qemu-7.2.9

RUN apt-get install -y gcc-12 g++-12 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 20 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 20 && \
    update-alternatives --config gcc && \
    update-alternatives --config g++

# riscv-gnu-toolchain dependencies: apt-get install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build
# QEMU dependencies: apt-get install git libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev ninja-build
# Buildroot dependencies: which sed make binutils build-essential diffutils gcc g++ bash patch gzip bzip2 perl tar cpio unzip rsync file bc findutils wget
# IOb-Linux dependencies: all of the above + apt-get install device-tree-compiler python3 sudo locales

# Sometimes Buildroot need proper locale, e.g. when using a toolchain
# based on glibc.
RUN locale-gen en_US.utf8

# Copy the application files
COPY . .
