obj-m += $(MODULE_NAME).o

LINUX_DIR ?= ../../submodules/linux-5.15.98

# Options to cross compile for RISCV system in a x86 host machine
CROSS_COMPILE_OPS = "ARCH=riscv"
CROSS_COMPILE_OPS += "CROSS_COMPILE=riscv64-unknown-linux-gnu-"

all: 
	make -C $(LINUX_DIR) $(CROSS_COMPILE_OPS) M=$(CURDIR) modules

clean: linux-clean
	find . -not -name "Makefile" -type f -delete

linux-clean:
	make -C $(LINUX_DIR) $(CROSS_COMPILE_OPS) M=$(CURDIR) clean
