#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if [ "$(hostname)" == "sol.labic" ]; then
   echo "Jamais rode isso no SOL!" 1>&2
   exit 1
fi

apt -y install linux-headers-$(uname -r) apt-file vim rsync figlet build-essential htop hwloc acpid mpich mpich-doc bison flex git ethtool gnuplot tree python-minimal 
apt -y install freeglut3-dev libx11-dev libxmu-dev libxi-dev libglu1-mesa libglu1-mesa-dev openssl g++ default-jre resolvconf

snap install cmake --classic                           # latest cmake is needed by some applications
apt -y install libncurses5-dev libncursesw5-dev # good for	nvidia nvtop builds
apt -y install ssh
apt -y install xclip zip unzip
apt -y install sysstat # sar and sysstat
apt -y install subversion 
echo "must edit /etc/defaults/sysstat to set to true, after that: systemctl restart sysstat"
