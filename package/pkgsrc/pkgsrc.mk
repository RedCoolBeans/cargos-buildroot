################################################################################
#
# pkgsrc
#
################################################################################

PKGSRC_VERSION = $(BR2_VERSION)
PKGSRC_SOURCE = bootstrap-cargos-x86_64-$(BR2_VERSION).tar.gz
PKGSRC_SITE = http://cargos.io/x86_64/bootstrap/
PKGSRC_DEPENDENCIES = busybox
PKGSRC_LICENSE = BSD

# No need to extract for target
PKGSRC_EXTRACT_CMDS =

define PKGSRC_INSTALL_TARGET_CMDS
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/var/db
	cp -a $(DL_DIR)/$(PKGSRC_SOURCE) $(TARGET_DIR)/var/db
endef

$(eval $(generic-package))
