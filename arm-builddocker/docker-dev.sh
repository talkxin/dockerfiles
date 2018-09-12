# docker pull docker-dev:1.9.1

# docker run --rm -it --privileged \
#   -e BUILDFLAGS -e DOCKER_CLIENTONLY -e DOCKER_EXECDRIVER -e DOCKER_EXPERIMENTAL \
#   -e DOCKER_GRAPHDRIVER -e DOCKER_STORAGE_OPTS -e DOCKER_USERLANDPROXY -e TESTDIRS -e TESTFLAGS -e TIMEOUT \
#   -v /Users/liuxin/Documents/docker/bundles:/go/src/github.com/docker/docker/bundles docker-dev:1.9.1 bash


apt-get update && apt-get -y install gcc-arm-linux-gnueabi bison flex wget
export GOARCH=arm
export CGO_ENABLED=1
export GOOS=linux
export CC=arm-linux-gnueabi-gcc

HOMEDIR=/go/src/github.com/docker/docker/

#设置编译文件夹
mkdir -p ${HOMEDIR}/armbuild/
cd ${HOMEDIR}/armbuild/

#安装1.15版automake
wget http://ftp.gnu.org/gnu/automake/automake-1.15.tar.xz
tar xvf automake-1.15.tar.xz
cd automake-1.15
./configure
make && make install
cd ${HOMEDIR}/armbuild/

#交叉编译libapparmor-dev
apt-get source libapparmor-dev
cd apparmor-2.10.95/libraries/libapparmor/
./configure --host=arm-linux 
make && make install
cd ${HOMEDIR}/armbuild/

#交叉编译libdevmapper-dev
apt-get source libdevmapper-dev
cd lvm2-2.02.98/
sed -i '/^#undef malloc/d' lib/misc/configure.h.in
sed -i '/^#undef realloc/d' lib/misc/configure.h.in
./configure --host=arm-linux --enable-static_link
make && make install
cd ${HOMEDIR}/armbuild/

# hack/make.sh binary