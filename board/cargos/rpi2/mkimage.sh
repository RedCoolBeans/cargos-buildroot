#!/bin/sh
#
# SD card image builder for rpi-buildroot
#
# Guillermo A. Amaral B. <g@maral.me>
# Adjusted to use kpartx instead of losetup which lacks -P (when < 2.22)
#

# sanaty check
USERID=`id -u`
if [ ${USERID} -ne 0 ]; then
	echo "${0} requires root privileges in order to work."
	exit 0
fi

section() {
	echo "*****************************************************************************************"
	echo "> ${*}"
	echo "*****************************************************************************************"
	sleep 1
}

# overrides
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
IMAGE="sdcard.img"
OUTPUT_PREFIX=""

if [ -z "${SIZE}" ]; then
    SIZE="256M"
fi

echo "Creating ${SIZE} size image..."
sleep 3

# dependencies
CP=`which cp`
DD=`which dd`
FDISK=`which fdisk`
KPARTX=`which kpartx`
LOSETUP=`which losetup`
MKDIR=`which mkdir`
MKFS_EXT4=`which mkfs.ext4`
MKFS_VFAT=`which mkfs.vfat`
MOUNT=`which mount`
RMDIR=`which rmdir`
SYNC=`which sync`
TAR=`which tar`
UMOUNT=`which umount`

if [ -z "${CP}" ] ||
   [ -z "${DD}" ] ||
   [ -z "${FDISK}" ] ||
   [ -z "${KPARTX}" ] ||
   [ -z "${LOSETUP}" ] ||
   [ -z "${MKDIR}" ] ||
   [ -z "${MKFS_EXT4}" ] ||
   [ -z "${MKFS_VFAT}" ] ||
   [ -z "${MOUNT}" ] ||
   [ -z "${RMDIR}" ] ||
   [ -z "${SYNC}" ] ||
   [ -z "${TAR}" ] ||
   [ -z "${UMOUNT}" ]; then
	echo "Missing dependencies:\n"
	echo "CP=${CP}"
	echo "DD=${DD}"
	echo "KPARTX=${KPARTX}"
	echo "FDISK=${FDISK}"
	echo "LOSETUP=${LOSETUP}"
	echo "MKDIR=${MKDIR}"
	echo "MKFS_EXT4=${MKFS_EXT4}"
	echo "MKFS_VFAT=${MKFS_VFAT}"
	echo "MOUNT=${MOUNT}"
	echo "RMDIR=${RMDIR}"
	echo "SYNC=${SYNC}"
	echo "TAR=${TAR}"
	echo "UMOUNT=${UMOUNT}"
	exit 1
fi

# sanity check
if [ ! -f "images/rootfs.tar" ]; then
	if [ -f "output/images/rootfs.tar" ]; then
		OUTPUT_PREFIX="output/"
	else
		echo "Didn't find boot and/or rootfs.tar! ABORT."
		exit 1
	fi
fi

# find loop device (adjust for usage with kpartx)
LOOP=`${LOSETUP} -f | sed 's,/dev,/dev/mapper,'`

# create image
${DD} if=/dev/zero of=${IMAGE} bs=${SIZE} count=1

# partition image
${FDISK} ${IMAGE} <<END
o
n
p
1

+32M
n
p
2


t
1
e
a
1
w
END

# loop image
kpartx -as ${IMAGE} || exit 1

# format partitions

section "Formatting partitions..."

${MKFS_VFAT} -F 16 -n BOOT -I "${LOOP}p1" || exit 1
${MKFS_EXT4} -F -q -L rootfs "${LOOP}p2" || exit 1

${MKDIR} .mnt

# fill boot

section "Populating boot partition..."

${MOUNT} "${LOOP}p1" .mnt || exit 2
${CP} -r ${OUTPUT_PREFIX}images/rpi-firmware/overlays .mnt
${CP} ${OUTPUT_PREFIX}images/rpi-firmware/*.dtb .mnt
${CP} ${OUTPUT_PREFIX}images/rpi-firmware/bootcode.bin .mnt
${CP} ${OUTPUT_PREFIX}images/rpi-firmware/fixup.dat .mnt
${CP} ${OUTPUT_PREFIX}images/rpi-firmware/start.elf .mnt
${CP} ${OUTPUT_PREFIX}images/zImage .mnt/kernel.img
${SYNC}
${UMOUNT} .mnt

# fill rootfs

section "Populating rootfs partition..."

${MOUNT} "${LOOP}p2" .mnt || exit 2
${TAR} -xpsf ${OUTPUT_PREFIX}images/rootfs.tar -C .mnt
${SYNC}
${UMOUNT} .mnt

${RMDIR} .mnt

# unmount
kpartx -d ${IMAGE}

section "Finished!"

exit 0
