################################################################################
#
# egcc 
#
################################################################################

EGCC_VERSION = 4.9.3
EGCC_SITE = $(BR2_GNU_MIRROR)/gcc
EGCC_SOURCE = gcc-$(EGCC_VERSION).tar.bz2
EGCC_LICENSE = GPLv3+
EGCC_LICENSE_FILES = COPYING

EGCC_CONF_OPTS  = \
	--prefix=/usr \
	--enable-languages=c,c++ \
	--disable-multilib \
	--disable-bootstrap \
	--disable-libquadmath \
	--disable-libatomic \
	--disable-libsanitizer \
	--with-system-zlib

EGCC_SUBDIR = build

define EGCC_CONFIGURE_SYMLINK
	mkdir -p $(@D)/build
	ln -sf ../configure $(@D)/build/configure
endef

EGCC_PRE_CONFIGURE_HOOKS += EGCC_CONFIGURE_SYMLINK

$(eval $(autotools-package))
