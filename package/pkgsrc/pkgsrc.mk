################################################################################
#
# pkgsrc
#
################################################################################

PKGSRC_VERSION = $(BR2_VERSION)
PKGSRC_SOURCE = bootstrap-cargos-x86_64-$(BR2_VERSION).tar.gz
PKGSRC_SITE = http://cargos.io/pub/pkgsrc/bootstrap/
PKGSRC_DEPENDENCIES = busybox
PKGSRC_LICENSE = BSD

# No need to extract for target
PKGSRC_EXTRACT_CMDS =

define PKGSRC_INSTALL_TARGET_CMDS
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/var/db
	cp -a $(DL_DIR)/$(PKGSRC_SOURCE) $(TARGET_DIR)/var/db

	# Install some symlinks for mail
	cd $(TARGET_DIR)/usr/sbin; ln -sf /usr/pkg/sbin/smtpctl sendmail
	cd $(TARGET_DIR)/var; ln -sf /usr/pkg/var/spool/mail mail
endef

$(eval $(generic-package))
