################################################################################
#
# Build the squashfs root filesystem image
#
################################################################################

ROOTFS_SQUASHFS_DEPENDENCIES = host-squashfs

ifeq ($(BR2_TARGET_ROOTFS_SQUASHFS4_LZ4),y)
ROOTFS_SQUASHFS_ARGS += -comp lz4
else
ifeq ($(BR2_TARGET_ROOTFS_SQUASHFS4_LZO),y)
ROOTFS_SQUASHFS_ARGS += -comp lzo
else
ifeq ($(BR2_TARGET_ROOTFS_SQUASHFS4_LZMA),y)
ROOTFS_SQUASHFS_ARGS += -comp lzma
else
ifeq ($(BR2_TARGET_ROOTFS_SQUASHFS4_XZ),y)
ROOTFS_SQUASHFS_ARGS += -comp xz
else
ROOTFS_SQUASHFS_ARGS += -comp gzip
endif
endif
endif
endif

define ROOTFS_SQUASHFS_CMD
	$(HOST_DIR)/usr/bin/mksquashfs $(TARGET_DIR) $@ -noappend \
		$(ROOTFS_SQUASHFS_ARGS) && \
	chmod 0644 $@
endef

define ROOTFS_SQUASHFS_NOINST_CMD
	$(HOST_DIR)/usr/bin/mksquashfs $(TARGET_DIR) ${@}-noinst -noappend -e var/db/bootstrap-cargos-x86_64-$(BR2_VERSION).tar.gz \
		$(ROOTFS_SQUASHFS_ARGS) && \
	chmod 0644 ${@}-noinst
endef

$(eval $(call ROOTFS_TARGET,squashfs))
