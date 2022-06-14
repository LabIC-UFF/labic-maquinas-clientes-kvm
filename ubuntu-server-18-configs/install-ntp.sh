#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if [ "$(hostname)" == "sol.labic" ]; then
   echo "Jamais rode isso no SOL!" 1>&2
   exit 1
fi

apt-get -y install ntp
service ntp stop
echo "server 192.168.88.51" >> /etc/ntp.conf
update-rc.d ntp defaults
service ntp restart
# testar instalacao
ntpq -p

echo "configure timezone to Sao Paulo"
timedatectl set-timezone America/Sao_Paulo
timedatectl
