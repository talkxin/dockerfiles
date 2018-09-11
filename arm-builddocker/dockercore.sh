#!/bin/bash


#docker pull dockercore/docker:17.05

#docker run --rm -i --privileged -e BUILDFLAGS -e KEEPBUNDLE -e DOCKER_BUILD_GOGC -e DOCKER_BUILD_PKGS -e DOCKER_CLIENTONLY -e DOCKER_DEBUG -e DOCKER_EXPERIMENTAL -e DOCKER_GITCOMMIT -e DOCKER_GRAPHDRIVER=devicemapper -e DOCKER_INCREMENTAL_BINARY -e DOCKER_REMAP_ROOT -e DOCKER_STORAGE_OPTS -e DOCKER_USERLANDPROXY -e TESTDIRS -e TESTFLAGS -e TIMEOUT -v "/Users/liuxin/Documents/docker/bundles:/go/src/github.com/docker/docker/bundles" -t "dockercore/docker:17.05" bash

echo "deb-src http://deb.debian.org/debian jessie main" >> /etc/apt/sources.list
apt-get update && apt-get install -y wget btrfs-tools git libncurses-dev bison flex libc6-dev-i386
export GOARCH=arm
export CGO_ENABLED=1
export GOOS=linux
export CC=arm-linux-gnueabihf-gcc
export DOCKER_GITCOMMIT=89658be
export HOMEDIR=/opt/
export ARM_GNU=${HOMEDIR}/armbuild/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/
export PATH=${PATH}:${ARM_GNU}/bin/

#设置编译文件夹
mkdir -p ${HOMEDIR}/armbuild/
cd ${HOMEDIR}/armbuild/

#下载交叉编译链
git clone https://github.com/raspberrypi/tools.git

#添加交叉编译库头文件及so的位置
#gcc找到头文件的路径
export C_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:${HOMEDIR}/armbuild/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/arm-linux-gnueabihf/include/:${HOMEDIR}/armbuild/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/arm-linux-gnueabihf/sysroot/usr/include/:/usr/include/

#g++找到头文件的路径
export CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:${HOMEDIR}/armbuild/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/arm-linux-gnueabihf/include/:${HOMEDIR}/armbuild/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/arm-linux-gnueabihf/sysroot/usr/include/:/usr/include/

#找到动态链接库的路径
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/lib/:/usr/lib/:/usr/local/lib/

#找到静态库的路径
export LIBRARY_PATH=${LIBRARY_PATH}:/lib/:/usr/lib/:/usr/local/lib/

#交叉编译 libseccomp-dev
wget https://github.com/seccomp/libseccomp/releases/download/v2.2.3/libseccomp-2.2.3.tar.gz
tar zxvf libseccomp-2.2.3.tar.gz
cd libseccomp-2.2.3
./configure --host=arm-linux --prefix=${ARM_GNU}/arm-linux-gnueabihf/
make && make install
cd ${HOMEDIR}/armbuild/

#交叉编译 libdevmapper-dev
apt-get source libdevmapper-dev
cd lvm2-2.02.111
patch -p0 < ${HOMEDIR}/armbuild/lvm2.patch
./configure --host=arm-linux --enable-static_link --prefix=${ARM_GNU}/arm-linux-gnueabihf/
make && make install
cd ${HOMEDIR}/armbuild/

#交叉编译 libapparmor-dev
apt-get source libapparmor-dev
cd apparmor-2.9.0/libraries/libapparmor/
./configure --host=arm-linux --prefix=${ARM_GNU}/arm-linux-gnueabihf/
make && make install
cd ${HOMEDIR}/armbuild/