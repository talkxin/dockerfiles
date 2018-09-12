FROM dockercore/docker:17.05

LABEL maintainer "talkxin <talkxin@gmail.com>"

WORKDIR /opt/armbuild/

ADD dockercore.sh /opt/armbuild/dockercore.sh

ADD lvm2.patch /opt/armbuild/lvm2.patch

#将默认的dash改为bash 提示选择no
RUN dpkg-reconfigure dash

RUN chmod 777 /opt/dockercore.sh && /opt/armbuild/dockercore.sh