################################################################################
#
# skeleton
#
################################################################################

# source included in buildroot
SKELETON_SOURCE =

# The skeleton can't depend on the toolchain, since all packages depends on the
# skeleton and the toolchain is a target package, as is skeleton.
# Hence, skeleton would depends on the toolchain and the toolchain would depend
# on skeleton.
SKELETON_ADD_TOOLCHAIN_DEPENDENCY = NO

ifeq ($(BR2_ROOTFS_SKELETON_CUSTOM),y)
SKELETON_PATH = $(BR2_ROOTFS_SKELETON_CUSTOM_PATH)
else
SKELETON_PATH = system/skeleton
endif

define SKELETON_INSTALL_TARGET_CMDS
	rsync -a --ignore-times $(SYNC_VCS_EXCLUSIONS) \
		--chmod=u=rwX,go=rX --exclude .empty --exclude '*~' --exclude 'rc.bootstrap*' \
		$(SKELETON_PATH)/ $(TARGET_DIR)/
	$(INSTALL) -m 0644 support/misc/target-dir-warning.txt \
		$(TARGET_DIR_WARNING_FILE)
	ln -snf lib $(TARGET_DIR)/$(LIB_SYMLINK)
	mkdir -p $(TARGET_DIR)/usr
	ln -snf lib $(TARGET_DIR)/usr/$(LIB_SYMLINK)
endef

SKELETON_TARGET_GENERIC_ISSUE = $(call qstrip,$(BR2_TARGET_GENERIC_ISSUE))
SKELETON_TARGET_GENERIC_ROOT_PASSWD = $(call qstrip,$(BR2_TARGET_GENERIC_ROOT_PASSWD))
SKELETON_TARGET_GENERIC_PASSWD_METHOD = $(call qstrip,$(BR2_TARGET_GENERIC_PASSWD_METHOD))
SKELETON_TARGET_GENERIC_BIN_SH = $(call qstrip,$(BR2_SYSTEM_BIN_SH))
SKELETON_TARGET_GENERIC_GETTY_PORT = $(call qstrip,$(BR2_TARGET_GENERIC_GETTY_PORT))
SKELETON_TARGET_GENERIC_GETTY_BAUDRATE = $(call qstrip,$(BR2_TARGET_GENERIC_GETTY_BAUDRATE))
SKELETON_TARGET_GENERIC_GETTY_TERM = $(call qstrip,$(BR2_TARGET_GENERIC_GETTY_TERM))
SKELETON_TARGET_GENERIC_GETTY_OPTIONS = $(call qstrip,$(BR2_TARGET_GENERIC_GETTY_OPTIONS))

define RC_BOOTSTRAP
	$(INSTALL) -m 0644 $(SKELETON_PATH)/etc/rc.bootstrap-$(BR2_PKGSRC_ARCH) \
		$(TARGET_DIR)/etc/rc.bootstrap
endef
TARGET_FINALIZE_HOOKS += RC_BOOTSTRAP

ifneq ($(SKELETON_TARGET_GENERIC_ISSUE),)
define SYSTEM_ISSUE
	mkdir -p $(TARGET_DIR)/etc
	echo "$(SKELETON_TARGET_GENERIC_ISSUE)" > $(TARGET_DIR)/etc/issue
	echo "" >> $(TARGET_DIR)/etc/issue
endef
TARGET_FINALIZE_HOOKS += SYSTEM_ISSUE
endif

# The TARGET_FINALIZE_HOOKS must be sourced only if the users choose to use the
# default skeleton.
ifeq ($(BR2_ROOTFS_SKELETON_DEFAULT),y)

