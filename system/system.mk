TARGET_GENERIC_HOSTNAME = $(call qstrip,$(BR2_TARGET_GENERIC_HOSTNAME))
TARGET_GENERIC_ISSUE = $(call qstrip,$(BR2_TARGET_GENERIC_ISSUE))
TARGET_GENERIC_ROOT_PASSWD = $(call qstrip,$(BR2_TARGET_GENERIC_ROOT_PASSWD))
TARGET_GENERIC_PASSWD_METHOD = $(call qstrip,$(BR2_TARGET_GENERIC_PASSWD_METHOD))
TARGET_GENERIC_BIN_SH = $(call qstrip,$(BR2_SYSTEM_BIN_SH))
TARGET_GENERIC_GETTY_PORT = $(call qstrip,$(BR2_TARGET_GENERIC_GETTY_PORT))
TARGET_GENERIC_GETTY_BAUDRATE = $(call qstrip,$(BR2_TARGET_GENERIC_GETTY_BAUDRATE))
TARGET_GENERIC_GETTY_TERM = $(call qstrip,$(BR2_TARGET_GENERIC_GETTY_TERM))
TARGET_GENERIC_GETTY_OPTIONS = $(call qstrip,$(BR2_TARGET_GENERIC_GETTY_OPTIONS))

ifeq ($(BR2_TARGET_GENERIC_GETTY),y)
define SYSTEM_SECURETTY
	grep -q '^$(TARGET_GENERIC_GETTY_PORT)$$' $(TARGET_DIR)/etc/securetty || \
		echo '$(TARGET_GENERIC_GETTY_PORT)' >> $(TARGET_DIR)/etc/securetty
endef
TARGET_FINALIZE_HOOKS += SYSTEM_SECURETTY
endif

#ifneq ($(TARGET_GENERIC_HOSTNAME),)
#define SYSTEM_HOSTNAME
#	mkdir -p $(TARGET_DIR)/etc
#	echo "$(TARGET_GENERIC_HOSTNAME)" > $(TARGET_DIR)/etc/hostname
#	$(SED) '$$a \127.0.1.1\t$(TARGET_GENERIC_HOSTNAME)' \
#		-e '/^127.0.1.1/d' $(TARGET_DIR)/etc/hosts
#endef
#TARGET_FINALIZE_HOOKS += SYSTEM_HOSTNAME
#endif

ifneq ($(TARGET_GENERIC_ISSUE),)
define SYSTEM_ISSUE
	mkdir -p $(TARGET_DIR)/etc
	echo "$(TARGET_GENERIC_ISSUE)" > $(TARGET_DIR)/etc/issue
	echo "" >> $(TARGET_DIR)/etc/issue
endef
TARGET_FINALIZE_HOOKS += SYSTEM_ISSUE
endif

ifneq ($(TARGET_GENERIC_ROOT_PASSWD),)
PACKAGES += host-mkpasswd
endif

NETWORK_DHCP_IFACE = $(call qstrip,$(BR2_SYSTEM_DHCP))

ifeq ($(BR2_ROOTFS_SKELETON_DEFAULT),y)

ifeq ($(BR2_TARGET_ENABLE_ROOT_LOGIN),y)
ifeq ($(TARGET_GENERIC_ROOT_PASSWD),)
SYSTEM_ROOT_PASSWORD =
else ifneq ($(filter $$1$$% $$5$$% $$6$$%,$(TARGET_GENERIC_ROOT_PASSWD)),)
SYSTEM_ROOT_PASSWORD = $(TARGET_GENERIC_ROOT_PASSWD)
else
PACKAGES += host-mkpasswd
# This variable will only be evaluated in the finalize stage, so we can
# be sure that host-mkpasswd will have already been built by that time.
SYSTEM_ROOT_PASSWORD = $(shell $(MKPASSWD) -m "$(TARGET_GENERIC_PASSWD_METHOD)" "$(TARGET_GENERIC_ROOT_PASSWD)")
endif
else # !BR2_TARGET_ENABLE_ROOT_LOGIN
SYSTEM_ROOT_PASSWORD = *
endif

define SYSTEM_SET_ROOT_PASSWD
	$(SED) 's,^root:[^:]*:,root:$(SYSTEM_ROOT_PASSWORD):,' $(TARGET_DIR)/etc/shadow
endef
TARGET_FINALIZE_HOOKS += SYSTEM_SET_ROOT_PASSWD

ifeq ($(BR2_SYSTEM_BIN_SH_NONE),y)
define SYSTEM_BIN_SH
	rm -f $(TARGET_DIR)/bin/sh
endef
else
define SYSTEM_BIN_SH
	ln -sf $(TARGET_GENERIC_BIN_SH) $(TARGET_DIR)/bin/sh
endef
endif
TARGET_FINALIZE_HOOKS += SYSTEM_BIN_SH

ifeq ($(BR2_TARGET_GENERIC_GETTY),y)
ifeq ($(BR2_PACKAGE_SYSVINIT),y)
# In sysvinit inittab, the "id" must not be longer than 4 bytes, so we
# skip the "tty" part and keep only the remaining.
define SYSTEM_GETTY
	$(SED) '/# GENERIC_SERIAL$$/s~^.*#~$(shell echo $(TARGET_GENERIC_GETTY_PORT) | tail -c+4)::respawn:/sbin/getty -L $(TARGET_GENERIC_GETTY_OPTIONS) $(TARGET_GENERIC_GETTY_PORT) $(TARGET_GENERIC_GETTY_BAUDRATE) $(TARGET_GENERIC_GETTY_TERM) #~' \
		$(TARGET_DIR)/etc/inittab
endef
else
# Add getty to busybox inittab
define SYSTEM_GETTY
	$(SED) '/# GENERIC_SERIAL$$/s~^.*#~$(TARGET_GENERIC_GETTY_PORT)::respawn:/sbin/getty -L $(TARGET_GENERIC_GETTY_OPTIONS) $(TARGET_GENERIC_GETTY_PORT) $(TARGET_GENERIC_GETTY_BAUDRATE) $(TARGET_GENERIC_GETTY_TERM) #~' \
		$(TARGET_DIR)/etc/inittab
endef
endif
TARGET_FINALIZE_HOOKS += SYSTEM_GETTY
endif

ifeq ($(BR2_TARGET_GENERIC_REMOUNT_ROOTFS_RW),y)
# Find commented line, if any, and remove leading '#'s
define SYSTEM_REMOUNT_RW
	$(SED) '/^#.*-o remount,rw \/$$/s~^#\+~~' $(TARGET_DIR)/etc/inittab
endef
else
# Find uncommented line, if any, and add a leading '#'
define SYSTEM_REMOUNT_RW
	$(SED) '/^[^#].*-o remount,rw \/$$/s~^~#~' $(TARGET_DIR)/etc/inittab
endef
endif
TARGET_FINALIZE_HOOKS += SYSTEM_REMOUNT_RW

endif # BR2_ROOTFS_SKELETON_DEFAULT
