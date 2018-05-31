FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
	dirmngr \
	gnupg \
	ca-certificates \
	hicolor-icon-theme \
	libasound2 \
	libgl1-mesa-dri \
	libgl1-mesa-glx \
  qemu

ENTRYPOINT [ "/usr/bin/qemu-system-arm" ]


#run -d --name qemu -e  DISPLAY=$ip:0 \
#-v /tmp/.X11-unix:/tmp/.X11-unix \
#-v ~/Documents/qemu/qemu/:/home/qemu \
#talkliu/raspi:qemu-v2 \
#-kernel /home/qemu/kernel-qemu-4.9.59-stretch \
#-cpu arm1176 \
#-m 256 \
#-M versatilepb \
#-dtb /home/qemu/versatile-pb.dtb \
#-no-reboot \
#-append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" \
#-net nic -net user,hostfwd=tcp::5022-:22 \
#-hda /home/qemu/2017-11-29-raspbian-stretch.img
