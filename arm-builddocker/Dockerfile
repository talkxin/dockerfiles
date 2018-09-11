FROM dockercore/docker:17.05

LABEL maintainer "talkxin <talkxin@gmail.com>"

WORKDIR /opt/armbuild/

ADD dockercore.sh /opt/armbuild/dockercore.sh

ADD lvm2.patch /opt/armbuild/lvm2.patch

RUN chmod 777 /opt/dockercore.sh && /opt/armbuild/dockercore.sh