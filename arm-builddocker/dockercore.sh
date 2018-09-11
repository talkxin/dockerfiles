#!/bin/bash


#docker pull dockercore/docker:17.05

#docker run --rm -i --privileged -e BUILDFLAGS -e KEEPBUNDLE -e DOCKER_BUILD_GOGC -e DOCKER_BUILD_PKGS -e DOCKER_CLIENTONLY -e DOCKER_DEBUG -e DOCKER_EXPERIMENTAL -e DOCKER_GITCOMMIT -e DOCKER_GRAPHDRIVER=devicemapper -e DOCKER_INCREMENTAL_BINARY -e DOCKER_REMAP_ROOT -e DOCKER_STORAGE_OPTS -e DOCKER_USERLANDPROXY -e TESTDIRS -e TESTFLAGS -e TIMEOUT -v "/Users/liuxin/Documents/docker/bundles:/go/src/github.com/docker/docker/bundles" -t "dockercore/docker:17.05" bash

echo "deb-src http://deb.debian.org/debian jessie main" >> /etc/apt/sources.list
apt-get update && apt-get install -y wget btrfs-tools git libncurses-dev bison flex libc6-dev-i386
echo "GOARCH=arm" >> /etc/profile
echo "CGO_ENABLED=1" >> /etc/profile
echo "GOOS=linux" >> /etc/profile
echo "CC=arm-linux-gnueabihf-gcc" >> /etc/profile
echo "DOCKER_GITCOMMIT=89658be" >> /etc/profile
echo "HOMEDIR=/opt/" >> /etc/profile
echo "ARM_GNU=${HOMEDIR}/armbuild/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/" >> /etc/profile
echo "PATH=${PATH}:${ARM_GNU}/bin/" >> /etc/profile
#添加交叉编译库头文件及so的位置

#gcc找到头文件的路径
echo "export C_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:${HOMEDIR}/armbuild/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/arm-linux-gnueabihf/include/:${HOMEDIR}/armbuild/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/arm-linux-gnueabihf/sysroot/usr/include/:/usr/include/" >> /etc/profile

#g++找到头文件的路径
echo "export CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:${HOMEDIR}/armbuild/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/arm-linux-gnueabihf/include/:${HOMEDIR}/armbuild/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/arm-linux-gnueabihf/sysroot/usr/include/:/usr/include/" >> /etc/profile

#找到动态链接库的路径
echo "export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/lib/:/usr/lib/:/usr/local/lib/" >> /etc/profile

#找到静态库的路径
echo "export LIBRARY_PATH=${LIBRARY_PATH}:/lib/:/usr/lib/:/usr/local/lib/" >> /etc/profile

#使配置文件生效
source /etc/profile

#设置编译文件夹
mkdir -p ${HOMEDIR}/armbuild/
cd ${HOMEDIR}/armbuild/

#下载交叉编译链
git clone https://github.com/raspberrypi/tools.git

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

# hack/make.sh binary