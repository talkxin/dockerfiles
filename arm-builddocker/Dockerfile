FROM dockercore/docker:17.05

LABEL maintainer "talkxin <talkxin@gmail.com>"

ENV HOMEDIR=/opt/
ENV ARM_GNU=${HOMEDIR}/armbuild/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/
ENV GOARCH=arm
ENV CGO_ENABLED=1
ENV GOOS=linux
ENV CC=arm-linux-gnueabihf-gcc
ENV DOCKER_GITCOMMIT=89658be
ENV PATH=${PATH}:${ARM_GNU}/bin/
ENV C_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:${HOMEDIR}/armbuild/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/arm-linux-gnueabihf/include/:${HOMEDIR}/armbuild/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/arm-linux-gnueabihf/sysroot/usr/include/:/usr/include/
ENV CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:${HOMEDIR}/armbuild/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/arm-linux-gnueabihf/include/:${HOMEDIR}/armbuild/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/arm-linux-gnueabihf/sysroot/usr/include/:/usr/include/
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/lib/:/usr/lib/:/usr/local/lib/
ENV LIBRARY_PATH=${LIBRARY_PATH}:/lib/:/usr/lib/:/usr/local/lib/

ADD dockercore.sh /opt/armbuild/dockercore.sh

ADD lvm2.patch /opt/armbuild/lvm2.patch

RUN ln -fs /bin/bash /bin/sh

RUN chmod 777 /opt/armbuild/dockercore.sh && /opt/armbuild/dockercore.sh