ifeq ($(BR2_TARGET_ENABLE_ROOT_LOGIN),y)
ifeq ($(SKELETON_TARGET_GENERIC_ROOT_PASSWD),)
SYSTEM_ROOT_PASSWORD =
else ifneq ($(filter $$1$$% $$5$$% $$6$$%,$(SKELETON_TARGET_GENERIC_ROOT_PASSWD)),)
SYSTEM_ROOT_PASSWORD = '$(SKELETON_TARGET_GENERIC_ROOT_PASSWD)'
else
SKELETON_DEPENDENCIES += host-mkpasswd
# This variable will only be evaluated in the finalize stage, so we can
# be sure that host-mkpasswd will have already been built by that time.
SYSTEM_ROOT_PASSWORD = "`$(MKPASSWD) -m "$(SKELETON_TARGET_GENERIC_PASSWD_METHOD)" "$(SKELETON_TARGET_GENERIC_ROOT_PASSWD)"`"
endif
else # !BR2_TARGET_ENABLE_ROOT_LOGIN
SYSTEM_ROOT_PASSWORD = "*"
endif

define SKELETON_SYSTEM_SET_ROOT_PASSWD
	$(SED) s,^root:[^:]*:,root:$(SYSTEM_ROOT_PASSWORD):, $(TARGET_DIR)/etc/shadow
endef
TARGET_FINALIZE_HOOKS += SKELETON_SYSTEM_SET_ROOT_PASSWD

ifeq ($(BR2_SYSTEM_BIN_SH_NONE),y)
define SKELETON_SYSTEM_BIN_SH
	rm -f $(TARGET_DIR)/bin/sh
endef
else
define SKELETON_SYSTEM_BIN_SH
	ln -sf $(SKELETON_TARGET_GENERIC_BIN_SH) $(TARGET_DIR)/bin/sh
endef
endif
TARGET_FINALIZE_HOOKS += SKELETON_SYSTEM_BIN_SH

ifeq ($(BR2_TARGET_GENERIC_GETTY),y)
ifeq ($(BR2_INIT_SYSV),y)
# In sysvinit inittab, the "id" must not be longer than 4 bytes, so we
# skip the "tty" part and keep only the remaining.
define SKELETON_SYSTEM_GETTY
	$(SED) '/# GENERIC_SERIAL$$/s~^.*#~$(shell echo $(SKELETON_TARGET_GENERIC_GETTY_PORT) | tail -c+4)::respawn:/sbin/getty -L $(SKELETON_TARGET_GENERIC_GETTY_OPTIONS) $(SKELETON_TARGET_GENERIC_GETTY_PORT) $(SKELETON_TARGET_GENERIC_GETTY_BAUDRATE) $(SKELETON_TARGET_GENERIC_GETTY_TERM) #~' \
		$(TARGET_DIR)/etc/inittab
endef
else ifeq ($(BR2_INIT_BUSYBOX),y)
# Add getty to busybox inittab
define SKELETON_SYSTEM_GETTY
	$(SED) '/# GENERIC_SERIAL$$/s~^.*#~$(SKELETON_TARGET_GENERIC_GETTY_PORT)::respawn:/sbin/getty -L $(SKELETON_TARGET_GENERIC_GETTY_OPTIONS) $(SKELETON_TARGET_GENERIC_GETTY_PORT) $(SKELETON_TARGET_GENERIC_GETTY_BAUDRATE) $(SKELETON_TARGET_GENERIC_GETTY_TERM) #~' \
		$(TARGET_DIR)/etc/inittab
endef
endif
TARGET_FINALIZE_HOOKS += SKELETON_SYSTEM_GETTY
endif

ifeq ($(BR2_INIT_BUSYBOX)$(BR2_INIT_SYSV),y)
ifeq ($(BR2_TARGET_GENERIC_REMOUNT_ROOTFS_RW),y)
# Find commented line, if any, and remove leading '#'s
define SKELETON_SYSTEM_REMOUNT_RW
	$(SED) '/^#.*-o remount,rw \/$$/s~^#\+~~' $(TARGET_DIR)/etc/inittab
endef
else
# Find uncommented line, if any, and add a leading '#'
define SKELETON_SYSTEM_REMOUNT_RW
	$(SED) '/^[^#].*-o remount,rw \/$$/s~^~#~' $(TARGET_DIR)/etc/inittab
endef
endif
TARGET_FINALIZE_HOOKS += SKELETON_SYSTEM_REMOUNT_RW
endif # BR2_INIT_BUSYBOX || BR2_INIT_SYSV

endif # BR2_ROOTFS_SKELETON_DEFAULT

$(eval $(generic-package))
