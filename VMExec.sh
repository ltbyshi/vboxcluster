#! /bin/bash

if [ "$#" -lt 1 ];then
    echo "Usage: $0 command [command ...]"
    exit 1
fi

for vm in $(awk '{print $2}' vms.txt);do
    ssh -o "StrictHostKeyChecking=no" -t "$vm" "$@"
done