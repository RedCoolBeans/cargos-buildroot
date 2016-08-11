################################################################################
#
# musl
#
################################################################################

MUSL_VERSION = 1.1.15
MUSL_SITE = http://www.musl-libc.org/releases
MUSL_LICENSE = MIT
MUSL_LICENSE_FILES = COPYRIGHT

# Before musl is configured, we must have the first stage
# cross-compiler and the kernel headers
MUSL_DEPENDENCIES = host-gcc-initial linux-headers

# musl does not provide a sys/queue.h implementation, so add the
# netbsd-queue package that will install a sys/queue.h file in the
# staging directory based on the NetBSD implementation.
MUSL_DEPENDENCIES += netbsd-queue

# musl is part of the toolchain so disable the toolchain dependency
MUSL_ADD_TOOLCHAIN_DEPENDENCY = NO

MUSL_INSTALL_STAGING = YES

# Thumb build is broken, build in ARM mode, since all architectures
# that support Thumb1 also support ARM.
ifeq ($(BR2_ARM_INSTRUCTIONS_THUMB),y)
MUSL_EXTRA_CFLAGS += -marm
endif

define MUSL_CONFIGURE_CMDS
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(filter-out -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64,$(TARGET_CFLAGS)) $(MUSL_EXTRA_CFLAGS)" \
		CPPFLAGS="$(filter-out -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64,$(TARGET_CPPFLAGS))" \
		./configure \
			--target=$(GNU_TARGET_NAME) \
			--host=$(GNU_TARGET_NAME) \
			--prefix=/usr \
			--libdir=/lib \
			--disable-gcc-wrapper \
			--enable-static \
			$(if $(BR2_STATIC_LIBS),--disable-shared,--enable-shared))
endef

define MUSL_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define MUSL_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		DESTDIR=$(STAGING_DIR) install-libs install-tools install-headers
endef

define MUSL_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		DESTDIR=$(TARGET_DIR) install-libs
	$(RM) $(addprefix $(TARGET_DIR)/lib/,crt1.o crtn.o crti.o Scrt1.o)
	# provide minimal libssp_nonshared.a so we don't need libssp from gcc
	$(TARGET_CC) $(TARGET_CFLAGS) -c package/musl/__stack_chk_fail_local.c -o \
		$(@D)/__stack_chk_fail_local.o 
	$(TARGET_AR) r $(TARGET_DIR)/usr/lib/libssp_nonshared.a $(@D)/__stack_chk_fail_local.o || return 1
endef

$(eval $(generic-package))
