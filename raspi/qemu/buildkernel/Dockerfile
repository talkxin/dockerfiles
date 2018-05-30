FROM ubuntu:18.04

RUN apt-get update;apt-get install -y \
    sudo \
    git \
    libncurses5-dev \
    gcc-arm-linux-gnueabihf

WORKDIR /home/
RUN git clone https://github.com/talkxin/qemu-rpi-kernel.git
ENTRYPOINT ["/home/qemu-rpi-kernel/build-kernel-qemu"]
