################################################################################
#
# toolchain
#
################################################################################

ifeq ($(BR2_TOOLCHAIN_BUILDROOT),y)
TOOLCHAIN_DEPENDENCIES += toolchain-buildroot
endif

TOOLCHAIN_ADD_TOOLCHAIN_DEPENDENCY = NO

$(eval $(virtual-package))
