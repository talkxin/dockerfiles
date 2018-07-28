#! /bin/bash

QT_TOP_DIR="/opt/qt5/"
QT_ARMTOOLS="https://github.com/raspberrypi/tools.git"
QT_ARMTOOLS_DIR="linux-tools"
QT_TOOLSNAME="arm-linux-gnueabihf"
QT_VERSION=""
[[ -z ${QT_EVERYWHERE+x} ]] && QT_EVERYWHERE="https://download.qt.io/archive/qt/5.9/5.9.6/single/qt-everywhere-opensource-src-5.9.6.tar.xz"
QT_OUTPUT="/usr/local/qt_output/"
TSLIB_VERSION=""
[[ -z ${TSLIB_PATH+x} ]] && TSLIB_PATH="https://github.com/kergoth/tslib/releases/download/1.16-rc2/tslib-1.16-rc2.tar.bz2"
TSLIB_OUTPUT="/usr/local/tslib/"
QT_CONFIGURE_OPTS="-prefix $QT_OUTPUT -release -opensource -xplatform linux-arm-gnueabi-g++ -no-opengl -no-dbus -no-icu -no-eglfs -no-iconv -I$TSLIB_OUTPUT/include -L$TSLIB_OUTPUT/lib"

mkdir -p $QT_TOP_DIR && cd $QT_TOP_DIR
#克隆树莓派官方交叉编译工具
git clone $QT_ARMTOOLS $QT_ARMTOOLS_DIR
mv $QT_ARMTOOLS_DIR /usr/local/
#将交叉编译工具添加至配置文件，并使之生效
echo "export PATH=/usr/local/$QT_ARMTOOLS_DIR/arm-bcm2708/arm-linux-gnueabihf/bin/:$PATH" > ~/.profile && source ~/.profile

#下载并解压tslib库
wget -O tslib $TSLIB_PATH && tar xvf tslib && rm tslib
TSLIB_VERSION=`ls | grep tslib | awk 'NR==1{print $1}'`

#下载并解压QT
wget -O qt-everywhere $QT_EVERYWHERE && tar xvf qt-everywhere && rm qt-everywhere
QT_VERSION=`ls | grep qt-everywhere | awk 'NR==1{print $1}'`

#编译tslib
cd $QT_TOP_DIR/$TSLIB_VERSION
echo "ac_cv_func_malloc_0_nonnull=yes" >arm-linux.cache
CC=$QT_TOOLSNAME-gcc ./configure --host=arm-linux --prefix=$TSLIB_OUTPUT --cache-file=arm-linux.cache
make && make install

cd $QT_TOP_DIR/$QT_VERSION
#修改qt默认编译工具
sed -i 's/arm-linux-gnueabi/arm-linux-gnueabihf/' qtbase/mkspecs/linux-arm-gnueabi-g++/qmake.conf
mkdir qt-build
cd qt-build
../configure $QT_CONFIGURE_OPTS
make -j4 && make install
#将output加入配置文件
echo "export PATH=$QT_OUTPUT/bin/:$PATH" > ~/.profile && source ~/.profile
#清理安装包
rm -rf $QT_TOP_DIR
