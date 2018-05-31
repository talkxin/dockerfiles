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
