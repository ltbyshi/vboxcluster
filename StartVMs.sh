#! /bin/bash

for vm in $(awk '{print $1}' vms.txt);do
    VBoxManage startvm "$vm" --type headless
done