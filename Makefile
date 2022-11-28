include config.mk

# Rules
.PHONY: build-OS clean qemu

# Automaticaly build minimall Linux OS for IOb-SoC-OpenCryptoLinux
build-OS: clean-OS build-dts build-opensbi build-rootfs build-linux-kernel

build-opensbi: clean-opensbi os_dir
	cp -r $(OS_SOFTWARE_DIR)/opensbi_platform/* $(OS_SUBMODULES_DIR)/OpenSBI/platform/ && \
		cd $(OS_SUBMODULES_DIR)/OpenSBI && $(MAKE) run PLATFORM=iob_soc

build-rootfs: clean-rootfs os_dir
	cd $(OS_SUBMODULES_DIR)/busybox && \
		cp $(OS_SOFTWARE_DIR)/rootfs_busybox/busybox_config $(OS_SUBMODULES_DIR)/busybox/configs/iob_defconfig && \
		$(MAKE) ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu- iob_defconfig && \
		CROSS_COMPILE=riscv64-unknown-linux-gnu- $(MAKE) -j$(nproc) && \
		CROSS_COMPILE=riscv64-unknown-linux-gnu- $(MAKE) install && \
		cd _install/ && cp $(OS_SOFTWARE_DIR)/rootfs_busybox/init init && \
		mkdir -p dev && sudo mknod dev/console c 5 1 && sudo mknod dev/ram0 b 1 0 && \
		find -print0 | cpio -0oH newc | gzip -9 > $(OS_DIR)/rootfs.cpio.gz

build-linux-kernel: clean-linux-kernel os_dir
	cd $(OS_SUBMODULES_DIR)/Linux && \
		cp $(OS_SOFTWARE_DIR)/linux_config $(OS_SUBMODULES_DIR)/Linux/arch/riscv/configs/iob_soc_defconfig && \
		$(MAKE) ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu- iob_soc_defconfig && \
		$(MAKE) ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu- -j2 && \
		cp $(OS_SUBMODULES_DIR)/Linux/arch/riscv/boot/Image $(OS_DIR)

build-dts: os_dir
	dtc -O dtb -o $(OS_DIR)/iob_soc.dtb $(OS_SOFTWARE_DIR)/iob_soc.dts

build-buildroot: clean-buildroot
	@wget https://buildroot.org/downloads/buildroot-2022.05.2.tar.gz && tar -xvzf buildroot-2022.05.2.tar.gz -C $(OS_SUBMODULES_DIR) && \
		cd $(OS_SUBMODULES_DIR)/buildroot-2022.05.2/ && \
		$(MAKE) BR2_EXTERNAL=$(OS_SOFTWARE_DIR)/buildroot iob_soc_defconfig && $(MAKE) -j2 && \
		cp $(OS_SUBMODULES_DIR)/buildroot-2022.05.2/output/images/Image $(OS_DIR)

# Automaticaly test RootFS in QEMU # WIP
build-qemu: 

run-qemu: build-qemu
	qemu-system-riscv32 -M virt -bios qemu_LinuxOS/fw_jump.elf -kernel qemu_LinuxOS/Image -append "rootwait root=/dev/vda ro" -drive file=qemu_LinuxOS/rootfs.ext2,format=raw,id=hd0 -device virtio-blk-device,drive=hd0 -netdev user,id=net0 -device virtio-net-device,netdev=net0 -nographic

# Support targets
os_dir:
	-@mkdir $(OS_SOFTWARE_DIR)/OS_build

#
# Clean
#
clean-opensbi:
	cd $(OS_SUBMODULES_DIR)/OpenSBI && $(MAKE) distclean

clean-rootfs:
	cd $(OS_SUBMODULES_DIR)/busybox && $(MAKE) distclean

clean-linux-kernel:
	cd $(OS_SUBMODULES_DIR)/Linux && $(MAKE) ARCH=riscv distclean

clean-buildroot:
	-@rm -rf $(OS_SUBMODULES_DIR)/buildroot-2022.05.2 && \
		rm buildroot-2022.05.2.tar.gz

clean-OS:
	@rm -rf $(OS_DIR)/*

clean-all: clean-OS
