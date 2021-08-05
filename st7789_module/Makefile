obj-m += fb_st7789v.o

KDIR ?= /lib/modules/`uname -r`/build

default:
	$(MAKE) -C $(KDIR) M=$(shell pwd) modules

install:
	$(MAKE) -C $(KDIR) M=$(shell pwd) modules_install
	$(DEPMOD)

clean:
	$(MAKE) -C $(KDIR) M=$(shell pwd) clean
