docker pull dockercore/docker:17.05

docker run --rm -i --privileged -e BUILDFLAGS -e KEEPBUNDLE -e DOCKER_BUILD_GOGC -e DOCKER_BUILD_PKGS -e DOCKER_CLIENTONLY -e DOCKER_DEBUG -e DOCKER_EXPERIMENTAL -e DOCKER_GITCOMMIT -e DOCKER_GRAPHDRIVER=devicemapper -e DOCKER_INCREMENTAL_BINARY -e DOCKER_REMAP_ROOT -e DOCKER_STORAGE_OPTS -e DOCKER_USERLANDPROXY -e TESTDIRS -e TESTFLAGS -e TIMEOUT -v "/Users/liuxin/Documents/docker/bundles:/go/src/github.com/docker/docker/bundles" -t "dockercore/docker:17.05" bash


echo "deb-src http://deb.debian.org/debian jessie main" >> /etc/apt/sources.list
apt-get update && apt-get install -y wget btrfs-tools git libncurses-dev bison flex #autotools-dev autoconf m4 perl autopoint
export GOARCH=arm
export CGO_ENABLED=1
export GOOS=linux
export CC=arm-linux-gnueabihf-gcc
export DOCKER_GITCOMMIT=89658be
export HOMEDIR=/go/src/github.com/docker/docker/
export ARM_GNU=${HOMEDIR}/armbuild/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/
export PATH=${PATH}:${ARM_GNU}/bin/

#设置编译文件夹
mkdir -p ${HOMEDIR}/armbuild/
cd ${HOMEDIR}/armbuild/

#下载交叉编译链
git clone https://github.com/raspberrypi/tools.git

#复制库头文件至交叉编译链中
cp -r /usr/include/* ${ARM_GNU}/include/
cp -r /usr/include/x86_64-linux-gnu/bits/ ${ARM_GNU}/include/
cp -r /usr/include/x86_64-linux-gnu/sys/ ${ARM_GNU}/include/

#交叉编译libseccomp-dev
wget https://github.com/seccomp/libseccomp/releases/download/v2.2.3/libseccomp-2.2.3.tar.gz
tar zxvf libseccomp-2.2.3.tar.gz
cd libseccomp-2.2.3
./configure --host=arm-linux
make && make install
ln -s /usr/local/lib/libseccomp.so ${ARM_GNU}/lib/libseccomp.so
cd ${HOMEDIR}/armbuild/

#交叉编译libdevmapper-dev
apt-get source libdevmapper-dev
cd lvm2-2.02.111
patch -p0 < ../lvm2.patch
./configure --host=arm-linux --enable-static_link
make && make install
ln -s /usr/lib/libdevmapper.so ${ARM_GNU}/lib/libapparmor.so
cd ${HOMEDIR}/armbuild/

#交叉编译libapparmor-dev
apt-get source libapparmor-dev
cd apparmor-2.9.0/libraries/libapparmor/
./configure --host=arm-linux 
make && make install
ln -s /usr/local/lib/libapparmor.so ${ARM_GNU}/lib/libapparmor.so
cd ${HOMEDIR}/armbuild/


hack/make.sh binary