################################################################################
#
# pkgsrc
#
################################################################################

PKGSRC_VERSION = $(BR2_VERSION)
PKGSRC_SOURCE = bootstrap-cargos-$(PKGSRC_VERSION)-$(BR2_PKGSRC_ARCH).tar.gz
PKGSRC_SITE = http://download.cargos.io/$(PKGSRC_VERSION)/$(BR2_PKGSRC_ARCH)/bootstrap
PKGSRC_DEPENDENCIES = busybox
PKGSRC_LICENSE = BSD

# No need to extract for target
PKGSRC_EXTRACT_CMDS =

define PKGSRC_INSTALL_TARGET_CMDS
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/var/db
	cp -a $(DL_DIR)/$(PKGSRC_SOURCE) $(TARGET_DIR)/var/db
endef

$(eval $(generic-package))
