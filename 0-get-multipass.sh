#!/bin/bash
echo " ==== This script will install multipass with libvirt ===="
sudo apt install libvirt-daemon-system
sudo snap install multipass
sudo snap connect multipass:libvirt
multipass list
multipass stop --all
sudo multipass set local.driver=libvirt
virsh list
echo " ==== finished script: multipass + libvirt ===="
