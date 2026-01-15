#!/bin/bash
THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export FS=$THISDIR/..

# Install language pack to fix locale warnings
dnf install -y glibc-langpack-en || true

locale -a
# update-locale LANG=$LANG || echo "problem setting locale"

dnf update -y || true

if [[ -f $FS/dnf-requirements.txt ]]; then
    echo "Installing requirements from $FS/dnf-requirements.txt"
    dnf install -y $(cat $FS/dnf-requirements.txt)
fi

# Ensure python points to python3
ln -sf /usr/bin/python3 /usr/bin/python

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
python --version || echo "python not present"

echo "gcc flags default detection"
gcc -Q --help=target || true
echo "gcc flags native detection"
gcc -Q --help=target -march=native || true
