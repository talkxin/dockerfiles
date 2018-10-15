#!/bin/sh

apt-get install debootstrap
debootstrap --arch=armel --foreign stretch fs_debian_stretch https://mirrors.cloud.tencent.com/debian
sudo DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C LANGUAGE=C LANG=C chroot fs_debian_stretch debootstrap/debootstrap --second-stage
