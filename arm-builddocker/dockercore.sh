#!/bin/sh


#docker pull dockercore/docker:17.05

#docker build -t talkliu/docker-arm:17.05 .

#docker run --rm -i --privileged -e BUILDFLAGS -e KEEPBUNDLE -e DOCKER_BUILD_GOGC -e DOCKER_BUILD_PKGS -e DOCKER_CLIENTONLY -e DOCKER_DEBUG -e DOCKER_EXPERIMENTAL -e DOCKER_GITCOMMIT -e DOCKER_GRAPHDRIVER=devicemapper -e DOCKER_INCREMENTAL_BINARY -e DOCKER_REMAP_ROOT -e DOCKER_STORAGE_OPTS -e DOCKER_USERLANDPROXY -e TESTDIRS -e TESTFLAGS -e TIMEOUT -v "/Users/liuxin/Documents/docker/bundles:/go/src/github.com/docker/docker/bundles" -t "talkliu/docker-arm:17.05"

# hack/make.sh binary
# hack/make.sh dynbinary

# 支持依赖安装 gcc-arm-linux-gnueabihf
# echo "deb http://ftp.de.debian.org/debian sid main" >> /etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian jessie main" >> /etc/apt/sources.list
apt-get update 
apt-get install -y wget \
                    btrfs-tools \
                    git \
                    libncurses-dev \
                    bison \
                    flex \
                    libc6-dev-i386 \
                    gperf \
                    gettext \
                    libglib2.0-dev \
                    libxml-tokeparser-perl \
                    libffi-dev \
                    libgio2.0-cil-dev
HOMEDIR=/opt/
ARM_GNU=${HOMEDIR}/armbuild/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/
PREFIXDIR=${HOMEDIR}/armbuild/libs/
DOCKERFILEDIR=/go/src/github.com/
cat >> ~/.profile << EOF
export CCHOST=arm-linux-gnueabihf
export GOARCH=arm
export CGO_ENABLED=1
export GOOS=linux
export CC=arm-linux-gnueabihf-gcc
export DOCKER_GITCOMMIT=89658be
export PATH=${PATH}:${ARM_GNU}/bin/:/usr/bin/:${PREFIXDIR}/bin/:${PREFIXDIR}/share/locale/
export HOMEDIR=/opt/
export ARM_GNU=${HOMEDIR}/armbuild/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/
export PREFIXDIR=${HOMEDIR}/armbuild/libs/
export DOCKERFILEDIR=/go/src/github.com/

#添加交叉编译库头文件及so的位置

export C_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:${ARM_GNU}/arm-linux-gnueabihf/include/:${ARM_GNU}/arm-linux-gnueabihf/sysroot/usr/include/:/usr/include/:${PREFIXDIR}/include/

export CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:${ARM_GNU}/arm-linux-gnueabihf/include/:${ARM_GNU}/arm-linux-gnueabihf/sysroot/usr/include/:/usr/include/:${PREFIXDIR}/include/

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/lib/:/usr/lib/:/usr/local/lib/:${ARM_GNU}/arm-linux-gnueabihf/sysroot/lib/:${PREFIXDIR}/lib/

export LIBRARY_PATH=${LIBRARY_PATH}:/lib/:/usr/lib/:/usr/local/lib/:${ARM_GNU}/arm-linux-gnueabihf/sysroot/lib/:${PREFIXDIR}/lib/

EOF

#使配置文件生效
source  ~/.profile 

#设置编译文件夹
mkdir -p ${HOMEDIR}/armbuild/
cd ${HOMEDIR}/armbuild/

#下载交叉编译链
git clone git://github.com/raspberrypi/tools.git

#交叉编译 libseccomp-dev
cd ${HOMEDIR}/armbuild/
wget https://github.com/seccomp/libseccomp/releases/download/v2.3.3/libseccomp-2.3.3.tar.gz
tar zxvf libseccomp-2.3.3.tar.gz
cd libseccomp-2.3.3
./configure --host=${CCHOST} --prefix=${PREFIXDIR}
make && make install

#交叉编译 libdevmapper-dev
cd ${HOMEDIR}/armbuild/
apt-get source libdevmapper-dev
cd lvm2-2.02.111
patch -p0 < ${HOMEDIR}/armbuild/lvm2.patch
./configure --host=${CCHOST} --prefix=${PREFIXDIR} --enable-static_link 
make && make install

