FROM ubuntu:18.04

LABEL maintainer "talkxin <talkxin@gmail.com>"

RUN apt-get update && apt-get install -y \
	dirmngr \
	gnupg \
	ca-certificates \
	hicolor-icon-theme \
	libasound2 \
	libgl1-mesa-dri \
	libgl1-mesa-glx \
  firefox

#ENV LANG en-US

ENTRYPOINT [ "/usr/bin/firefox" ]

#for mac
#安装x11工具
#brew cask install xquartz
#安装Macport 用以支持x11服务器与客户端 https://www.macports.org/
#sudo port -v install xorg-server
#sudo port -v install xorg
#安装成功后检查系统是否支持xhost
#open -a XQuartz
#ip=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
#xhost + $ip
#docker run -d --name firefox -e DISPLAY=$ip:0 -v /tmp/.X11-unix:/tmp/.X11-unix {this images}
