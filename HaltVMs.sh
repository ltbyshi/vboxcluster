#! /bin/bash

for vm in $(awk '{print $2}' vms.txt);do
    ssh -o "StrictHostKeyChecking=no" -t "$vm" "sudo halt -p"
done