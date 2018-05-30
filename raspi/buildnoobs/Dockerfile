#用于编译树莓派noobs
FROM ubuntu:18.04
RUN apt-get update
#安装基础软件
RUN apt-get install -y git zip
#noobs必要关联软件
RUN apt-get install -y make gcc g++ cpio python bc rsync qt4-linguist-tools texinfo
#清理镜像
RUN apt-get clean
#clone项目
WORKDIR /home/
RUN git clone https://github.com/raspberrypi/noobs
#进入工作目录
WORKDIR /home/noobs
#切换到当前版本
RUN git checkout v2.8
#指定生成文件的挂载点
VOLUME ["/home/output"]
#映射编译命令
ENTRYPOINT ["/home/noobs/BUILDME.sh"]
