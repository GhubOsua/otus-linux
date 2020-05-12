#!/bin/bash
sudo yum -y update
sudo yum -y install mdadm
sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
sudo mdadm --create --verbose /dev/md0 -l 5 -n 5 /dev/sd{b,c,d,e,f}
cat /proc/mdstat
#sudo bash -c "echo "DEVICE partitions" > /etc/mdadm/mdadm.conf"
sudo bash -c 'echo "DEVICE partitions" > /etc/mdadm/mdadm.conf && mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf'