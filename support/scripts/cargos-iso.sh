CD=`pwd`/output/images

_version=`cat ${CD}/../target/etc/cargos-release`

rm -rf release/${_version}

for _rel in "" -noinst; do
	[ -z ${_rel} ] && _cloud="-cloud" || _cloud=""
	for _c in "" ${_cloud}; do
		_tmp=`mktemp -d -p .`
		rsync -qv ${CD}/bzImage ${_tmp}/
		rsync -qv ${CD}/rootfs.squashfs${_rel} ${_tmp}/

		mkdir -p ${_tmp}/boot/grub

		cat > ${_tmp}/boot/grub/grub.cfg << EOF
set menu_color_normal=cyan/blue
set menu_color_highlight=white/blue
set timeout=10

menuentry 'CargOS-${_version}' {
    set background_color=black
    linux    /bzImage root=/dev/ram0 ramdisk_size=131072 quiet ${_c##-}
    initrd   /rootfs.squashfs${_rel}
}
menuentry 'CargOS-${_version} with serial console on ttyS0' {
    set background_color=black
    linux    /bzImage console=ttyS0 root=/dev/ram0 ramdisk_size=131072 quiet ${_c##-}
    initrd   /rootfs.squashfs${_rel}
}
EOF

		GMR=`which grub-mkrescue 2>/dev/null`; test -n "${GMR}" || GMR=`which grub2-mkrescue 2>/dev/null`
		${GMR} -o cargos${_rel}${_c}-${_version}.iso ${_tmp}
		qemu-img convert -O qcow2 cargos${_rel}${_c}-${_version}.iso cargos${_rel}${_c}-${_version}.qcow2

		rm -rf ${_tmp}/* && rmdir ${_tmp}

		mkdir -p release/${_version}/iso release/${_version}/qcow2
		mv cargos${_rel}${_c}-${_version}.iso release/${_version}/iso
		mv cargos${_rel}${_c}-${_version}.qcow2 release/${_version}/qcow2

		(cd release/${_version}/iso && ln -sf cargos${_rel}${_c}-${_version}.iso cargos${_rel}${_c}.iso)

		rsync -qv ${CD}/bzImage release/${_version}/bzImage-${_version}
		rsync -qv ${CD}/rootfs.squashfs${_rel} release/${_version}/rootfs.squashfs${_rel}-${_version}
	done
done

(cd release/${_version} && 
	find -type f -exec sha256sum {} \; | sed "s,\./,,g" > /tmp/SHA256 && \
	mv /tmp/SHA256 .
)
