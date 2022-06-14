#!/bin/bash
echo " ==== fix-ssh-multipass script depends on having multipass installed with NFS /home/ubuntu mounted ===="
multipass list
echo ""
echo "UBUNTU user folder must exist on /home/"
ls -la /home
echo ""
echo " => WILL add multipass credentials to ubuntu user folder"
ssh-keygen -y -f /var/snap/multipass/common/data/multipassd/ssh-keys/id_rsa >> id_rsa.pub
cat id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys 
echo "==== finished fix-ssh-multipass script ===="