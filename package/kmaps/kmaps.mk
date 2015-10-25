################################################################################
#
# kmaps
#
################################################################################

KMAPS_VERSION = 6.x
KMAPS_SOURCE = kmaps.tcz
KMAPS_SITE = http://distro.ibiblio.org/tinycorelinux/6.x/x86/tcz
KMAPS_DEPENDENCIES = busybox
KMAPS_LICENSE = GPL

# No need to extract for target
KMAPS_EXTRACT_CMDS =

define KMAPS_INSTALL_TARGET_CMDS
	unsquashfs -f -d $(@D)/squashfs-root $(DL_DIR)/kmaps.tcz
	cp -pR $(@D)/squashfs-root/usr/share/kmap $(TARGET_DIR)/usr/share
endef

$(eval $(generic-package))