#交叉编译 libapparmor-dev
cd ${HOMEDIR}/armbuild/
apt-get source libapparmor-dev
cd apparmor-2.9.0/libraries/libapparmor/
./configure --host=${CCHOST} --prefix=${PREFIXDIR}
make && make install

#交叉编译 libltdl-dev
cd ${HOMEDIR}/armbuild/
apt-get source libltdl-dev
cd libtool-2.4.2/
./configure --host=${CCHOST} --prefix=${PREFIXDIR}
make && make install

#交叉编译 libattr1-dev
cd ${HOMEDIR}/armbuild/
apt-get source libattr1-dev
cd attr-2.4.47/
./configure --host=${CCHOST} --prefix=${PREFIXDIR}
make && make install install-dev install-lib

#交叉编译 libcap-dev 关联libattr1
cd ${HOMEDIR}/armbuild/
apt-get source libcap-dev
cd libcap2-2.24/
sed -i 's/BUILD_CC := $(CC)/BUILD_CC := gcc/g' Make.Rules
C_INCLUDE_PATH=/usr/include/ LDFLAGS="-L${HOMEDIR}/armbuild/libs/lib/ -lattr" make
make RAISE_SETFCAP=no prefix=${PREFIXDIR} install

#交叉编译 intltool
cd ${HOMEDIR}/armbuild/
wget http://ftp.gnome.org/pub/gnome/sources/intltool/0.40/intltool-0.40.0.tar.gz
tar zxvf intltool-0.40.0.tar.gz
cd intltool-0.40.0
./configure --host=${CCHOST} --prefix=${PREFIXDIR}
make && make install

#交叉编译 libtinfo-dev
cd ${HOMEDIR}/armbuild/
apt-get source libtinfo-dev
cd ncurses-5.9+20140913/
./configure --host=${CCHOST} --prefix=${PREFIXDIR} --without-cxx --without-cxx-binding --without-ada --without-manpages --without-progs --without-tests --with-shared
make C_INCLUDE_PATH=${ARM_GNU}/arm-linux-gnueabihf/sysroot/usr/include/gnu/
make install
ln -s ${PREFIXDIR}/lib/libncurses.so.5 ${PREFIXDIR}/lib/libtinfo.so.5
ln -s ${PREFIXDIR}/lib/libtinfo.so.5 ${PREFIXDIR}/lib/libtinfo.so
make clean
./configure --host=${CCHOST} --prefix=${PREFIXDIR} --without-cxx --without-cxx-binding --without-ada --without-manpages --without-progs --without-tests --with-shared --enable-widec
make C_INCLUDE_PATH=${ARM_GNU}/arm-linux-gnueabihf/sysroot/usr/include/gnu/
make install

#交叉编译 util-linux 关联 libtinfo-dev
cd ${HOMEDIR}/armbuild/
wget https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.32/util-linux-2.32.tar.gz
tar zxvf util-linux-2.32.tar.gz
cd util-linux-2.32/
./configure --host=${CCHOST} --prefix=${PREFIXDIR} --without-systemd --without-python
make LDFLAGS="-L${PREFIXDIR}/lib -ltinfo" && make install

#交叉编译expat
cd ${HOMEDIR}/armbuild/
apt-get source expat
cd expat-2.1.0
./configure --host=${CCHOST} --prefix=${PREFIXDIR}
make && make install

#交叉编译dbus
cd ${HOMEDIR}/armbuild/
apt-get source libdbus-1-dev
cd dbus-1.8.22/
./configure LDFLAGS="-L${PREFIXDIR}/lib -lexpat" --host=${CCHOST} --prefix=${PREFIXDIR} --disable-systemd --enable-tests=no
make && make install

#交叉编译 ffi
cd ${HOMEDIR}/armbuild/
apt-get source libffi-dev
cd libffi-3.1/
./configure --host=${CCHOST} --prefix=${PREFIXDIR}
make && make install

#交叉编译 zlib
cd ${HOMEDIR}/armbuild/
apt-get source zlib
cd zlib-1.2.8.dfsg/
./configure --prefix=${PREFIXDIR}
make && make install

