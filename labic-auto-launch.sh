#!/bin/bash

echo "remember to first run: ./0-get-multipass.sh"
echo "remember to first run: ./0-fix-ssh-multipass.sh"

echo "PARAMS $# EXPECTS IMAGE NAME = $1"

if [[ -z $1 ]]; then
   echo "ERROR! MUST PASS IMAGE NAME"
   exit 1
fi

MNAME=$1
CPUS=16
MEM=15G
DISK=50G
DISTRO=focal
# SPECIFIC 'bionic' or 'focal'

echo "BUILDING $MNAME"

echo "multipass launch -n $MNAME -c $CPUS -m $MEM -d $DISK --cloud-init cloud-config-ldap.yaml $DISTRO"
multipass launch -n $MNAME -c $CPUS -m $MEM -d $DISK --cloud-init cloud-config-ldap.yaml $DISTRO

echo "WILL TEST /home AT $MNAME"
multipass exec $MNAME  -- ls /home

echo "WILL SETUP LDAP FOR $MNAME"
multipass transfer ubuntu-server-18-configs/*.base $MNAME:
multipass transfer ubuntu-server-18-configs/all_sudo.sh $MNAME:
multipass transfer ubuntu-server-18-configs/setup_docker.sh $MNAME:

multipass exec $MNAME -- ls -la

echo "1/3 WILL COPY ldap.conf"
multipass exec $MNAME -- sudo cp ldap.conf.base /etc/ldap.conf
multipass exec $MNAME -- echo "OK"
echo "2/3 WILL COPY nsswitch.conf"
multipass exec $MNAME -- sudo cp nsswitch.conf.base /etc/nsswitch.conf
multipass exec $MNAME -- echo "OK"
echo "3/3 WILL COPY common-password"
multipass exec $MNAME -- sudo cp pam-d-common-password.base /etc/pam.d/common-password
multipass exec $MNAME -- echo "OK"
#ldapsearch -H ldap://192.168.88.51 -b dc=LABIC -x | tail

echo "WILL TEST LDAP FOR $MNAME"
##multipass exec $MNAME -- ldapsearch -H ldap://192.168.88.51 -b dc=LABIC -x | tail
multipass exec $MNAME -- ldapsearch -H ldap://192.168.91.2 -b dc=LABIC -x | tail

#multipass exec testldap -- sudo apt -y install libnss-ldap libpam-ldap ldap-utils
#ds

echo "WILL GET IP FOR $MNAME"
multipass exec $MNAME  -- ip -br address show scope global

echo "CHANGING PASSWORD TO root AS root (DO MANUALLY)"
#multipass exec $MNAME  -- echo -e "root\nroot" | sudo passwd root


echo "DONE! TRY TO LOGIN DIRECTLY AT $MNAME"

echo "OR TO ENTER DIRECTLY: multipass shell $MNAME"

# sudo ssh -L 2222:localhost:22 -i /var/snap/multipass/common/data/multipassd/ssh-keys/id_rsa multipass@10.17.213.46

# ON REMOTE: autossh -f -M 0 -N root@192.168.91.152 -R 2222:localhost:22 -C


echo "Remember to set root password and to add everyone to admin group"
# for ID in $(getent passwd | grep /home | cut -d ':' -f1); do echo $ID; adduser $ID admin; done
multipass exec $MNAME  -- sudo sh ./all_sudo.sh
multipass exec $MNAME  -- sudo sh ./setup_docker.sh

echo "Also make /etc/sudoers passwordless: %admin ALL=(ALL) NOPASSWD:ALL"


# https://discourse.ubuntu.com/t/multipass-port-forwarding-with-iptables/18741

##IP=`multipass exec $MNAME  -- ip -br address show scope global | grep "172.16.122" | awk '{print $3}' | cut -d/ -f1`
IP=`virsh net-dhcp-leases default  | grep $MNAME | awk '{print $5}' | cut -d/ -f1`
#
echo "IP SHOULD BE $IP... TO ROUTE SSH, EXECUTE THESE:"
echo "sudo iptables -t nat -I PREROUTING 1 -i eno1 -p tcp --dport 2222 -j DNAT --to-destination $IP:22"
echo "sudo iptables -I FORWARD 1 -p tcp -d $IP --dport 22 -j ACCEPT"
echo "iptables-save > /etc/iptables/rules.v4"
echo ""
echo "-->TO DELETE FROM 'FORWARD':"
echo "iptables -L FORWARD --line-numbers (and look for 'tcp dpt:ssh')"
echo "iptabled -D FORWARD LINE_NUMBER"
echo "-->TO DELETE FROM 'nat':"
echo "sudo iptables -t nat --line-numbers -L"
echo "sudo iptables -t nat -D PREROUTING LINE_NUMBER"

# apt install iptables-persistent
# iptables-save > /etc/iptables/rules.v4

echo "to list qemu instances: ps -ef | grep qemu-system-x86_64"

echo "if using libvirt and ifconfig  is 192.168.122.1"
echo "virsh net-destroy default"
echo "virsh net-start default"
echo "virsh net-edit default"
echo "ADJUST NETWORK PATTERN and destroy/start again"
