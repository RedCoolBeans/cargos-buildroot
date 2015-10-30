################################################################################
#
# docker target filesystem
#
################################################################################

define ROOTFS_DOCKER_CMD
	tar --exclude="*usr/include*" --numeric-owner -C $(TARGET_DIR) -c . | docker import - $(BR2_TARGET_ROOTFS_DOCKER_NAME)
endef

$(eval $(call ROOTFS_TARGET,docker))
