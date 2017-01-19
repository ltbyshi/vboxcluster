#! /bin/bash

for vm in $(awk '{print $1}' vms.txt);do
    VBoxManage clonevm "CentOS-6.5" --snapshot "Origin" --options link --name "$vm" --register
done

while IFS=$'\t' read Name Host Addr Netmask;do
    VBoxManage guestproperty set $Name /Custom/IP $Addr
    VBoxManage guestproperty set $Name /Custom/Netmask $Netmask
    VBoxManage guestproperty set $Name /Custom/HostName $Host
    VBoxManage modifyvm $Name --groups "/centos6"
done < vms.txt