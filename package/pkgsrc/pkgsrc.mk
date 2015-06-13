################################################################################
#
# pkgsrc
#
################################################################################

PKGSRC_VERSION = $(BR2_VERSION)
ifeq ($(BR2_ARM_CPU_ARMV7A),y)
PLATFORM=rpi2
else
PLATFORM=x86_64
endif
PKGSRC_SOURCE = bootstrap-cargos-$(PKGSRC_VERSION)-$(PLATFORM).tar.gz
PKGSRC_SITE = http://download.cargos.io/$(PKGSRC_VERSION)/$(PLATFORM)/bootstrap/
PKGSRC_DEPENDENCIES = busybox
PKGSRC_LICENSE = BSD

# No need to extract for target
PKGSRC_EXTRACT_CMDS =

define PKGSRC_INSTALL_TARGET_CMDS
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/var/db
	cp -a $(DL_DIR)/$(PKGSRC_SOURCE) $(TARGET_DIR)/var/db
endef

$(eval $(generic-package))
