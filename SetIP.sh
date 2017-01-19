#! /bin/bash

VBoxManage guestproperty set "CentOS-6.5" /Custom/IP 192.168.56.110
VBoxManage guestproperty set "CentOS-6.5" /Custom/Netmask 255.255.255.0
#for i in $(seq 1 3);do
#    VBoxManage guestproperty set "centos6-vm$i" /Custom/IP 192.168.56.11$i
#    VBoxManage guestproperty set "centos6-vm$i" /Custom/Netmask 255.255.255.0
#done

while IFS=$'\t' read Name Host Addr Netmask;do
    VBoxManage guestproperty set $Name /Custom/IP $Addr
    VBoxManage guestproperty set $Name /Custom/Netmask $Netmask
done < vms.txt