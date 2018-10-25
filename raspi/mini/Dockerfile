#用于编译树莓派noobs
FROM ubuntu:18.04

RUN sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
RUN apt-get update && apt-get install -y gcc-arm-linux-gnueabi curl xz-utils u-boot-tools make gcc bc libncurses5-dev bison flex wget vim

ENV LINUXVERSION linux-4.10
ENV BUSYBOXVERSION busybox-1.24.2

WORKDIR /build/

RUN wget https://cdn.kernel.org/pub/linux/kernel/v4.x/${LINUXVERSION}.tar.xz

RUN wget https://busybox.net/downloads/${BUSYBOXVERSION}.tar.bz2

ADD build.sh /build/build.sh
ADD busybox_defconfig.patch /build/busybox_defconfig.patch
ADD linux_versatile.patch /build/linux_versatile.patch

RUN chmod 777 /build/build.sh