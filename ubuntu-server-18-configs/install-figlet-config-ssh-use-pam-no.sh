#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if [ "$(hostname)" == "sol.labic" ]; then
   echo "Jamais rode isso no SOL!" 1>&2
   exit 1
fi


figlet "LABIC   IC/UFF" > /etc/issue
echo "                    Universidade Federal Fluminense" >> /etc/issue
echo "                        Instituto de Computacao" >> /etc/issue
echo "                 Laboratorio de Inteligencia Computacional" >> /etc/issue
echo >> /etc/issue

sed -i 's/\\/\\\\/g' /etc/issue
echo -n > /etc/issue.net

echo "configuring ssh with banner and UsePAM=no, to be faster (DISABLED)"
#mv /etc/ssh/sshd_config /etc/ssh/sshd_config.bkp
#cp sshd_config.base /etc/ssh/sshd_config
echo "Please, manually add to /etc/ssh/sshd_config"
echo "#==========================================="
echo "PermitRootLogin yes"
echo "PubkeyAcceptedKeyTypes=+ssh-rsa"
echo "# no default banner path"
echo "#Banner none"
echo "Banner /etc/issue"
echo "#==========================================="


echo "restarting ssh server"
service ssh restart
