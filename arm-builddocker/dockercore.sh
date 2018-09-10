# docker pull dockercore/docker:17.05

# docker run --rm -i --privileged \
#  -e BUILDFLAGS -e KEEPBUNDLE -e DOCKER_BUILD_GOGC -e DOCKER_BUILD_PKGS -e DOCKER_CLIENTONLY -e DOCKER_DEBUG -e DOCKER_EXPERIMENTAL -e DOCKER_GITCOMMIT \
#  -e DOCKER_GRAPHDRIVER=devicemapper -e DOCKER_INCREMENTAL_BINARY -e DOCKER_REMAP_ROOT -e DOCKER_STORAGE_OPTS -e DOCKER_USERLANDPROXY -e TESTDIRS -e TESTFLAGS -e TIMEOUT \
#  -v "/Users/liuxin/Documents/docker/bundles:/go/src/github.com/docker/docker/bundles" -t "dockercore/docker:17.05" bash


apt-get update && apt-get install -y bison flex wget git
export GOARCH=arm
export CGO_ENABLED=1
export GOOS=linux
export DOCKER_GITCOMMIT=89658be #docker:17.05-ce

export HOMEDIR=/go/src/github.com/docker/docker/

#设置编译文件夹
mkdir -p ${HOMEDIR}/armbuild/
cd ${HOMEDIR}/armbuild/

#下载交叉编译链
git clone https://github.com/raspberrypi/tools.git
export CC=${HOMEDIR}/armbuild/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/bin/arm-linux-gnueabihf-gcc
