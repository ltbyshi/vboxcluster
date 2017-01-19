#! /bin/bash

OUTFILE="vms.txt"
printf '' > $OUTFILE
for i in $(seq 1 4);do
    printf "centos6-vm$i\tvm$i.centos6.vbox\t192.168.56.11$i\t255.255.255.0\n" >> $OUTFILE
done