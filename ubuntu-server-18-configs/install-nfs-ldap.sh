#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if [ "$(hostname)" == "sol.labic" ]; then
   echo "Jamais rode isso no SOL!" 1>&2
   exit 1
fi


apt -y install nfs-common

echo "configuring /home mount via NFS (setup on /etc/fstab), do not repeat this command!"
cat fstab2 >> /etc/fstab
mount /home

# NEW
DEBIAN_FRONTEND=noninteractive apt-get -y install sudo nfs-common figlet libnss-ldap libpam-ldap ldap-utils python3-pip python3-virtualenv make locate
# OLD
DEBIAN_FRONTEND=noninteractive apt-get -y install libnss-ldap libpam-ldap ldap-utils #sudo-ldap

echo "configuring /etc/ldap.conf"
mv /etc/ldap.conf /etc/ldap.conf.bkp
cp ldap.conf.base /etc/ldap.conf

echo "configuring /etc/nsswitch.conf"
mv /etc/nsswitch.conf /etc/nsswitch.conf.bkp
cp nsswitch.conf.base /etc/nsswitch.conf

echo "configuring /etc/pam.d/common-password"
mv /etc/pam.d/common-password /etc/pam.d/common-password.bkp
cp pam-d-common-password.base /etc/pam.d/common-password

echo ""
echo "testing connection to LDAP server (should return few responses)"
ldapsearch -H ldap://192.168.91.2 -b dc=LABIC -x | tail

echo ""
echo "trying to authenticate remote user imcoelho (hope next line is not empty)"
getent passwd imcoelho

echo ""
echo "if you want to manually try remote login, just test: su - imcoelho"
echo "it should enter any desired user"
