.PHONY: all

VER := 0.5.1
ARCH := amd64
NAME := flannel
TARGET := $(NAME)-$(VER)
TARGET_TAR := $(TARGET)-linux-$(ARCH).tar.gz

all: $(BUILDDIR)/$(TARGET)/flanneld $(BUILDDIR)/setup-network-environment network.mk
	mkdir -p $(ROOTFS)/usr/bin
	cp -af $(BUILDDIR)/$(TARGET)/flanneld $(ROOTFS)/usr/bin
	cp -af $(BUILDDIR)/setup-network-environment $(ROOTFS)/usr/bin
	cp -af ./setup-network-environment.service $(ROOTFS)/lib/systemd/system
	cp -af ./flanneld.service $(ROOTFS)/lib/systemd/system
	ln -sf /lib/systemd/system/setup-network-environment.service  $(ROOTFS)/lib/systemd/system/multi-user.target.wants/
	ln -sf /lib/systemd/system/flanneld.service  $(ROOTFS)/lib/systemd/system/multi-user.target.wants/

$(BUILDDIR)/$(TARGET)/flanneld:
	curl -L https://github.com/coreos/flannel/releases/download/v$(VER)/$(TARGET_TAR) -o $(BUILDDIR)/$(TARGET_TAR)
	cd $(BUILDDIR) && tar -xzf $(TARGET_TAR)

$(BUILDDIR)/setup-network-environment: DIR := $(shell mktemp -d)
$(BUILDDIR)/setup-network-environment: GOPATH := $(DIR)
$(BUILDDIR)/setup-network-environment:
	mkdir -p $(DIR)/src/github.com/kelseyhightower
	cd $(DIR)/src/github.com/kelseyhightower && git clone https://github.com/kelseyhightower/setup-network-environment
	cd $(DIR)/src/github.com/kelseyhightower/setup-network-environment && godep go build .
	cp $(DIR)/src/github.com/kelseyhightower/setup-network-environment/setup-network-environment $(BUILDDIR)
	rm -rf $(DIR)
