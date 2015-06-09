################################################################################
#
# eudev
#
################################################################################

EUDEV_VERSION = 3.0
EUDEV_SOURCE = eudev-$(EUDEV_VERSION).tar.gz
EUDEV_SITE = http://dev.gentoo.org/~blueness/eudev
EUDEV_LICENSE = GPLv2+ (programs), LGPLv2.1+ (libraries)
EUDEV_LICENSE_FILES = COPYING
EUDEV_INSTALL_STAGING = YES

# mq_getattr is in librt
EUDEV_CONF_ENV += LIBS=-lrt

EUDEV_CONF_OPTS =		\
	--disable-manpages	\
	--sbindir=/sbin		\
	--with-rootlibdir=/lib	\
	--libexecdir=/lib	\
	--with-firmware-path=/lib/firmware	\
	--disable-introspection			\
	--enable-split-usr			\
	--enable-libkmod

EUDEV_DEPENDENCIES = host-pkgconf util-linux kmod
EUDEV_PROVIDES = udev

ifeq ($(BR2_PACKAGE_EUDEV_RULES_GEN),y)
EUDEV_CONF_OPTS += --enable-rule_generator
endif

ifeq ($(BR2_PACKAGE_LIBGLIB2),y)
EUDEV_CONF_OPTS += --enable-gudev
EUDEV_DEPENDENCIES += libglib2
else
EUDEV_CONF_OPTS += --disable-gudev
endif

$(eval $(autotools-package))
