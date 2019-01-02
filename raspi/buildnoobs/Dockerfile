#用于编译树莓派noobs
FROM ubuntu:18.04
#noobs必要关联软件
RUN apt-get update && apt-get install -y wget git zip make gcc g++ cpio python bc rsync qt4-linguist-tools texinfo libncurses5-dev
#清理镜像
RUN apt-get clean
#clone项目
WORKDIR /home/
RUN git clone https://github.com/talkxin/noobs.git
#进入工作目录
WORKDIR /home/noobs
#切换到当前版本
#RUN git checkout v2.8
#指定生成文件的挂载点
VOLUME ["/home/output"]
#映射编译命令
ENTRYPOINT ["/home/noobs/BUILDME.sh"]