#交叉编译 glib-2.0
apt-get source libglib2.0-dev
cd glib2.0-2.42.1/
echo ac_cv_type_long_long=yes>arm-linux.cache
echo glib_cv_stack_grows=no>>arm-linux.cache
echo glib_cv_uscore=no>>arm-linux.cache
echo ac_cv_func_posix_getpwuid_r=yes>>arm-linux.cache
echo ac_cv_func_posix_getgrgid_r=yes>>arm-linux.cache
./configure \
LDFLAGS="-L${ARM_GNU}/arm-linux-gnueabihf/sysroot/usr/lib/ -L${PREFIXDIR}/lib -ldl" \
CFLAGS="-I${PREFIXDIR}/include/ -I${ARM_GNU}/arm-linux-gnueabihf/include/" \
--host=${CCHOST} --prefix=${PREFIXDIR} --enable-static=yes --cache-file=./arm-linux.cache 
make
make install
cd ${HOMEDIR}/armbuild/

#交叉编译 libsystemd-dev 关联 【intltool 需要 4.0以上、libattr1、util-linux、libcap】
wget http://www.freedesktop.org/software/systemd/systemd-219.tar.xz
tar xvf systemd-219.tar.xz
cd systemd-219
./configure \
PKG_CONFIG_LIBDIR="${PREFIXDIR}/lib/pkgconfig" \
LDFLAGS="-L${PREFIXDIR}/lib/ -L${PREFIXDIR}/lib64/ -lattr -lcap" \
CFLAGS="-I${PREFIXDIR}/include/" \
--host=${CCHOST} \
--prefix=${PREFIXDIR}
sed -i 's/#define malloc rpl_malloc/#define rpl_malloc=malloc/g' config.h
make && make install
cd ${HOMEDIR}/armbuild/

#安装最新golang【安装最新版 docker-containerd 时需要最少go-1.8以上支持 当前版本不需要安装】
# wget https://dl.google.com/go/go1.11.linux-amd64.tar.gz
# tar zxvf go1.11.linux-amd64.tar.gz
# rm -rf /usr/local/go/
# mv go/ /usr/local/go/
# cd ${HOMEDIR}/armbuild/

#调整lib路径，使ld引入
mkdir -p ${ARM_GNU}/arm-linux-gnueabihf/sysroot/usr/local/
cp -r ${PREFIXDIR}/lib64/* ${PREFIXDIR}/lib/
ln -s ${PREFIXDIR}/lib/ ${ARM_GNU}arm-linux-gnueabihf/sysroot/usr/local/
rm -rf /usr/local/lib/libseccomp*
cp ${PREFIXDIR}/lib/libseccomp* /usr/local/lib/

#编译docker运行可执行文件
#【 docker-containerd docker-containerd-ctr docker-containerd-shim docker-runc docker-init docker-proxy 】

#编译 docker-containerd 【关联 protobuf 】
cd ${DOCKERFILEDIR}
git clone git://github.com/docker/containerd.git
mv containerd/ docker/containerd/
cd ${DOCKERFILEDIR}/docker/containerd
git checkout v0.2.3
make
make install
rm -rf /usr/local/bin/docker-containerd*
mv /usr/local/bin/containerd /usr/local/bin/docker-containerd
mv /usr/local/bin/ctr /usr/local/bin/docker-containerd-ctr
mv /usr/local/bin/containerd-shim /usr/local/bin/docker-containerd-shim

#编译 docker-runc 【需要 libseccomp-2.3.3 支持】
cd ${DOCKERFILEDIR}
go get github.com/opencontainers/runc
cd ${DOCKERFILEDIR}/opencontainers/runc
git checkout v1.0.0-rc2
make
make install
rm /usr/local/bin/docker-runc
cp /usr/local/sbin/runc /usr/local/bin/docker-runc

#编译 docker-init
cd ${DOCKERFILEDIR}
git clone git://github.com/krallin/tini.git
cd tini
git checkout v0.13.0
cmake .
make && make install
ln -s ${ARM_GNU}/arm-linux-gnueabihf/sysroot/lib/ld-linux-armhf.so.3 /lib/ld-linux-armhf.so.3
rm /usr/local/bin/docker-init
mv /usr/local/bin/tini /usr/local/bin/docker-init

#编译 docker-proxy
cd ${DOCKERFILEDIR}
git clone git://github.com/docker/libnetwork.git
cd libnetwork/libnetwork/cmd/proxy/
go build -ldflags="$PROXY_LDFLAGS" -o /usr/local/bin/docker-proxy