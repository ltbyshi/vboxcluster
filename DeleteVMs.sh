#! /bin/bash

for vm in $(awk '{print $1}' vms.txt);do
    VBoxManage unregistervm "$vm" --delete
done