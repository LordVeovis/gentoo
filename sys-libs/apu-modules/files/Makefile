PWD = $(shell pwd)
KDIR = $(KERNEL_DIR)

modules module:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules

install: $(MODULE)
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules_install

clean:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) clean
