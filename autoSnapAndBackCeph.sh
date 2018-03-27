#!/bin/bash
vms=`grep 'ceph:' /etc/pve/nodes/*/qemu-server/* | egrep -v 'backup=0|unused' | awk -F'/' '{print $7}' | sed 's/\..*//' | uniq`
for vm in $vms
do
 ./snapANDback.sh $vm
done


