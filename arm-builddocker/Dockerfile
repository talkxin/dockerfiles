FROM dockercore/docker:17.05

LABEL maintainer "talkxin <talkxin@gmail.com>"

ADD dockercore.sh /opt/armbuild/dockercore.sh

ADD lvm2.patch /opt/armbuild/lvm2.patch

RUN ln -fs /bin/bash /bin/sh

RUN chmod 777 /opt/armbuild/dockercore.sh && /opt/armbuild/dockercore.sh

CMD source ~/.profile && /bin/bash

