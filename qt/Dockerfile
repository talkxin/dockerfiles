FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    libtool \
    g++ \
    git \
    wget \
    python \
    make \
    xz-utils

ADD build_qt_arm.sh /opt/qt5/build_qt_arm.sh

#clone项目
WORKDIR /opt/qt5/

RUN chmod +x build_qt_arm.sh && ./build_qt_arm.sh
