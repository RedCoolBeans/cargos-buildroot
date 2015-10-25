################################################################################
#
# rcorder
#
################################################################################

RCORDER_VERSION = 20150312
RCORDER_SITE = http://nerd.hu
RCORDER_SOURCE = rcorder-$(RCORDER_VERSION).tar.gz

# take precedence over busybox implementation
RCORDER_MAKE_ENV = $(TARGET_MAKE_ENV)
RCORDER_MAKE_OPTS = CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS)" \
	LIBS="$(RCORDER_EXTRA_LIBS)"
RCORDER_LICENSE = BSD

define RCORDER_BUILD_CMDS
	$(RCORDER_MAKE_ENV) $(MAKE) $(RCORDER_MAKE_OPTS) -C $(@D)
endef

define RCORDER_INSTALL_TARGET_CMDS
	$(RCORDER_MAKE_ENV) $(MAKE) $(RCORDER_MAKE_OPTS) \
		BASEDIR="$(TARGET_DIR)" install -C $(@D)
endef

$(eval $(generic-package))
