#!/bin/bash -e

#install build tools
apt-get install -y gcc-arm-linux-gnueabi curl xz-utils u-boot-tools make gcc bc libncurses5-dev bison flex patch unzip

TOOLS=arm-linux-gnueabi
LINUXVERSION=linux-4.10
BUSYBOXVERSION=busybox-1.24.2
LIBSDIR=/usr/${TOOLS}/lib/
DEFCONFIG=$1
IMAGECOUNT=$2
SKIP_KERNEL_REBUILD=0
OUTPUTDIR="output/"

if [ ! $DEFCONFIG ] 
then
	echo "build.sh error:unknow linux build deconfig"
	echo "default use whith versatile_defconfig build linux"
	DEFCONFIG="versatile_defconfig"
	# exit 1
fi

if [ ! $IMAGECOUNT ] 
then
	IMAGECOUNT=32
fi


rm -rf ${LINUXVERSION}
rm -rf ${BUSYBOXVERSION}
rm -rf tmpfs
rm -rf zImage
rm -rf *.dtb
rm -rf rootfs*
rm -rf ramdisk.*

#创建输出文件
mkdir -p $OUTPUTDIR

# tar xvf linux-4.10.tar.xz
# tar xvf busybox-1.24.2.tar.bz2

for i in $*; do
    if [ $i = "skip-kernel-rebuild" ]; then
        SKIP_KERNEL_REBUILD=1
    fi
done

if [ $SKIP_KERNEL_REBUILD -ne 1 ]; then
	# build linux

	# Kernel Features  --->
	#     Memory split (3G/1G user/kernel split)  --->
	#     [*] High Memory Support
	# Device Drivers  --->
	#     [*] Block devices  --->
	#         <*>   RAM block device support
	#         (32768)  Default RAM disk size (kbytes)
	# System Type  --->
	#     [ ] Enable the L2x0 outer cache controller

	# curl https://cdn.kernel.org/pub/linux/kernel/v4.x/${LINUXVERSION}.tar.xz | tar xJf -
	tar xf ${LINUXVERSION}.tar.xz

	cd ${LINUXVERSION}

	#versatile_defconfig
	#vexpress_defconfig
	make CROSS_COMPILE=${TOOLS}- ARCH=arm $DEFCONFIG
	if [ "$DEFCONFIG"x = "versatile_defconfig"x ] ; then 
		patch -p0 < ../linux_versatile.patch
	else
		patch -p0 < ../linux_vexpress.patch
	fi
	make CROSS_COMPILE=${TOOLS}- ARCH=arm menuconfig
	make CROSS_COMPILE=${TOOLS}- ARCH=arm zImage dtbs -j4

	cp -f arch/arm/boot/zImage ../${OUTPUTDIR}

	if [[ "$(echo $DEFCONFIG | grep "vexpress")" != "" ]]
	then
	  cp -f arch/arm/boot/dts/vexpress-v2p-ca9.dtb ../${OUTPUTDIR}
	else
	  cp -f arch/arm/boot/dts/versatile-pb.dtb ../${OUTPUTDIR}
	fi

	cd ..
fi

#build busybox

# Busybox Settings  --->
# 	Build Options  ---> 
#     	[*] Build BusyBox as a static binary (no shared libs)

# curl https://busybox.net/downloads/${BUSYBOXVERSION}.tar.bz2 | tar xjf -
tar xf ${BUSYBOXVERSION}.tar.bz2


cd ${BUSYBOXVERSION}

make defconfig
patch -p0 < ../busybox_defconfig.patch
make CROSS_COMPILE=${TOOLS}- ARCH=arm menuconfig
make CROSS_COMPILE=${TOOLS}- ARCH=arm
make CROSS_COMPILE=${TOOLS}- ARCH=arm install

cd ..

#rootfs

unzip 17.05.0-ce-rc1.zip
mkdir -p rootfs/{dev,etc/init.d,lib}

cp ${BUSYBOXVERSION}/_install/* -r rootfs/
cp -P ${LIBSDIR}/* rootfs/lib/
cp ${BUSYBOXVERSION}/examples/bootfloppy/etc/* -r rootfs/etc/

mknod rootfs/dev/tty1 c 4 1
mknod rootfs/dev/tty2 c 4 2
mknod rootfs/dev/tty3 c 4 3
mknod rootfs/dev/tty4 c 4 4
mknod rootfs/dev/console c 5 1
mknod rootfs/dev/null c 1 3

dd if=/dev/zero of=rootfs.ext2 bs=1M count=${IMAGECOUNT}

mkfs.ext2 rootfs.ext2

mkdir -p tmpfs
mount -t ext2 rootfs.ext2 tmpfs/ -o loop
cp -r rootfs/*  tmpfs/
cp 17.05.0-ce-rc1/docker* tmpfs/usr/bin/
umount tmpfs
gzip --best -c rootfs.ext2 > ramdisk.gz
mkimage -n "ramdisk" -A arm -O linux -T ramdisk -C gzip -d ramdisk.gz ramdisk.img
if [ "$DEFCONFIG"x = "versatile_defconfig"x ] ; then 
	cp -r ramdisk.img $OUTPUTDIR
else
	cp -r rootfs.ext2 $OUTPUTDIR
fi

#control +a x 
# qemu-system-arm -M vexpress-a9 \
# -m 512M \
# -kernel zImage \
# -dtb vexpress-v2p-ca9.dtb \
# -nographic \
# -append "root=/dev/mmcblk0  console=ttyAMA0" \
# -sd rootfs.ext2

# qemu-system-arm -M versatilepb \
# -m 256 \
# -kernel zImage \
# -dtb versatile-pb.dtb \
# -append "rw earlyprintk loglevel=8 console=ttyAMA0,115200 dwc_otg.lpm_enable=0 rootfstype=ext2 root=/dev/ram init=/linuxrc ramdisk_size=32768" \
# -serial stdio \
# -initrd ramdisk.img \
# -cpu arm1176 #raspi add this



