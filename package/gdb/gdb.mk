################################################################################
#
# gdb
#
################################################################################

GDB_VERSION = $(call qstrip,$(BR2_GDB_VERSION))
GDB_SITE = $(BR2_GNU_MIRROR)/gdb

ifeq ($(BR2_arc),y)
GDB_SITE = $(call github,foss-for-synopsys-dwc-arc-processors,binutils-gdb,$(GDB_VERSION))
GDB_SOURCE = gdb-$(GDB_VERSION).tar.gz
GDB_FROM_GIT = y
endif

ifeq ($(BR2_microblaze),y)
GDB_SITE = $(call github,Xilinx,gdb,$(GDB_VERSION))
GDB_SOURCE = gdb-$(GDB_VERSION).tar.gz
GDB_FROM_GIT = y
endif

# Starting from 7.8.x, bz2 tarballs no longer available, use .tar.xz
# instead.
ifneq ($(filter 7.8.%,$(GDB_VERSION)),)
GDB_SOURCE = gdb-$(GDB_VERSION).tar.xz
endif

GDB_SOURCE ?= gdb-$(GDB_VERSION).tar.bz2
GDB_LICENSE = GPLv2+ LGPLv2+ GPLv3+ LGPLv3+
GDB_LICENSE_FILES = COPYING COPYING.LIB COPYING3 COPYING3.LIB

# We only want gdbserver and not the entire debugger.
ifeq ($(BR2_PACKAGE_GDB_DEBUGGER),)
GDB_SUBDIR = gdb/gdbserver
HOST_GDB_SUBDIR = .
else
GDB_DEPENDENCIES = ncurses
endif

# For the host variant, we really want to build with XML support,
# which is needed to read XML descriptions of target architectures. We
# also need ncurses.
HOST_GDB_DEPENDENCIES = host-expat host-ncurses

# Apply the Xtensa specific patches
XTENSA_CORE_NAME = $(call qstrip, $(BR2_XTENSA_CORE_NAME))
ifneq ($(XTENSA_CORE_NAME),)
define GDB_XTENSA_PRE_PATCH
	tar xf $(BR2_XTENSA_OVERLAY_DIR)/xtensa_$(XTENSA_CORE_NAME).tar \
		-C $(@D) --strip-components=1 gdb
endef
GDB_PRE_PATCH_HOOKS += GDB_XTENSA_PRE_PATCH
HOST_GDB_PRE_PATCH_HOOKS += GDB_XTENSA_PRE_PATCH
endif

# When gdb sources are fetched from the binutils-gdb repository, they
# also contain the binutils sources, but binutils shouldn't be built,
# so we disable it.
GDB_DISABLE_BINUTILS_CONF_OPTS = \
	--disable-binutils \
	--disable-ld \
	--disable-gas

GDB_CONF_ENV = \
	ac_cv_type_uintptr_t=yes \
	gt_cv_func_gettext_libintl=yes \
	ac_cv_func_dcgettext=yes \
	gdb_cv_func_sigsetjmp=yes \
	bash_cv_func_strcoll_broken=no \
	bash_cv_must_reinstall_sighandlers=no \
	bash_cv_func_sigsetjmp=present \
	bash_cv_have_mbstate_t=yes \
	gdb_cv_func_sigsetjmp=yes

# The shared only build is not supported by gdb, so enable static build for
# build-in libraries with --enable-static.
GDB_CONF_OPTS = \
	--without-uiout \
	--disable-gdbtk \
	--without-x \
	--disable-sim \
	$(GDB_DISABLE_BINUTILS_CONF_OPTS) \
	$(if $(BR2_PACKAGE_GDB_SERVER),--enable-gdbserver) \
	--with-curses \
	--without-included-gettext \
	--disable-werror \
	--enable-static

ifeq ($(BR2_PACKAGE_GDB_TUI),y)
	GDB_CONF_OPTS += --enable-tui
else
	GDB_CONF_OPTS += --disable-tui
endif

ifeq ($(BR2_PACKAGE_GDB_PYTHON),y)
	GDB_CONF_OPTS += --with-python=$(TOPDIR)/package/gdb/gdb-python-config
	GDB_DEPENDENCIES += python
else
	GDB_CONF_OPTS += --without-python
endif

# This removes some unneeded Python scripts and XML target description
# files that are not useful for a normal usage of the debugger.
define GDB_REMOVE_UNNEEDED_FILES
	$(RM) -rf $(TARGET_DIR)/usr/share/gdb
endef

GDB_POST_INSTALL_TARGET_HOOKS += GDB_REMOVE_UNNEEDED_FILES

# This installs the gdbserver somewhere into the $(HOST_DIR) so that
# it becomes an integral part of the SDK, if the toolchain generated
# by Buildroot is later used as an external toolchain. We install it
# in debug-root/usr/bin/gdbserver so that it matches what Crosstool-NG
# does.
define GDB_SDK_INSTALL_GDBSERVER
	$(INSTALL) -D -m 0755 $(TARGET_DIR)/usr/bin/gdbserver \
		$(HOST_DIR)/usr/$(GNU_TARGET_NAME)/debug-root/usr/bin/gdbserver
endef

ifeq ($(BR2_PACKAGE_GDB_SERVER),y)
GDB_POST_INSTALL_TARGET_HOOKS += GDB_SDK_INSTALL_GDBSERVER
endif

# A few notes:
#  * --target, because we're doing a cross build rather than a real
#    host build.
#  * --enable-static because gdb really wants to use libbfd.a
HOST_GDB_CONF_OPTS = \
	--target=$(GNU_TARGET_NAME) \
	--enable-static \
	--without-uiout \
	--disable-gdbtk \
	--without-x \
	--enable-threads \
	--disable-werror \
	--without-included-gettext \
	$(GDB_DISABLE_BINUTILS_CONF_OPTS) \
	--disable-sim

ifeq ($(BR2_PACKAGE_HOST_GDB_TUI),y)
	HOST_GDB_CONF_OPTS += --enable-tui
else
	HOST_GDB_CONF_OPTS += --disable-tui
endif

ifeq ($(BR2_PACKAGE_HOST_GDB_PYTHON),y)
	HOST_GDB_CONF_OPTS += --with-python=$(HOST_DIR)/usr/bin/python2
	HOST_GDB_DEPENDENCIES += host-python
else
	HOST_GDB_CONF_OPTS += --without-python
endif

ifeq ($(GDB_FROM_GIT),y)
HOST_GDB_DEPENDENCIES += host-texinfo
else
# don't generate documentation
GDB_CONF_ENV += ac_cv_prog_MAKEINFO=missing
HOST_GDB_CONF_ENV += ac_cv_prog_MAKEINFO=missing
endif

# legacy $arch-linux-gdb symlink
define HOST_GDB_ADD_SYMLINK
	cd $(HOST_DIR)/usr/bin && \
		ln -snf $(GNU_TARGET_NAME)-gdb $(ARCH)-linux-gdb
endef

HOST_GDB_POST_INSTALL_HOOKS += HOST_GDB_ADD_SYMLINK

HOST_GDB_POST_INSTALL_HOOKS += gen_gdbinit_file

$(eval $(autotools-package))
$(eval $(host-autotools-package))
