#! /bin/bash

exec 3> hosts
echo "# VBox cluster" >&3
while IFS=$'\t' read Name Host Addr Netmask;do
    echo -e "$Addr\t$Host" >&3
done < vms.txt
exec 3>&-