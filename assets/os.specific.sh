#!/bin/bash
THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export FS=$THISDIR/..

locale -a
update-locale LANG=$LANG || echo "problem setting locale"

apt-get -qq update || true

if [[ -f $FS/apt-requirements.txt ]]; then
    echo "apt-ing"
    apt-get -qq update
    echo "apt-ing $FS/apt-requirements.txt"
    xargs apt-get -q install -y < $FS/apt-requirements.txt
fi


# install specific git version 2.31 otherwise we will get the hell out of dubious permissions in github actions
if [[ -f $FS/git.tar.gz ]]; then
    apt-get install -y dh-autoreconf libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev
    pushd $FS
    tar -zxf ./git.tar.gz
    cd ./git-$GITVER
    make configure
    ./configure --prefix=/usr
    make install
    git –-version
    popd
fi

if [[ "x$GIT_CONFIGURE" == "xtrue" ]]; then
    echo "Updating git"
    git config --global user.name "ci@mazoea"
    git config --global user.email "ci@$BUILDER"
    git config --global core.filemode false
fi

echo "whoami `whoami`"
echo "pwd `pwd`"
echo "hostname `hostname`"
cat /proc/cpuinfo || echo "cpuinfo problem"
gcc --version || echo "gcc not present"
g++ --version || echo "g++ not present"
cmake --version || echo "cmake not present"


echo "installing cmake3"
# add-apt-repository ppa:george-edison55/cmake-3.x -y
# apt-get -qq update || true
# apt-get -q install -y cmake
# add-apt-repository --remove ppa:george-edison55/cmake-3.x -y
# cmake --version || echo "cmake not present"
# CMAKE
wget https://github.com/Kitware/CMake/releases/download/v3.18.2/cmake-3.18.2-Linux-x86_64.sh -q -O /tmp/cmake-install.sh && \
    chmod u+x /tmp/cmake-install.sh && \
    mkdir /usr/bin/cmake && \
    /tmp/cmake-install.sh --skip-license --exclude-subdir --prefix=/usr/local/ && \
    rm /tmp/cmake-install.sh

#GGMAJOR=`g++ -dumpversion | cut -f1 -d.`
if [[ "x$GCCVERSION" != "x" ]]; then
    VERSION=$GCCVERSION
else
    VERSION=4.8
fi
update-alternatives --remove-all gcc 
update-alternatives --remove-all g++

echo "installing g++$VERSION"
add-apt-repository ppa:ubuntu-toolchain-r/test -y
add-apt-repository ppa:git-core/ppa -y
apt-get -qq update || true
apt-get -q install -y gcc-$VERSION g++-$VERSION git
add-apt-repository --remove ppa:ubuntu-toolchain-r/test -y
add-apt-repository --remove ppa:git-core/ppa -y

update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-$VERSION 90 --slave /usr/bin/g++ g++ /usr/bin/g++-$VERSION
gcc --version || echo "gcc not present"
g++ --version || echo "g++ not present"
echo "gcc flags default detection"
gcc -Q --help=target
echo "gcc flags native detection"
gcc -Q --help=target -march=native 
