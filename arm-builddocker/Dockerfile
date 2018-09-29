FROM dockercore/docker:17.05

LABEL maintainer "talkxin <talkxin@gmail.com>"

ADD dockercore-arm.sh /opt/armbuild/dockercore-arm.sh

ADD lvm2.patch /opt/armbuild/lvm2.patch

ADD make.sh.patch /opt/armbuild/make.sh.patch

RUN ln -fs /bin/bash /bin/sh

RUN chmod 777 /opt/armbuild/dockercore-arm.sh && /opt/armbuild/dockercore-arm.sh

CMD source ~/.profile && /bin/bash

