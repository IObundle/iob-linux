include config.mk

PROJECT_NAME:=iob_linux

REMOTE_USER?=
REMOTE_SERVER?=
ifneq ($(strip $(REMOTE_USER)$(REMOTE_SERVER)),)
    REMOTE_BUILD := true
endif

# Rules
.PHONY: build-OS clean-all qemu

# Automaticaly build minimall Linux OS for IOb-SoC-OpenCryptoLinux
build-OS: clean-OS build-dts build-opensbi build-rootfs build-linux-kernel

build-opensbi: clean-opensbi $(OS_DIR)
	cp -r $(OS_SOFTWARE_DIR)/opensbi_platform/* $(OS_SUBMODULES_DIR)/OpenSBI/platform/ && \
		cd $(OS_SUBMODULES_DIR)/OpenSBI && \
		CROSS_COMPILE=riscv64-unknown-linux-gnu- $(MAKE) run PLATFORM=iob_soc

build-rootfs: clean-rootfs $(OS_DIR)
	cd $(OS_SUBMODULES_DIR)/busybox && \
		cp $(OS_SOFTWARE_DIR)/rootfs_busybox/busybox_config $(OS_SUBMODULES_DIR)/busybox/configs/iob_defconfig && \
		$(MAKE) ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu- iob_defconfig && \
		CROSS_COMPILE=riscv64-unknown-linux-gnu- $(MAKE) -j$(nproc) && \
		CROSS_COMPILE=riscv64-unknown-linux-gnu- $(MAKE) install && \
		cd _install/ && cp $(OS_SOFTWARE_DIR)/rootfs_busybox/init init && \
		mkdir -p dev && sudo mknod dev/console c 5 1 && sudo mknod dev/ram0 b 1 0 && \
		find -print0 | cpio -0oH newc | gzip -9 > $(OS_DIR)/rootfs.cpio.gz

LINUX_VERSION=linux-5.15.98
LINUX_IMAGE=$(OS_SUBMODULES_DIR)/$(LINUX_VERSION)/arch/riscv/boot/Image
build-linux-kernel: $(OS_DIR) $(LINUX_IMAGE)
		cp $(LINUX_IMAGE) $(OS_DIR)

$(LINUX_IMAGE): $(OS_SUBMODULES_DIR)/$(LINUX_VERSION)
	cd $(OS_SUBMODULES_DIR)/$(LINUX_VERSION) && \
		cp $(OS_SOFTWARE_DIR)/linux_config $(OS_SUBMODULES_DIR)/$(LINUX_VERSION)/arch/riscv/configs/iob_soc_defconfig && \
		$(MAKE) ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu- iob_soc_defconfig && \
		$(MAKE) ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu- -j4

$(OS_SUBMODULES_DIR)/$(LINUX_VERSION): $(LINUX_VERSION).tar.xz
	tar -xf $(LINUX_VERSION).tar.xz -C $(OS_SUBMODULES_DIR)

$(LINUX_VERSION).tar.xz:
	wget https://cdn.kernel.org/pub/linux/kernel/v5.x/$(LINUX_VERSION).tar.xz

build-dts: $(OS_DIR)
	dtc -O dtb -o $(OS_DIR)/iob_soc.dtb $(OS_SOFTWARE_DIR)/iob_soc.dts

BUILDROOT_VERSION=buildroot-2022.02.10
BUILDROOT_DIR=$(OS_SUBMODULES_DIR)/$(BUILDROOT_VERSION)
build-buildroot: $(OS_DIR) $(BUILDROOT_DIR)
	cd $(BUILDROOT_DIR) && \
		$(MAKE) BR2_EXTERNAL=$(OS_SOFTWARE_DIR)/buildroot iob_soc_defconfig && $(MAKE) -j4 && \
		cp $(BUILDROOT_DIR)/output/images/rootfs.cpio.gz $(OS_DIR)

$(BUILDROOT_DIR):
	@wget https://buildroot.org/downloads/$(BUILDROOT_VERSION).tar.gz && \
		tar -xvzf $(BUILDROOT_VERSION).tar.gz -C $(OS_SUBMODULES_DIR)

# Automaticaly test RootFS in QEMU # WIP
build-qemu-kernel: clean-linux-kernel $(OS_DIR)
	cd $(OS_SUBMODULES_DIR)/Linux && \
		$(MAKE) ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu- rv32_defconfig && \
		$(MAKE) ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu- -j2 && \
		cp $(OS_SUBMODULES_DIR)/Linux/arch/riscv/boot/Image $(OS_DIR)

run-qemu: build-qemu-kernel
	qemu-system-riscv32 -nographic -machine virt -kernel $(OS_SOFTWARE_DIR)/OS_build/Image -append "rootwait root=/dev/vda ro" -drive file=$(OS_SOFTWARE_DIR)/OS_build/rootfs.cpio.gz,format=raw,id=hd0 -device virtio-blk-device,drive=hd0

# Support targets
$(OS_DIR):
	mkdir $(OS_SOFTWARE_DIR)/OS_build

#
# Clean
#
clean-opensbi:
	-@cd $(OS_SUBMODULES_DIR)/OpenSBI && $(MAKE) distclean && \
		rm $(OS_DIR)/fw_*.bin

clean-rootfs:
	-@cd $(OS_SUBMODULES_DIR)/busybox && $(MAKE) distclean && \
		rm $(OS_DIR)/rootfs.cpio.gz

clean-linux-kernel:
	-@rm -r $(OS_SUBMODULES_DIR)/$(LINUX_VERSION) && \
		rm $(OS_DIR)/Image

clean-buildroot:
	-@rm -rf $(OS_SUBMODULES_DIR)/$(BUILDROOT_VERSION) && \
		rm $(BUILDROOT_VERSION).tar.gz

clean-OS:
	@rm -rf $(OS_DIR)

clean-all: clean-OS
